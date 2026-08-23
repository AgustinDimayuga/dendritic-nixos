{ pkgs, ... }:
  {

  programs.git = {
    enable = true;
  };
  programs.git.settings.user = {
    email = "axocuadi@calpoly.edu";
    name = "AgustinDimayuga";


  };

}
