{
  formats,
  symlinkJoin,
  makeWrapper,
  betterleaks,
}:
let
  tomlFormat = formats.toml { };

  configFile = tomlFormat.generate "betterleaks.toml" {
    extend.useDefault = true;

    # Ignores the following:
    #    - secrets encrypted by sops
    #    - the placeholders for psql variable substitution
    filter = ''
      (
        filter.matchesAny(attributes["path"], [`modules/core/secrets\.yaml`]) &&
        filter.matchesAny(finding["match"], [`ENC\[AES256_GCM`])
      ) || (
        filter.matchesAny(attributes["path"], [`modules/pastyears\.nix`]) &&
        filter.matchesAny(finding["line"], [`:'[a-z_]+_password'`])
      )
    '';
  };
in
symlinkJoin {
  name = "betterleaks-wrapped-${betterleaks.version}";

  paths = [ betterleaks ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram "$out/bin/betterleaks" \
      --add-flags "--config ${configFile}"
  '';

  inherit (betterleaks) meta;
}
