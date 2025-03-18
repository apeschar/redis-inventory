{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
  }: let
    eachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = eachSystem (system: {
      default = nixpkgs.legacyPackages.${system}.buildGoModule {
        name = "redis-inventory";
        src = ./.;
        vendorHash = "sha256-0PvP5Qv+QobIcGHOGBMmAMYOnrRN/5SwmTAYhTndiQs=";
      };
    });

    checks = eachSystem (system: {
      default =
        nixpkgs.legacyPackages.${system}.runCommand "check" {
          buildInputs = [self.packages.${system}.default];
        } ''
          ${self.packages.${system}.default}/bin/redis-inventory --help > $out
        '';
    });
  };
}
