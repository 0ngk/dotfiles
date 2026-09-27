{pkgs, username, ...}: {
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  services.gpg-agent.pinentry.package = pkgs.pinentry_mac;
}
