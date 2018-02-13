package = "kong-plugin-oauth2-custom"
version = "0.1.0-1"
-- The version '0.1.0' is the source code version, the trailing '1' is the version of this rockspec.
-- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.

-- Here we extract it from the package name.
local pluginName = package:match("^kong%-plugin%-(.+)$")  -- "oauth2-custom"

supported_platforms = {"linux", "macosx"}
source = {
  -- these are initially not required to make it work
  url = "git://github.com/shiva2991/kong-plugin-oauth2-custom",
  tag = "v0.0"
}

description = {
  summary = "A plugin to support various authentication mechanism like OTP, LDAP, Basic, JDBC etc, for generating oauth2 token.",
  homepage = "http://rahogata.co.in",
  license = "MIT"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".access"] = "kong/plugins/"..pluginName.."/access.lua",
    ["kong.plugins."..pluginName..".api"] = "kong/plugins/"..pluginName.."/api.lua",
    ["kong.plugins."..pluginName..".daos"] = "kong/plugins/"..pluginName.."/daos.lua",
    ["kong.plugins."..pluginName..".postgres"] = "kong/plugins/"..pluginName.."/migrations/postgres.lua",
    ["kong.plugins."..pluginName..".cassandra"] = "kong/plugins/"..pluginName.."/migrations/cassandra.lua",
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
-- modules specially for authentication.	
    ["kong.plugins."..pluginName..".social"] = "kong/plugins/"..pluginName.."/social.lua",
    ["kong.plugins."..pluginName..".utils"] = "kong/plugins/"..pluginName.."/utils.lua",
    ["kong.plugins."..pluginName..".pfactory"] = "kong/plugins/"..pluginName.."/pfactory.lua"
  }
}
