{ inputs, ... }: {
  flake.modules.nixos.core = { lib, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops.defaultSopsFile = ./secrets.yaml;

    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    virtualisation.vmVariant = {
      # Use the age key from the host (my development machine) to decrypt
      # in the VMs.
      virtualisation.sharedDirectories.host-age = {
        source = "/home/vkcku/.config/sops/age";
        target = "/run/sops/age";
      };

      sops.age.keyFile = lib.mkForce "/run/sops/age/keys.txt";
    };
  };
}
