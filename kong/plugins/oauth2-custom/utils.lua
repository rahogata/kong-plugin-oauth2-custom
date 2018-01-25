local singletons = require "kong.singletons"
local social = require "kong.plugins.oauth2-custom.social"

local _M = {}

local SOCIAL = "SOCIAL"

function _M.get_providers(provider_type)
  local providers = {}
  local provider_entities = singletons.dao.auth_providers:find_all({ provider_type = provider_type })
  for i, v in ipairs(provider_entities) do
    table.insert(providers, { name = v.name, method = v.method, uri = v.uri .. v.name, response_type = v.response_type })
  end
  return providers
end

function _M.list_merge(a, b)
  local temp
  if not a then
    a = {}
  end
  if not b then
    b = {}
  end
  if #a > #b then
    temp = a
    a = b
    b = temp
  end
  for i, v in ipairs(a) do table.insert(b, v) end
  return b
end

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

function _M.moduleof(provider_type)
  if provider_type == SOCIAL then
    return social
  end
  return nil
end

return _M
