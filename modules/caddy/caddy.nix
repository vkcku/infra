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
      infra.portRequests.caddy_admin = 2019;

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
          hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
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
          admin localhost:${toString config.infra.ports.caddy_admin}

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
