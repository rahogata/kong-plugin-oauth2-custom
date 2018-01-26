local singletons = require "kong.singletons"
local url = require "socket.url"

local _M = {}

function _M.retrieve_parameters()
  return ngx.req.get_uri_args()
end

function _M.load_new_session_state(session)
  return session
end

function _M.load_provider(provider_name)
   local provider, err = singletons.dao.auth_providers:find_all({ name = provider_name })[1]
   if err then
      return nil, err
    end
    return provider
end

function _M.validate_uris(v)
  if v then
    if #v == 0 then
      return false, "Invalid request."
    end
    for _, uri in ipairs(v) do
      local parsed_uri = url.parse(uri)
      if not (parsed_uri and parsed_uri.host and parsed_uri.scheme) then
        return false, "cannot parse '" .. uri .. "'"
      end
      if parsed_uri.fragment ~= nil then
        return false, "fragment not allowed in '" .. uri .. "'"
      end
    end
    return true, nil
  end
  return false, "Invalid uri found in the configuration."
end

return _M
