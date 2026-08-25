{ pkgs, ... }:
{
  boot.initrd.systemd.enable = true;

  boot.resumeDevice = "/dev/disk/by-uuid/513972bd-0634-483c-8cba-7eaa0abb043c";

  boot.kernelParams = [
    "resume=/dev/disk/by-uuid/513972bd-0634-483c-8cba-7eaa0abb043c"
    "mem_sleep_default=s2idle"
  ];

  # Suspend-then-hibernate after this delay (tweak to taste)
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1min";
  };

  services.logind.settings.Login = {
    LidSwitchIgnoreInhibited = "yes";
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "suspend-then-hibernate";
    lidSwitchExternalPower = "suspend-then-hibernate";
    lidSwitchDocked = "suspend-then-hibernate";
  };
  services.acpid.enable = false;
  systemd.services.disable-tbt-wakeup = {
    description = "Disable Thunderbolt/USB wakeup sources causing premature resume from suspend";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "disable-tbt-wakeup" ''
        for dev in TXHC TDM0 TDM1 TRP0 TRP1 TRP2 TRP3; do
          if grep -q "^$dev" /proc/acpi/wakeup; then
            echo "$dev" > /proc/acpi/wakeup
          fi
        done
      '';
    };
  };
}
