{
  pkgs,
  lib,
  treefmt-nix-config,
  betterleaks,
  ...
}:
treefmt-nix-config.lib.mkTreefmt pkgs {
  settings.excludes = [ "modules/core/secrets.yaml" ];

  programs.typos.configFile = toString (
    (pkgs.formats.toml { }).generate "typos.toml" {
      default.extend-words = {
        facter = "facter";
      };
      default.extend-identifiers = {
        FOD = "FOD";
        FODs = "FODs";
      };
    }
  );

  settings.formatter."betterleaks" = {
    command = lib.getExe betterleaks;
    options = [
      "dir"
      "--verbose"
    ];
    includes = [ "*" ];
    priority = 1;
  };

  programs.kdlfmt.enable = true;
}
