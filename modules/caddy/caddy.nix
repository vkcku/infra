{
  inputs,
  self,
  lib,
  ...
}:
{
  flake.modules.nixos.caddy =
    { config, pkgs, ... }:
    let
      cloudflareIPs =
        lib.pipe
          [ ./cloudflare-ip-v4.txt ./cloudflare-ip-v6.txt ]
          [
            (map (file: lib.splitString "\n" (builtins.readFile file)))
            lib.concatLists
            (map lib.trim)
            (lib.filter (line: line != ""))
          ];
    in
    {
      infra.ports.requests.caddy_admin = 2019;

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      sops = {
        secrets."cloudflare_dns_api_key" = {
          owner = config.services.caddy.user;
        };

        templates."caddy.env" = {
          content = ''
            INFRA_CF_DNS_API_KEY="${config.sops.placeholder."cloudflare_dns_api_key"}"
          '';
          owner = config.services.caddy.user;
        };
      };

      systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates."caddy.env".path;

      services.caddy = {
        enable = true;

        package = pkgs.caddy.withPlugins {
          plugins = [
            "github.com/caddy-dns/cloudflare@v0.2.4" # for DNS-01 challenge
          ];
          # The hash needs to be updated whenever the plugins are updated AND
          # when caddy itself is updated (via an update to nixpkgs). This
          # is because the hash is derived from the combination of both
          # caddy and the plugins dependencies. This is unfortunate since
          # it means that we can't track if the hash mismatch is due to a
          # change in the plugin source. For now, the plugins I am using
          # are relatively trustworthy so I'm going to ignore this for
          # now. The linked Github issue has some details on how this could
          # be mitigated. I should look into that at some point.
          #
          # REF: https://github.com/nixos/nixpkgs/issues/450289
          #
          # TODO: Separate out the hashes for caddy and plugins somehow. See
          # above issue.
          hash = "sha256-dQvk6ezY6TQ1J7PjhCXnThF/SqVgPwBO8/RXzHCY+js=";
        };

        # Keep this for development and set it to null for production.
        # acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
        acmeCA = null;

        email = "acme@mail.vkcku.com";

        logFormat = ''
          level INFO
          output file ${config.services.caddy.logDir}/caddy.log
          format append {
            "caddy.version" "${config.services.caddy.package.version}"
            "infra.version" "${self.rev or self.dirtyRev}"
            "infra.nixpkgs_version" "${inputs.nixpkgs.rev}"
            "os.name" "${config.system.nixos.codeName}"
            "os.version" "${config.system.nixos.version}"
            "host.id" "${config.networking.hostId}"
            "host.name" "${config.networking.hostName}"
            "service.name" "caddy"
          }
        '';

        globalConfig = ''
          admin localhost:${toString config.infra.ports.assigned.caddy_admin}

          acme_dns cloudflare {env.INFRA_CF_DNS_API_KEY}

          grace_period 2m

          servers {
            timeouts {
              read_body 45s
              read_header 10s
              write 45s
              idle 10m
            }

            client_ip_headers CF-Connecting-IP X-Forwarded-For
            trusted_proxies static ${lib.concatStringsSep " " cloudflareIPs}

            strict_sni_host on
          }

          servers :443 {
            name https
          }

          servers :80 {
            name http
          }
        '';

        virtualHosts."http://" = { };
      };
    };
}
