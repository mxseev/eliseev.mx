{
  description = "eliseev.mx Astro website";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {self, nixpkgs, ...}: let
    supportedSystems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      packageJson = builtins.fromJSON (builtins.readFile ./package.json);
      pnpm = pkgs.pnpm_10;
      source = pkgs.lib.cleanSourceWith {
        src = ./.;
        filter = path: type:
          !(type == "directory" && builtins.elem (baseNameOf path) [
            ".astro"
            ".git"
            "dist"
            "node_modules"
            "result"
          ]) && !(builtins.elem (baseNameOf path) [".env" ".env.production"]);
      };
      pnpmDeps = pkgs.fetchPnpmDeps {
        pname = packageJson.name;
        inherit (packageJson) version;
        src = source;
        inherit pnpm;
        fetcherVersion = 4;
        hash = "sha256-VHm7rcIc20Vk/knH/tmV+HA8BD2AE/byZWi7BpT1qOU=";
      };
    in rec {
      default = website;

      website = pkgs.stdenv.mkDerivation {
        pname = packageJson.name;
        inherit (packageJson) version;
        src = source;

        nativeBuildInputs = [
          pkgs.nodejs_22
          pnpm
          pkgs.pnpmConfigHook
          pkgs.makeWrapper
        ];

        inherit pnpmDeps;

        buildPhase = ''
          runHook preBuild
          pnpm build
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/lib/eliseev-mx $out/bin
          cp -r dist node_modules $out/lib/eliseev-mx/
          makeWrapper ${pkgs.nodejs_22}/bin/node $out/bin/eliseev-mx \
            --add-flags "$out/lib/eliseev-mx/dist/server/entry.mjs" \
            --set-default HOST 0.0.0.0 \
            --set-default PORT 4321

          runHook postInstall
        '';

        meta = {
          description = "Personal website at eliseev.mx";
          mainProgram = "eliseev-mx";
          platforms = supportedSystems;
        };
      };
    });

    nixosModules.default = {config, lib, pkgs, ...}: let
      cfg = config.services.eliseevmx;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in {
      options.services.eliseevmx = {
        enable = lib.mkEnableOption "eliseev.mx website";

        host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = "Address on which the web server listens.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 4321;
          description = "Port on which the web server listens.";
        };
      };

      config = lib.mkIf cfg.enable {
        systemd.services.eliseevmx = {
          description = "eliseev.mx website";
          after = ["network.target"];
          wantedBy = ["multi-user.target"];

          environment = {
            HOST = cfg.host;
            PORT = toString cfg.port;
          };

          serviceConfig = {
            DynamicUser = true;
            ExecStart = lib.getExe package;
            Restart = "on-failure";
          };
        };
      };
    };

    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = [pkgs.nodejs_22 pkgs.pnpm_10];
      };
    });
  };
}
