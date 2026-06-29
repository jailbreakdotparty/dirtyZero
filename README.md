<div align="center">
  <br>
  <a href="https://jailbreak.party/discord"><img src="https://github.com/jailbreakdotparty/dirtyZero/blob/main/PreviewIcon.png?raw=true" alt="App Icon" width="175"></a>
  <br>
  <h1>dirtyZero</h1>
  <p>A simple customization toolbox that utilizes <a href="https://project-zero.issues.chromium.org/issues/391518636">CVE-2025-24203</a>. Supports iOS 16.0 - iOS 18.3.2.</p>
  <p><a href="https://github.com/jailbreakdotparty/dirtyZero/releases/latest">Latest Release</a> • <a href="https://jailbreak.party/discord">Discord Server</a> • <a href="https://jailbreak.party">Our Website</a></p>
</div>

## Installation
Please ensure that your device is supported before usage. Refer to the table below.
| OS Version | Status |
| - | - |
| iOS 15 and below | Unsupported |
| iOS 16.x | Supported |
| iOS 17.0 - iOS 17.7.5 | Supported |
| iOS 17.7.6 - iOS 17.7.x | Unsupported |
| iOS 18.0 - iOS 18.3.2 | Supported |
| iOS 18.4+ | Unsupported |

- While not explicitly stated, iPads are also fully supported by dirtyZero and have their own custom UI.
- If your device is not covered by this support table, then it is not supported and *never* will be. **Do not create issues or ask for support regarding expanded version support.**
- You will also need a sideloading method of your choice to use this tool. Almost all methods of sideloading, including TrollStore and LiveContainer, are supported.

## Usage
- Tweaks are applied using [CVE-2025-24203](https://project-zero.issues.chromium.org/issues/391518636), which is a kernel bug that allows us to temporarily zero out files to read-only locations in memory. This means that, if something goes wrong, rebooting the device will revert all tweaks. Tweaks may revert by themselves overtime due to SSV reloading these system files. There is no way to get around this with this exploit.
- After you successfully apply tweaks, you will need to respring for most tweaks to take effect. You can do this by simply clicking the Respring button. If that does not work, then you can also use the RespringApp method. Simply download the app from [here](https://github.com/jailbreakdotparty/dirtyZero/releases/tag/respringr), sideload it, and open the app. You can also make dirtyZero use this method of respringing when clicking the Respring button in settings. If neither of those are sufficent, visit [this website](https://jailbreak.party/respring) and your device will respring on it's own.
- It is not recommended to use this app in parity with a jailbroken device. It may conflict with other tweaks in the jailbroken enviroment, which could cause issues.

## Tweaks
- For your convience, there is a custom tweak creator. Click the paintbrush icon in the top-right corner, add the paths you'd like to zero out, and use it as you would a normal tweak on the homepage.
- If you'd like to zero out a specific path once, enable Debug Settings in Settings.
- Get information on tweaks and remove custom tweaks by swiping left on the tweak cell.
- To use Risky Tweaks, enable them in settings.

<details>
<summary>All Versions (16.0 – 18.3.2)</summary>

* Home Screen
  * Hide Dock Background
  * Clear Folder Backgrounds
  * Clear Widget Config BG
  * Clear Spotlight Background
  * Hide Delete Icon
* Lock Screen
  * Clear Passcode Background
  * Hide Lock Icon
* Alerts & Overlays
  * Clear Notification & Widget BGs
  * Blue Notification Shadows
  * Clear Touch & Alert Backgrounds
  * Hide Home Bar
  * Remove Glassy Overlays
  * Clear App Switcher
* Fonts & Icons
  * Enable Helvetica Font
  * Disable Emojis
  * Hide Ringer Icon
  * Hide Tethering Icon
* Sound Effects
  * Disable AirDrop Ping
  * Disable Charge Sound
  * Disable Low Battery Sound
  * Disable Payment Sounds
  * Disable Dialing Sounds
* Risky Tweaks
  * Remove CC Background
  * Disable ALL Banners
  * Disable ALL Accent Colors
  * Break System Font
  * Break Clock Font
  * Break SpringBoard Names

</details>

<details>
<summary>iOS 16.0 – 17.7.5 only</summary>

* Lock Screen
  * Hide Quick Action Icons
* Control Center
  * Disable Slider Icons
  * Hide WiFi & Bluetooth Icons
  * Disable Screen Mirroring Module
  * Disable Orientation Lock Module
  * Disable Focus Module

</details>

<details>
<summary>iOS 17.0 – 18.3.2 only</summary>

* Control Center
  * Hide Player Buttons

</details>

<details>
<summary>iOS 18.0 – 18.3.2 only</summary>

* Home Screen
  * Clear App Library BG
  * Clear Library Search BG
* Lock Screen
  * Hide Large Battery Icon
* Control Center
  * Clear CC Modules
  * Disable Slider Icons

</details>

## Credits
- [skadz108](https://github.com/skadz108): Original project creator, rewrote exploit in Swift.
- [lunginspector](https://github.com/lunginspector): Rewrote dirtyZero, contributed tweaks, features, and UI.
- [Ian Beer (Google Project Zero)](https://project-zero.issues.chromium.org/issues/391518636): Discovering & publishing CVE-2025-24203.
- [neonmodder123](https://github.com/neonmodder123): Discovered WebView respring method.
