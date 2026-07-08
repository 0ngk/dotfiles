local M = {}

local api = vim.api
local fn = vim.fn
local uv = vim.uv or vim.loop

local augroup = api.nvim_create_augroup("TabWorkspaces", { clear = true })
local sidecar_dir = fn.stdpath("data") .. "/tab-workspaces"

local state = {}
local refresh_debounce_ms = 120
local refresh_timer = nil
local refresh_timer_active = false
local refresh_pending = false
local ui_cache = {
  area_hits = 0,
  area_rebuilds = 0,
  area_version = -1,
  area_value = nil,
  dirty_count = 0,
  strip_columns = nil,
  strip_current = nil,
  strip_hits = 0,
  strip_rebuilds = 0,
  strip_value = "",
  strip_version = -1,
  summaries = {},
  summary_hits = 0,
  summary_rebuilds = 0,
  version = 0,
}

local perf_stats = {
  diagnostic_event_count = 0,
  refresh_coalesced = 0,
  refresh_flushed = 0,
  refresh_requested = 0,
  last_refresh_flushed_at = nil,
  last_refresh_reason = nil,
  last_refresh_requested_at = nil,
}

local function mark_ui_dirty()
  ui_cache.version = ui_cache.version + 1
  ui_cache.dirty_count = ui_cache.dirty_count + 1
  ui_cache.summaries = {}
end

local excluded_buftypes = {
  help = true,
  nofile = true,
  prompt = true,
  quickfix = true,
  terminal = true,
}

local excluded_filetypes = {
  [""] = false,
  Avante = true,
  codecompanion = true,
  fern = true,
  help = true,
  lazy = true,
  noice = true,
  notify = true,
  qf = true,
  snacks_dashboard = true,
  snacks_input = true,
  snacks_notif = true,
  snacks_picker_input = true,
  snacks_picker_list = true,
  snacks_picker_preview = true,
}

local function trim(value)
  return value and value:match("^%s*(.-)%s*$") or nil
end

local function now_iso8601()
  return os.date("%Y-%m-%d %H:%M:%S")
end

local function perf_snapshot()
  return {
    diagnostic_event_count = perf_stats.diagnostic_event_count,
    ui_area_hits = ui_cache.area_hits,
    ui_area_rebuilds = ui_cache.area_rebuilds,
    ui_dirty_count = ui_cache.dirty_count,
    ui_strip_hits = ui_cache.strip_hits,
    ui_strip_rebuilds = ui_cache.strip_rebuilds,
    ui_summary_hits = ui_cache.summary_hits,
    ui_summary_rebuilds = ui_cache.summary_rebuilds,
    ui_version = ui_cache.version,
    refresh_coalesced = perf_stats.refresh_coalesced,
    refresh_flushed = perf_stats.refresh_flushed,
    refresh_requested = perf_stats.refresh_requested,
    last_refresh_flushed_at = perf_stats.last_refresh_flushed_at or "never",
    last_refresh_reason = perf_stats.last_refresh_reason or "none",
    last_refresh_requested_at = perf_stats.last_refresh_requested_at or "never",
  }
end

local function refresh_ui(reason)
  mark_ui_dirty()
  perf_stats.refresh_requested = perf_stats.refresh_requested + 1
  perf_stats.last_refresh_reason = reason or "unspecified"
  perf_stats.last_refresh_requested_at = now_iso8601()
  refresh_pending = true

  if refresh_timer_active then
    perf_stats.refresh_coalesced = perf_stats.refresh_coalesced + 1
    return
  end

  if not refresh_timer then
    refresh_timer = uv.new_timer()
    if not refresh_timer then
      vim.schedule(function()
        pcall(vim.cmd, "redrawstatus")
        pcall(vim.cmd, "redrawtabline")
      end)
      return
    end
  end

  refresh_timer_active = true
  refresh_timer:start(refresh_debounce_ms, 0, function()
    refresh_timer_active = false
    if not refresh_pending then
      return
    end

    refresh_pending = false
    vim.schedule(function()
      pcall(vim.cmd, "redrawstatus")
      pcall(vim.cmd, "redrawtabline")
      perf_stats.refresh_flushed = perf_stats.refresh_flushed + 1
      perf_stats.last_refresh_flushed_at = now_iso8601()
    end)
  end)
end

local function sidecar_path(session_path)
  return string.format("%s/%s.json", sidecar_dir, fn.sha256(session_path))
end

local function tabpages()
  return api.nvim_list_tabpages()
end

local function current_tabpage()
  return api.nvim_get_current_tabpage()
end

local function current_window()
  return api.nvim_get_current_win()
end

local function normalize_tabpage(tabpage)
  if tabpage == nil or tabpage == 0 then
    return current_tabpage()
  end
  return tabpage
end

local function valid_tabpage(tabpage)
  return tabpage and api.nvim_tabpage_is_valid(tabpage)
end

local function prune_invalid_tabpages()
  for tabpage in pairs(state) do
    if not valid_tabpage(tabpage) then
      state[tabpage] = nil
    end
  end
end

local function get_tab_state(tabpage, create)
  tabpage = normalize_tabpage(tabpage)
  prune_invalid_tabpages()
  if not valid_tabpage(tabpage) then
    return nil
  end

  local tab_state = state[tabpage]
  if not tab_state and create then
    tab_state = {
      buffers = {},
      windows = {},
      manual_name = nil,
    }
    state[tabpage] = tab_state
  end
  if tab_state then
    tab_state.buffers = tab_state.buffers or {}
    tab_state.windows = tab_state.windows or {}
  end
  return tab_state
end

local function tab_windows(tabpage)
  if not valid_tabpage(tabpage) then
    return {}
  end
  return api.nvim_tabpage_list_wins(tabpage)
end

local function normalize_window(winid, tabpage)
  if winid and winid ~= 0 then
    return winid
  end

  local current = current_window()
  if current and api.nvim_win_is_valid(current) then
    if not tabpage or not valid_tabpage(tabpage) or api.nvim_win_get_tabpage(current) == tabpage then
      return current
    end
  end

  local wins = tab_windows(tabpage)
  return wins[1]
end

local function valid_window(winid, tabpage)
  if not winid or not api.nvim_win_is_valid(winid) then
    return false
  end
  if tabpage and valid_tabpage(tabpage) and api.nvim_win_get_tabpage(winid) ~= tabpage then
    return false
  end
  return true
end

local function is_normal_window(win)
  if not api.nvim_win_is_valid(win) then
    return false
  end
  local config = api.nvim_win_get_config(win)
  return config.relative == ""
end

local function prune_invalid_window_states(tabpage)
  local tab_state = get_tab_state(tabpage, false)
  if not tab_state then
    return
  end

  local active_windows = {}
  for _, winid in ipairs(tab_windows(tabpage)) do
    active_windows[winid] = true
  end

  for winid in pairs(tab_state.windows) do
    if not active_windows[winid] or not valid_window(winid, tabpage) then
      tab_state.windows[winid] = nil
    end
  end
end

local function get_window_state(tabpage, winid, create)
  tabpage = normalize_tabpage(tabpage)
  local tab_state = get_tab_state(tabpage, create)
  if not tab_state then
    return nil
  end

  prune_invalid_window_states(tabpage)
  winid = normalize_window(winid, tabpage)
  if not valid_window(winid, tabpage) or not is_normal_window(winid) then
    return nil
  end

  local win_state = tab_state.windows[winid]
  if not win_state and create then
    win_state = { buffers = {} }
    tab_state.windows[winid] = win_state
  end

  if win_state then
    win_state.buffers = win_state.buffers or {}
  end

  return win_state, winid, tab_state
end

function M.is_normal_buffer(bufnr)
  if not bufnr or bufnr <= 0 or not api.nvim_buf_is_valid(bufnr) then
    return false
  end
  if not vim.bo[bufnr].buflisted then
    return false
  end

  local buftype = vim.bo[bufnr].buftype
  if buftype ~= "" and excluded_buftypes[buftype] then
    return false
  end
  if buftype ~= "" then
    return false
  end

  local filetype = vim.bo[bufnr].filetype
  if excluded_filetypes[filetype] then
    return false
  end

  return true
end

local function prune_invalid_buffers(buffer_set)
  for bufnr in pairs(buffer_set) do
    if not M.is_normal_buffer(bufnr) then
      buffer_set[bufnr] = nil
    end
  end
end

local function visible_normal_buffer(winid)
  if not valid_window(winid) or not is_normal_window(winid) then
    return nil
  end
  local bufnr = api.nvim_win_get_buf(winid)
  if not M.is_normal_buffer(bufnr) then
    return nil
  end
  return bufnr
end

local function buffer_list_order()
  local order = {}
  for _, info in ipairs(fn.getbufinfo({ buflisted = 1 })) do
    order[#order + 1] = info.bufnr
  end
  return order
end

local function remove_buffer_from_tab_state(tab_state, bufnr)
  tab_state.buffers[bufnr] = nil
  for _, win_state in pairs(tab_state.windows) do
    win_state.buffers[bufnr] = nil
  end
end

local function tab_contains_buffer_in_windows(tab_state, bufnr)
  for _, win_state in pairs(tab_state.windows) do
    if win_state.buffers[bufnr] then
      return true
    end
  end
  return false
end

local function track_buffer_in_window(bufnr, tabpage, winid)
  if not M.is_normal_buffer(bufnr) then
    return false
  end

  local win_state, _, tab_state = get_window_state(tabpage, winid, true)
  if not win_state then
    return false
  end

  local changed = false
  if not win_state.buffers[bufnr] then
    win_state.buffers[bufnr] = true
    changed = true
  end
  if not tab_state.buffers[bufnr] then
    tab_state.buffers[bufnr] = true
    changed = true
  end

  return changed
end

local function window_members(tabpage, winid, excluded_bufnr)
  tabpage = normalize_tabpage(tabpage)
  local win_state, normalized_winid, tab_state = get_window_state(tabpage, winid, true)
  if not win_state then
    return {}
  end

  prune_invalid_buffers(win_state.buffers)

  local visible_bufnr = visible_normal_buffer(normalized_winid)
  if visible_bufnr then
    win_state.buffers[visible_bufnr] = true
    tab_state.buffers[visible_bufnr] = true
  end

  local buffers = {}
  for _, bufnr in ipairs(buffer_list_order()) do
    if win_state.buffers[bufnr] and bufnr ~= excluded_bufnr and M.is_normal_buffer(bufnr) then
      buffers[#buffers + 1] = bufnr
    end
  end
  return buffers
end

local function workspace_members(tabpage, excluded_bufnr)
  tabpage = normalize_tabpage(tabpage)
  local tab_state = get_tab_state(tabpage, true)
  if not tab_state then
    return {}
  end

  prune_invalid_window_states(tabpage)
  prune_invalid_buffers(tab_state.buffers)

  local members = {}
  for bufnr in pairs(tab_state.buffers) do
    members[bufnr] = true
  end

  for _, winid in ipairs(tab_windows(tabpage)) do
    local win_state = get_window_state(tabpage, winid, true)
    if win_state then
      prune_invalid_buffers(win_state.buffers)
      local visible_bufnr = visible_normal_buffer(winid)
      if visible_bufnr then
        win_state.buffers[visible_bufnr] = true
        tab_state.buffers[visible_bufnr] = true
        members[visible_bufnr] = true
      end
      for bufnr in pairs(win_state.buffers) do
        members[bufnr] = true
      end
    end
  end

  local buffers = {}
  for _, bufnr in ipairs(buffer_list_order()) do
    if members[bufnr] and bufnr ~= excluded_bufnr and M.is_normal_buffer(bufnr) then
      buffers[#buffers + 1] = bufnr
    end
  end

  return buffers
end

function M.workspace_buffers(tabpage)
  return workspace_members(normalize_tabpage(tabpage))
end

function M.workspace_buffer_count(tabpage)
  return #M.workspace_buffers(tabpage)
end

local function tab_includes_buffer(tabpage, bufnr)
  for _, member in ipairs(workspace_members(tabpage)) do
    if member == bufnr then
      return true
    end
  end
  return false
end

local function count_buffer_memberships(bufnr)
  local count = 0
  for _, tabpage in ipairs(tabpages()) do
    if tab_includes_buffer(tabpage, bufnr) then
      count = count + 1
    end
  end
  return count
end

local function create_placeholder_buffer(tabpage, winid)
  local bufnr = api.nvim_create_buf(true, false)
  local tab_state = get_tab_state(tabpage, true)
  tab_state.buffers[bufnr] = true
  if winid and valid_window(winid, tabpage) then
    track_buffer_in_window(bufnr, tabpage, winid)
  end
  return bufnr
end

local function tab_displays_buffer(tabpage, bufnr)
  for _, winid in ipairs(tab_windows(tabpage)) do
    if is_normal_window(winid) and api.nvim_win_get_buf(winid) == bufnr then
      return true
    end
  end
  return false
end

local function window_displays_buffer(winid, bufnr)
  return valid_window(winid) and is_normal_window(winid) and api.nvim_win_get_buf(winid) == bufnr
end

local function replace_buffer_in_window(tabpage, winid, source_bufnr, replacement_bufnr)
  if not valid_window(winid, tabpage) or not is_normal_window(winid) then
    return
  end
  if not window_displays_buffer(winid, source_bufnr) then
    return
  end

  local ok = pcall(api.nvim_win_set_buf, winid, replacement_bufnr)
  if ok then
    track_buffer_in_window(replacement_bufnr, tabpage, winid)
  end
end

local function replace_buffer_in_tab(tabpage, source_bufnr, replacement_bufnr)
  for _, winid in ipairs(tab_windows(tabpage)) do
    replace_buffer_in_window(tabpage, winid, source_bufnr, replacement_bufnr)
  end
end

local function ensure_replacement_buffer(tabpage, source_bufnr)
  local fallback = workspace_members(tabpage, source_bufnr)[1]
  if fallback then
    return fallback
  end
  return create_placeholder_buffer(tabpage)
end

local function ensure_window_replacement_buffer(tabpage, winid, source_bufnr)
  local fallback = window_members(tabpage, winid, source_bufnr)[1]
  if fallback then
    return fallback
  end

  fallback = workspace_members(tabpage, source_bufnr)[1]
  if fallback then
    return fallback
  end

  return create_placeholder_buffer(tabpage, winid)
end

local function unregister_buffer(bufnr)
  for _, tabpage in ipairs(tabpages()) do
    local tab_state = get_tab_state(tabpage, false)
    if tab_state then
      remove_buffer_from_tab_state(tab_state, bufnr)
    end
  end
end

local function global_delete_buffer(bufnr)
  if not M.is_normal_buffer(bufnr) then
    return false
  end
  if vim.bo[bufnr].modified then
    vim.notify("Buffer has unsaved changes", vim.log.levels.WARN)
    return false
  end

  local ok, err = pcall(vim.cmd, ("bdelete %d"):format(bufnr))
  if not ok then
    vim.notify(err, vim.log.levels.ERROR)
    return false
  end

  refresh_ui()
  return true
end

function M.global_delete_buffer(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  return global_delete_buffer(bufnr)
end

function M.add_buffer_to_workspace(bufnr, tabpage, winid)
  tabpage = normalize_tabpage(tabpage)
  if not valid_tabpage(tabpage) then
    return false
  end

  local changed = track_buffer_in_window(bufnr, tabpage, winid)
  if changed then
    refresh_ui()
  end
  return changed
end

function M.remove_buffer_from_workspace(bufnr, tabpage)
  tabpage = normalize_tabpage(tabpage)
  local tab_state = get_tab_state(tabpage, false)
  if not tab_state or not M.is_normal_buffer(bufnr) then
    return false
  end
  if not tab_state.buffers[bufnr] and not tab_contains_buffer_in_windows(tab_state, bufnr) then
    return false
  end

  if tab_displays_buffer(tabpage, bufnr) then
    local replacement = ensure_replacement_buffer(tabpage, bufnr)
    replace_buffer_in_tab(tabpage, bufnr, replacement)
  end

  remove_buffer_from_tab_state(tab_state, bufnr)
  refresh_ui()
  return true
end

function M.remove_buffer_from_window(bufnr, winid, tabpage)
  tabpage = normalize_tabpage(tabpage)
  local win_state, normalized_winid, tab_state = get_window_state(tabpage, winid, true)
  if not win_state or not M.is_normal_buffer(bufnr) then
    return false
  end

  if not win_state.buffers[bufnr] then
    local visible_bufnr = visible_normal_buffer(normalized_winid)
    if visible_bufnr ~= bufnr then
      return false
    end
    win_state.buffers[bufnr] = true
    tab_state.buffers[bufnr] = true
  end

  if window_displays_buffer(normalized_winid, bufnr) then
    local replacement = ensure_window_replacement_buffer(tabpage, normalized_winid, bufnr)
    replace_buffer_in_window(tabpage, normalized_winid, bufnr, replacement)
  end

  win_state.buffers[bufnr] = nil
  if not tab_contains_buffer_in_windows(tab_state, bufnr) then
    tab_state.buffers[bufnr] = nil
  end

  refresh_ui()
  return true
end

function M.close_workspace_buffer(bufnr, tabpage, winid)
  tabpage = normalize_tabpage(tabpage)
  bufnr = bufnr or api.nvim_get_current_buf()
  winid = normalize_window(winid, tabpage)

  if not M.is_normal_buffer(bufnr) then
    vim.cmd("q")
    return false
  end

  if vim.bo[bufnr].modified then
    vim.notify("Buffer has unsaved changes", vim.log.levels.WARN)
    return false
  end

  return M.remove_buffer_from_window(bufnr, winid, tabpage)
end

local function reset_tab_state(tabpage)
  tabpage = normalize_tabpage(tabpage)
  local tab_state = get_tab_state(tabpage, true)
  tab_state.buffers = {}
  tab_state.windows = {}
  tab_state.manual_name = nil

  for _, winid in ipairs(tab_windows(tabpage)) do
    if is_normal_window(winid) then
      tab_state.windows[winid] = { buffers = {} }
      local bufnr = visible_normal_buffer(winid)
      if bufnr then
        tab_state.windows[winid].buffers[bufnr] = true
        tab_state.buffers[bufnr] = true
      end
    end
  end
end

local function seed_tab_state(tabpage)
  tabpage = normalize_tabpage(tabpage)
  local tab_state = get_tab_state(tabpage, true)
  prune_invalid_window_states(tabpage)
  prune_invalid_buffers(tab_state.buffers)

  for _, winid in ipairs(tab_windows(tabpage)) do
    if is_normal_window(winid) then
      local win_state = tab_state.windows[winid]
      if not win_state then
        win_state = { buffers = {} }
        tab_state.windows[winid] = win_state
      end

      prune_invalid_buffers(win_state.buffers)
      local bufnr = visible_normal_buffer(winid)
      if bufnr then
        win_state.buffers[bufnr] = true
        tab_state.buffers[bufnr] = true
      end
    end
  end
end

function M.reset_workspace(tabpage)
  reset_tab_state(tabpage)
  refresh_ui()
end

local function tab_cwd(tabpage)
  local ok, cwd = pcall(api.nvim_tabpage_call, tabpage, function()
    return fn.getcwd()
  end)
  return ok and cwd or nil
end

local function workspace_default_name(tabpage, buffers)
  local cwd = tab_cwd(tabpage)
  if cwd and cwd ~= "" then
    local basename = fn.fnamemodify(cwd, ":t")
    if basename ~= "" then
      return basename
    end
  end

  buffers = buffers or M.workspace_buffers(tabpage)
  if #buffers > 0 then
    local filename = fn.fnamemodify(api.nvim_buf_get_name(buffers[1]), ":t")
    if filename ~= "" then
      return filename
    end
  end

  return ("Workspace %d"):format(api.nvim_tabpage_get_number(tabpage))
end

function M.workspace_label(tabpage, buffers)
  tabpage = normalize_tabpage(tabpage)
  local tab_state = get_tab_state(tabpage, true)
  local manual_name = trim(tab_state.manual_name)
  if manual_name and manual_name ~= "" then
    return manual_name
  end
  return workspace_default_name(tabpage, buffers)
end

function M.rename_workspace(name, tabpage)
  tabpage = normalize_tabpage(tabpage)
  local tab_state = get_tab_state(tabpage, true)
  local normalized = trim(name)
  tab_state.manual_name = normalized ~= "" and normalized or nil
  refresh_ui()
end

local function sorted_tabs()
  local result = {}
  for index, tabpage in ipairs(tabpages()) do
    result[#result + 1] = { index = index, tabpage = tabpage }
  end
  return result
end

local function escape_statusline(text)
  return text:gsub("%%", "%%%%")
end

local function shorten(text, max_width)
  if #text <= max_width then
    return text
  end
  return text:sub(1, max_width - 3) .. "..."
end

local function diagnostics_for_buffers(buffers)
  local counts = {
    error = 0,
    hint = 0,
    info = 0,
    warn = 0,
  }

  for _, bufnr in ipairs(buffers) do
    for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
      local severity = diagnostic.severity
      if severity == vim.diagnostic.severity.ERROR then
        counts.error = counts.error + 1
      elseif severity == vim.diagnostic.severity.WARN then
        counts.warn = counts.warn + 1
      elseif severity == vim.diagnostic.severity.INFO then
        counts.info = counts.info + 1
      elseif severity == vim.diagnostic.severity.HINT then
        counts.hint = counts.hint + 1
      end
    end
  end

  return counts
end

local function workspace_summary(tabpage)
  tabpage = normalize_tabpage(tabpage)
  local cached = ui_cache.summaries[tabpage]
  if cached and cached.version == ui_cache.version then
    ui_cache.summary_hits = ui_cache.summary_hits + 1
    return cached.value
  end

  local buffers = M.workspace_buffers(tabpage)
  local modified = false
  for _, bufnr in ipairs(buffers) do
    if vim.bo[bufnr].modified then
      modified = true
      break
    end
  end

  local value = {
    buffers = buffers,
    count = #buffers,
    diagnostics = diagnostics_for_buffers(buffers),
    label = M.workspace_label(tabpage, buffers),
    modified = modified,
  }

  ui_cache.summary_rebuilds = ui_cache.summary_rebuilds + 1
  ui_cache.summaries[tabpage] = {
    value = value,
    version = ui_cache.version,
  }
  return value
end

function M.workspace_strip()
  local columns = vim.o.columns
  local current = current_tabpage()
  if
    ui_cache.strip_version == ui_cache.version
    and ui_cache.strip_columns == columns
    and ui_cache.strip_current == current
  then
    ui_cache.strip_hits = ui_cache.strip_hits + 1
    return ui_cache.strip_value
  end

  local tabs = sorted_tabs()
  if #tabs == 0 then
    ui_cache.strip_value = ""
    ui_cache.strip_version = ui_cache.version
    ui_cache.strip_columns = columns
    ui_cache.strip_current = current
    return ""
  end

  local narrow = columns < 120
  local segments = {}

  for _, item in ipairs(tabs) do
    if not narrow or item.tabpage == current then
      local summary = workspace_summary(item.tabpage)
      local label = shorten(summary.label, narrow and 18 or 24)
      local modified = summary.modified and " ●" or ""
      local hl = item.tabpage == current and "WorkspaceStatuslineCurrent" or "WorkspaceStatuslineInactive"
      local text = string.format(" %d:%s(%d)%s ", item.index, escape_statusline(label), summary.count, modified)
      segments[#segments + 1] = string.format("%%#%s#%s", hl, text)
    end
  end

  ui_cache.strip_value = table.concat(segments, "%#StatusLine# ")
  ui_cache.strip_version = ui_cache.version
  ui_cache.strip_columns = columns
  ui_cache.strip_current = current
  ui_cache.strip_rebuilds = ui_cache.strip_rebuilds + 1
  return ui_cache.strip_value
end

function M.workspace_diagnostics(tabpage)
  return workspace_summary(tabpage).diagnostics
end

function M.workspace_perf_stats()
  return perf_snapshot()
end

function M.bufferline_custom_area()
  if ui_cache.area_version == ui_cache.version and ui_cache.area_value then
    ui_cache.area_hits = ui_cache.area_hits + 1
    return ui_cache.area_value
  end

  local summary = workspace_summary()
  local counts = summary.diagnostics
  local result = {}

  if counts.error > 0 then
    result[#result + 1] = { text = "  " .. counts.error, link = "DiagnosticError" }
  end
  if counts.warn > 0 then
    result[#result + 1] = { text = "  " .. counts.warn, link = "DiagnosticWarn" }
  end
  if counts.info > 0 then
    result[#result + 1] = { text = "  " .. counts.info, link = "DiagnosticInfo" }
  end
  if counts.hint > 0 then
    result[#result + 1] = { text = "  " .. counts.hint, link = "DiagnosticHint" }
  end

  result[#result + 1] = {
    text = " 󰈔 " .. summary.count,
    link = "Comment",
  }

  ui_cache.area_rebuilds = ui_cache.area_rebuilds + 1
  ui_cache.area_value = result
  ui_cache.area_version = ui_cache.version
  return result
end

function M.is_buffer_in_workspace(bufnr, tabpage)
  tabpage = normalize_tabpage(tabpage)
  if not M.is_normal_buffer(bufnr) then
    return false
  end

  local tab_state = get_tab_state(tabpage, true)
  if not tab_state then
    return false
  end

  if tab_state.buffers[bufnr] then
    return true
  end

  for _, member in ipairs(workspace_members(tabpage)) do
    if member == bufnr then
      return true
    end
  end

  return false
end

function M.is_buffer_in_window(bufnr, winid, tabpage)
  tabpage = normalize_tabpage(tabpage)
  if not M.is_normal_buffer(bufnr) then
    return false
  end

  local win_state, normalized_winid, tab_state = get_window_state(tabpage, winid, true)
  if not win_state then
    return false
  end

  prune_invalid_buffers(win_state.buffers)
  local visible_bufnr = visible_normal_buffer(normalized_winid)
  if visible_bufnr then
    win_state.buffers[visible_bufnr] = true
    tab_state.buffers[visible_bufnr] = true
  end

  return win_state.buffers[bufnr] or false
end

function M.close_workspace(tabpage)
  tabpage = normalize_tabpage(tabpage)
  if not valid_tabpage(tabpage) then
    return false
  end

  local buffers = M.workspace_buffers(tabpage)
  for _, bufnr in ipairs(buffers) do
    if count_buffer_memberships(bufnr) == 1 and vim.bo[bufnr].modified then
      vim.notify("Workspace has unsaved buffers", vim.log.levels.WARN)
      return false
    end
  end

  if #tabpages() == 1 then
    for _, bufnr in ipairs(buffers) do
      if count_buffer_memberships(bufnr) == 1 then
        global_delete_buffer(bufnr)
      else
        local tab_state = get_tab_state(tabpage, false)
        if tab_state then
          remove_buffer_from_tab_state(tab_state, bufnr)
        end
      end
    end

    pcall(vim.cmd, "only")
    reset_tab_state(tabpage)
    local replacement = M.workspace_buffers(tabpage)[1] or create_placeholder_buffer(tabpage)
    pcall(api.nvim_set_current_buf, replacement)
    refresh_ui()
    return true
  end

  for _, bufnr in ipairs(buffers) do
    if count_buffer_memberships(bufnr) == 1 then
      global_delete_buffer(bufnr)
    else
      local tab_state = get_tab_state(tabpage, false)
      if tab_state then
        remove_buffer_from_tab_state(tab_state, bufnr)
      end
    end
  end

  state[tabpage] = nil
  local tabnr = api.nvim_tabpage_get_number(tabpage)
  local ok, err = pcall(vim.cmd, ("tabclose %d"):format(tabnr))
  if not ok then
    vim.notify(err, vim.log.levels.ERROR)
    return false
  end

  refresh_ui()
  return true
end

local function current_session_path()
  local ok, persisted = pcall(require, "persisted")
  if not ok then
    return nil
  end
  if vim.g.persisting_session and vim.g.persisting_session ~= "" then
    return vim.g.persisting_session
  end
  if vim.g.persisted_loaded_session and vim.g.persisted_loaded_session ~= "" then
    return vim.g.persisted_loaded_session
  end
  if type(persisted.current) == "function" then
    local current_ok, session_path = pcall(persisted.current)
    if current_ok and session_path and session_path ~= "" then
      return session_path
    end
  end
  return nil
end

local function save_sidecar(session_path)
  if not session_path or session_path == "" then
    return
  end

  local ok_mkdir = pcall(fn.mkdir, sidecar_dir, "p")
  if not ok_mkdir then
    return
  end

  local payload = {
    tabs = {},
    version = 1,
  }

  for index, tabpage in ipairs(tabpages()) do
    local tab_state = get_tab_state(tabpage, true)
    local buffers = {}
    local seen = {}

    for _, bufnr in ipairs(M.workspace_buffers(tabpage)) do
      local path = fn.fnamemodify(api.nvim_buf_get_name(bufnr), ":p")
      if path ~= "" and not seen[path] then
        seen[path] = true
        buffers[#buffers + 1] = path
      end
    end

    payload.tabs[#payload.tabs + 1] = {
      buffers = buffers,
      index = index,
      name = tab_state.manual_name,
    }
  end

  local encoded = vim.json.encode(payload)
  pcall(fn.writefile, { encoded }, sidecar_path(session_path))
end

local function restore_sidecar(session_path)
  if not session_path or session_path == "" then
    return
  end

  local path = sidecar_path(session_path)
  if fn.filereadable(path) == 0 then
    for _, tabpage in ipairs(tabpages()) do
      reset_tab_state(tabpage)
    end
    refresh_ui()
    return
  end

  local ok_read, lines = pcall(fn.readfile, path)
  if not ok_read then
    return
  end
  if #lines == 0 then
    return
  end

  local ok, payload = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok or type(payload) ~= "table" then
    return
  end

  for tabpage in pairs(state) do
    state[tabpage] = nil
  end

  local payload_tabs = type(payload.tabs) == "table" and payload.tabs or {}
  local tabs = tabpages()
  for index, entry in ipairs(payload_tabs) do
    local tabpage = tabs[index]
    if tabpage and valid_tabpage(tabpage) and type(entry) == "table" then
      local tab_state = get_tab_state(tabpage, true)
      tab_state.buffers = {}
      tab_state.windows = {}
      tab_state.manual_name = entry.name

      for _, path_value in ipairs(entry.buffers or {}) do
        local absolute_path = fn.fnamemodify(path_value, ":p")
        if absolute_path ~= "" then
          local bufnr = fn.bufnr(absolute_path)
          if bufnr < 0 then
            pcall(vim.cmd, "silent! badd " .. fn.fnameescape(absolute_path))
            bufnr = fn.bufnr(absolute_path)
          end
          if bufnr > 0 and M.is_normal_buffer(bufnr) then
            tab_state.buffers[bufnr] = true
          end
        end
      end

      for _, winid in ipairs(tab_windows(tabpage)) do
        if is_normal_window(winid) then
          tab_state.windows[winid] = { buffers = {} }
          local bufnr = visible_normal_buffer(winid)
          if bufnr then
            tab_state.windows[winid].buffers[bufnr] = true
            tab_state.buffers[bufnr] = true
          end
        end
      end
    end
  end

  for index = #payload_tabs + 1, #tabs do
    reset_tab_state(tabs[index])
  end

  refresh_ui()
end

local function setup_commands()
  api.nvim_create_user_command("WorkspaceRename", function(opts)
    local rename = function(value)
      M.rename_workspace(value)
    end

    if opts.args ~= "" then
      rename(opts.args)
      return
    end

    vim.ui.input({
      default = M.workspace_label(),
      prompt = "Workspace name: ",
    }, function(input)
      if input ~= nil then
        rename(input)
      end
    end)
  end, {
    nargs = "?",
    desc = "Rename current workspace",
  })

  api.nvim_create_user_command("WorkspaceRemoveBuffer", function()
    M.remove_buffer_from_workspace(api.nvim_get_current_buf())
  end, {
    desc = "Remove current buffer from workspace",
  })

  api.nvim_create_user_command("WorkspaceReset", function()
    M.reset_workspace()
  end, {
    desc = "Reset current workspace membership and name",
  })

  api.nvim_create_user_command("WorkspaceClose", function()
    M.close_workspace()
  end, {
    desc = "Close current workspace safely",
  })

  api.nvim_create_user_command("WorkspacePerfStats", function()
    local stats = M.workspace_perf_stats()
    local lines = {
      ("diagnostic_event_count: %d"):format(stats.diagnostic_event_count),
      ("refresh_requested: %d"):format(stats.refresh_requested),
      ("refresh_flushed: %d"):format(stats.refresh_flushed),
      ("refresh_coalesced: %d"):format(stats.refresh_coalesced),
      ("ui_version: %d"):format(stats.ui_version),
      ("ui_dirty_count: %d"):format(stats.ui_dirty_count),
      ("ui_summary_rebuilds: %d"):format(stats.ui_summary_rebuilds),
      ("ui_summary_hits: %d"):format(stats.ui_summary_hits),
      ("ui_strip_rebuilds: %d"):format(stats.ui_strip_rebuilds),
      ("ui_strip_hits: %d"):format(stats.ui_strip_hits),
      ("ui_area_rebuilds: %d"):format(stats.ui_area_rebuilds),
      ("ui_area_hits: %d"):format(stats.ui_area_hits),
      ("last_refresh_reason: %s"):format(stats.last_refresh_reason),
      ("last_refresh_requested_at: %s"):format(stats.last_refresh_requested_at),
      ("last_refresh_flushed_at: %s"):format(stats.last_refresh_flushed_at),
    }

    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Workspace Perf" })
  end, {
    desc = "Show workspace UI refresh performance stats",
  })
end

function M.setup()
  if M._did_setup then
    return
  end
  M._did_setup = true

  setup_commands()
  reset_tab_state(current_tabpage())

  api.nvim_create_autocmd("BufWinEnter", {
    group = augroup,
    callback = function(event)
      M.add_buffer_to_workspace(event.buf, current_tabpage(), current_window())
    end,
  })

  api.nvim_create_autocmd({ "TabEnter", "TabNewEntered" }, {
    group = augroup,
    callback = function()
      seed_tab_state(current_tabpage())
      refresh_ui()
    end,
  })

  api.nvim_create_autocmd("WinEnter", {
    group = augroup,
    callback = function()
      local winid = current_window()
      local bufnr = api.nvim_win_get_buf(winid)
      M.add_buffer_to_workspace(bufnr, current_tabpage(), winid)
    end,
  })

  api.nvim_create_autocmd("WinNew", {
    group = augroup,
    callback = function()
      local tabpage = current_tabpage()
      local winid = current_window()
      local tab_state = get_tab_state(tabpage, true)
      if tab_state and is_normal_window(winid) and not tab_state.windows[winid] then
        tab_state.windows[winid] = { buffers = {} }
      end
      refresh_ui()
    end,
  })

  api.nvim_create_autocmd("WinClosed", {
    group = augroup,
    callback = function(event)
      local winid = tonumber(event.match)
      if not winid then
        return
      end
      for _, tab_state in pairs(state) do
        tab_state.windows[winid] = nil
      end
      refresh_ui()
    end,
  })

  api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = augroup,
    callback = function(event)
      unregister_buffer(event.buf)
      refresh_ui()
    end,
  })

  api.nvim_create_autocmd("DiagnosticChanged", {
    group = augroup,
    callback = function()
      perf_stats.diagnostic_event_count = perf_stats.diagnostic_event_count + 1
      mark_ui_dirty()
    end,
  })

  api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = "PersistedSavePre",
    callback = function()
      save_sidecar(current_session_path())
    end,
  })

  api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = "PersistedLoadPost",
    callback = function()
      vim.schedule(function()
        restore_sidecar(vim.g.persisted_loaded_session)
      end)
    end,
  })
end

return M
