{
  description = "bo nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    system = "aarch64-darwin";
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [ 
	 alacritty
	 lazygit
	 neovim
	 git
	 curl
	 tmux
	 mkalias
	 nix-zsh-completions
	 nodejs_20
	 vscode
	 yarn
	 tree
	 prettierd
	 postgresql
	 postgresql16Packages.postgis
	 corepack
	 aerospace
	 ffmpeg
	 kubectl
	 docker
	 awscli2
      ];

      system.activationScripts.applications.text = let
  	env = pkgs.buildEnv {
    	name = "system-applications";
    	paths = config.environment.systemPackages;
    	pathsToLink = "/Applications";
  	};
      in
  	pkgs.lib.mkForce ''
  	# Set up applications.
  		echo "setting up /Applications..." >&2
  		rm -rf /Applications/Nix\ Apps
  		mkdir -p /Applications/Nix\ Apps
  		find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
  		while read -r src; do
    			app_name=$(basename "$src")
    			echo "copying $src" >&2
    			${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
  		done
      	'';

      system.defaults = {
	dock.autohide = true;
	finder.FXPreferredViewStyle = "clmv";
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      programs.zsh.enable = true;
      nix.enable = false;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;
      
      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#SOMEUSER
    darwinConfigurations."SOMEUSER" = nix-darwin.lib.darwinSystem {
      system = system;
      modules = [ configuration
      home-manager.darwinModules.home-manager
	{
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # home-manager.users.jdoe = ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }

      ];
    };
  };
}
