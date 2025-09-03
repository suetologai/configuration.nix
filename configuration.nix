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
  networking.hostName = "nixos-kde"; # Feel free to change this
  networking.networkmanager.enable = true;

  # --- TIME, LANGUAGE, and KEYBOARD ---
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  console.keyMap = "us";
  
  # Set keyboard layouts for the graphical session.
  services.xserver.layout = "us,ru";
  services.xserver.xkbOptions = "grp:win_space_toggle"; # Switch layouts with Win+Space
  
  # --- GRAPHICS (KDE Plasma 6 + Wayland on Intel iGPU) ---
  services.xserver.enable = true;
  
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # --- SOUND (Pipewire) ---
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
    initialHashedPassword = "$6$YOUR_HASHED_PASSWORD_HERE";
  };
  security.sudo.wheelNeedsPassword = true;

  # Allow unfree packages if needed (e.g., for discord).
  nixpkgs.config.allowUnfree = true;

  # --- PACKAGES ---
  environment.systemPackages = with pkgs; [
    # Basic utils
    git
    wget
    firefox
    discord

    # KDE packages
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.spectacle

    # Wi-Fi and network analysis
    aircrack-ng
    wireshark
    kismet
    nmap

    # Hacking / pentesting
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
  # REMOVED: `services.tlp.enable = true;` has been removed.
  # KDE Plasma 6 automatically enables and uses `power-profiles-daemon` by default.
  # Enabling both causes a conflict. The default daemon is recommended for desktop integration.
  
  system.stateVersion = "25.05";
}
