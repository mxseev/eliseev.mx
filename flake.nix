{
  description = "eliseev.mx Astro website";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs supportedSystems;
      nixpkgsFor = system: nixpkgs.legacyPackages.${system};

      packageJson = builtins.fromJSON (builtins.readFile ./package.json);
      source = lib.cleanSourceWith {
        src = ./.;
        filter =
          path: type:
          !(
            type == "directory"
            && builtins.elem (baseNameOf path) [
              ".astro"
              ".git"
              "dist"
              "node_modules"
              "result"
            ]
          )
          && !(builtins.elem (baseNameOf path) [
            ".env"
            ".env.production"
          ]);
      };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor system;
          nodejs = pkgs.nodejs_latest;
          pnpm = pkgs.pnpm;
          pnpmDeps = pkgs.fetchPnpmDeps {
            pname = packageJson.name;
            inherit (packageJson) version;
            src = source;
            inherit pnpm;
            fetcherVersion = 4;
            hash = "sha256-JRsW+2n4GAoZ1deiL1tMfkm3EDHgOqJ9yPNfOgN956A=";
          };
          website = pkgs.stdenv.mkDerivation {
            pname = packageJson.name;
            inherit (packageJson) version;
            src = source;

            nativeBuildInputs = [
              nodejs
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
              makeWrapper ${nodejs}/bin/node $out/bin/eliseev-mx \
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
        in
        {
          default = website;
          inherit website;
        }
      );

      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.services.eliseevmx;
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
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
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];

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

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.nodejs_latest
              pkgs.pnpm
            ];
          };
        }
      );
    };
}
