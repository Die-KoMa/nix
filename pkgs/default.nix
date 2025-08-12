flakes: final: prev:
let
  inherit (prev) lib system;
  inherit (lib) versionOlder getVersion mapAttrs;
  unstable = flakes.nixpkgs-unstable.legacyPackages.${system};

  atLeastOrOverride =
    from: pkg: version:
    if versionOlder (getVersion prev.${pkg}) version then from.${pkg} else prev.${pkg};
  overrideOlder' = from: mapAttrs (atLeastOrOverride from);
  overrideOlder = overrideOlder' unstable;
in
(overrideOlder {
  element-desktop = "1.11.109";
  matrix-synapse-unwrapped = "1.135.2";
})
// {
}
