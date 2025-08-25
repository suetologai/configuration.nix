# This is the main configuration file for your NixOS system.
# It's where you declaratively define the entire state of your machine.

{ config, pkgs, ... }:

{
  # Import settings from your hardware-specific configuration.
  imports =
    [ ./hardware-configuration.nix ];

  # --- BOOTLOADER (systemd-boot for UEFI) ---
  # This is the modern, default, and most reliable method for UEFI systems.
  # It does NOT require specifying a device like "/dev/sda", avoiding boot issues.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # For your i7-3770, it's good practice to load the latest microcode updates.
  hardware.cpu.intel.updateMicrocode = true;

  # --- NETWORKING ---
  # Set a hostname for your machine.
  networking.hostName = "nixos-kde";
  # Enable NetworkManager. It's the standard tool for managing network connections.
  networking.networkmanager.enable = true;

  # --- TIME, LANGUAGE, and KEYBOARD ---
  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Set the main system language to English.
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Configure the console keymap (for TTY, before graphics start).
  console.keyMap = "us";
  
  # Configure keyboard layouts for the graphical session.
  services.xserver = {
    layout = "us,ru";
    xkbOptions = "grp:win_space_toggle";
  };
  
  # --- GRAPHICAL DESKTOP ENVIRONMENT (Minimal KDE Plasma on Wayland) ---
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.wayland.enable = true;

  # Enable KDE Plasma as the Desktop Manager.
  services.xserver.desktopManager.plasma5.enable = true;

  # Integrated Intel GPU driver.
  services.xserver.videoDrivers = [ "modesetting" ];

  # --- SOUND SYSTEM (PipeWire) ---
  sound.enable = true;
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
    # Password will be set manually after installation.
  };
  security.sudo.wheelNeedsPassword = true;

  # --- SYSTEM PACKAGES ---
  environment.systemPackages = with pkgs; [
    git
    wget
    firefox
    # Correct, full package names for KDE apps
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
    # Correct, full package name for the KDE portal
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
