{
  flake.modules.nixos.postgres =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      toMB = b: builtins.floor (b / (1024 * 1024));

      cfg = config.infra.postgres;

      pgVersion = lib.strings.getVersion pkgs.postgresql;
      pgMajor = lib.versions.major pgVersion;
    in
    {
      options.infra.postgres = {
        memory = lib.mkOption {
          type = lib.types.int;
          description = "How much RAM (in bytes) that is available for Postgres to use.";
          # In general Postgres is not the only thing that is running on the
          # machine so configure it assuming it has 40% of the total RAM. The
          # percentage is quite random and not based on any empirical testing.
          default = builtins.floor (config.infra.core.facts.memory * 4 / 10);
        };

        socket_directory = lib.mkOption {
          type = lib.types.str;
          default = "/run/postgresql";
          description = "Directory containing Unix-domain socket.";
        };
      };

      config = {

        infra.ports.requests.postgres = 5432;

        systemd.services.postgresql.serviceConfig.LogsDirectory = "postgresql/${pgMajor}";

        services.postgresql = {
          enable = true;
          package = pkgs.postgresql;
          enableJIT = true;
          settings = {
            listen_addresses = lib.mkForce "";
            port = config.infra.ports.assigned.postgres;
            unix_socket_directories = cfg.socket_directory;
            password_encryption = "scram-sha-256";

            # The below configurations are based on the values recommended in
            # https://youtu.be/XUkTUMZRBE8?t=259 for databases that tend to
            # fit in memory.
            shared_buffers = "${toString (toMB (cfg.memory * 0.25))}MB";
            work_mem = "8MB";
            maintenance_work_mem = "128MB";

            seq_page_cost = 0.1;
            random_page_cost = 0.1;

            io_method = "io_uring";

            # JSON logging, written per-day into a directory scoped to the
            # Postgres major version.
            logging_collector = true;
            log_destination = lib.mkForce "jsonlog";
            log_directory = "/var/log/postgresql/${pgMajor}";
            log_filename = "postgresql-%Y-%m-%d.log";

            log_autovacuum_min_duration = "250ms";
            log_checkpoints = true;
            log_connections = true;
            log_disconnections = true;
            log_lock_waits = true;
            log_lock_failures = true;
            log_recovery_conflict_waits = true;
            log_statement = "ddl";
            log_duration = true;
            log_min_duration_statement = "100ms";
          };

          # Allows me to login without requiring a password (peer auth) while
          # all the applications etc. will require a password.
          authentication = lib.mkForce ''
            # TYPE   DATABASE  USER                          ADDRESS  METHOD
              local  all       postgres                               peer
              local  all       ${config.infra.core.username}          peer
              local  all       all                                    scram-sha-256
          '';

          ensureUsers = [
            {
              name = config.infra.core.username;
            }
          ];
        };

        assertions = [
          {
            assertion = pgMajor == "18";
            message = "expected postgres to be version 18; found ${pgVersion}";
          }
        ];
      };
    };
}
