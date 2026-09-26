# DuoLab

Companion code for *Developing for iPhone Duo: Approaches and Tips* by Ihor
Malovanyi. The book (PDF + EPUB, 159 pages, hardware-verified update free for
every buyer) is on Gumroad: https://ihormalovanyi.gumroad.com/l/iphone-duo and Buy Me a Coffee: <link>. The first
chapter is free: https://ihormalovanyi.gumroad.com/l/iphone-duo-sample.

## What this is

One Xcode project with four apps and a UI test bundle. DuoLab is a SwiftUI
app with one small screen per topic of the book, grouped by chapter.
DuoLab UIKit shows the same topics with UIKit. DuoProbe is the instrument
behind the book's measured numbers: it logs geometry, size classes, insets,
reserved regions and hinge data as JSON lines. Postcards is the showcase
app: one small product that uses the book's approaches together (see
below). Every code listing in the book is cut from these sources, so the
book's code is the code that builds here.

## Requirements

- Xcode 27.1 beta (27A9269) or later, with the iOS 27.1 SDK. Xcode 27.1
  beta needs macOS Tahoe 26.6 or later.
- The iOS 27.1 simulator runtime, which installs separately from Xcode:
  Xcode > Settings > Components.
- The iPhone Duo simulator, which appears with the iOS 27.1 runtime.
- An iPhone Duo for the camera screens (Chapters 13 and 14).

Every target deploys to iOS 27.0 and builds in the Swift 6 language mode
with complete concurrency checking. API that is new in iOS 27.1 is used
behind `if #available(iOS 27.1, *)` or `@available(iOS 27.1, *)`.

## Build

1. Optionally regenerate the project from `project.yml` with
   [XcodeGen](https://github.com/yonaskolb/XcodeGen): `xcodegen generate`.
   The Info.plist files in `Config/` are generated from `project.yml` too.
2. Open `DuoLab.xcodeproj`.
3. Pick the iPhone Duo simulator and one of the four schemes: **DuoLab**,
   **DuoLabUIKit**, **DuoProbe** or **Postcards**. The DuoLab scheme's Test action runs
   the **DuoLabUITests** bundle.
4. To run on a device, choose your team under Signing & Capabilities for
   each target.

From the command line, in this folder:

```
xcodebuild -project DuoLab.xcodeproj -scheme DuoLab \
  -destination 'platform=iOS Simulator,name=iPhone Duo' build
```

## Postcards, the showcase app

A postcard folds, so the fold of the device becomes the crease of the
card. Open, fold and rotate the iPhone Duo simulator with a card on
screen (Device Hub's pose buttons, or the hinge slider that appears while
you hold Option).

- Closed: the list gets the system's vertical tab bar (Chapter 7); a card
  shows one side at a time and flips between them.
- Open in a tall layout: the split view shows the list and the card; the
  card's two sides stack (Chapters 4, 6, 9).
- Open in a wide layout and folded like a book: the split view's columns
  land on the fold; the spread is an `ArrangementView` with the split
  style, and the stamp keeps clear of the camera's occlusion region
  (Chapters 8, 9).
- Folded like a laptop: picture on top, message and keyboard below
  (Chapters 11, 17).
- While folding: the picture tilts with the hinge angle (Chapter 10).
- Edit (the sliders button on a card): a sheet with the card's details,
  half height when closed, a form sheet on the inner display.
- Blueprint (the dashed-square toggle, in the list and on a card): draws
  what the system reports over the screen: safe area, bar, fold, cameras.
  The cards lay out around these lines. Taps pass through it.

Sources are in `Postcards/`; screenshots of every pose are in
`Postcards/Screenshots/`. Cards are saved as JSON in the app's Documents
folder; a fresh install shows six sample cards.

## Where the book's snippets are

A listing in the book is the code between two marker lines:

```
// snippet:begin ch08-query-regions
...
// snippet:end ch08-query-regions
```

The id starts with the chapter number. Listings are at most 76 columns
wide once the common indentation is removed. The HTML page in Chapter 16
is printed from the `DuoPage.html` constant; `Web/duo.html` is the same
page, and debug builds check that the two match.

| Snippet | File |
|---|---|
| `ch01-size-class-readout` | `DuoLab/Screens/Ch01HelloDuo.swift` |
| `ch02-scene-size-swiftui` | `DuoLab/Screens/Ch02SceneGeometry.swift` |
| `ch02-scene-phase` | `DuoLab/Screens/Ch02SceneGeometry.swift` |
| `ch02-uiscreen-replacement` | `DuoLabUIKit/Screens/Ch02SceneGeometry.swift` |
| `ch02-effective-geometry` | `DuoLabUIKit/Screens/Ch02SceneGeometry.swift` |
| `ch03-probe-record` | `Shared/ProbeRecord.swift` |
| `ch04-viewthatfits` | `DuoLab/Screens/Ch04FluidLayout.swift` |
| `ch04-anylayout-lifted-state` | `DuoLab/Screens/Ch04FluidLayout.swift` |
| `ch04-ongeometrychange` | `DuoLab/Screens/Ch04FluidLayout.swift` |
| `ch04-container-relative-frame` | `DuoLab/Screens/Ch04FluidLayout.swift` |
| `ch04-antipattern-root-branch` | `DuoLab/Screens/Ch04FluidLayout.swift` |
| `ch04-trait-tracking` | `DuoLabUIKit/Screens/Ch04FluidLayout.swift` |
| `ch04-compositional-even-columns` | `DuoLabUIKit/Screens/Ch04FluidLayout.swift` |
| `ch05-safe-area-per-edge` | `DuoLab/Screens/Ch05SafeAreas.swift` |
| `ch05-background-bleed` | `DuoLab/Screens/Ch05SafeAreas.swift` |
| `ch05-concentric-corners` | `DuoLab/Screens/Ch05SafeAreas.swift` |
| `ch05-background-extension` | `DuoLab/Screens/Ch05SafeAreas.swift` |
| `ch05-layout-margins-asymmetric` | `DuoLabUIKit/Screens/Ch05SafeAreas.swift` |
| `ch05-layout-region-bar` | `DuoLabUIKit/Screens/Ch05SafeAreas.swift` |
| `ch05-corner-configuration` | `DuoLabUIKit/Screens/Ch05SafeAreas.swift` |
| `ch05-background-extension-view` | `DuoLabUIKit/Screens/Ch05SafeAreas.swift` |
| `ch06-navigation-split-view` | `DuoLab/Screens/Ch06Containers.swift` |
| `ch06-tabview-sidebar-placement` | `DuoLab/Screens/Ch06Containers.swift` |
| `ch06-sheet-placement` | `DuoLab/Screens/Ch06Containers.swift` |
| `ch06-popover-menu-alert` | `DuoLab/Screens/Ch06Containers.swift` |
| `ch06-split-view-controller` | `DuoLabUIKit/Screens/Ch06Containers.swift` |
| `ch06-tab-sidebar-placement` | `DuoLabUIKit/Screens/Ch06Containers.swift` |
| `ch06-sheet-preferred-placement` | `DuoLabUIKit/Screens/Ch06Containers.swift` |
| `ch07-toolbar-ordering` | `DuoLab/Screens/Ch07Bars.swift` |
| `ch07-overflow-priority` | `DuoLab/Screens/Ch07Bars.swift` |
| `ch07-badges` | `DuoLab/Screens/Ch07Bars.swift` |
| `ch07-axis-behavior` | `DuoLab/Screens/Ch07Bars.swift` |
| `ch07-vertical-edge-custom-view` | `DuoLab/Screens/Ch07Bars.swift` |
| `ch07-vertical-behavior-opt-out` | `DuoLab/Screens/Ch07Bars.swift` |
| `ch07-compression-behavior` | `DuoLab/Screens/Ch07Bars.swift` |
| `ch07-uikit-axis-behavior` | `DuoLabUIKit/Screens/Ch07Bars.swift` |
| `ch07-uikit-overflow` | `DuoLabUIKit/Screens/Ch07Bars.swift` |
| `ch07-uikit-compression` | `DuoLabUIKit/Screens/Ch07Bars.swift` |
| `ch07-vertical-bar-edge-trait` | `DuoLabUIKit/Screens/Ch07Bars.swift` |
| `ch07-preferred-vertical-bar-behavior` | `DuoLabUIKit/Screens/Ch07Bars.swift` |
| `ch08-query-regions` | `DuoLab/Screens/Ch08ReservedRegions.swift` |
| `ch08-draw-regions` | `DuoLab/Screens/Ch08ReservedRegions.swift` |
| `ch08-displace-custom-bar` | `DuoLab/Screens/Ch08ReservedRegions.swift` |
| `ch08-even-columns` | `DuoLab/Screens/Ch08ReservedRegions.swift` |
| `ch08-layout-direction-behavior` | `DuoLab/Screens/Ch08ReservedRegions.swift` |
| `ch08-uikit-query-regions` | `DuoLabUIKit/Screens/Ch08ReservedRegions.swift` |
| `ch08-uikit-layout-timing` | `DuoLabUIKit/Screens/Ch08ReservedRegions.swift` |
| `ch09-arrangement-basic` | `DuoLab/Screens/Ch09Arrangements.swift` |
| `ch09-split-ratio` | `DuoLab/Screens/Ch09Arrangements.swift` |
| `ch09-split-size` | `DuoLab/Screens/Ch09Arrangements.swift` |
| `ch09-split-fixed-size` | `DuoLab/Screens/Ch09Arrangements.swift` |
| `ch09-split-axes` | `DuoLab/Screens/Ch09Arrangements.swift` |
| `ch09-overlay-edge` | `DuoLab/Screens/Ch09Arrangements.swift` |
| `ch09-overlay-zindex` | `DuoLab/Screens/Ch09Arrangements.swift` |
| `ch09-custom-style` | `DuoLab/Screens/Ch09Arrangements.swift` |
| `ch09-secondary-vanishes` | `DuoLab/Screens/Ch09Arrangements.swift` |
| `ch09-uikit-arrangement` | `DuoLabUIKit/Screens/Ch09Arrangements.swift` |
| `ch09-uikit-split-dimensions` | `DuoLabUIKit/Screens/Ch09Arrangements.swift` |
| `ch09-uikit-overlay` | `DuoLabUIKit/Screens/Ch09Arrangements.swift` |
| `ch09-uikit-overlay-zindex` | `DuoLabUIKit/Screens/Ch09Arrangements.swift` |
| `ch10-onhingechange` | `DuoLab/Screens/Ch10Hinge.swift` |
| `ch10-hinge-effect` | `DuoLab/Screens/Ch10Hinge.swift` |
| `ch10-uikit-hinge-interaction` | `DuoLabUIKit/Screens/Ch10Hinge.swift` |
| `ch11-pose-layout-matrix` | `DuoLab/Screens/Ch11Poses.swift` |
| `ch12-open-window` | `DuoLab/Screens/Ch12Scenes.swift` |
| `ch12-scene-phase-log` | `DuoLab/Screens/Ch12Scenes.swift` |
| `ch12-activation-action` | `DuoLabUIKit/Screens/Ch12Windows.swift` |
| `ch12-request-scene-error` | `DuoLabUIKit/Screens/Ch12Windows.swift` |
| `ch13-capture-actor` | `DuoLab/Screens/Ch13Camera.swift` |
| `ch13-direction-coordinator` | `DuoLab/Screens/Ch13Camera.swift` |
| `ch13-switch-input` | `DuoLab/Screens/Ch13Camera.swift` |
| `ch13-mirroring` | `DuoLab/Screens/Ch13Camera.swift` |
| `ch13-rotation-coordinator` | `DuoLab/Screens/Ch13Camera.swift` |
| `ch13-preview-aspect` | `DuoLab/Screens/Ch13Camera.swift` |
| `ch14-accessory-model` | `DuoLab/Screens/Ch14CaptureAccessory.swift` |
| `ch14-scene-accessory` | `DuoLab/Screens/Ch14CaptureAccessory.swift` |
| `ch14-uikit-register-accessory` | `DuoLabUIKit/Screens/Ch14CaptureAccessory.swift` |
| `ch14-uikit-accessory-role` | `DuoLabUIKit/Screens/Ch14CaptureAccessory.swift` |
| `ch15-metal-drawable-resize` | `DuoLab/Screens/Ch15Games.swift` |
| `ch15-spritekit-scale-mode` | `DuoLab/Screens/Ch15Games.swift` |
| `ch15-letterbox-math` | `DuoLab/Screens/Ch15Games.swift` |
| `ch16-wkwebview` | `DuoLab/Screens/Ch16Web.swift` |
| `ch16-duo-html` | `DuoLab/Screens/Ch16Web.swift` |
| `ch17-biometry-copy` | `DuoLab/Screens/Ch17System.swift` |
| `ch17-accessibility-readout` | `DuoLab/Screens/Ch17System.swift` |
| `ch17-uikit-reduce-transparency` | `DuoLabUIKit/Screens/Ch17System.swift` |
| `ch18-uitest-matrix` | `DuoLabUITests/PoseMatrixUITests.swift` |
| `ch18-snapshot-helper` | `DuoLabUITests/PoseMatrixUITests.swift` |
| `ch19-availability-gate` | `DuoLab/Screens/Ch19Migration.swift` |
| `ch19-catalyst-guard` | `DuoLab/Screens/Ch19Migration.swift` |

## DuoProbe

1. Run the DuoProbe scheme on the iPhone Duo simulator or on a device.
2. Pick the pose you are about to set. The labels are the cases of
   `PoseLabel` in `Shared/PoseLabel.swift`: closed portrait and landscape,
   open tall and wide, book, laptop, tent, Split View left and right,
   Picture in Picture, a sheet on each display, right-to-left, Reduce
   Transparency, and custom.
3. Set the pose. In the simulator, use the Device Hub controls; there is
   no command-line control for the fold.
4. Use the app. Every layout pass, hinge update, scene activation change,
   keyboard notification and Record Now tap appends one line to
   `Documents/probe.jsonl`. The fields are listed in
   `Shared/ProbeRecord.swift`; a value that isn't available is `null`.
5. Tap Share Log, or copy the log from the simulator:

```
xcrun simctl get_app_container booted pro.ihor.unfolded.DuoProbe data
```

The log is in `Documents/` inside that folder. On a device the file is
also visible in the Files app, under On My iPhone > DuoProbe.

Synthesized taps may not reach apps in the iPhone Duo simulator, so the
apps also read a few launch-environment values, passed as `SIMCTL_CHILD_`
variables to `xcrun simctl launch`: `DUOPROBE_POSE`, `DUOPROBE_TAB=uikit`
and `DUOPROBE_FOCUS_KEYBOARD=1` for DuoProbe, and, in debug builds,
`DUOLAB_DEMO=<demo>` for DuoLab (a case of `Demo`, such as
`hingeReadout`) and `DUOLAB_DEMO=<chapter>` for DuoLab UIKit.

## Known limitations

- The simulator has no camera. The camera screens show a placeholder there;
  the capture code and the camera capture accessory need a device.
- Mac Catalyst isn't a destination in this version. In Xcode 27.1 beta,
  iOS 27.1 symbols don't compile for Mac Catalyst (known issue 185924957),
  so every use of them sits behind `#if !targetEnvironment(macCatalyst)`.
- Folding the simulator needs Device Hub; poses can't be set from the
  command line.
- Values DuoProbe and DuoLab report in the simulator come from the iOS
  27.1 simulator runtime; check them on hardware.

## License

MIT. Copyright (c) 2026 Ihor Malovanyi. See `LICENSE`.

## Reference files

- `API-REFERENCE.md`: every symbol the book names (656 entries), with the SDK's availability annotation, the declaring file and line in the iOS 27.1 SDK, the documentation link where one exists, and the chapters that use it. Appendix A of the book prints only the iOS 27.1 additions; this file is the complete table.
- `SPEC.md`: the project's structure and the table of snippet ids. Each listing in the book sits between `// snippet:begin <id>` and `// snippet:end <id>` markers in these sources; search for the id to find the code in context.
