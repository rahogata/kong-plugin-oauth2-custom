
return {
  {
    name = "2018-01-17-init_auth_providers",
    up = [[
      CREATE TABLE IF NOT EXISTS auth_providers(
        id uuid,
        name text UNIQUE,
        provider_type text,
        config json,
        created_at timestamp without time zone default (CURRENT_TIMESTAMP(0) at time zone 'utc'),
        PRIMARY KEY(id)
        );

        DO $$
          BEGIN
            IF (SELECT to_regclass('auth_providers_name_idx')) IS NULL THEN
              CREATE INDEX auth_providers_name_idx ON auth_providers(name);
            END IF;
        END$$;
    ]],
    down = [[
      DROP TABLE auth_providers;
    ]]
  }
}
