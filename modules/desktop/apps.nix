{ inputs, ... }: {
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      mkNixPak = inputs.nixpak.lib.nixpak {
        inherit (pkgs) lib;
        inherit pkgs;
      };
    in
    {
      options.infra.desktop = {
        excludedApps = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "The applications to exclude from being installed. By default all applications are installed.";
          default = [ ];
        };
      };

      config =
        let
          appNames = lib.pipe (builtins.readDir ./_apps) [
            (lib.filterAttrs (_name: type: type == "regular"))
            builtins.attrNames
            (map (lib.removeSuffix ".nix"))
          ];
          filteredApps = lib.subtractLists config.infra.desktop.excludedApps appNames;
          apps = map (
            name:
            pkgs.callPackage (./_apps + "/${name}.nix") {
              inherit mkNixPak;

              zen-browser-unwrapped =
                inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped;
            }
          ) filteredApps;
        in
        {
          environment.systemPackages = apps;
        };
    };
}
