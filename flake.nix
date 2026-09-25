{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # keep-sorted start block=yes newline_separated=yes
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    hjem = {
      url = "github:feel-co/hjem";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-darwin.follows = "";
      };
    };

    import-tree.url = "github:denful/import-tree";

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pastyears = {
      # `git+ssh` allows using my SSH credentials instead of having to setup
      # a Github PAT.
      url = "git+ssh://git@github.com/vkcku/pastyears";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix-config.follows = "treefmt-nix-config";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix-config = {
      url = "github:vkcku/treefmt-nix-config";
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
        ./modules
        ./nix
        # keep-sorted end
      ]
    );
}
