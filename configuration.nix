{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix ];

  # --- BOOTLOADER ---
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
  services.keyboard = {
    layout = "us,ru";
    options = [ "grp:win_space_toggle" ];
  };
  
  # --- GRAPHICS (KDE + Wayland) ---
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.wayland.enable = true;
  services.xserver.displayManager.sddm.defaultSession = "plasmawayland";

  services.xserver.desktopManager.plasma5.enable = true;

  services.xserver.videoDrivers = [ "modesetting" "intel" "nvidia" ];

  # --- SOUND ---
  hardware.pulseaudio.enable = false;
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
    initialHashedPassword = "$6$ВАШ";
  };
  security.sudo.wheelNeedsPassword = true;

  # --- PACKAGES ---
  environment.systemPackages = with pkgs; [
    # Базовые
    git
    wget
    firefox
    discord
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.spectacle

    # Wi-Fi и сетевой анализ
    aircrack-ng
    wireshark
    kismet
    nmap

    # Хакинг / пентест
    metasploit
    hydra
  ];

  # --- HARDWARE & SERVICES ---
  hardware.bluetooth.enable = true;
  services.printing.enable = true;

  # --- WAYLAND PORTALS ---
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-kde ];
  };

  # --- POWER MANAGEMENT ---
  services.tlp.enable = true;
}

  
  system.stateVersion = "25.05";
}
