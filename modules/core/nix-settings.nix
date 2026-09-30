{ self, ... }:
{
  flake.modules.nixos.core =
    { config, ... }:
    let
      profile = config.infra.core.profile;

      gcPeriod =
        if profile == "server" then
          "7d"
        else if profile == "daily-use" then
          "90d"
        else
          throw "unreocognized profile ${profile}";
    in
    {
      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than ${gcPeriod} --log-format internal-json";
          persistent = true;
        };

        optimise = {
          automatic = true;
          dates = "weekly";
          persistent = true;
        };

        settings = {
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          allowed-users = [ ];
          trusted-users = [ "@wheel" ];
        };
      };

      system = {
        configurationRevision = self.rev or self.dirtyRev or "unknown";
        nixos.label = "${config.system.nixos.release}-${self.shortRev or self.dirtyShortRev or "unknown"}";
      };
    };
}
