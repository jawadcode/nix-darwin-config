{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs = {
        cl-nix-lite.url = "github:r4v3n6101/cl-nix-lite/url-fix";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs @ {
    self,
    home-manager,
    nix-darwin,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    mac-app-util,
    nixpkgs,
  }: let
    system = "x86_64-darwin";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    configuration = {pkgs, ...}: {
      users = {
        knownUsers = ["qak"];
        users.qak = {
          uid = 501;
          shell = pkgs.fish;
          packages = with pkgs; [
            lsd
            bat
            helix
            nil
            alejandra
            pyright
            python314
            yt-dlp
            ffmpeg-full
            imagemagick
          ];
        };
      };

      environment.variables = {
        EDITOR = "hx";
      };

      environment.systemPackages = with pkgs; [git wget curl ripgrep fd];

      fonts.packages = with pkgs; [
        roboto
        ibm-plex
        (iosevka-bin.override {variant = "SS07";})
        (callPackage ./iosevka-term-ss07-nerd-font.nix {})
      ];

      programs.fish.enable = true;

      homebrew = {
        enable = true;
        brews = [];
        casks = ["microsoft-office" "skim" "processing"];
      };

      services.aerospace.enable = true;

      security.pam.services.sudo_local.touchIdAuth = true;

      nixpkgs.hostPlatform = system;
      system.primaryUser = "qak";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
    };
  in {
    darwinConfigurations."Jawads-MacBook-Air" = nix-darwin.lib.darwinSystem {
      inherit pkgs;
      modules = [
        {
          nix = {
            optimise.automatic = true;
            settings.experimental-features = "nix-command flakes";
          };
        }
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = false;

            # User owning the Homebrew prefix
            user = "qak";

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
          };
        }
        # Optional: Align homebrew taps config with nix-homebrew
        ({config, ...}: {
          homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
        })
        configuration
        mac-app-util.darwinModules.default
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            sharedModules = [mac-app-util.homeManagerModules.default];
            useGlobalPkgs = true;
            useUserPackages = true;
            users.qak = import ./home.nix;
          };
          users.users.qak.home = "/Users/qak";
        }
      ];
      specialArgs = {inherit inputs;};
    };
  };
}
