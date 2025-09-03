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
  
  # CHANGED: NixOS 25.05 uses Plasma 6. The `plasma5` option has been replaced.
  services.desktopManager.plasma6.enable = true;

  # Enable the SDDM display manager.
  services.displayManager.sddm.enable = true;
  # Enable the Wayland session in SDDM by default.
  services.displayManager.sddm.wayland.enable = true;

  # NOTE: For modern Intel integrated graphics (like in the i7-13620H),
  # it's best to NOT specify any video drivers. NixOS will automatically
  # use the correct 'modesetting' kernel driver, which is the recommended default.
  # The line below is commented out for this reason.
  # services.xserver.videoDrivers = [ "modesetting" ];

  # --- SOUND (Pipewire) ---
  # Disable PulseAudio as Pipewire provides a compatible implementation.
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
    # IMPORTANT: Replace the placeholder with your actual hashed password.
    # Generate one with the command: mkpasswd -m sha-512
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

    # KDE packages are mostly included with plasma6, but explicit is fine.
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
  # This is crucial for screen sharing and file dialogs in Wayland.
  xdg.portal = {
    enable = true;
    # Add GTK portal for better compatibility with GTK apps (like Firefox).
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    # Set KDE as the default backend.
    config.common.default = "*";
  };

  # --- POWER MANAGEMENT ---
  services.tlp.enable = true;
  
  # Do not change this line. It's used by the `nixos-rebuild` command.
  system.stateVersion = "25.05";
}
