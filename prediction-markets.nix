{ config, lib, pkgs, ... }:

let
  workingDir = "${config.home.homeDirectory}/dude-workspace/dude-prediction-markets";
  stateDir = "${config.home.homeDirectory}/.local/state/dude-prediction-markets";
  vaultDir = "${config.home.homeDirectory}/vault";
in
{
  systemd.user.services.dude-prediction-markets = {
    Unit = {
      Description = "Dude Prediction Markets Strategy Runner";
      After = [ "network.target" ];
      StartLimitBurst = "5";
      StartLimitIntervalSec = "120s";
    };
    Service = {
      Type = "oneshot";
      WorkingDirectory = workingDir;
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${stateDir}"
        "${pkgs.coreutils}/bin/mkdir -p ${vaultDir}/reports/prediction-markets"
      ];
      ExecStart = "${pkgs.nodejs_24}/bin/node ${workingDir}/src/runner.js --once";
      Environment = [
        "PM_STATE_DIR=${stateDir}"
        "OBSIDIAN_DIR=${vaultDir}"
        "PATH=${lib.makeBinPath [
          pkgs.git
          pkgs.gh
          pkgs.nodejs_24
          pkgs.coreutils
        ]}:${config.home.homeDirectory}/dude-workspace/dude-prediction-markets/node_modules/.bin:/usr/bin:/bin"
      ];
    };
  };

  systemd.user.timers.dude-prediction-markets = {
    Unit = {
      Description = "Timer for Dude Prediction Markets Runner";
    };
    Timer = {
      OnCalendar = "*-*-* *:00/30:00";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
