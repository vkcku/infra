{
  perSystem = { pkgs, ... }: {
    apps.bootstrap-indra =
      let
        bin = pkgs.writeShellApplication {
          name = "bootstrap-indra";
          runtimeInputs = [
            # keep-sorted start
            pkgs.git
            pkgs.nixos-anywhere
            pkgs.openssh
            pkgs.sops
            pkgs.ssh-to-age
            pkgs.yq-go
            # keep-sorted end
          ];
          text = ''
            rootdir="$(git rev-parse --show-toplevel)"

            extrafiles="$(mktemp -d)"
            trap 'rm -rf "$extrafiles"' EXIT

            keydir="$extrafiles/etc/ssh"
            mkdir --parents "$keydir"

            privatekey="$keydir/ssh_host_ed25519_key"
            publickey="$privatekey.pub"

            ssh-keygen -t ed25519 -N "" -C "root@indra" -f "$privatekey"
            chmod 600 "$privatekey"
            chmod 644 "$publickey"

            agekey="$(ssh-to-age < "$publickey")"

            yq \
              --inplace \
              "(.keys | .. | select(anchor == \"indra\")) = \"$agekey\"" \
              "$rootdir/.sops.yaml"
              
            sops updatekeys --yes "$rootdir/modules/core/secrets.yaml"

            nixos-anywhere \
              --flake "$rootdir#indra" \
              --extra-files "$extrafiles" \
              --target-host "root@145.223.22.205"

            git add "$rootdir/.sops.yaml" "$rootdir/modules/core/secrets.yaml"
            git commit -m "indra: update sops key"
          '';
        };
      in
      {
        type = "app";
        program = "${bin}/bin/bootstrap-indra";
        meta.description = "bootstrap the indra machine by doing a fresh installation.";
      }

    ;
  };
}
