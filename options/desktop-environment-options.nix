{ lib, myTypes, ... }:

{
  options = {
    desktopEnvironment = {
      sway = lib.mkEnableOption "Sway window manager";
      displayManager = lib.mkOption {
        default = {
          enable = true;
          name = "sddm";
        };
        type = myTypes.displayManagerType;
      };
      workspaces = lib.mkOption {
        default = [
          {
            label = "TERMINAL";
            output = "DP-1";
            shortcut = 0;
            apps = [ "firefox" ];
          }
        ];
        type = lib.types.listOf myTypes.workspaceType;
      };
    };
  };
}
