{pkgs, lib, username, ...}: {
  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.packages =
    (import ../modules/packages.nix {
      inherit pkgs lib;
    })
    ++ (import ../modules/packages-alpine.nix {
      inherit pkgs lib;
    });

  services.gpg-agent.pinentry.package = pkgs.pinentry-curses;
}
