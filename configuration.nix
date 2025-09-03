{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix ];

  # --- BOOTLOADER ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable Intel microcode updates.
  hardware.cpu.intel.updateMicrocode = config.boot.loader.systemd-boot.enable;

  # --- NETWORKING ---
  networking.hostName = "nixos-kde";
  networking.networkmanager.enable = true;

  # --- TIME, LANGUAGE, and KEYBOARD ---
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  console.keyMap = "us";
  
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:win_space_toggle";
  
  # --- GRAPHICS (KDE Plasma 6 + Wayland on Intel iGPU) ---
  services.xserver.enable = true;
  
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # --- SOUND (Pipewire) ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- USERS ---
  users.users.Sueta = {
    isNormalUser = true;
    description = "Sueta";
    extraGroups = [ "wheel" "networkmanager" ];
    # Sets the initial password to "graf".
    # You will be prompted to change this password on your first login.
    initialPassword = "graf";
  };
  security.sudo.wheelNeedsPassword = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # --- PACKAGES ---
  environment.systemPackages = with pkgs; [
    git
    wget
    firefox
    discord
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.spectacle
    aircrack-ng
    wireshark
    kismet
    nmap
    metasploit
    hydra
  ];

  # --- HARDWARE & SERVICES ---
  hardware.bluetooth.enable = true;
  services.printing.enable = true;

  # --- WAYLAND PORTALS ---
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # --- POWER MANAGEMENT ---
  # The line `services.tlp.enable = true;` was removed
  # because it conflicts with `power-profiles-daemon` which
  # is enabled by default with KDE Plasma.

  system.stateVersion = "25.05";
}
