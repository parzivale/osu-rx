{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
  # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake {inherit inputs;} (top @ {
      config,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        # ...
      ];
      perSystem = {
        config,
        pkgs,
        ...
      }: {
        packages = rec {
          osurx = pkgs.buildDotnetModule {
            pname = "osurx";
            version = "1.0.0";
            src = ./.;
            projectFile = "osu!rx/osu!rx.csproj";
            nugetDeps = ./deps.json;
            dotnet-sdk = pkgs.dotnet-sdk_8;
            dotnet-runtime = pkgs.dotnet-runtime_8;

            # Cross-target Windows
            selfContainedBuild = true;
            runtimeId = "win-x64";

            executables = []; # skip Linux wrapper scripts
          };
          default = osurx;
        };
      };
    });
}
