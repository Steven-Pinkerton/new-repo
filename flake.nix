{
  description = "A Remote Machine Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixinate.url = "github:matthewcroughan/nixinate";
  };

  outputs = { self, nixpkgs, nixinate }:
  {
      apps = nixinate.nixinate.x86_64-linux self;
      nixosConfigurations.remote-machine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
#          "${nixpkgs}/nixos/modules/virtualisation/openstack-config.nix"
          (import ./configuration.nix)
          {
            imports = [ "${nixpkgs}/nixos/modules/virtualisation/openstack-config.nix" ];
            _module.args.nixinate =  {
              host = "128.199.11.198";
              sshUser = "root";
              buildOn = "remote";
              Hermetic = true;
            };
          }
        ];
     };
  };
}
