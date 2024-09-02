# lndir (simple)

This is similar to xorg's `lndir` utility, but optimized for usage within nixpkgs.
Original motivation was to remove `xorg.lndir` from being in the `symlinkJoin`
trivial builder of nixpkgs. Since `symlinkJoin` is used in the bootstrapping
of stdenv, it creates a dependency on an additional 20-40 derivations

Differences from xorg's lndir include:
- Only dependencies are bash and gnu coreutils
- Symlink locations are all resolved to absolute paths
- `-silent` is the default behavior
- `-ignorelinks` (deprecated) and `-withrevifo` (not relevant) are ignored
- `<from dir>` and `<destination dir>` must be defined
- `<destination dir>` will be created if doesn't already exist
- If `<from dir>` is a file, then just a symlink is created
