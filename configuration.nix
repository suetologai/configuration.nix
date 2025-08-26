{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix ];

  # --- BOOTLOADER (systemd-boot for UEFI) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  hardware.cpu.intel.updateMicrocode = true;

  # --- NETWORKING ---
  networking.hostName = "nixos-kde";
  networking.networkmanager.enable = true;

  # --- TIME, LANGUAGE, and KEYBOARD ---
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  
  console.keyMap = "us";
  
  # NEW: Modern, global keyboard configuration for both SDDM and Wayland session.
  services.keyboard = {
    layout = "us,ru";
    options = [ "grp:win_space_toggle" ];
  };
  
  # --- GRAPHICAL DESKTOP ENVIRONMENT (Minimal KDE Plasma on Wayland) ---
  services.xserver.enable = true;
  
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.wayland.enable = true;
  # NEW: Force default session to Wayland.
  services.xserver.displayManager.sddm.defaultSession = "plasmawayland";

  services.xserver.desktopManager.plasma5.enable = true;

  services.xserver.videoDrivers = [ "modesetting" ];

  # --- SOUND SYSTEM (PipeWire) ---
  # sound.enable = true; was removed as it's deprecated.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- USER ACCOUNTS ---
  users.users.Sueta = {
    isNormalUser = true;
    description = "Sueta";
    extraGroups = [ "wheel" "networkmanager" ];
    initialHashedPassword = "$6$ВАШ";
  };
  security.sudo.wheelNeedsPassword = true;

  # --- SYSTEM PACKAGES ---
  environment.systemPackages = with pkgs; [
    git
    wget
    firefox
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.spectacle
  ];

  # --- HARDWARE & SERVICES ---
  hardware.bluetooth.enable = false;
  services.printing.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  # --- NIX PACKAGE MANAGER SETTINGS ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  system.stateVersion = "25.05";
}
