{
  config,
  lib,
  pkgs,
  ...
}:

{

  environment.systemPackages = with pkgs; [
    lazygit
    gcc
    fzf
    ripgrep
    fd
    sqlite
    ast-grep
    python3
    python313Packages.httplib2
    python313Packages.urllib3
    python313Packages.requests
    luarocks-nix
    lua
    unzip
    php
    ghostscript
    nodejs
    tree-sitter
    lua-language-server
    stylua
    fastfetch
    clang-tools
    neovim-node-client
    rustc
    cargo
    nixfmt

  ];

}
