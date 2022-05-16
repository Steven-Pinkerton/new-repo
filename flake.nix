{ config, pkgs, ...}:

{
nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
        experimental-geatures = nix-command flakes
        '';
    };

    system = {
        stateVersion = "21.11";
        };

    time.timeZone = "Europe/Amsterdam";

    services = {
        tailscape.enable = true;
        nginx.enable = true;
        openssh = {
          enable = true;
          passwordAuthentication = false;
          permitRootLogin = "no";
          challengeResponseAuthentication = false;
        };

    environment = {
        variables = {
            EDITOR ="nvim";
            LC_ALL = config.i18n.defaultLocale;
            TERM= "xterm-s56color";
        };
    };

    nixpkgs.config.allowUnfree = true;

        boot.loader.grub.enable = true;
        boot.loaded.grub.version = 2;
        boot.loader.grub.device = "/dev/sda";

        networking.useDHCP = false;
        networking.interfaces.ens33.useDHCP = true;

    i18.defaultLocale = "en_GB.UTF-8";
        console = {
            font = "Lat2-Terminus16";
            keyMap = "uk";
        };

    users.users.steven = {
        isNormalUser = true;
        initalHashedPassword = "$6$2IMeBUr3ehYkkF9p$popywjgNmIsi1pSdE1AtHH29mHjUVPAgJwsxRoAoMt0bEoovw.A5P7Y2wo0xO611JQizf0DCMV9UWIXpGdyxt/";
        extraGroups = [ "wheel" ];
    };

    environment.systemPackages = with pkgs; [
        neovim
    ];
    programs.bash.shellInit = ''
    TERM=xterm
    '';
    } 