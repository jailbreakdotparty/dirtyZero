<div align="center">
  <br>
  <a href="https://jailbreak.party/discord"><img src="https://github.com/jailbreakdotparty/dirtyZero/blob/main/dirtyZeroAppIcon.png?raw=true" alt="SparseBoxPlus Icon" width="150"></a>
  <br>
  <h1>dirtyZero</h1>
  <p>A simple customization toolbox that utilizes various exploits to zero out file memory.</a></p>
  <p>iOS 16.0 - iOS 18.7.1 & iOS 26.0 - iOS 26.0.1</p>
  <p><a href="https://github.com/jailbreakdotparty/dirtyZero/releases/latest">Download</a> • <a href="https://jailbreak.party/discord">Discord</a> • <a href="https://jailbreak.party">Website</a></p>
</div>

>[!NOTE]
>All tweaks are done in memory, so if something goes wrong, simply reboot your device to revert any changes you made.

## Exploit Information
- This app uses both [l0ckwire](https://project-zero.issues.chromium.org/issues/391518636) and [DarkSword](https://github.com/htimesnine/DarkSword-RCE) in order to zero out file memory and customize your device. l0ckwire is a lot more stable, but supports less versions of iOS and is more prone to reverting. The kernel exploit from the DarkSword chain has less stability, may not work on weird device configurations, and is a lot more finicky when it comes to applying tweaks. You may have to apply multiple times for all tweaks to work!
- If you are on iOS 16.0 - iOS 18.3.2 (with exceptions), both exploits will be available to you. Otherwise, you'll only be able to use DarkSword (as it supports a wider range of iOS versions).

## What kinds of tweaks are available?
- dirtyZero has more than 30+ tweaks, which mostly involve removing elements from the device (such as the dock or home bar). However, on iOS 26, there are a lot less tweaks due to the fact that removing many various elements requires more than just zeroing out a file in memory.

## How do I apply the tweaks once the app is ready and I've selected my tweaks?
- dirtyZero now has a built in respring method. If it does not work, here are some other methods:
**Method 1: RespringApp**
1. Install [RespringApp](https://github.com/jailbreakdotparty/dirtyZero/releases/download/respringapp/respringapp.ipa) using your preferred method of sideloading.
2. In dirtyZero, click the orange "Respring" button.
3. Profit 🔥

If you sideloaded RespringApp using SideStore or have otherwise changed the bundle ID of RespringApp, you will need to manually set the app's bundle ID in dirtyZero's settings for the built-in Respring button to work.

You can also open RespringApp from the Home Screen to cause a respring.

*This method brought to you by [@nyaathea](https://x.com/nyaathea).*

**Method 2: Display & Text Size**
1. Before applying the tweaks, go into Settings > Display & Brightness > Display Zoom
2. Pick the option that's opposite of the one you're currently using.
3. After, apply the tweaks.
4. Go back into Settings > Display & Brightness > Display Zoom
5. Pick the option that's opposite of the one you're currently using.

## Credits
- [Skadz](https://github.com/skadz108) - app developer and backend.
- [lunginspector](https://github.com/lunginspector) - main UI, tweaks, and project maintainer.
- [Ian Beer of Google Project Zero](https://project-zero.issues.chromium.org/issues/391518636) - discovering and publishing CVE-2025-24203.
- [Duy Tran](https://github.com/khanhduytran0) - App detection exploit, and various contributions to other utilized libraries
- [rooootdev](https://github.com/rooootdev) - DarkSword exploit library and implementation assistance
- [AppInstalleriOS](https://github.com/AppInstalleriOSGH) - Patchfinder assistance and numerous contributions
- [wh1te4ever](https://github.com/wh1te4ever) - Various additions and research to DarkSword exploit
- [opa334](https://github.com/opa334) - Original DarkSword kernel exploit implementation, and various required libraries
- [Alfie CG](https://github.com/alfiecg24) - Developed kernelcache downloading library
- [neonmodder123](https://github.com/neonmodder123) - Developed WebView respring method.

