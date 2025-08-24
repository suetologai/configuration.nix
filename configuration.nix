# /mnt/etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports =
    [ # Файл с определением вашего оборудования. НЕ ТРОГАТЬ.
      ./hardware-configuration.nix
    ];

  # 1. ЗАГРУЗЧИК (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 2. СЕТЬ И ИМЯ КОМПЬЮТЕРА
  networking.hostName = "nixos-labwc";
  networking.networkmanager.enable = true; # Для Ethernet

  # 3. ОПТИМИЗАЦИЯ ПОД ОБОРУДОВАНИЕ
  hardware.bluetooth.enable = false; # Отключаем Bluetooth

  # 4. ЯЗЫК, ВРЕМЯ И КЛАВИАТУРА (для Wayland)
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";

  # ПРАВИЛЬНЫЙ способ настройки клавиатуры для Wayland
  environment.variables = {
    XKB_DEFAULT_LAYOUT = "us,ru";
    XKB_DEFAULT_OPTIONS = "grp:alt_shift_toggle";
  };

  # 5. ГРАФИКА И РАБОЧЕЕ ОКРУЖЕНИЕ
  # ПРАВИЛЬНЫЙ способ включения графики для Intel (одной строки достаточно)
  hardware.opengl.enable = true;

  # Отключаем старый X.org
  services.xserver.enable = false;

  # Включаем оконный композитор labwc
  programs.labwc.enable = true;

  # Включаем экран входа в систему (login manager)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.regreet}/bin/regreet --command ${pkgs.labwc}/bin/labwc";
        user = "greeter";
      };
    };
  };

  # 6. ЗВУК (через Pipewire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # 7. ПОЛЬЗОВАТЕЛЬ
  users.users.<ВАШЕ_ИМЯ_ПОЛЬЗОВАТЕЛЯ> = {
    isNormalUser = true;
    description = "Мой Пользователь";
    extraGroups = [ "networkmanager" "wheel" ]; # "wheel" дает право на sudo
    # Пароль нужно задать через хэш! Смотри инструкцию ниже.
    hashedPassword = "СЮДА_ВСТАВИТЬ_ХЭШ_ПАРОЛЯ";
  };

  # 8. УСТАНОВКА ПРОГРАММ
  environment.systemPackages = with pkgs; [
    alacritty
    git
    brave
    waybar
    telegram-desktop
    discord
  ];

  # 9. АВТОЗАПУСК ПРИЛОЖЕНИЙ
  environment.etc."xdg/labwc/autostart".text = ''
    #!/bin/sh
    waybar &
    alacritty &
  '';

  # 10. ВЕРСИЯ СИСТЕМЫ
  system.stateVersion = "25.05";
}
