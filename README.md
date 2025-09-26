# dirtyZero
**A simple customization toolbox that utilizes [CVE-2025-24203](https://project-zero.issues.chromium.org/issues/391518636).**

[Download](https://github.com/jailbreakdotparty/dirtyZero/releases) • [Join our Discord!](https://discord.gg/XPj66zZ4gT)

# Disclaimer
All file modifications are done in memory. If something goes wrong or you want to revert the tweaks, just force reboot your phone. Note that this toolbox, or any subsequent toolbox that uses this exploit, **cannot** write to files. It can only *temporaily* disable them.

# Support Table
| iOS Version | Support Status |
| -------- | ------- |
| iOS 16.0 - iOS 16.7.11  | Supported |
| iOS 17.0 - iOS 17.7.5 | Supported |
| iOS 17.7.6+ | Not Supported |
| iOS 18.0 - iOS 18.3.2 | Supported |
| iOS 18.4+ | Not Supported |

# Available Tweaks
  - Home Screen
    - Disable Dock Background
    - Disable Folder Backgrounds
    - Disable Alert & Touch Backgrounds
    - Disable Spotlight Backgroud
    - Disable Widget Config BG
    - Disable App Library BG (iOS 18 only)
  - Lock Screen
    - Disable Passcode Background
    - Disable Lock Icon
    - Disable Quick Action Icons (iOS 16 & 17 only)
    - Disable Large Battery Icon (iOS 18 only)
  - Global Customization
    - Disable Notification Widget BGs
    - Disable Home Bar
    - Enable Helvetica Font
    - Disable Slider Icons
  - Control Center
    - Disable CC Background
    - Disable CC Module Background (iOS 18 only)
    - Disable WiFi & Bluetooth Icons (iOS 16 & 17 only)
    - Disable DND Icon
    - Disable Screen Mirroring Module (iOS 16 & 17 only)
    - Disable Orientation Lock Module (iOS 16 & 17 only)
    - Disable Focus Module (iOS 16 & 17 only)
  - Sound Effects
    - Disable AirDrop Ping
    - Disable Charge Sound
    - Disable Low Battery Sound
    - Disable Payment Sounds

# How do I respring after applying the tweaks?
## Option 1: Use RespringApp
1. Install [RespringApp](https://github.com/jailbreakdotparty/dirtyZero/releases/download/respringapp/respringapp.ipa) using your preferred method of sideloading. Make sure the bundle ID is exactly `com.respring.app`.
2. In dirtyZero, click the orange "Respring" button.
3. Profit 🔥

*This method brought to you by [`@nyaathea`](https://x.com/nyaathea). Due to the nature of the method, it is not possible to integrate this directly into the dirtyZero app, hence the seperate IPA. Note that you can also simply click the RespringApp application itself to respring.*

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
