{
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos."vkcku.com" =
    { config, ... }:
    let
      indexHtml = ''
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>vkcku.com</title>
          </head>
          <body>
            <h1>Website under construction.</h1>
          </body>
        </html>
      '';
    in
    {
      services.caddy.virtualHosts."vkcku.com" = {
        serverAliases = [ "www.vkcku.com" ];
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

          header Content-Type "text/html; charset=utf-8"
          respond `${indexHtml}` 200
        '';
      };

      assertions = [
        {
          assertion = config.services.caddy.enable;
          message = "caddy must be enabled for vkcku.com";
        }
      ];
    };
}
