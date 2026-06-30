//
//  TweakArray.swift
//  dirtyZero
//
//  Created by lunginspector on 4/14/26.
//

import SwiftUI

enum SectionType: Codable {
    case normal, risky, custom
}

struct ZeroSection: Identifiable, Equatable, Codable {
    var id = UUID()
    var name: String
    var icon: String
    var hex: String = hexCode(color: .accent)
    var sectionType: SectionType = .normal
    var isExpanded = true
    var tweaks: [ZeroTweak]
}

struct ZeroTweak: Identifiable, Equatable, Codable {
    var id = UUID()
    var name: String
    var icon: String
    var minSupportedVersion: Double = 0.0
    var maxSupportedVersion: Double = 99.0
    var isOn: Bool = false
    var paths: [String]
}

enum TweakArray {
    static var tweaks: [ZeroSection] = [
        ZeroSection(name: "Custom Tweaks", icon: "paintbrush", hex: hexCode(color: .purple), sectionType: .custom, isExpanded: false, tweaks: [
            
        ]),
        ZeroSection(name: "Home Screen", icon: "house", tweaks: [
            ZeroTweak(name: "Hide Dock Background", icon: "dock.rectangle", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/dockDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/dockLight.materialrecipe"]),
            ZeroTweak(name: "Clear Folder Backgrounds", icon: "folder", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderDark.materialrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/folderLight.materialrecipe"]),
            ZeroTweak(name: "Clear Widget Config BG", icon: "square.text.square", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/stackConfigurationBackground.materialrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/stackConfigurationForeground.materialrecipe"]),
            ZeroTweak(name: "Clear App Library BG", icon: "square.dashed", minSupportedVersion: 18.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/coplanarLeadingTrailingBackgroundBlur.materialrecipe"]),
            ZeroTweak(name: "Clear Library Search BG", icon: "magnifyingglass", minSupportedVersion: 18.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/homeScreenOverlay.materialrecipe"]),
            ZeroTweak(name: "Clear Spotlight Background", icon: "rectangle.and.text.magnifyingglass", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/knowledgeBackgroundDarkZoomed.descendantrecipe", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/knowledgeBackgroundZoomed.descendantrecipe"]),
            ZeroTweak(name: "Hide Delete Icon", icon: "xmark", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/SpringBoardHome.framework/Assets.car"])
        ]),
        ZeroSection(name: "Lock Screen", icon: "lock", tweaks: [
            ZeroTweak(name: "Clear Passcode Background", icon: "ellipsis.rectangle", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/dashBoardPasscodeBackground.materialrecipe"]),
            ZeroTweak(name: "Hide Lock Icon", icon: "lock", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@2x-812h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@2x-896h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@3x-812h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@3x-896h.ca/main.caml", "/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/lock@3x-d73.ca/main.caml"]),
            ZeroTweak(name: "Hide Quick Action Icons", icon: "flashlight.off.fill", minSupportedVersion: 16.0, maxSupportedVersion: 17.7, paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/Assets.car"]),
            ZeroTweak(name: "Hide Large Battery Icon", icon: "bolt", minSupportedVersion: 18.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/CoverSheet.framework/Assets.car"])
        ]),
        ZeroSection(name: "Alerts & Overlays", icon: "platter.filled.top.iphone", tweaks: [
            ZeroTweak(name: "Clear Notification & Widget BGs", icon: "platter.filled.top.iphone", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/platterStrokeLight.visualstyleset", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platterStrokeDark.visualstyleset", "/System/Library/PrivateFrameworks/CoreMaterial.framework/plattersDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platters.materialrecipe", "/System/Library/PrivateFrameworks/UserNotificationsUIKit.framework/stackDimmingLight.visualstyleset", "/System/Library/PrivateFrameworks/UserNotificationsUIKit.framework/stackDimmingDark.visualstyleset"]),
            ZeroTweak(name: "Blue Notifcation Shadows", icon: "paintpalette", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: [
                "/System/Library/PrivateFrameworks/PlatterKit.framework/platterVibrantShadowLight.visualstyleset", "/System/Library/PrivateFrameworks/PlatterKit.framework/platterVibrantShadowDark.visualstyleset"]),
            ZeroTweak(name: "Clear Touch & Alert Backgrounds", icon: "list.bullet.rectangle", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/platformContentDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platformContentLight.materialrecipe"]),
            ZeroTweak(name: "Hide Home Bar", icon: "line.3.horizontal", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car"]),
            ZeroTweak(name: "Remove Glassy Overlays", icon: "text.rectangle.page", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/platformChromeDark.materialrecipe", "/System/Library/PrivateFrameworks/CoreMaterial.framework/platformChromeLight.materialrecipe"]),
            ZeroTweak(name: "Clear App Switcher", icon: "switch.programmable", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/SpringBoard.framework/homeScreenBackdrop-application.materialrecipe", "/System/Library/PrivateFrameworks/SpringBoard.framework/homeScreenBackdrop-switcher.materialrecipe"])
        ]),
        ZeroSection(name: "Fonts & Icons", icon: "paintbrush", tweaks: [
            ZeroTweak(name: "Enable Helvetica Font", icon: "character.cursor.ibeam", minSupportedVersion: 17.0, maxSupportedVersion: 18.3, paths: ["/System/Library/Fonts/Core/SFUI.ttf"]),
            ZeroTweak(name: "Enable Helvetica Font ", icon: "character.cursor.ibeam", minSupportedVersion: 16.0, maxSupportedVersion: 16.9, paths: ["/System/Library/Fonts/CoreUI/SFUI.ttf"]),
            ZeroTweak(name: "Disable Emojis", icon: "circle.slash", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/Fonts/CoreAddition/AppleColorEmoji-160px.ttc"]),
            ZeroTweak(name: "Hide Ringer Icon", icon: "bell.slash", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/SpringBoard.framework/Ringer-Leading-D73.ca/main.caml"]),
            ZeroTweak(name: "Hide Tethering Icon", icon: "link", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/SpringBoard.framework/Tethering-D73.ca/main.caml"])
        ]),
        ZeroSection(name: "Control Center", icon: "square.grid.2x2", tweaks: [
            ZeroTweak(name: "Clear CC Modules", icon: "circle.grid.2x2", minSupportedVersion: 18.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/modulesSheer.descendantrecipe", "/System/Library/ControlCenter/Bundles/FocusUIModule.bundle/Info.plist"]),
            ZeroTweak(name: "Disable Slider Icons ", icon: "sun.max", minSupportedVersion: 16.0, maxSupportedVersion: 17.7, paths: ["/System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/index.xml", "/System/Library/PrivateFrameworks/MediaControls.framework/Volume.ca/index.xml"]),
            ZeroTweak(name: "Disable Slider Icons", icon: "sun.max", minSupportedVersion: 18.0, maxSupportedVersion: 18.3, paths: ["/System/Library/ControlCenter/Bundles/DisplayModule.bundle/Brightness.ca/index.xml", "/System/Library/PrivateFrameworks/MediaControls.framework/VolumeSemibold.ca/index.xml"]),
            ZeroTweak(name: "Hide Player Buttons", icon: "play", minSupportedVersion: 17.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/MediaControls.framework/PlayPauseStop.ca/index.xml", "/System/Library/PrivateFrameworks/MediaControls.framework/ForwardBackward.ca/index.xml"]),
            ZeroTweak(name: "Hide DND Icon", icon: "moon", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/FocusUI.framework/dnd_cg_02.ca/main.caml"]),
            ZeroTweak(name: "Hide WiFi & Bluetooth Icons", icon: "wifi", minSupportedVersion: 16.0, maxSupportedVersion: 17.7, paths: ["/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle/Bluetooth.ca/index.xml", "/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle/WiFi.ca/index.xml"]),
            ZeroTweak(name: "Disable Screen Mirroring Module", icon: "rectangle.on.rectangle", minSupportedVersion: 16.0, maxSupportedVersion: 17.7, paths: ["/System/Library/ControlCenter/Bundles/AirPlayMirroringModule.bundle/Info.plist"]),
            ZeroTweak(name: "Disable Orientation Lock Module", icon: "lock.rotation", minSupportedVersion: 16.0, maxSupportedVersion: 17.7, paths: ["/System/Library/ControlCenter/Bundles/OrientationLockModule.bundle/Info.plist"]),
            ZeroTweak(name: "Disable Focus Module", icon: "moon", minSupportedVersion: 16.0, maxSupportedVersion: 17.7, paths: ["/System/Library/ControlCenter/Bundles/FocusUIModule.bundle/Info.plist"])
        ]),
        ZeroSection(name: "Sound Effects", icon: "speaker.wave.2", tweaks: [
            ZeroTweak(name: "Disable AirDrop Ping", icon: "dot.radiowaves.left.and.right", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/Audio/UISounds/Modern/airdrop_invite.caf"]),
            ZeroTweak(name: "Disable Charge Sound", icon: "bolt", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/Audio/UISounds/connect_power.caf"]),
            ZeroTweak(name: "Disable Low Battery Sound", icon: "battery.25", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/Audio/UISounds/low_power.caf"]),
            ZeroTweak(name: "Disable Payment Sounds", icon: "creditcard", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/Audio/UISounds/payment_success.caf", "/System/Library/Audio/UISounds/payment_failure.caf"]),
            ZeroTweak(name: "Disable Dialing Sounds", icon: "phone", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/Audio/UISounds/nano/dtmf-0.caf", "/System/Library/Audio/UISounds/nano/dtmf-1.caf", "/System/Library/Audio/UISounds/nano/dtmf-2.caf", "/System/Library/Audio/UISounds/nano/dtmf-3.caf", "/System/Library/Audio/UISounds/nano/dtmf-4.caf", "/System/Library/Audio/UISounds/nano/dtmf-5.caf", "/System/Library/Audio/UISounds/nano/dtmf-6.caf", "/System/Library/Audio/UISounds/nano/dtmf-7.caf", "/System/Library/Audio/UISounds/nano/dtmf-8.caf", "/System/Library/Audio/UISounds/nano/dtmf-9.caf", "/System/Library/Audio/UISounds/nano/dtmf-pound.caf", "/System/Library/Audio/UISounds/nano/dtmf-star.caf"])
        ]),
        ZeroSection(name: "Risky Tweaks", icon: "exclamationmark.triangle", hex: hexCode(color: .red), sectionType: .risky, tweaks: [
            ZeroTweak(name: "Remove CC Background", icon: "square.dashed", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/CoreMaterial.framework/modulesBackground.materialrecipe"]),
            ZeroTweak(name: "Disable ALL Banners", icon: "exclamationmark.triangle", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/SpringBoard.framework/BannersAuthorizedBundleIDs.plist"]),
            ZeroTweak(name: "Disable ALL Accent Colors", icon: "paintpalette", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/CoreUI.framework/DesignLibrary-iOS.bundle/iOSRepositories/DarkStandard.car"]),
            ZeroTweak(name: "Break System Font", icon: "text.badge.xmark", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/Fonts/Core/SFUI.ttf", "/System/Library/Fonts/Core/Helvetica.ttc"]),
            ZeroTweak(name: "Break Clock Font", icon: "clock", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/Fonts/Core/ADTNumeric.ttc"]),
            ZeroTweak(name: "Break SpringBoard names", icon: "house", minSupportedVersion: 16.0, maxSupportedVersion: 18.3, paths: ["/System/Library/PrivateFrameworks/SpringBoardUIServices.framework/SpringBoardUIServices.loctable", "/System/Library/PrivateFrameworks/SpringBoardHome.framework/SpringBoardHome.loctable", "/System/Library/CoreServices/SpringBoard.app/SpringBoard.loctable"]),
        ])
    ]
}
