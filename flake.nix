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
      in {
        formatter = pkgs.alejandra;
        # checks = {
        #   default = nixvim_config.inputs.nixvim.lib.${system}.check.mkTestDerivationFromNixvimModule neovimModule;
        # };
        packages.devenv-up = self.devShells.${system}.default.config.procfileScript;
        devShells.default = devenv.lib.mkShell{
            inherit inputs pkgs;
            modules = [
            ({pkgs, config, ...}: {
                packages = [
                    neovim
                    pkgs.gtk4
                    pkgs.just
                    pkgs.ruff
                    pkgs.manim
                    pkgs.mpv
                ];
             })
            ];

        };
        # pkgs.mkShell {
        #     packages = [
        #         neovim
        #         pkgs.uv
        #         pkgs.virtualenv
        #         pkgs.just
        #         pkgs.pango
        #         pkgs.gtk4
        #         pkgs.cairo
        #         pkgs.ffmpeg
        #         pkgs.sox
        #         pkgs.manim
        #         
        #                 ];
        # shellHook = ''
        #     unset PYTHONPATH
        #     export REPO_ROOT=$(git rev-parse --show-toplevel)
        #   '';
        # };
      }
    );
}
