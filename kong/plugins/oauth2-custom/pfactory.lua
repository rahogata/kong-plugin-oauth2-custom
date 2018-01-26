-- Authentication provider modules
local social = require "kong.plugins.oauth2-custom.social"

local _M = {}

local SOCIAL = "SOCIAL"

function _M.moduleof(provider_type)
  if provider_type == SOCIAL then
    return social
  end
  return nil
end

return _M
