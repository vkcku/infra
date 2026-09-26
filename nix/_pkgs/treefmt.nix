{ pkgs, treefmt-nix-config, ... }:
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

  programs.kdlfmt.enable = true;
}
