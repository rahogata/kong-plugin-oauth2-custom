
local AUTH_PROVIDERS = {
  primary_key = { "id" },
  table = "auth_providers",
  cache_key = { "name" },
  fields = {
    id = { type = "id", dao_insert_value = true },
    name = { type = "string", required = true, unique = true },
    provider_type = { type = "string", required = true },
    config = { type = "table", required = true },
    created_at = { type = "timestamp", immutable = true, dao_insert_value = true }
  }
}

return {
  auth_providers = AUTH_PROVIDERS
}
