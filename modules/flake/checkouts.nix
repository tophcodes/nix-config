# Out-of-store symlinks (ADR-016) point into a working copy, so the tracked
# file is the live file. Modules from more than one flake link payload this
# way, and each flake has its own working copy. `checkouts` maps the store
# path of a flake's source to that working copy; every flake whose modules
# link payload adds its own entry.
{
  config,
  lib,
  ...
}: let
  inherit (config) checkouts;
in {
  options = {
    checkouts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Working-copy directory per flake, keyed by the store path of the flake's source.";
    };

    # Declared as a lazy attribute set so that more than one module can add
    # helpers to `flake.lib`.
    flake.lib = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
      description = "Helpers for flake-parts modules, by name.";
    };
  };

  config.flake.lib = rec {
    # Working-copy path of a source path inside one of the flakes in
    # `checkouts`. A path literal in a flake module resolves against the store
    # copy, so the store prefix is replaced by the working-copy root.
    #
    # Rejects paths from any other source rather than concatenating: the root
    # would otherwise be prepended to an already-absolute path, and the result
    # is a dangling symlink that only surfaces when something reads it.
    repoPath = p: let
      path = toString p;
      root = lib.findFirst (r: lib.hasPrefix "${r}/" path) null (lib.attrNames checkouts);
    in
      if root == null
      then throw "repoPath: ${path} is not inside a flake listed in `checkouts`"
      else checkouts.${root} + lib.removePrefix root path;

    aspects = {
      # Home-manager module linking each `target = ./source` pair to its working
      # copy. Returns a module rather than a source value because
      # `mkOutOfStoreSymlink` needs `pkgs`, which only exists once the module is
      # evaluated. This keeps that plumbing out of every aspect.
      #
      # Targets are home-relative: ".config/zed", ".claude/agents".
      mkSymlinks = mapping: {config, ...}: {
        home.file =
          lib.mapAttrs (_: source: {
            source = config.lib.file.mkOutOfStoreSymlink (repoPath source);
          })
          mapping;
      };
    };
  };
}
