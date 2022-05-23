{ config, pkgs, ... }:
{
  nix =
  {
    package = pkgs.nixFlakes;
    extraOptions = ''
        experimental-geatures = nix-command flakes
        '';
  };

  system =
  {
    stateVersion = "21.11";
  };

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_GB.UTF-8";


  services =
  {
    tailscale.enable = true;
    nginx.enable = true;
  };

  environment =
  {
    variables =
    {
        EDITOR ="nvim";
        LC_ALL = config.i18n.defaultLocale;
        TERM= "xterm-256color";
    };
  };

  nixpkgs.config.allowUnfree = true;

  networking =
  {
    useDHCP = false;
    interfaces.ens33.useDHCP = true;
  };


  console =
  {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };
  users.users.steven =
  {
    isNormalUser = true;
    initialHashedPassword = "test";
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs;
  [
    neovim
  ];

  programs.bash.shellInit =
     ''
    TERM=xterm
     '';
}