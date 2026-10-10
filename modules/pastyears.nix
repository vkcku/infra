{ self, inputs, ... }: {
  flake.modules.nixos.pastyears =
    { config, pkgs, ... }:
    let
      user = "pastyears";

      database = "pastyears";

      appPasswordKey = "services/pastyears/pg_app";
      migrationsPasswordKey = "services/pastyears/pg_migrations";

      appPasswordPath = config.sops.secrets.${appPasswordKey}.path;
      migrationsPasswordPath = config.sops.secrets.${migrationsPasswordKey}.path;

      initScript = pkgs.writeText "pastyears-init-script.sql" ''
        \set ON_ERROR_STOP on

        \set app_password `cat "$CREDENTIALS_DIRECTORY/app_password"`
        \set migrations_password `cat "$CREDENTIALS_DIRECTORY/migrations_password"`

        ALTER ROLE pastyears_app WITH LOGIN PASSWORD :'app_password';
        ALTER ROLE pastyears_migrations WITH LOGIN PASSWORD :'migrations_password';

        ALTER DATABASE pastyears OWNER TO pastyears_migrations;

        \connect pastyears

        REVOKE ALL ON DATABASE pastyears FROM PUBLIC;
        REVOKE ALL ON SCHEMA public FROM PUBLIC;

        GRANT CONNECT ON DATABASE pastyears TO pastyears_app;

        GRANT USAGE ON SCHEMA public TO pastyears_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO pastyears_app;
        GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO pastyears_app;

        ALTER DEFAULT PRIVILEGES FOR ROLE pastyears_migrations
          GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO pastyears_app;
        ALTER DEFAULT PRIVILEGES FOR ROLE pastyears_migrations
          GRANT USAGE, SELECT ON SEQUENCES TO pastyears_app;

        CREATE SCHEMA IF NOT EXISTS dba;

        REVOKE ALL ON SCHEMA dba FROM PUBLIC;
        GRANT USAGE ON SCHEMA dba TO pastyears_migrations;

        CREATE OR REPLACE FUNCTION dba.grant_app_on_schema(target_schema text)
          RETURNS void
          LANGUAGE plpgsql
          AS $$
          BEGIN
            -- The dba schema is internal bookkeeping; the app role must not get
            -- any access to it.
            IF target_schema = 'dba' THEN
              RETURN;
            END IF;

            EXECUTE format(
              'GRANT USAGE ON SCHEMA %I TO pastyears_app', target_schema);
            EXECUTE format(
              'GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA %I TO pastyears_app',
              target_schema);
            EXECUTE format(
              'GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA %I TO pastyears_app',
              target_schema);
            EXECUTE format(
              'ALTER DEFAULT PRIVILEGES FOR ROLE pastyears_migrations IN SCHEMA %I '
              'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO pastyears_app',
              target_schema);
            EXECUTE format(
              'ALTER DEFAULT PRIVILEGES FOR ROLE pastyears_migrations IN SCHEMA %I '
              'GRANT USAGE, SELECT ON SEQUENCES TO pastyears_app',
              target_schema);
          END;
          $$;

        CREATE OR REPLACE FUNCTION dba.grant_app_on_new_schema()
          RETURNS event_trigger
          LANGUAGE plpgsql
          AS $$
          DECLARE
            obj record;
          BEGIN
            FOR obj IN
              SELECT object_identity
              FROM pg_event_trigger_ddl_commands()
              WHERE command_tag = 'CREATE SCHEMA'
            LOOP
              PERFORM dba.grant_app_on_schema(obj.object_identity);
            END LOOP;
          END;
          $$;

        DROP EVENT TRIGGER IF EXISTS pastyears_grant_app_on_new_schema;
        CREATE EVENT TRIGGER pastyears_grant_app_on_new_schema
          ON ddl_command_end
          WHEN TAG IN ('CREATE SCHEMA')
          EXECUTE FUNCTION dba.grant_app_on_new_schema();
      '';
    in
    {
      infra.ports.requests.pastyears = true;

      users.users."${user}" = {
        isSystemUser = true;
        group = user;
      };

      users.groups."${user}" = { };

      sops.secrets = {
        ${appPasswordKey} = {
          owner = user;
          restartUnits = [
            config.systemd.services.pastyears-db-init.name
            config.systemd.services.pastyears.name
          ];
        };
        ${migrationsPasswordKey} = {
          owner = user;
          restartUnits = [
            config.systemd.services.pastyears-db-init.name
            config.systemd.services.pastyears.name
          ];
        };
      };

      sops.templates =
        let
          mkConnectionString =
            role: passwordPlaceholder:
            "postgresql://${role}:${passwordPlaceholder}@/${database}?host=${config.infra.postgres.socket_directory}&port=${toString config.infra.ports.assigned.postgres}";
        in
        {
          "pastyears_app_url" = {
            owner = user;
            content = mkConnectionString "pastyears_app" config.sops.placeholder.${appPasswordKey};
            restartUnits = [ config.systemd.services.pastyears.name ];
          };
          "pastyears_migrations_url" = {
            owner = user;
            content =
              mkConnectionString "pastyears_migrations"
                config.sops.placeholder.${migrationsPasswordKey};
            restartUnits = [ config.systemd.services.pastyears.name ];
          };
        };

      services.postgresql = {
        ensureUsers = [
          {
            name = "pastyears_app";
          }
          {
            name = "pastyears_migrations";
          }
        ];

        ensureDatabases = [ database ];
      };

      systemd.services.pastyears-db-init = {
        description = "Initialise the pastyears database roles and permissions";
        # ensureUsers/ensureDatabases run in postgresql-setup.service, not
        # postgresql.service, so order after that to guarantee the roles and
        # database exist before this script references them.
        after = [ config.systemd.services.postgresql-setup.name ];
        requires = [ config.systemd.services.postgresql-setup.name ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          User = "postgres";
          Group = "postgres";

          LoadCredential = [
            "app_password:${appPasswordPath}"
            "migrations_password:${migrationsPasswordPath}"
          ];

          ExecStart = "${config.services.postgresql.package}/bin/psql --host ${config.infra.postgres.socket_directory} --port ${toString config.infra.ports.assigned.postgres} --file ${initScript}";

          # keep-sorted start block=yes
          AmbientCapabilities = "";
          CapabilityBoundingSet = "";
          IPAddressDeny = "any";
          KeyringMode = "private";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateNetwork = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          ReadOnlyPaths = [ config.infra.postgres.socket_directory ];
          RemoveIPC = true;
          RestrictAddressFamilies = [ "AF_UNIX" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
          ];
          UMask = "0077";
          # keep-sorted end
        };
      };

      systemd.services.pastyears =
        let
          pastyears = inputs.pastyears.packages.${pkgs.stdenv.hostPlatform.system}.pastyears;
        in
        {
          description = "pastyears application server";
          after = [
            config.systemd.services.pastyears-db-init.name
            "network-online.target"
          ];
          requires = [ config.systemd.services.pastyears-db-init.name ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            User = user;
            Group = user;

            ExecStartPre = "${pastyears}/bin/migrations -connstring 'file:${config.sops.templates.pastyears_migrations_url.path}' -migrations-dir '${pastyears}/share/migrations' -schema-file '' up";
            ExecStart = "${pastyears}/bin/pastyears --connstring-key 'file:${config.sops.templates.pastyears_app_url.path}' --dist-dir '${pastyears}/share/frontend/dist' --manifest-path '${pastyears}/share/frontend/manifest.json' --port ${toString config.infra.ports.assigned.pastyears} --host 0.0.0.0";
            Restart = "on-failure";
            RestartSec = 5;

            # keep-sorted start block=yes
            AmbientCapabilities = "";
            CapabilityBoundingSet = "";
            # Accept traffic from localhost and tailscale.
            IPAddressAllow = [
              "localhost"
              "100.64.0.0/10"
              "fd7a:115c:a1e0::/48"
            ];
            IPAddressDeny = "any";
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateMounts = true;
            PrivateTmp = true;
            PrivateUsers = true;
            ProcSubset = "pid";
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "strict";
            ReadOnlyPaths = [ config.infra.postgres.socket_directory ];
            RemoveIPC = true;
            RestrictAddressFamilies = [
              "AF_UNIX"
              "AF_INET"
              "AF_INET6"
            ];
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            SystemCallFilter = [
              "@system-service"
              "~@privileged"
              "~@resources"
            ];
            UMask = "0077";
            # keep-sorted end
          };
        };

      services.caddy.virtualHosts."pastyears.net" = {
        serverAliases = [ "www.pastyears.net" ];
        extraConfig = ''
          log {
            level INFO
            output file ${config.services.caddy.logDir}/vkcku.com.log
            format append {
              wrap filter {
                wrap json
                fields {
                  request>client_ip ip_mask {
                    ipv4 24
                    ipv6 48
                  }
                }
              }

              "caddy.version" "${config.services.caddy.package.version}"
              "infra.version" "${self.rev or self.dirtyRev}"
              "infra.nixpkgs_version" "${inputs.nixpkgs.rev}"
              "os.name" "${config.system.nixos.codeName}"
              "os.version" "${config.system.nixos.version}"
              "host.id" "${config.networking.hostId}"
              "host.name" "${config.networking.hostName}"
              "cf.ray" "{http.request.header.CF-Ray}"
              "cf.country" "{http.request.header.CF-IPCountry}"
              "service.namespace" "vkcku.com"
              "service.name" "caddy"
            }
          }

          @internal path /internal /internal/*
          handle @internal {
            respond 404
          }

          handle {
            reverse_proxy localhost:${toString config.infra.ports.assigned.pastyears}
          }
        '';
      };

      assertions = [
        {
          assertion = config.services.postgresql.enable;
          message = "postgres must be enabled to run pastyears";
        }
        {
          assertion = pkgs.lib.versions.major config.services.postgresql.package.version == "18";
          message = "pastyears requires PostgreSQL 18, but services.postgresql.package is version ${config.services.postgresql.package.version}";
        }
      ];
    };
}
