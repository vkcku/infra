{
  flake.modules.nixos.desktop = { ... }: {
    # Networking
    networking.networkmanager.enable = true;

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
