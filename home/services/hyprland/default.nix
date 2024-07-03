{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      # Refer to the wiki for more information.
      # https://wiki.hyprland.org/Configuring/Configuring-Hyprland/

      # Please note not all available settings / options are set here.
      # For a full list, see the wiki

      # You can split this configuration into multiple files
      # Create your files separately and then link them to this file like this:
      # source = ~/.config/hypr/myColors.conf


      ################
      ### MONITORS ###
      ################

      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor=desc:BOE 0x095F,preferred,auto,1.6   # Framework 13
      monitor=desc:ASUSTek COMPUTER INC VG258 MBLMQS146465,1920x1080@144,0x0,1,vrr,2
      monitor=desc:ViewSonic Corporation VX2457 0x01010101,1920x1080@60,1920x0,1,vrr,2
      monitor=,preferred,auto,1


      ###################
      ### MY PROGRAMS ###
      ###################

      # See https://wiki.hyprland.org/Configuring/Keywords/

      # Set programs that you use
      $terminal = kitty
      $fileManager = pcmanfm-qt
      $menud = rofi -show drun
      $menuw = rofi -show window
      $browser = vivaldi


      #################
      ### AUTOSTART ###
      #################

      # Autostart necessary processes (like notifications daemons, status bars, etc.)
      # Or execute your favorite apps at launch like this:

      exec-once = lxqt-policykit-agent
      exec-once = waybar -s ~/.config/waybar/translucent.css
      exec-once = nm-applet
      exec-once = gammastep-indicator
      exec-once = jamesdsp --tray
      exec-once = wayland-pipewire-idle-inhibit
      # exec-once = hypridle
      exec-once = type solaar > /dev/null && solaar -w hide
      exec-once = $terminal


      #############################
      ### ENVIRONMENT VARIABLES ###
      #############################

      # See https://wiki.hyprland.org/Configuring/Environment-variables/

      env = XCURSOR_SIZE,24
      env = HYPRCURSOR_THEME,phinger-cursors-light
      env = HYPRCURSOR_SIZE,24
      env = QT_QPA_PLATFORM,wayland
      env = QT_QPA_PLATFORMTHEME,qt5ct


      #####################
      ### LOOK AND FEEL ###
      #####################

      # Refer to https://wiki.hyprland.org/Configuring/Variables/

      # https://wiki.hyprland.org/Configuring/Variables/#general
      general { 
          gaps_in = 5
          gaps_out = 5

          border_size = 2

          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = false 

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false

          layout = dwindle
      }

      # https://wiki.hyprland.org/Configuring/Variables/#decoration
      decoration {
          rounding = 10

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0
          inactive_opacity = 1.0

          drop_shadow = true
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur {
              enabled = true
              size = 3
              passes = 1

              vibrancy = 0.1696
          }
      }

      # https://wiki.hyprland.org/Configuring/Variables/#animations
      animations {
          enabled = true

          # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = myBezier, 0.05, 0.9, 0.1, 1.05

          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }

      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      dwindle {
          pseudotile = true # Master switch for pseudotiling. Enabling is bound to mod + P in the keybinds section below
          preserve_split = true # You probably want this
      }

      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      master {
          new_status = master
      }

      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc {
          disable_splash_rendering = true
          force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
      }


      #############
      ### INPUT ###
      #############

      # https://wiki.hyprland.org/Configuring/Variables/#input
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options = compose:caps
          kb_rules =

          repeat_rate = 40
          repeat_delay= 250

          follow_mouse = 1

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

          touchpad {
              natural_scroll = false
              tap_button_map = lmr
          }
      }

      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      gestures {
          workspace_swipe = true
      }

      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
      device {
          name = epic-mouse-v1
          sensitivity = -0.5
      }


      ####################
      ### KEYBINDINGSS ###
      ####################

      # See https://wiki.hyprland.org/Configuring/Keywords/
      $mod = SUPER # Sets "Windows" key as main modifier

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mod, Return, exec, $terminal
      bind = $mod, E,      exec, $fileManager
      bind = $mod, D,      exec, $menud
      bind = $mod, Tab,    exec, $menuw
      bind = $mod, O,      exec, $browser

      bind = $mod, C, centerwindow,
      bind = $mod, Q, killactive,
      bind = $mod, M, exit,
      bind = $mod, V, togglefloating,
      bind = $mod, P, pseudo,      # dwindle
      bind = $mod, J, togglesplit, # dwindle

      bind = , XF86MonBrightnessDown, exec, brillo -U 5
      bind = , XF86MonBrightnessUp,   exec, brillo -A 5

      bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +3%    #increase sound volume
      bind = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -3%    #decrease sound volume
      bind = , XF86AudioMute,        exec, pactl set-sink-mute   @DEFAULT_SINK@ toggle # mute sound

      bind = , XF86AudioNext, exec, mpc next
      bind = , XF86AudioPrev, exec, mpc prev
      bind = , XF86AudioPlay, exec, playerctl play-pause

      # Screenshot a window
      bind = $mod, PRINT, exec, hyprshot -m window
      # Screenshot a monitor
      bind = , PRINT, exec, hyprshot -m output
      # Screenshot a region
      bind = SHIFT, PRINT, exec, hyprshot -m region

      # Move focus with mod + arrow keys
      bind = $mod, left,  movefocus, l
      bind = $mod, right, movefocus, r
      bind = $mod, up,    movefocus, u
      bind = $mod, down,  movefocus, d

      # Switch workspaces with mod + [0-9]
      bind = $mod, 1, workspace, 1
      bind = $mod, 2, workspace, 2
      bind = $mod, 3, workspace, 3
      bind = $mod, 4, workspace, 4
      bind = $mod, 5, workspace, 5
      bind = $mod, 6, workspace, 6
      bind = $mod, 7, workspace, 7
      bind = $mod, 8, workspace, 8
      bind = $mod, 9, workspace, 9
      bind = $mod, 0, workspace, 10

      # Move active window to a workspace with mod + SHIFT + [0-9]
      bind = $mod SHIFT, 1, movetoworkspace, 1
      bind = $mod SHIFT, 2, movetoworkspace, 2
      bind = $mod SHIFT, 3, movetoworkspace, 3
      bind = $mod SHIFT, 4, movetoworkspace, 4
      bind = $mod SHIFT, 5, movetoworkspace, 5
      bind = $mod SHIFT, 6, movetoworkspace, 6
      bind = $mod SHIFT, 7, movetoworkspace, 7
      bind = $mod SHIFT, 8, movetoworkspace, 8
      bind = $mod SHIFT, 9, movetoworkspace, 9
      bind = $mod SHIFT, 0, movetoworkspace, 10

      # Example special workspace (scratchpad)
      bind = $mod,       S, togglespecialworkspace, magic
      bind = $mod SHIFT, S, movetoworkspace,        special:magic

      # Scroll through existing workspaces with mod + scroll
      bind = $mod, mouse_down, workspace, e+1
      bind = $mod, mouse_up,   workspace, e-1

      # Move/resize windows with mod + LMB/RMB and dragging
      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow

      bindm = $mod, Control_L, movewindow
      bindm = $mod, ALT_L,     resizewindow

      bind = $mod, A, submap, fastedit
      submap = fastedit
          binde =      , left,   movefocus,  l
          binde =      , right,  movefocus,  r
          binde =      , up,     movefocus,  u
          binde =      , down,   movefocus,  d
          bind  = SHIFT, left,   movewindow, l
          bind  = SHIFT, right,  movewindow, r
          bind  = SHIFT, up,     movewindow, u
          bind  = SHIFT, down,   movewindow, d
          bind  =      , escape, submap,     reset
      submap = reset


      ##############################
      ### WINDOWS AND WORKSPACES ###
      ##############################

      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
      windowrulev2 = opacity 0.95, class:^kitty$

      windowrulev2 = float,      class:^mpv$
      windowrulev2 = noborder,   class:^mpv$
      windowrulev2 = rounding 0, class:^mpv$

      windowrulev2 = float,      class:^.gamescope-wrapped$
      windowrulev2 = rounding 0, class:^.gamescope-wrapped$

      # Vivaldi pip window
      windowrulev2 = rounding 0, title:^Picture in picture$

      windowrulev2 = suppressevent maximize, class:.* # You'll probably like this.

      layerrule = blur, waybar
    '';
  };
}
