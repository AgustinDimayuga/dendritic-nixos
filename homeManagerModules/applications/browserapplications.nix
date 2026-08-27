{ pkgs, ... }:
{
  xdg.desktopEntries = {
    notion = {
      name = "Notion";
      genericName = "Workspace";
      comment = "Notion web app";
      exec = "chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --disable-vulkan --app=https://app.notion.com";
      terminal = false;
      categories = [
        "Office"
        "Utility"
      ];
      icon = ../assets/icons/notion_icon.png;
    };

    outlook = {
      name = "Outlook";
      genericName = "Email Client";
      comment = "Outlook web app";
      exec = "chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --disable-vulkan --app=https://outlook.office365.com";
      terminal = false;
      categories = [
        "Office"
        "Network"
        "Email"
      ];
      icon = ../assets/icons/outlook_icon.png;
    };
    canvas = {
      name = "Canvas";
      genericName = "LMS Client";
      comment = "School";
      exec = "chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --disable-vulkan --app=https://canvas.calpoly.edu";
      terminal = false;
      categories = [
        "Office"
        "Utility"
      ];
      icon = ../assets/icons/canvas_logo.png;
    };

  };
}
