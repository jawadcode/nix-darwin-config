{
  # config,
  pkgs,
  ...
}: let
  getExe = pkgs.lib.meta.getExe;
  getExe' = pkgs.lib.meta.getExe';
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "qak";
  home.homeDirectory = "/Users/qak";
  home.packages = with pkgs; [
    nix-your-shell
    emacs-lsp-booster
    discord
    logisim-evolution
    rars
  ];

  programs.fish = {
    enable = true;
    shellAbbrs = {
      tree = "lsd --tree";
      clean-crap = "nix-store --optimise && nix-collect-garbage -d && sudo nix-store --optimise && sudo nix-collect-garbage -d && sudo darwin-rebuild switch --flake ~/nix-darwin-config";
    };
    interactiveShellInit = ''
      function fish_hybrid_key_bindings --description \
      "Vi-style bindings that inherit emacs-style bindings in all modes"
          for mode in default insert visual
              fish_default_key_bindings -M $mode
          end
          fish_vi_key_bindings --no-erase
      end

      set -g fish_key_bindings fish_hybrid_key_bindings

      ${getExe pkgs.nix-your-shell} fish | source
    '';
  };

  programs.nix-index.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.shell.enableFishIntegration = true;

  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisplayBookmarksToolbar = "newtab";
      OfferToSaveLogins = false;
      HardwareAcceleration = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        Exceptions = [];
      };
      NoDefaultBookmarks = true;
      PromptForDownloadLocation = true;
      AutofillCreditCardEnabled = true;
    };
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        front_end = "WebGpu",
        color_scheme = "Apple System Colors",
        font = wezterm.font_with_fallback({ "IosevkaTermSS07 Nerd Font", "Apple Color Emoji" }),
        font_size = 15.5,
        hide_tab_bar_if_only_one_tab = true,
      }
    '';
  };

  # Doesn't exist????
  # programs.discord.enable = true;

  programs.helix = {
    enable = true;
    defaultEditor = true;
    languages = {
      language = let
        applyCommon = lang:
          {
            indent = {
              tab-width = 4;
              unit = "    ";
            };
            auto-format = true;
          }
          // lang;
      in
        map
        applyCommon
        [
          {
            name = "python";
            language-servers = ["pyright"];
          }
          {
            name = "c";
          }
          {
            name = "cpp";
          }
        ]
        ++ [
          {
            name = "nix";
            formatter = {
              command = "alejandra";
            };
          }
        ];
    };
    settings = {
      theme = "dark_plus";
      editor = {
        bufferline = "always";
        lsp.display-inlay-hints = true;
        statusline = {
          left = ["mode" "spinner"];
          center = ["file-name"];
          right = ["diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
          separator = "│";
        };
      };
      keys.normal = {
        "S-tab" = "goto_next_buffer";
        "A-tab" = "goto_previous_buffer";
      };
    };
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    extraPackages = epkgs: with epkgs; [treesit-grammars.with-all-grammars];
  };

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    profiles.default = {
      userSettings = {
        "editor.fontFamily" = "'Iosevka Term SS07'";
        "editor.fontSize" = 18;
        "rust-analyzer.server.path" = "rust-analyzer";
      };
      extensions = with pkgs.vscode-extensions; [
        astro-build.astro-vscode
        mkhl.direnv
        rust-lang.rust-analyzer
        myriad-dreamin.tinymist
        ocamllabs.ocaml-platform
        svelte.svelte-vscode
        vscodevim.vim
      ];
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
    };
  };

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
