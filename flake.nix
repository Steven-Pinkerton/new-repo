{
  description = "A Remote Machine Flake";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
      nixinate.url = "github:matthewcroughan/nixinate";
     };

  outputs = { self, nixpkgs, nixinate }:
  {
      apps = nixinate.nixinate.x86_64-linux self;
      nixosConfigurations.remote-machine = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         
         modules = [ 
           (import 
           ./configuration.nix)
           <nixpkgs/nixos/modules/virtualisation/openstack-config.nix> 
         
           {
             _module.args.nixinate =  {
               host = "193.16.42.17";
               sshUser = "Steven";
               buildOn = "remote";
             }
           }
         ];
  };
};
}