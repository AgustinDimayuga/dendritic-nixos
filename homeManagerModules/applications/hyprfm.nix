{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.hyprfm.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.ffmpeg # video thumbnails + ffprobe metadata
    pkgs.exiftool # photo EXIF/GPS info
    pkgs.libimobiledevice # iPhone pairing tools (skip if no iPhone)
    pkgs.glib # provides the `gio` command
    pkgs.rclone # cloud drives (skip if you don't need it)
  ];
}
