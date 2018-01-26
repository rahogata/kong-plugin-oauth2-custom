local crud = require "kong.api.crud_helpers"
local pfactory = require "kong.plugins.oauth2-custom.pfactory"

local function validateconfig(self, dao_factory, helpers)
  local pmodule = pfactory.moduleof(self.params.provider_type)
  if not pmodule then
    return helpers.responses.send_HTTP_BAD_REQUEST("Invalid provider type")
  end
  local ok, err = pmodule.validate_config(self.params.config)
  if not ok then
    helpers.responses.send_HTTP_BAD_REQUEST(err)
  end
end

return {
  ["/oauth2_tokens/"] = {
    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.oauth2_tokens)
    end,

    PUT = function(self, dao_factory)
      crud.put(self.params, dao_factory.oauth2_tokens)
    end,

    POST = function(self, dao_factory)
      crud.post(self.params, dao_factory.oauth2_tokens)
    end
  },

  ["/oauth2_tokens/:token_or_id"] = {
    before = function(self, dao_factory, helpers)
      local credentials, err = crud.find_by_id_or_field(
        dao_factory.oauth2_tokens,
        { consumer_id = self.params.consumer_id },
        self.params.token_or_id,
        "access_token"
      )

      if err then
        return helpers.yield_error(err)
      elseif next(credentials) == nil then
        return helpers.responses.send_HTTP_NOT_FOUND()
      end
      self.params.token_or_id = nil

      self.oauth2_token = credentials[1]
    end,

    GET = function(self, dao_factory, helpers)
      return helpers.responses.send_HTTP_OK(self.oauth2_token)
    end,

    PATCH = function(self, dao_factory)
      crud.patch(self.params, dao_factory.oauth2_tokens, self.oauth2_token)
    end,

    DELETE = function(self, dao_factory)
      crud.delete(self.oauth2_token, dao_factory.oauth2_tokens)
    end
  },

  ["/oauth2/"] = {
    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.oauth2_credentials)
    end
  },

  ["/consumers/:username_or_id/oauth2/"] = {
    before = function(self, dao_factory, helpers)
      crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
      self.params.consumer_id = self.consumer.id
    end,

    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.oauth2_credentials)
    end,

    PUT = function(self, dao_factory)
      crud.put(self.params, dao_factory.oauth2_credentials)
    end,

    POST = function(self, dao_factory)
      crud.post(self.params, dao_factory.oauth2_credentials)
    end
  },

  ["/consumers/:username_or_id/oauth2/:clientid_or_id"] = {
    before = function(self, dao_factory, helpers)
      crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
      self.params.consumer_id = self.consumer.id

      local credentials, err = crud.find_by_id_or_field(
        dao_factory.oauth2_credentials,
        { consumer_id = self.params.consumer_id },
        self.params.clientid_or_id,
        "client_id"
      )

      if err then
        return helpers.yield_error(err)
      elseif next(credentials) == nil then
        return helpers.responses.send_HTTP_NOT_FOUND()
      end
      self.params.clientid_or_id = nil

      self.oauth2_credential = credentials[1]
    end,

    GET = function(self, dao_factory, helpers)
      return helpers.responses.send_HTTP_OK(self.oauth2_credential)
    end,

    PATCH = function(self, dao_factory)
      crud.patch(self.params, dao_factory.oauth2_credentials, self.oauth2_credential)
    end,

    DELETE = function(self, dao_factory)
      crud.delete(self.oauth2_credential, dao_factory.oauth2_credentials)
    end
  },

  ["/oauth2-custom/auth_providers/"] = {
    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.auth_providers)
    end,

    PUT = function(self, dao_factory, helpers)
      validateconfig(self, dao_factory, helpers)
      crud.put(self.params, dao_factory.auth_providers)
    end,

    POST = function(self, dao_factory, helpers)
      validateconfig(self, dao_factory, helpers)
      crud.post(self.params, dao_factory.auth_providers)
    end
  },

  ["/oauth2-custom/auth_providers/:name"] = {
    before = function(self, dao_factory, helpers)
      local providers, err = crud.find_by_id_or_field(
        dao_factory.auth_providers,
        nil,
        self.params.name,
        "name")

      if err then
        return helpers.yield_error(err)
      elseif next(providers) == nil then
        return helpers.responses.send_HTTP_NOT_FOUND()
      end
      self.provider = providers[1]
    end,

    GET = function(self, dao_factory, helpers)
      return helpers.responses.send_HTTP_OK(self.provider)
    end,

    DELETE = function(self, dao_factory)
      crud.delete(self.provider, dao_factory.auth_providers)
    end
  }
}
