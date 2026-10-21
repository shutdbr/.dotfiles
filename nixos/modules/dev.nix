# Programming: languages, language servers, LaTeX, build tools, AI. The servers
# serve both neovim (nvim/lua/toadvenom/lsp.lua) and Doom.
{ pkgs, ... }:
let
  unstable = import <nixos-unstable> { };
in
{
  environment.systemPackages = with pkgs; [
    # gcc and make also compile Doom's tree-sitter grammars
    gcc
    gnumake
    # npm comes with it. `npm i -g` can't write to the store:
    # npm config set prefix ~/.npm-global, then add ~/.npm-global/bin to PATH
    nodejs
    python3
    texliveMedium # most documents; nix shell nixpkgs#texliveFull for the rest
    proverif # doom/lisp/proverif.el calls it

    # AI coding agents; Codex alone follows nixos-unstable.
    claude-code
    unstable.codex

    # language servers
    clang-tools # clangd
    lua-language-server
    typescript-language-server
    vscode-langservers-extracted # html, css, json
    texlab
  ];
}
