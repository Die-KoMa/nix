flakes: final: prev:
let
  inherit (final) system;
  inherit (prev.lib) versionOlder getVersion mapAttrs;
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
  neovim-thelegy = flakes.qed.packages.${system}.qed;
  inxi-full = final.inxi.override { withRecommends = true; };
}
