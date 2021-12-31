{pkgs, lib, config, ...}:
let
  home = config.home.homeDirectory;
  raise = "${home}/src/scripts/raise.sh";
  myExecutor = pkgs.gnomeExtensions.executor.overrideAttrs (old: {
    buildCommand = old.buildCommand + ''
        substituteInPlace $out/share/gnome-shell/extensions/executor@raujonas.github.io/extension.js --replace "'/bin/bash'" "'/usr/bin/env', 'bash'"
    '';
  });
  extensions = with pkgs.gnomeExtensions; [
    caffeine
    myExecutor
    system-monitor
    sound-output-device-chooser
  ];
  findUuid = e: e.uuid or e.extensionUuid;
  extensionLink = ext: let uuid = findUuid ext; in {
    target = "${home}/.local/share/gnome-shell/extensions/${uuid}";
    source = "${ext}/share/gnome-shell/extensions/${uuid}";
  };
  extPair = e: { name = e.name; value = extensionLink e; };
  mkTuple = lib.hm.gvariant.mkTuple;
in {

  # Put cross-OS packages (including CLI) in apps.nix
  home.packages = with pkgs; [
  ] ++ extensions;
  home.file = builtins.listToAttrs (map extPair extensions);

  dconf.settings = let
    mediaKeys = "org/gnome/settings-daemon/plugins/media-keys";
    extensionsKey = "org/gnome/shell/extensions";
    colors0 = "#333333ff"; colors1 = "#555555ff"; colors2 = "#777777ff"; colors3 = "#999999ff"; colors4 = "#bbbbbbff"; colors5 = "#ddddddff";
  in {
    "org/gnome/shell".disable-user-extensions = false;
    "org/gnome/shell".enabled-extensions = map findUuid extensions;

    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = false;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file://${home}/.desktop.jpg";
      color-shading-type="solid";
      primary-color="#000000000000";
      picture-options="zoom";
      secondary-color="#000000000000";
    };

    "desktop/ibus/general" = {
      preload-engines = [];
    };

    "desktop/ibus/panel/emoji" = {
      font = "Noto Color Emoji 16";
    };

    "org/freedesktop/ibus/engine/anthy/common" = {
      input-mode = 0;
    };

    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "ca+eng" ]) (mkTuple [ "ibus" "anthy" ]) ];
      per-window = false;
      sources = [ (mkTuple [ "xkb" "ca+eng" ]) (mkTuple [ "ibus" "anthy" ]) ];
      xkb-options = [ "ctrl:nocaps" "compose:menu" "terminate:ctrl_alt_bksp" "lv3:ralt_switch" ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ "<Primary><Shift><Alt><Super>space" ];
      switch-input-source-backward = [ "<Primary><Alt><Super>space" ];
    };

    "org/gnome/desktop/interface" = {
      gtk-im-module = "ibus";
    };

    "${mediaKeys}" = {
      custom-keybindings = [
        "/${mediaKeys}/custom-keybindings/custom0/"
        "/${mediaKeys}/custom-keybindings/custom1/"
        "/${mediaKeys}/custom-keybindings/custom2/"
        "/${mediaKeys}/custom-keybindings/custom3/"
        "/${mediaKeys}/custom-keybindings/custom4/"
      ];
    };

    "${mediaKeys}/custom-keybindings/custom0" = {
      binding = ''<Primary><Shift><Alt><Super>e'';
      command = ''${raise} "emacs@" ${pkgs.emacs}/bin/emacs'';
      name = ''Emacs'';
    };

    "${mediaKeys}/custom-keybindings/custom1" = {
      binding = ''<Primary><Shift><Alt><Super>f'';
      command = ''${raise} "Mozilla Firefox" ${pkgs.firefox}/bin/firefox'';
      name = ''Firefox'';
    };

    "${mediaKeys}/custom-keybindings/custom2" = {
      binding = ''<Primary><Shift><Alt><Super>Return'';
      command = ''${raise} "edd@freamon" ${pkgs.gnome.gnome-terminal}/bin/gnome-terminal'';
      name = ''Terminal'';
    };

    "${mediaKeys}/custom-keybindings/custom3" = {
      binding = ''<Primary><Shift>Break'';
      command = ''systemctl suspend'';
      name = ''Suspend'';
    };

    "${mediaKeys}/custom-keybindings/custom4" = {
      binding = ''<Primary>AudioRaiseVolume'';
      command = ''${pkgs.gnome.gnome-control-center}/bin/gnome-control-center sound'';
      name = ''sound preferences'';
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
    };

    "${extensionsKey}/caffeine".user-enabled = false;

    "${extensionsKey}/executor" = {
      center-active = false;
      center-commands-json = ''{"commands":[]}'';
      right-active = false;
      right-commands-json = ''{"commands":[]}'';
      left-active = true;
      left-commands-json=''{"commands":[{"command":"/home/edd/.nix-profile/bin/b np get","interval":5,"uuid":"13f3aa20-7461-448c-ab74-0ee48989a077"}]}'';
      left-index = 2;
      location = 0;
    };

    "${extensionsKey}/system-monitor" = {
      battery-hidesystem = true;
      battery-show-menu = true;
      center-display = false;
      compact-display = false;
      cpu-graph-width = 80;
      cpu-individual-cores = false;
      cpu-iowait-color = colors0;
      cpu-nice-color = colors1;
      cpu-other-color = colors2;
      cpu-show-text = true;
      cpu-system-color = colors3;
      cpu-user-color = colors4;
      disk-read-color = colors2;
      disk-write-color = colors4;
      memory-buffer-color = colors1;
      memory-cache-color = colors3;
      memory-graph-width = 80;
      memory-program-color = colors4;
      move-clock = false;
      net-collisions-color = colors1;
      net-down-color = colors2;
      net-downerrors-color = colors4;
      net-graph-width = 80;
      net-up-color = colors3;
      net-uperrors-color = colors5;
      thermal-sensor-file = "/sys/class/hwmon/hwmon5/temp1_input";
    };
  };

  # Some variant types aren't supported yet
  #
  home.activation.dconfExtraSettings = lib.hm.dag.entryAfter [ "installPackages" ]
    (let
      extraConf = ''
      [org/gnome/Weather]
      locations=[<(uint32 2, <('Vancouver International Airport', 'CYVR', false, [(0.85841109795478021, -2.1496638678574467)], @a(dd) [])>)>]

      [org/gnome/clocks]
      world-clocks=[{'location': <(uint32 2, <('London', 'EGWU', true, [(0.89971722940307675, -0.007272211034407213)], [(0.89884456477707964, -0.0020362232784242244)])>)>}, {'location': <(uint32 2, <('Reykjavík', 'BIRK', true, [(1.1193378211279323, -0.38222710618675809)], [(1.1196287151543625, -0.38309977081275531)])>)>}, {'location': <(uint32 2, <('Brussels', 'EBBR', true, [(0.88837258926511375, 0.079121586939312094)], [(0.88720903061268674, 0.07563092843532343)])>)>}, {'location': <(uint32 2, <('Tokyo', 'RJTI', true, [(0.62191898430954862, 2.4408429589140699)], [(0.62282074357417661, 2.4391218722853854)])>)>}]

      [org/gnome/shell/weather]
      automatic-location=true
      locations=[<(uint32 2, <('Vancouver International Airport', 'CYVR', false, [(0.85841109795478021, -2.1496638678574467)], @a(dd) [])>)>]

      [org/gnome/shell/world-clocks]
      locations=[<(uint32 2, <('London', 'EGWU', true, [(0.89971722940307675, -0.007272211034407213)], [(0.89884456477707964, -0.0020362232784242244)])>)>, <(uint32 2, <('Reykjavík', 'BIRK', true, [(1.1193378211279323, -0.38222710618675809)], [(1.1196287151543625, -0.38309977081275531)])>)>, <(uint32 2, <('Brussels', 'EBBR', true, [(0.88837258926511375, 0.079121586939312094)], [(0.88720903061268674, 0.07563092843532343)])>)>, <(uint32 2, <('Tokyo', 'RJTI', true, [(0.62191898430954862, 2.4408429589140699)], [(0.62282074357417661, 2.4391218722853854)])>)>]
'';
      iniFile = pkgs.writeText "hm-extra-dconf.ini" extraConf;
     in ''
        if [[ -v DBUS_SESSION_BUS_ADDRESS ]]; then
          DCONF_DBUS_RUN_SESSION=""
        else
          DCONF_DBUS_RUN_SESSION="${pkgs.dbus}/bin/dbus-run-session"
        fi

        $DRY_RUN_CMD $DCONF_DBUS_RUN_SESSION ${pkgs.dconf}/bin/dconf load / < ${iniFile}

        unset DCONF_DBUS_RUN_SESSION
      '');
}
