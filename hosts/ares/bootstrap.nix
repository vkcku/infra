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

            keydir="$extrafiles/persist/etc/ssh"
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
              
            sops updatekeys --yes "$rootdir/modules/base/secrets.yaml"

            sudo disko-install \
              --flake "$rootdir#ares" \
              --disk main "/dev/disk/by-id/nvme-WD_Green_SN350_1TB_231350803893" \
              --extra-files "$keydir" "/persist/etc/ssh"
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
