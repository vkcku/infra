{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # keep-sorted start block=yes newline_separated=yes
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:denful/import-tree";

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
        ./hosts
        ./modules
        ./nix
        # keep-sorted end
      ]
    );
}
