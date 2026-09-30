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

    rules = [
      # https://developers.cloudflare.com/fundamentals/api/get-started/token-formats/
      {
        id = "infra-cloudflare";
        description = "Cloudflare API token/key";
        regex = ''\bcf(k|ut|at)_[A-Za-z0-9]{40,64}\b'';
        keywords = [
          "cfk_"
          "cfut_"
          "cfat_"
        ];
      }
    ];

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
