<div align="center">
  <br>
  <a href="https://jailbreak.party/discord"><img src="https://github.com/jailbreakdotparty/dirtyZero/blob/main/PreviewIcon.png?raw=true" alt="App Icon" width="150"></a>
  <br>
  <h1>dirtyZero</h1>
  <p>Simple customization toolbox, utilizing <a href="https://project-zero.issues.chromium.org/issues/391518636">CVE-2025-24203</a>.</p>
  <p>Supports iOS 16.0 - iOS 18.3.2.</p>
  <a href="https://github.com/jailbreakdotparty/dirtyZero/releases/latest"><img alt="GitHub Downloads (all assets, all releases)" src="https://img.shields.io/github/downloads/jailbreakdotparty/dirtyZero/total?style=flat-square&color=B2FFC6"></a>
  <a href="https://github.com/jailbreakdotparty/dirtyZero/stargazers"> <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/jailbreakdotparty/dirtyZero?style=flat-square&color=%23FFD300"></a> 
  <a href="https://jailbreak.party/discord"><img alt="Discord" src="https://img.shields.io/discord/1349128546072793218?style=flat-square&logo=discord&logoColor=FFFFFF&color=5865F2"></a> 
  <a href="https://jailbreak.party"><img alt="Static Badge" src="https://img.shields.io/badge/jailbreak.party-blue?style=flat-square&label=%20&color=3868DB"></a>
</div>

### Installation
Please ensure that your device is supported before usage. Refer to the table below.
| OS Version | Supported? |
| - | - |
| iOS 15 and lower | No |
| iOS 16.x | Yes |
| iOS 17.0 - iOS 17.7.5 | Yes |
| iOS 18.0 - iOS 18.3.2 | Yes |
| iOS 17.7.6+/iOS 18.4+ | No |

- If your device is not covered by this support table, then it is not supported and *never* will be. **Do not create issues or ask for support regarding later version support.**
- You will also need a sideloading method of your choice to use this tool. Almost all methods of sideloading, including LiveContainer, are supported.

### Info & Usage
- Tweaks are applied with an exploit implementation of [CVE-2025-24203](https://project-zero.issues.chromium.org/issues/391518636). This exploit allows us to zero-out any file that's read-only in the iOS sandbox. If something goes wrong, or you'd just like to revert tweaks, reboot your device.
- To apply tweaks, you'll need to respring your device. If the built-in method does not work, download & sideload [this](https://github.com/jailbreakdotparty/dirtyZero/releases/tag/respringr) app. Alternatively, visit the [respring](https://jailbreak.party/respring) website.
- While unlikely to cause issues, using this tool with a jailbroken iPhone *could* cause issues. It's not recommended to use them together.
- To see information about a tweak, swipe left on the toggle.

## Credits
- [skadz108](https://github.com/skadz108): Original project creator, rewrote exploit in Swift.
- [lunginspector](https://github.com/lunginspector): Rewrote dirtyZero, contributed tweaks, features, and UI.
- [Ian Beer (Google Project Zero)](https://project-zero.issues.chromium.org/issues/391518636): Discovering & publishing CVE-2025-24203.
- [neonmodder123](https://github.com/neonmodder123): Discovered WebView respring method.
