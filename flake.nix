{
  description = "Basic flake for working with manim on python";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    nixvim_config.url = "github:AlejandroGomezFrieiro/nixvim_config";
    devenv.url = "github:cachix/devenv";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixvim_config,
    flake-utils,
    devenv,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        neovimModule = {
          inherit pkgs;
          module = {
            imports = [
              nixvim_config.outputs.nixosModules.${system}.nvim
            ];
            plugins.lsp.servers.pylsp.enable = true;
          };
        };
        neovim = nixvim_config.inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule neovimModule;
        # python_dotenv = pkgs.python3Packages.buildPythonPackage rec {
        #     pname = "python-dotenv";
        #     version = "0.21.1";
        #     src = pkgs.fetchPypi {
        #         inherit pname version;
        #         sha256 = "HJPej2Ns3jzjdykoGNDkQLbkWoLyFcN0SXkVH6gVHEk=";
        #     };
        # };
        #       manim_voiceover = pkgs.python3Packages.buildPythonPackage rec {
        #       pyproject = true;
        #       pname = "manim_voiceover";
        #       version = "0.3.7";
        #       build-system = [
        #   pkgs.python312Packages.poetry-core
        # ];
        #       dependencies = [
        #               pkgs.python312Packages.jaxlib
        #               pkgs.python312Packages.jax
        #                                       ];
        #       buildInputs = [
        #               pkgs.python312Packages.soxr
        #               pkgs.python312Packages.manim
        #               pkgs.python312Packages.mutagen
        #               pkgs.python312Packages.pip
        #               pkgs.python312Packages.pydub
        #               python_dotenv
        #               pkgs.python312Packages.python-slugify
        #       ];
        #
        #     src = pkgs.fetchFromGitHub {
        #       owner = "ManimCommunity";
        #       repo = "manim-voiceover";
        #       rev = "v0.3.7";
        #       sha256 = "VwU1Jk10DR13yWHJ0CNyFRGsfYN4xXm8SVWVjMsoig0="; # TODO
        #     };
        #       };
      in {
        formatter = pkgs.alejandra;
        packages.devenv-up = self.devShells.${system}.default.config.procfileScript;
        devShells.render = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            ({
              pkgs,
              config,
              ...
            }: {
              packages = [
                pkgs.gtk4
                pkgs.just
                pkgs.manim
              ];
            })
          ];
        };
        devShells.default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            ({
              pkgs,
              config,
              ...
            }: {
              packages = [
                neovim
                pkgs.gtk4
                pkgs.just
                pkgs.ruff
                pkgs.manim
                # manim_voiceover
                pkgs.mpv
              ];
            })
          ];
        };
      }
    );
}
