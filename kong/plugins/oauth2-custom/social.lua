local putils = require "kong.plugins.oauth2-custom.utils"
local singletons = require "kong.singletons"
local responses = require "kong.tools.responses"
local utils = require "kong.tools.utils"

local _M = {}

local RESPONSE_TYPE = "response_type"
local CODE = "code"
local ERROR = "error"
local CLIENT_ID = "client_id"
local REDIRECT_URI = "redirect_uri"
local SCOPE = "scope"
local STATE = "state"

local function load_oauth2_credential_by_client_id_into_memory(client_id)
  local credentials, err = singletons.dao.oauth2_credentials:find_all {client_id = client_id}
  if err then
    return nil, err
  end
  return credentials[1]
end

local function get_redirect_uri(client_id)
  local client, err
  if client_id then
    local credential_cache_key = singletons.dao.oauth2_credentials:cache_key(client_id)
    client, err = singletons.cache:get(credential_cache_key, nil,
                                       load_oauth2_credential_by_client_id_into_memory,
                                       client_id)
    if err then
      return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
    end
  end
  return client and client.redirect_uri or nil, client
end

local function retrieve_scopes(parameters, conf)
  local scope = parameters[SCOPE]
  local scopes = {}
  if conf.scopes and scope then
    for v in scope:gmatch("%S+") do
      if not utils.table_contains(conf.scopes, v) then
        return false, {[ERROR] = "invalid_scope", error_description = "\"" .. v .. "\" is an invalid " .. SCOPE}
      else
        table.insert(scopes, v)
      end
    end
  end

  return true, scopes
end

function _M.execute(conf, provider)

  local parameters = putils.retrieve_parameters()
  local response_type = parameters[RESPONSE_TYPE]
  -- Check response_type
  if not (response_type == CODE and conf.enable_authorization_code) then -- Authorization Code Grant (http://tools.ietf.org/html/rfc6749#section-4.1.1)
    response_params = {[ERROR] = "unsupported_response_type", error_description = "Invalid " .. RESPONSE_TYPE}
  end

-- Check client_id and redirect_uri
  allowed_redirect_uris, client = get_redirect_uri(parameters[CLIENT_ID])

  if not allowed_redirect_uris then
    response_params = {[ERROR] = "invalid_client", error_description = "Invalid client authentication" }
  else
    redirect_uri = parameters[REDIRECT_URI] and parameters[REDIRECT_URI] or allowed_redirect_uris[1]

    if not utils.table_contains(allowed_redirect_uris, redirect_uri) then
      response_params = {[ERROR] = "invalid_request", error_description = "Invalid " .. REDIRECT_URI .. " that does not match with any redirect_uri created with the application" }
    end
  end

  -- Check scopes
  local ok, scopes = retrieve_scopes(parameters, conf)
  if not ok then
    response_params = scopes -- If it's not ok, then this is the error message
  end

  if not response_params[ERROR] then
    local state_cache_key = utils.random_string();
    local state, err = singletons.cache:get(state_cache_key, nil,
                      putils.load_new_session_state,
                      { client_state = parameters[STATE], client_id = client.id, redirect_url = redirect_uri, scopes = scopes, api_id = ngx.ctx.api.id })
    if err then
      return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
    end
    local authorization_url = provider.config.authorization_uri .. "?response_type=code&client_id=" .. provider.config.client_id .. "&redirect_uri=" .. provider.config.callback_url .. "&scope=" .. table.concat(provider.config.scopes, " ") .. "&state=" .. state_cache_key
    return ngx.redirect(authorization_url)
  end

    -- Sending response in JSON format
  return responses.send(response_params[ERROR] and 400 or 200, response_params, {
    ["cache-control"] = "no-store",
    ["pragma"] = "no-cache"
  })

end

return _M
