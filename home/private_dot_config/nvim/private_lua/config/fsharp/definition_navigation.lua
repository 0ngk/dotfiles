local M = {}

local function normalize_location(location)
  if location and location.targetUri then
    return {
      uri = location.targetUri,
      range = location.targetSelectionRange or location.targetRange,
    }
  end
  return location
end

function M.jump_to_locations(locations, offset_encoding, title)
  if not locations or #locations == 0 then
    return false, "No locations returned from LSP."
  end

  local normalized = vim.tbl_map(normalize_location, locations)

  if #normalized == 1 then
    local opened = vim.lsp.util.show_document(normalized[1], offset_encoding or "utf-16", {
      reuse_win = true,
      focus = true,
    })
    if opened then
      return true, nil
    end
    local uri = normalized[1] and (normalized[1].uri or normalized[1].targetUri) or "<unknown>"
    return false, ("Failed to open LSP location: %s"):format(uri)
  end

  local items = vim.lsp.util.locations_to_items(normalized, offset_encoding or "utf-16")
  vim.fn.setqflist({}, " ", { title = title, items = items })
  vim.cmd("copen")
  return true, nil
end

return M
