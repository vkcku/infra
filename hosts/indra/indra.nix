{ config, ... }:
let
  flakeConfig = config;
in
{
  flake.modules.nixos.indra = { ... }: {
    imports = map (m: flakeConfig.flake.modules.nixos."${m}") [
      # keep-sorted start
      "caddy"
      "core"
      "deploy-user"
      "pastyears"
      "ports"
      "postgres"
      "vkcku.com"
      # keep-sorted end
    ];

    hardware.facter.reportPath = ./facter.json;

    infra.core = {
      profile = "server";
      facts.memory = 8 * 1000 * 1000 * 1000; # 8 GB
    };

    boot = {
      loader.grub = {
        enable = true;
        efiSupport = false;
      };

      kernelParams = [
        "console=tty1"
        # The Hostinger VPS does not work if the console output is not sent
        # to the serial console as well.
        "console=ttyS0,115200n8"
      ];
    };

    system.stateVersion = "26.11";
  };
}
