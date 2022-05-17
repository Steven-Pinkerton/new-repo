{
  description = "A Remote Machine Flake";

inputs = {
  nixpkgs.url = "github.com/NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs, ...}: {
  nixosConfigurations = {
    mySystem = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
};
}