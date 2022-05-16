{ 
  outputs = { self, nixpkgs, ...}: {
  nixosConfigurations = {
    mySystem = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
};
}