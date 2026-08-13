{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      # Install the Ghostty terminfo so that SSH sessions from a Ghostty
      # terminal work correctly (e.g. TERM=xterm-ghostty is recognised).
      #
      # Only pull in the terminfo output rather than the full Ghostty package
      # which avoids building the GUI app on headless servers.
      environment.systemPackages = [ pkgs.ghostty.terminfo ];
    };
}
