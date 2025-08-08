{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true;
        };
        
        fhs = pkgs.buildFHSEnv {
          name = "cuda-env";
          targetPkgs = pkgs: with pkgs; [
            cudaPackages.cuda_cudart
            cudaPackages.cudatoolkit
            cudaPackages.cuda_nvcc
            cudaPackages.cudnn
            libuv
            uv
            gcc13
            glibc
            python312
            # Additional libraries that might be needed
            zlib
            stdenv.cc.cc.lib
            libGL
            libGLU
            xorg.libX11
            xorg.libXi
            xorg.libXmu
            xorg.libXext
            xorg.libXt
            xorg.libXrender
            ncurses5
          ];
          
          multiPkgs = pkgs: with pkgs; [
            zlib
          ];
          
          runScript = "bash";
          
          profile = ''
            export CUDA_PATH=${pkgs.cudatoolkit}
            export LD_LIBRARY_PATH=${pkgs.cudatoolkit}/lib:${pkgs.cudaPackages.cudnn}/lib:$LD_LIBRARY_PATH
            export LIBRARY_PATH=${pkgs.cudatoolkit}/lib:$LIBRARY_PATH
            export CUDA_HOME=${pkgs.cudatoolkit}
            export TORCHINDUCTOR_COMPILE_THREADS=4
            
            # Initialize virtual environment
            if [ ! -d ".venv" ]; then
              uv venv .venv -p 3.12
            fi
            source .venv/bin/activate
            
            uv pip install -e .
            uv pip install ninja packaging psutil
            MAX_JOBS=1 uv pip install flash-attn --no-build-isolation
          '';
        };
      in {
        devShells.default = fhs.env;
      });
}
