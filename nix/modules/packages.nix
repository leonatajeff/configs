{ config, pkgs, ...}:

{
 environment.systemPackages = with pkgs; [
   git
   tree
   vim
   neovim
   ffmpeg
   tmux
 ];

 fonts.packages = with pkgs; [
   nerd-fonts.iosevka-term
 ];
}
