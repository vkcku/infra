{
  flake.modules.nixos.desktop = { config, ... }: {
    # Networking
    networking.networkmanager.enable = true;
    users.users."${config.infra.core.username}".extraGroups = [ "networkmanager" ];

    # Bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = false;

    # Audio
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Battery
    services.upower.enable = true;
    services.tuned.enable = true;
  };
}
