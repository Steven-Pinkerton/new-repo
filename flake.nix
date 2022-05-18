{
  description = "A Remote Machine Flake";

inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  };

  outputs = { self, nixpkgs, ...}: 
  {

  nixosConfigurations.remote-machine = {
    mySystem = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = 
      [ import ./configuration.nix ];
    };
  };
};
}