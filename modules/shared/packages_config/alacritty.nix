{
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
      keyboard.bindings = [];
      env.WINIT_X11_SCALE_FACTOR = "1.0";
    };
  };
}
