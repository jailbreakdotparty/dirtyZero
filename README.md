# dirtyZero
**A simple customization toolbox that utilizes [CVE-2025-24203](https://project-zero.issues.chromium.org/issues/391518636). Supports iOS 16.0 - iOS 18.3.2.**

[Download](https://github.com/jailbreakdotparty/dirtyZero/releases/latest) • [jbdotparty Discord](https://jailbreak.party/discord) • [jbdotparty Website](https://jailbreak.party)

>[!NOTE]
>All file modifications are done in memory. If something goes wrong or you want to revert the tweaks, just force reboot your device. This toolbox, or any toolbox that uses this exploit, **cannot** write to files. It can only *temporaily* disable them.

## Support Table
| iOS Version | Support Status |
| -------- | ------- |
| iOS 16.0 - iOS 16.7.x  | Supported |
| iOS 17.0 - iOS 17.7.5 | Supported |
| iOS 17.7.6+ | Not Supported |
| iOS 18.0 - iOS 18.3.2 | Supported |
| iOS 18.4+ | Not Supported |

## The tweaks aren't showing up. How do I apply them?
You'll have to respring your device for changes to take effect. Click [here](https://github.com/jailbreakdotparty/dirtyZero?tab=readme-ov-file#option-1-use-respringapp) to learn how.

## Device Tweaks
  - Home Screen
    - Hide Dock Background
    - Clear Folder Backgrounds
    - Clear Widget Config BG
    - Clear App Library BG (iOS 18 only)
    - Clear Library Search BG
    - Clear Spotlight Background
    - Hide Delete Icon
  - Lock Screen
    - Clear Passcode Background
    - Hide Lock Icon
    - Hide Quick Action Icons (iOS 16 & 17 only)
    - Disable Large Battery Icon (iOS 18 only)
  - Alerts & Overlays
    - Clear Notification & Widget BGs
    - Blue Notification Shadows
    - Clear Touch & Alert Backgrounds
    - Hide Home Bar
    - Remove Glassy Overlays
    - Clear App Switcher BG
  - Fonts & Icons
    - Enable 𝖧𝖾𝗅𝗏𝖾𝗍𝗂𝖼𝖺 Font
    - Disable Emojis
    - Hide Ring Animations
    - Hide Tethering Graphic
  - Control Center
    - Clear CC Module Background (iOS 18 only)
    - Disable Slider Icons
    - Hide WiFi & Bluetooth Icons (iOS 16 & 17 only)
    - Hide Player Buttons
    - Hide DND Icon
    - Disable Screen Mirroring Module (iOS 16 & 17 only)
    - Disable Orientation Lock Module (iOS 16 & 17 only)
    - Disable Focus Module (iOS 16 & 17 only)
  - Sound Effects
    - Disable AirDrop Ping
    - Disable Charge Sound
    - Disable Low Battery Sound
    - Disable Payment Sounds
    - Disable Dialing Sounds
  - Risky Tweaks (enable these in settings, will likely cause you to have to force reboot your device)
    - Disable CC Background
    - Disable ALL Accent Colors
    - Break System Font
    - Disable ALL Banners
    - Break SpringBoard Labels
    - Break System Labels

## Other Features
  - Custom Tweaks
    - Create your own tweaks by specifying paths that you'd like to zero out. You can remove the ones you've created by holding down on the custom tweak. Go to settings and click "Remove Custom Tweaks" to get rid of them all at once.

## How do I respring after applying the tweaks?
## Option 1: Use RespringApp
1. Install [RespringApp](https://github.com/jailbreakdotparty/dirtyZero/releases/download/respringapp/respringapp.ipa) using your preferred method of sideloading. If you signed RespringApp with PPQ Protection or AltStore/SideStore, enable "Change Respring App Bundle ID" in settings and type in the bundle id of RespringApp. You can find the bundle id in AltStore's/SideStore's "View App IDs" menu or with tools like [Antrag](https://github.com/khcrysalis/Antrag).
2. In dirtyZero, click the orange "Respring" button.
3. Profit 🔥

*This method brought to you by [`@nyaathea`](https://x.com/nyaathea). Due to the nature of the method, it is not possible to integrate this directly into the dirtyZero app, hence the seperate IPA. Note that you can also simply click the RespringApp application itself to respring.* If the respring button inside of dirtyZero does not work, get the exact Bundle ID of the RespringApp (you probably had PPQ enabled when sideloading), open dirtyZero's settings, and click "Change Respring App BID."

**Option 2: Display & Text Size**
1. Before applying the tweaks, go into Settings > Display & Brightness > Display Zoom
2. Pick the option that's opposite of the one you're currently using.
3. After, apply the tweaks.
4. Go back into Settings > Display & Brightness > Display Zoom
5. Pick the option that's opposite of the one you're currently using.


# Credits
- [Skadz](https://github.com/skadz108) for making this app.
- [lunginspector](https://github.com/lunginspector) for the UI and numerous tweaks.
- Ian Beer of Google Project Zero for discovering and publishing the exploit.
