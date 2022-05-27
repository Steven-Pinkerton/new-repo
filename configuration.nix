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

      nginx = {
        enable = true;
      
        virtualHosts."dirunum.platonic.systems" = {
            auth_request = "/validate";

            location."/validate" = {
                proxyPass = "http://vouch.dirunum.platonic.systems:9090;";
                extraConfig = ''
                    proxy_set_request_body off;
                    auth_request_set $auth_resp_x_vouch_user $upstream_http_x_vouch_user;
                    #auth_request_set $auth_resp_jwt $upstream_http_x_vouch_jwt;
                    #auth_request_set $auth_resp_err $upstream_http_x_vouch_err;
                    #auth_request_set $auth_resp_failcount$upstream_http_x_vouch_failcount;
            '';
            };
            
            #This may go in the extra-config we will ask john.
            error_page."404" = "@error401";

            location."@error401" = {
                return."302" = "https://vouch.dirunum.platonic.systems:9090/login?url=$scheme://$http_host$request_uri&lasso-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;";
            };
            };
        };
    };

  vouchConfig = {
              vouch = {
                  domains = "dirunum.platonic.systems";
                  whiteList = "*@platonic.systems";
                  cookie.domain = "dirunum.platonic.systems";
          };
        };
        
          oauth = rec {
            provider = "google";
            client_id = "914818019586-2l79nadchde09crb29u5lkdq7q5h1pa7.apps.googleusercontent.com";
            client_secret = "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";
            callback_url = "https://vouch.dirunum.platonic.systems:9090/auth";
            preferredDomain = "https://dirunum.platonic.systems";
        };


    serviceConfig = {
                  ExecStart = 
                ''
                ${pkgs.vouch-proxy}/bin/vouch-proxy \
                -config ${{ppkgs.formats.yaml {}).generate "config.yml" vouchConfig}
                '';
            Restart = "on-failure";
            RestartSec = 5;
            WorkingDirectory = "/var/lib/vouch-proxy";
              RuntimeDirectory = "vouch-proxy";

            User = "vouch-proxy";
            Group = "vouch-proxy";
            SartLimitBurst = 3;
          };

          users.users.vouch-proxy = {
          isSystemUser = true;
          group = "vouch-proxy";
  };
  users.groups.vouch-proxy = { };

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
    vouch-proxy 
  ];

  programs.bash.shellInit =
     ''
    TERM=xterm
     '';
}