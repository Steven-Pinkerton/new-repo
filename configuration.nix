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

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "steven.a.pinkerton@platonic.systems";
  services =
  {
    tailscale.enable = true;

    oauth2_proxy = {
      enable = true;
      provider = "google";
      clientID = "914818019586-2l79nadchde09crb29u5lkdq7q5h1pa7.apps.googleusercontent.com";
      clientSecret = "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";
      email.addresses = "*@platonic.systems";
      cookie = {
        domain = "diurnum.platonic.systems";
        secret = "zEPbQ6FNd7aCFcjBN5t3hfiJDjWFTuClIxpK1K_xjco";
      };
      redirectURL = "https://diurnum.platonic.systems/oauth2/callback";     #This is the endpoint I think.
      upstream= "http://127.0.0.1:8888";
      setXauthrequest = true;
      #cookie_domains=[".website.com"]
      #cookie_secure="false"
      #cookie_samesite="lax"
      # redirect_url="https://my.website.com/oauth2/callback"
      # upstreams="http://127.0.0.1:8888/" # My website server
      # set_xauthrequest=true
      # upstreams=["file:///dev/null"]  THIS HERE IS THE ONLY mysterious part left
    };


    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;


      virtualHosts."diurnum.platonic.systems" = {
        enableACME = true;
        forceSSL = true;

          locations."/oauth2/" = {
            proxyPass = "http://127.0.0.1:4180";
            extraConfig = ''
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-Ip $remote_addr;
                  proxy_set_header X-Scheme $scheme;
                  proxy_set_header X-Auth-Request-Redirect "https://diurnum.platonic.systems";
                  ''; #may need $request_uri here
          };

          locations."/oauth2/auth" = {
            proxyPass = "http://127.0.0.1:4180";
            extraConfig = ''
                    proxy_set_header Host             $host;
                    proxy_set_header X-Real-IP        $remote_addr;
                    proxy_set_header X-Scheme         $scheme;
                    proxy_set_header Content-Length   "";
                    proxy_pass_request_body           off;
                '';
          };
          
          locations."/" = {
            proxyPass = "http://127.0.0.1:8888"; #website location
            extraConfig = ''
                  error_page 401 = /oauth2/sign_in;
                  proxy_set_header Host             $host;
                  proxy_set_header X-Real-IP        $remote_addr;
                  proxy_set_header X-Scheme         $scheme;
                  proxy_set_header Content-Length   "";
                  proxy_pass_request_body           off;
                  auth_request_set $token  $upstream_http_x_auth_request_access_token;
                  proxy_set_header X-Access-Token $token;
                  auth_request_set $auth_cookie $upstream_http_set_cookie;
                  add_header Set-Cookie $auth_cookie;
                  auth_request_set $auth_cookie_name_upstream_1 $upstream_cookie_auth_cookie_name_1;
                  
                  if ($auth_cookie ~* "(; .*)") {
                    set $auth_cookie_name_0 $auth_cookie_name_0;
                    set $auth_cookie_name_1 "auth_cookie_name_1=$auth_cookie_name_upstream_1$1";
                   }
                  if ($auth_cookie_name_upstream_1) {
                    add_header Set-Cookie $auth_cookie_name_0;
                    add_header Set-Cookie $auth_cookie_name_1;
                    }

                  proxy_set_header X-Forwarded-For $remote_addr;
                  # This line is error
                  #proxy_set_header Host $http_host;
                  '';
               };
          #      #auth_request /oauth2/auth;
          #      # proxy_set_header Host $host;
          #      #proxy_set_header X-Real-IP $remote_addr;
          #      # proxy_set_header X-User $user;
          #      # auth_request_set $user   $upstream_http_x_auth_request_user;
          #      # auth_request_set $email  $upstream_http_x_auth_request_email;
          #;
      };
    };
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

  users.users.root =
  {
    isNormalUser = true;
    initialHashedPassword = "test";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDeppey98/6oV5sXi/fy8fqxlc+tyYQlxiuVOhx8IcvZ Chloe Kever (git.platonic.systems)"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILMaYwUX4MK8kWv0EW0ALvNMDAgIMvaLehvTSN28gf4R Chloe Kever (git.platonic.systems)"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBhiyE9bWby5TFXruner51NhKMQ3BPU0c038J6Aw2rD9 Chloe Kever (git.platonic.systems)"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK3TTLUhxTyEEPDxZlSM5v6aGwJ8vHadfrrhkARrNh/j Chloe Kever (git.platonic.systems)"
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcmzPcybQwfyCE7RvrQaoEFS7HzDjP0QUvxyI7/GR3S Chloe Kever (git.platonic.systems)"
    ];
  };

  environment.systemPackages = with pkgs;
  [
    neovim
  ];

  networking.firewall.allowedTCPPorts = [ 8080 9090 ];

  programs.bash.shellInit =
     ''
    TERM=xterm
     '';

}