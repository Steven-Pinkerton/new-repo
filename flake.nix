{
  description = "A Remote Machine Flake";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
     };

  outputs = { self, nixpkgs, nixinate, ...}:
  {
      nixosConfigurations.remote-machine = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         modules = [ (import ./configuration.nix) ];
         }
    };
  };