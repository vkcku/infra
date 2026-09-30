{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # keep-sorted start block=yes newline_separated=yes
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    # The last released version of helix is quite outdated so follow HEAD
    # instead.
    #
    # See https://github.com/helix-editor/helix/issues/15319.
    helix = {
      url = "github:helix-editor/helix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    import-tree.url = "github:denful/import-tree";

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pastyears = {
      # `git+ssh` allows using my SSH credentials instead of having to setup
      # a Github PAT.
      url = "git+ssh://git@github.com/vkcku/pastyears";

      # Unfortunately, this cannot follow nixpkgs. The reason for that is
      # because it relies on FODs for installing pnpm dependencies. The output
      # hash may differ based on the pnpm version which causes a build that
      # works in the pastyears repo to fail in this (in CI where there is
      # no cached /nix/store).
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    terranix = {
      url = "github:terranix/terranix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
      };
    };

    treefmt-nix-config = {
      url = "github:vkcku/treefmt-nix-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      inputs.import-tree [
        # keep-sorted start
        ./apps
        ./hosts
        ./iaac/default.nix
        ./modules
        ./nix
        # keep-sorted end
      ]
    );
}
