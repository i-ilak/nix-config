{ ... }: {
  alacritty = {
    enable = true;
    settings = {
      window = {
        decorations = "None";
        dynamic_title = true;
        opacity = 0.98;
        #option_as_alt   = "Both";
        title = "Alacritty";
        padding = {
          x = 5;
          y = 5;
        };
        startup_mode = "Maximized";
      };
      mouse.hide_when_typing = true;
      font = {
        size = 11.0;
        normal = {
          family = "MesloLGS NF";
          style = "Regular";
        };
        bold = {
          family = "MesloLGS NF";
          style = "Bold";
        };
        italic = {
          family = "MesloLGS NF";
          style = "Italic";
        };
        bold_italic = {
          family = "MesloLGS NF";
          style = "Bold Italic";
        };
      };
      keyboard.bindings = [ ];
      env.WINIT_X11_SCALE_FACTOR = "1.0";
      colors = {
        indexed_colors = [
          {
            color = "#EF9F76";
            index = 16;
          }
          {
            color = "#F2D5CF";
            index = 17;
          }
        ];
        normal = {
          black = "#51576D";
          blue = "#8CAAEE";
          cyan = "#81C8BE";
          green = "#A6D189";
          magenta = "#F4B8E4";
          red = "#E78284";
          white = "#B5BFE2";
          yellow = "#E5C890";
        };
        bright = {
          black = "#626880";
          blue = "#8CAAEE";
          cyan = "#81C8BE";
          green = "#A6D189";
          magenta = "#F4B8E4";
          red = "#E78284";
          white = "#A5ADCE";
          yellow = "#E5C890";
        };
        cursor = {
          cursor = "#F2D5CF";
          text = "#303446";
        };
        dim = {
          black = "#51576D";
          blue = "#8CAAEE";
          cyan = "#81C8BE";
          green = "#A6D189";
          magenta = "#F4B8E4";
          red = "#E78284";
          white = "#B5BFE2";
          yellow = "#E5C890";
        };
        hints = {
          start = {
            background = "#E5C890";
            foreground = "#303446";
          };
          end = {
            background = "#A5ADCE";
            foreground = "#303446";
          };
        };
        primary = {
          background = "#303446";
          bright_foreground = "#C6D0F5";
          dim_foreground = "#C6D0F5";
          foreground = "#C6D0F5";
        };
        search = {
          focused_match = {
            background = "#A6D189";
            foreground = "#303446";
          };
          matches = {
            background = "#A5ADCE";
            foreground = "#303446";
          };
        };
        selection = {
          background = "#F2D5CF";
          text = "#303446";
        };
        vi_mode_cursor = {
          cursor = "#BABBF1";
          text = "#303446";
        };
      };
    };
  };
}
