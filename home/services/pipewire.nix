{ pkgs, ... }:
let
  # param_eq reads AutoEQ text. The first line must be
  # "Preamp: N dB" (a flat gain). Later lines are PK / LSC / HSC.
  eqFile = name: text: pkgs.writeText "eq-${name}.txt" text;

  # bs2b-lv2 symbols fcut / feed. LSP limiter stereo symbols below.
  # Enum 0 is Herm Thin, oversampling None, dither None, sidechain
  # Internal. Threshold and knee are linear gain: 1.0 is 0 dB.
  tail = [
    {
      type = "lv2";
      name = "crossfeed";
      plugin = "http://bs2b.sourceforge.net/plugins/bs2b";
      control = {
        fcut = 700.0;
        feed = 4.5;
      };
    }
    {
      type = "lv2";
      name = "limiter";
      plugin = "http://lsp-plug.in/plugins/lv2/limiter_stereo";
      control = {
        alr = 1;
        alr_at = 5.0;
        alr_rt = 50.0;
        mode = 0;
        th = 1.0;
        knee = 1.0;
        boost = 1;
        lk = 5.0;
        at = 5.0;
        rt = 5.0;
        ovs = 0;
        dith = 0;
        extsc = 0;
        slink = 100.0;
        smooth = -5.0;
      };
    }
  ];

  # One smart filter per output. Apps keep selecting the hardware
  # sink; WirePlumber inserts the chain whose target matches.
  chain =
    {
      name,
      description,
      eq,
      target,
    }:
    {
      name = "libpipewire-module-filter-chain";
      # A missing plugin must not take down the whole daemon.
      flags = [ "nofail" ];
      args = {
        "node.description" = description;
        "audio.channels" = 2;
        "audio.position" = [
          "FL"
          "FR"
        ];
        "filter.graph" = {
          nodes = [
            {
              type = "builtin";
              name = "eq";
              label = "param_eq";
              config.filename = eq;
            }
          ]
          ++ tail;
          links = [
            {
              output = "eq:Out 1";
              input = "crossfeed:in0";
            }
            {
              output = "eq:Out 2";
              input = "crossfeed:in1";
            }
            {
              output = "crossfeed:out0";
              input = "limiter:in_l";
            }
            {
              output = "crossfeed:out1";
              input = "limiter:in_r";
            }
          ];
          inputs = [
            "eq:In 1"
            "eq:In 2"
          ];
          outputs = [
            "limiter:out_l"
            "limiter:out_r"
          ];
        };
        "capture.props" = {
          "node.name" = "eq-${name}";
          "node.description" = description;
          "media.class" = "Audio/Sink";
          "filter.smart" = true;
          "filter.smart.name" = name;
          "filter.smart.target" = target;
        };
        # Absent hardware waits. It does not fall through onto
        # another sink.
        "playback.props" = {
          "node.name" = "eq-${name}-playback";
          "node.passive" = true;
          "node.dont-fallback" = true;
          "node.linger" = true;
          "stream.dont-remix" = true;
        };
      };
    };

  lv2Plugins = pkgs.buildEnv {
    name = "pipewire-headphone-lv2";
    paths = [
      pkgs.lsp-plugins
      pkgs.bs2b-lv2
    ];
    pathsToLink = [ "/lib/lv2" ];
  };
in
{
  services.pipewire = {
    enable = true;
    extraLv2Packages = [
      pkgs.lsp-plugins
      pkgs.bs2b-lv2
    ];

    # Firefox -> SoundCore mini (F4:2B:7D:63:60:B4) when that
    # sink exists.
    pulseConfigs."50-firefox-soundcore" = {
      "pulse.rules" = [
        {
          matches = [
            { "application.process.binary" = "firefox"; }
            { "application.process.binary" = ".firefox-wrapped"; }
          ];
          actions = {
            quirks = [ "remove-capture-dont-move" ];
            update-props = {
              "target.object" = "bluez_output.F4_2B_7D_63_60_B4.1";
              "node.dont-move" = true;
            };
          };
        }
      ];
    };

    configs."10-headphone-eq" = {
      "context.modules" = [
        (chain {
          name = "hyperx";
          description = "HyperX Cloud Alpha Wireless EQ";
          eq = eqFile "hyperx" ''
            Preamp: -6.3 dB
            Filter 1: ON LSC Fc 105 Hz Gain -4.8 dB Q 0.7
            Filter 2: ON PK Fc 44.3 Hz Gain 1.8 dB Q 1.67
            Filter 3: ON PK Fc 159.8 Hz Gain -1.6 dB Q 1.39
            Filter 4: ON PK Fc 1372.7 Hz Gain 4.8 dB Q 0.98
            Filter 5: ON PK Fc 2607.4 Hz Gain -5.4 dB Q 2.53
            Filter 6: ON PK Fc 4072.6 Hz Gain 7.0 dB Q 2.79
            Filter 7: ON PK Fc 5511.6 Hz Gain 2.0 dB Q 4.93
            Filter 8: ON PK Fc 7137.7 Hz Gain -2.5 dB Q 5.91
            Filter 9: ON PK Fc 8661.0 Hz Gain -7.7 dB Q 1.81
            Filter 10: ON HSC Fc 10000 Hz Gain -1.8 dB Q 0.7
          '';
          target = {
            "node.name" = "alsa_output.usb-HP__Inc_HyperX_Cloud_Alpha_Wireless_00000001-00.analog-stereo";
          };
        })
        # The 6XX is the headphone jack on this analog sink, which
        # is also the speaker output. The curve follows the sink.
        (chain {
          name = "hd6xx";
          description = "HD 6XX EQ";
          eq = eqFile "hd6xx" ''
            Preamp: -9.41 dB
            Filter 1: ON LSC Fc 105 Hz Gain 10.9 dB Q 0.7
            Filter 2: ON PK Fc 65.5 Hz Gain -5.8 dB Q 0.57
            Filter 3: ON PK Fc 176.2 Hz Gain -1.7 dB Q 1.22
            Filter 4: ON PK Fc 722.5 Hz Gain 0.3 dB Q 1.45
            Filter 5: ON PK Fc 1125.5 Hz Gain 0.6 dB Q 5.5
            Filter 6: ON PK Fc 1169.2 Hz Gain -1.4 dB Q 3.26
            Filter 7: ON PK Fc 1230.8 Hz Gain -0.5 dB Q 2.52
            Filter 8: ON PK Fc 1939.1 Hz Gain 0.7 dB Q 3.24
            Filter 9: ON PK Fc 8813.9 Hz Gain 5.8 dB Q 1.82
            Filter 10: ON HSC Fc 10000 Hz Gain -2.2 dB Q 0.7
          '';
          target = {
            "node.nick" = "ALC236 Analog";
            "media.class" = "Audio/Sink";
          };
        })
        # USB smart case, not Bluetooth. Rtings B&K 5128 in-ear,
        # Elite 10 Gen 2 (not Gen 1, not DHRME).
        (chain {
          name = "jabra-elite-10";
          description = "Jabra Elite 10 EQ";
          eq = eqFile "jabra-elite-10" ''
            Preamp: -2.8 dB
            Filter 1: ON LSC Fc 105 Hz Gain -2.4 dB Q 0.70
            Filter 2: ON PK Fc 153 Hz Gain 3.6 dB Q 1.47
            Filter 3: ON PK Fc 7705 Hz Gain -3.0 dB Q 1.53
            Filter 4: ON PK Fc 42 Hz Gain -1.1 dB Q 0.66
            Filter 5: ON PK Fc 298 Hz Gain -1.9 dB Q 2.16
            Filter 6: ON HSC Fc 10000 Hz Gain -2.4 dB Q 0.70
            Filter 7: ON PK Fc 3305 Hz Gain 2.3 dB Q 2.23
            Filter 8: ON PK Fc 876 Hz Gain 0.7 dB Q 2.57
            Filter 9: ON PK Fc 4901 Hz Gain -1.1 dB Q 4.73
            Filter 10: ON PK Fc 1981 Hz Gain -0.8 dB Q 3.47
          '';
          target = {
            "node.name" =
              "alsa_output.usb-MediaTek_Inc_Jabra_Elite_Smart_Case_0000000000000000-00.analog-stereo";
          };
        })
      ];
    };
  };

  # The NixOS unit sets LV2_PATH from pipewire.service.d/overrides.conf.
  # Drop-ins are lexical, so this name has to sort after that file or
  # the empty NixOS path wins and filter-chain refuses to start.
  xdg.configFile."systemd/user/pipewire.service.d/zz-headphone-eq.conf".text = ''
    [Service]
    Environment=LV2_PATH=${lv2Plugins}/lib/lv2
  '';
}
