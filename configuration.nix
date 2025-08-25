# This is the main configuration file for your NixOS system.
# It's where you declaratively define the entire state of your machine.

{ config, pkgs, ... }:

{
  # Import settings from your hardware-specific configuration.
  imports =
    [ ./hardware-configuration.nix ];

  # --- BOOTLOADER ---
  # We use the GRUB bootloader.
  boot.loader.grub.enable = true;
  # IMPORTANT: Set this to your installation disk. (e.g., "/dev/sda", "/dev/nvme0n1")
  # Use `lsblk` to find out.
  boot.loader.grub.device = "/dev/sdb";
  # Enable os-prober to detect other operating systems like Windows.
  boot.loader.grub.useOSProber = true;
  # For your i7-3770, it's good practice to load the latest microcode updates.
  hardware.cpu.intel.updateMicrocode = true;

  # --- NETWORKING ---
  # Set a hostname for your machine.
  networking.hostName = "nixos-kde";
  # Enable NetworkManager. It's the standard tool for managing network connections
  # and works perfectly for Ethernet.
  networking.networkmanager.enable = true;

  # --- TIME, LANGUAGE, and KEYBOARD ---
  # Set your time zone.
  time.timeZone = "Europe/Moscow"; # Change this to your actual timezone if needed.

  # Set the main system language to English.
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Configure the console keymap (for TTY, before graphics start).
  console.keyMap = "us";
  
  # Configure keyboard layouts for the graphical session.
  services.xserver = {
    # Layouts: English (us) is the default, Russian (ru) is the second.
    layout = "us,ru";
    # Key combination to switch between layouts: Win + Space.
    xkbOptions = "grp:win_space_toggle";
  };
  
  # --- GRAPHICAL DESKTOP ENVIRONMENT (Minimal KDE Plasma on Wayland) ---
  # Enable the X Server, which is a prerequisite for Wayland compositors too.
  services.xserver.enable = true;
  
  # Enable SDDM (Simple Desktop Display Manager) as the login screen.
  services.xserver.displayManager.sddm.enable = true;
  # IMPORTANT: This line enables the Wayland session option in SDDM.
  services.xserver.displayManager.sddm.wayland.enable = true;

  # Enable KDE Plasma as the Desktop Manager.
  # The "minimal" setup is achieved by manually specifying essential
  # applications in `environment.systemPackages` below.
  services.xserver.desktopManager.plasma5.enable = true;

  # Since you have an integrated Intel GPU (Ivy Bridge), the generic "modesetting"
  # driver is the modern and recommended choice. It's built into the Linux kernel.
  services.xserver.videoDrivers = [ "modesetting" ];

  # --- SOUND SYSTEM (PipeWire) ---
  # PipeWire is the modern sound server for Linux, essential for Wayland.
  sound.enable = true;
  hardware.pulseaudio.enable = false; # Disable PulseAudio, as PipeWire replaces it.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- USER ACCOUNTS ---
  # Define your user account.
  users.users.Sueta = {
    isNormalUser = true;
    description = "Sueta";
    # Add user to the "wheel" group for administrative privileges (sudo)
    # and "networkmanager" to manage network connections.
    extraGroups = [ "wheel" "networkmanager" ];
    # The password will be set manually after the first boot for security.
  };
  # Allow members of the "wheel" group to use sudo.
  security.sudo.wheelNeedsPassword = true;

  # --- SYSTEM PACKAGES ---
  # List the packages you want to install globally. This is where you build your
  # minimal system. We are only adding the bare essentials for a functioning desktop.
  environment.systemPackages = with pkgs; [
    # Basic utilities
    git
    wget
    
    # Web Browser
    firefox

    # Essential KDE Applications
    konsole             # The terminal emulator
    kdePackages.dolphin # The file manager
    kate                # A powerful text editor
    kdePackages.spectacle # The screenshot tool
  ];

  # --- HARDWARE & SERVICES ---
  # Since you don't have Bluetooth, we can disable it completely.
  hardware.bluetooth.enable = false;

  # Enable the CUPS printing system. Comment this out if you never plan to print.
  services.printing.enable = true;

  # Enable desktop portals. This is crucial for apps (especially Flatpaks)
  # to correctly handle things like opening files and screen sharing on Wayland.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-kde ];
  };

  # --- NIX PACKAGE MANAGER SETTINGS ---
  # Enable new Nix command-line tools and Flakes feature.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Automatically run garbage collection to clean up unused packages.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  # This value determines the NixOS release from which the default settings for
  # stateful data are taken. It's recommended to leave this for the installed version.
  system.stateVersion = "25.05";
}
