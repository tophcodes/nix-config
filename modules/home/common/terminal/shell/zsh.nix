{config, ...}: {
  # fish is the login shell; zsh only needs to exist so that non-interactive
  # `zsh -c` (macOS default, editors, agents) still sees the environment.
  # Enabling it makes HM write ~/.zshenv, which sources hm-session-vars.sh —
  # otherwise EDITOR and friends only ever existed inside fish.
  programs.zsh = {
    enable = true;

    inherit (config.home) shellAliases;

    history.path = "${config.xdg.dataHome}/zsh/history";
  };
}
