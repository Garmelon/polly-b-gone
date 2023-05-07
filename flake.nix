{
  outputs = { self, nixpkgs }:
    let forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in {
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in rec {
          default = polly-b-gone;
          polly-b-gone = pkgs.stdenv.mkDerivation {
            pname = "polly-b-gone";
            version = "2020-06-06";
            src = ./.;

            nativeBuildInputs = with pkgs; [ copyDesktopItems ];
            buildInputs = with pkgs; [ libGL libGLU glew freeglut SDL SDL_mixer SDL_image tinyxml ];

            desktopItems = [
              (pkgs.makeDesktopItem {
                name = "polly-b-gone";
                icon = "polly-b-gone";
                exec = "polly-b-gone";
                desktopName = "Polly-B-Gone";
                categories = [ "Game" "ArcadeGame" ];
              })
            ];

            installPhase = ''
              runHook preInstall

              mkdir -p $out/bin
              mv bin/main $out/bin/polly-b-gone
              mkdir -p $out/share/polly-b-gone
              mv resources/* $out/share/polly-b-gone

              install -Dm444 ${./icon_16.png} $out/share/icons/hicolor/16x16/apps/polly-b-gone.png
              install -Dm444 ${./icon_32.png} $out/share/icons/hicolor/32x32/apps/polly-b-gone.png
              install -Dm444 ${./icon_128.png} $out/share/icons/hicolor/128x128/apps/polly-b-gone.png
              install -Dm444 ${./icon_256.png} $out/share/icons/hicolor/256x256/apps/polly-b-gone.png

              runHook postInstall
            '';

            # SDL files are imported directly as "SDL_xyz.h", not as "SDL/SDL_xyz.h". In
            # addition, SDL stopped adding any directories to the include paths on the
            # latest unstable.
            # TODO Remove first argument again later
            NIX_CFLAGS_COMPILE = [
              "-I${pkgs.lib.getDev pkgs.SDL}/include"
              "-I${pkgs.lib.getDev pkgs.SDL}/include/SDL"
            ];
          };
        }
      );
    };
}
