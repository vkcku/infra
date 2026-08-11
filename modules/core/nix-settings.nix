{ self, ... }:
{
  flake.modules.nixos.core =
    { config, ... }:
    {
      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 5d --log-format internal-json";
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
