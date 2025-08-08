{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python311;
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            uv
          ];

          shellHook = ''
            if [ ! -d ".venv" ]; then
              uv venv .venv -p 3.12
            fi
            source .venv/bin/activate

            uv pip install -e .
            uv pip install ninja packaging psutil
            MAX_JOBS=1 uv pip install flash-attn --no-build-isolation
          '';
        };
      });
}
