{ config, pkgs, ... }:
{
  nix =
    {
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
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

  services.openssh.enable = true;

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
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtWv2ob5XjdbrGZ39WuDFWP3lU8JGVzcFHDKlbX0vlOXb2N8se3xYrExuvMIMnGqctklpO2n9r4N9+XpES+S7IsnQ80eZhxPfZ3GEb7B4JFfPxPZn7OMAjH+8pWfPOoeetgreM6vg19RvruhVX5bPqxtuzK5Kw2WRluLx4PeL1wjeHwoiEb4G3N21bDT7FDTbjZBEdPV4uu0WfeM9NJh2OgYgVdMl/Q/NdnJKCwXSGxEt45DSdZDfWOuKTNxoBQKnA50aTm4dEPjMjr1ab/ztu3fJ1h5pJHu3Z000wAbWF+ngOiEvrMj/sF67NLSIqpcSosno2q3iNVVIgR+OlDpN4UdSVYUZv9sBQq1+B3GUzwobLPBWUlVU8U8nXNizapp4kMMxHIBN0vMenPOiQ3mFyggLIMVJ54crh5pTXESRbuh1UfXbFOXPvwAmVLj8DVzFgnk9nRP9yNLm+fl/0pIzy6dvsBc5D5jHxKdLdSsC8tQ1BkD14fesPZOOoQN89H8U= steven@Steven"
    ];
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
