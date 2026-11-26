# list recipes
default:
    @just --list

# re-evaluate the examples on every change
dev:
    watchexec -e nix -- just test

# evaluate the example configurations
test:
    nix build .#checks.x86_64-linux.examples --no-link

# format all files
fmt:
    nix fmt

# everything CI checks
check:
    nix flake check
