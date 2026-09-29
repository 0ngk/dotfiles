local M = {}

local DECOMPILE_ERROR_MARKER = "Error while decompiling symbol"
local LOADED_PROJECTS_ERROR_MARKER = "in LoadedProjects"
local REQUEST_TIMEOUT_MS = 7000
local REQUEST_RETRY_DELAY_MS = 300
local MAX_DEFINITION_ATTEMPTS = 4

local function extract_locations(responses)
  if type(responses) ~= "table" then
    return nil, nil
  end

  for client_id, response in pairs(responses) do
    local result = response and response.result
    if result then
      local locations = vim.islist(result) and result or { result }
      if #locations > 0 then
        local client = vim.lsp.get_client_by_id(tonumber(client_id))
        local offset_encoding = client and client.offset_encoding or "utf-16"
        return locations, offset_encoding
      end
    end
  end

  return nil, nil
end

local function extract_error_message(responses)
  if type(responses) ~= "table" then
    return nil
  end

  local best_error
  local best_score = -1

  for _, response in pairs(responses) do
    local err = response and (response.err or response.error)
    if err and err.message then
      local message = err.message
      local score = 0

      if message:find(LOADED_PROJECTS_ERROR_MARKER, 1, true) then
        score = score + 4
      end
      if message:find(DECOMPILE_ERROR_MARKER, 1, true) then
        score = score + 3
      end
      if message:find("not found", 1, true) then
        score = score + 2
      end

      if score > best_score then
        best_error = message
        best_score = score
      end
    end
  end

  return best_error
end

local function make_position_params(bufnr, winid, method)
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "fsautocomplete" })[1]
    or vim.lsp.get_clients({ bufnr = bufnr })[1]
  local encoding = client and client.offset_encoding or "utf-16"
  local params = vim.lsp.util.make_position_params(winid, encoding)

  if method == "textDocument/references" then
    params.context = { includeDeclaration = true }
  end

  return params
end

function M.request_locations(bufnr, winid, method)
  local params = make_position_params(bufnr, winid, method)
  local responses = vim.lsp.buf_request_sync(bufnr, method, params, REQUEST_TIMEOUT_MS)
  local locations, offset_encoding = extract_locations(responses)
  local error_message = extract_error_message(responses)
  return locations, offset_encoding, error_message
end

function M.is_transient_definition_error(error_message)
  return type(error_message) == "string" and error_message:find(LOADED_PROJECTS_ERROR_MARKER, 1, true) ~= nil
end

function M.is_decompile_error(error_message)
  return type(error_message) == "string" and error_message:find(DECOMPILE_ERROR_MARKER, 1, true) ~= nil
end

function M.request_definition_with_retry(bufnr, winid)
  local locations, offset_encoding, error_message = M.request_locations(bufnr, winid, "textDocument/definition")
  if locations or not M.is_transient_definition_error(error_message) then
    return locations, offset_encoding, error_message
  end

  for _ = 2, MAX_DEFINITION_ATTEMPTS do
    vim.wait(REQUEST_RETRY_DELAY_MS)
    locations, offset_encoding, error_message = M.request_locations(bufnr, winid, "textDocument/definition")
    if locations or not M.is_transient_definition_error(error_message) then
      break
    end
  end

  return locations, offset_encoding, error_message
end

return M
