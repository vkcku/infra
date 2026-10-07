{ self, ... }: {
  perSystem = { pkgs, ... }: {
    apps.bootstrap-ares =
      let
        bin = pkgs.writeShellApplication {
          name = "bootstrap-ares";
          runtimeInputs = [
            # keep-sorted start
            pkgs.disko
            pkgs.git
            pkgs.openssh
            pkgs.sops
            pkgs.ssh-to-age
            pkgs.yq-go
            # keep-sorted end
          ];
          text = ''
            # The live installer creates its own hostid which results in
            # the import of the ZFS pool failing. Instead forcefully set
            # the hostid as configured in Nix.
            sudo rm -rf /etc/hostid
            sudo zgenhostid -f "${self.nixosConfigurations.ares.config.networking.hostId}"

            rootdir="$(git rev-parse --show-toplevel)"

            extrafiles="$(mktemp -d)"
            trap 'rm -rf "$extrafiles"' EXIT

            keydir="$extrafiles/etc/ssh"
            mkdir --parents "$keydir"

            privatekey="$keydir/ssh_host_ed25519_key"
            publickey="$privatekey.pub"

            ssh-keygen -t ed25519 -N "" -f "$privatekey"
            chmod 600 "$privatekey"
            chmod 644 "$publickey"

            agekey="$(ssh-to-age < "$publickey")"

            yq \
              --inplace \
              "(.keys | .. | select(anchor == \"ares\")) = \"$agekey\"" \
              "$rootdir/.sops.yaml"
              
            sops updatekeys --yes "$rootdir/modules/core/secrets.yaml"

            # The live installer's Nix store lives in a RAM-backed tmpfs, which
            # is too small to build the full system closure. disko-install
            # builds the closure on the installer store *before* formatting the
            # disk, so it runs out of space. Instead we partition and mount the
            # real disk first, then let nixos-install build into the mounted
            # target store (/mnt/nix/store) rather than the tmpfs.
            #
            # See https://github.com/nix-community/disko/issues/942

            sudo disko \
              --mode destroy,format,mount \
              --flake "$rootdir#ares"

            sudo mkdir -p /mnt/etc/ssh
            sudo cp "$privatekey" "$publickey" /mnt/etc/ssh/

            sudo nixos-install \
              --flake "$rootdir#ares" \
              --root /mnt \
              --no-root-passwd
          '';
        };
      in
      {
        type = "app";
        program = "${bin}/bin/bootstrap-ares";
        meta.description = "bootstrap the ares machine by doing a fresh installation (run on the live installer after copying over the repo)";
      };
  };
}
