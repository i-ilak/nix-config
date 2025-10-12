_: {
  programs.helix = {
    settings = {
      editor = {
        line-number = "relative";
        bufferline = "multiple";
        default-yank-register = "+";
        shell = [
          "bash"
          "-c"
        ];
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        indent-guides = {
          character = "╎";
          render = true;
        };
        color-modes = true;
        popup-border = "all";
        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "file-name"
          ];
          mode = {
            normal = "N";
            insert = "I";
            select = "V";
          };
        };
        file-picker = {
          hidden = false;
        };
      };
      keys = {
        normal = {
          "s" = ":w";
          "tab" = "goto_next_buffer";
          "S-tab" = "goto_previous_buffer";
          "A-x" = "extend_to_line_bounds";
          "X" = "select_line_above";
          "f" = {
            "f" = "file_picker";
            "u" = "goto_reference";
            "g" = "global_search";
            "s" = "symbol_picker";
          };
          "r" = {
            "r" = "rename_symbol";
          };
        };
        select = {
          "A-x" = "extend_to_line_bounds";
          "X" = "select_line_above";
        };
      };
    };
  };
}
