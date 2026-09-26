# Companion project specification (DuoLab + DuoProbe)

Owner: editor. Implementer: code-author (Phase 3). Ground truth for names: `research/symbols.csv` (only `verified`/`sdk` rows may be used). This file lists WHAT the companion must contain; the code-author decides HOW, within the constraints below.

## 1. Project layout and settings

```
companion/
  project.yml            xcodegen spec → DuoLab.xcodeproj (regenerate with `xcodegen generate`)
  DuoLab.xcodeproj       generated, committed
  README.md              build instructions, requirements, license notice (author: Ihor Malovanyi)
  LICENSE                MIT, © 2026 Ihor Malovanyi
  Shared/                code used by all targets (ProbeRecord, PoseLabel, formatting helpers)
  DuoLab/                SwiftUI app (target DuoLab)
  DuoLabUIKit/           UIKit app (target DuoLabUIKit)
  DuoProbe/              instrument app (target DuoProbe; SwiftUI shell + one UIKit screen)
  DuoLabUITests/         XCUITest target with the pose-matrix skeleton (ch18)
  Web/                   duo.html for the WKWebView demo (ch16)
```

- Deployment target iOS 27.0 for every target; `SWIFT_VERSION = 6.0` (Swift 6 language mode); `SWIFT_STRICT_CONCURRENCY = complete`; `SWIFT_APPROACHABLE_CONCURRENCY` may be on; `MainActor` default isolation is allowed if it keeps snippets shorter.
- Every iOS 27.1 API is used behind `if #available(iOS 27.1, *)` (or `@available(iOS 27.1, *)` on a whole view/type). Chapter 19 teaches a reusable SwiftUI gating pattern; the same helper is used everywhere so readers see one idiom.
- No Mac Catalyst destination in v1.0 (Xcode 27.1 known issues 185924957 / 187046347). Wrap any Catalyst-sensitive code in `#if !targetEnvironment(macCatalyst)` anyway, so a reader adding Catalyst builds.
- Zero warnings. Any warning that cannot be fixed is listed in `PLAN.md` with a reason.
- Bundle ids: `pro.ihor.unfolded.DuoLab`, `.DuoLabUIKit`, `.DuoProbe`. Display names: DuoLab, DuoLab UIKit, DuoProbe. Launch screen via `UILaunchScreen` dictionary in Info.plist (a launch screen is required with the iOS 27 SDK). Scene-based life cycle in every target (`UIApplicationSceneManifest`), and `UIApplicationSupportsMultipleScenes = true` for DuoLab and DuoLabUIKit (ch12 demo).
- Build command (the gate): `DEVELOPER_DIR=/Applications/Xcode.27.1.beta.app/Contents/Developer xcodebuild -project companion/DuoLab.xcodeproj -scheme <scheme> -destination 'platform=iOS Simulator,name=iPhone Duo' -derivedDataPath /tmp/unfolded-dd build`. All three schemes must build clean; `make companion` runs them.
- No third-party dependencies. No Apple imagery. No author or tool names other than "Ihor Malovanyi" in headers/README/LICENSE.

## 2. Snippet conventions

- Markers on their own lines: `// snippet:begin <id>` … `// snippet:end <id>`; ids are `chNN-kebab-name`, unique across the project.
- Inside markers: ≤ 76 columns after removing the common leading indentation, no trailing whitespace, no marker nesting, no `// MARK` noise. Snippets must read as complete, idiomatic units (a whole view, a whole method, or a whole type). Anything the reader needs to understand the snippet is inside it or named in the chapter.
- Every API named in a snippet must be a `verified` or `sdk` row of `research/symbols.csv`. If a name from this spec does not exist in the SDK, do NOT invent a replacement: stop, write it in `companion/OPEN-ISSUES.md`, and keep building the rest.
- SwiftUI snippets live in `DuoLab/Screens/ChNN*.swift`; UIKit snippets in `DuoLabUIKit/Screens/ChNN*.swift`. One file per chapter per target.

## 3. DuoLab (SwiftUI) — screens and required snippet ids

DuoLab is a `NavigationSplitView`-free `NavigationStack` app with a `List` of demo screens grouped by chapter, plus a `TabView` demo entry. Each screen is small, self-explanatory, and safe to run in every pose. Required snippets (the chapter briefs reference exactly these ids):

| Chapter | Screen | Snippet ids |
|---|---|---|
| 1 | "Hello Duo": shows horizontal/vertical size class, scene size, display scale, and whether a vertical bar edge exists | `ch01-size-class-readout` |
| 2 | Scene geometry readout: `onGeometryChange` size vs `UIScreen.main.bounds` (via a tiny UIKit helper) to show the discrepancy; scene phase | `ch02-scene-size-swiftui`, `ch02-scene-phase` |
| 3 | DuoProbe walkthrough pointer (text only) | — |
| 4 | Fluid layout: `ViewThatFits` card row; `AnyLayout` switching H/V by size class with lifted state; `onGeometryChange`; `containerRelativeFrame` grid; anti-pattern shown as commented-out code in a `.pitfall` snippet | `ch04-viewthatfits`, `ch04-anylayout-lifted-state`, `ch04-ongeometrychange`, `ch04-container-relative-frame`, `ch04-antipattern-root-branch` |
| 5 | Safe areas: per-edge readout, background bleed with `ignoresSafeArea` on the background only, concentric corners (`ConcentricRectangle`, `containerShape`), `backgroundExtensionEffect()` under bars, RTL toggle | `ch05-safe-area-per-edge`, `ch05-background-bleed`, `ch05-concentric-corners`, `ch05-background-extension` |
| 6 | Containers: `NavigationSplitView` three-column demo, `TabView` with `defaultTabBarPlacement(.sidebar)` opt-in, sheet with `presentationPlacement(.leading/.trailing/.center)` picker, popover/menu/alert triggers | `ch06-navigation-split-view`, `ch06-tabview-sidebar-placement`, `ch06-sheet-placement`, `ch06-popover-menu-alert` |
| 7 | Bars: `toolbar` with `cancellationAction`, `topBarPinnedTrailing`, groups; `axisBehavior` per item; `toolbarVerticalBehavior(.disabled)` toggle on a pushed screen; `toolbarVerticalCompressionBehavior`; `visibilityPriority` + `ToolbarOverflowMenu`; custom view reading `toolbarVerticalEdge`; badges | `ch07-toolbar-ordering`, `ch07-axis-behavior`, `ch07-vertical-behavior-opt-out`, `ch07-compression-behavior`, `ch07-overflow-priority`, `ch07-vertical-edge-custom-view`, `ch07-badges` |
| 8 | Reserved regions: `GeometryReader` + `reservedRegions(kind:options:layoutDirectionBehavior:)` overlay drawing every region (active vs inactive, frame vs margins); a custom bottom bar that moves out of the division; even-column grid driven by inactive division; `.fixed` vs `.mirrors` in RTL | `ch08-query-regions`, `ch08-draw-regions`, `ch08-displace-custom-bar`, `ch08-even-columns`, `ch08-layout-direction-behavior` |
| 9 | Arrangements: `ArrangementView` primary/secondary with style picker (automatic/split/overlay), `splitArrangementLayoutRatio`, `splitArrangementLayoutSize`, `splitArrangementFixedLayoutSize`, `SplitArrangementViewStyle.axes`, `overlayArrangementEdge`, reading `splitArrangementAxis` and `overlayArrangementZIndex`, a custom `ArrangementViewStyle`; "secondary disappears" reproduction toggle | `ch09-arrangement-basic`, `ch09-split-ratio`, `ch09-split-size`, `ch09-split-fixed-size`, `ch09-split-axes`, `ch09-overlay-edge`, `ch09-overlay-zindex`, `ch09-custom-style`, `ch09-secondary-vanishes` |
| 10 | Hinge: `onHingeChange` readout (status, angle in degrees and radians, nil), a parallax/blur effect driven by angle with `.partiallyOpen` gate and reset branch | `ch10-onhingechange`, `ch10-hinge-effect` |
| 11 | Pose gallery: one screen that applies the ch11 layout matrix (tall/wide/laptop) using only size classes + regions | `ch11-pose-layout-matrix`, `ch11-fold-split-layout` |
| 12 | Scenes: open a new window via `openWindow` with error handling; `scenePhase` logging; `UIWindowScene.ActivationAction` in the UIKit target | `ch12-open-window`, `ch12-scene-phase-log` |
| 13 | Camera (device-only; simulator shows a placeholder): `AVCaptureDeviceDirectionCoordinator` per preview view, descriptors handed to a `CaptureSession` actor, single-input switch with preview mask, mirroring rule, `RotationCoordinator` per device, `dynamicAspectRatio` + `videoGravity` | `ch13-direction-coordinator`, `ch13-capture-actor`, `ch13-switch-input`, `ch13-mirroring`, `ch13-rotation-coordinator`, `ch13-preview-aspect` |
| 14 | Capture accessory: `.sceneAccessory { CameraCaptureAccessory(isEnabled:) { … } }` with shared observable model; role check | `ch14-scene-accessory`, `ch14-accessory-model` |
| 15 | Games/video: `MTKView`-hosting view that resizes drawables, `SpriteKit` scene with scale mode picker, letterbox math helper (numbers labeled derived) | `ch15-metal-drawable-resize`, `ch15-spritekit-scale-mode`, `ch15-letterbox-math` |
| 16 | Web: `WKWebView` loading `Web/duo.html` (viewport-fit=cover, per-edge env(), dvh, container query, ResizeObserver readout) | `ch16-wkwebview`, `ch16-duo-html` (HTML file; marker lines use `<!-- snippet:begin … -->`, see §2 note below) |
| 17 | System: `LAContext.biometryType`-aware copy, Reduce Transparency and Dynamic Type readouts, RTL toggle pointer | `ch17-biometry-copy`, `ch17-accessibility-readout` |
| 18 | Testing: XCUITest skeleton iterating the pose matrix with a `PoseLabel` enum and an env-var gate for unsupported poses; snapshot helper | `ch18-uitest-matrix`, `ch18-snapshot-helper` |
| 19 | Migration: reusable availability gate (`@ViewBuilder` helper or `ViewModifier`) for 27.1 modifiers; `#if !targetEnvironment(macCatalyst)` guard | `ch19-availability-gate`, `ch19-catalyst-guard` |

Note on HTML snippets: the preprocessor only scans `*.swift`; put the HTML snippet inside a Swift multi-line string constant in `DuoLab/Screens/Ch16Web.swift` (marker lines around the string) AND ship the same HTML as `Web/duo.html`. Keep them identical.

## 4. DuoLabUIKit — mirrors the UIKit side

A `UITabBarController` (two tabs: Demos, Settings) whose Demos tab is a `UINavigationController` with a table of screens. Required snippet ids: `ch02-uiscreen-replacement`, `ch02-effective-geometry`, `ch04-trait-tracking`, `ch04-compositional-even-columns`, `ch05-layout-margins-asymmetric`, `ch05-layout-region-bar`, `ch05-corner-configuration`, `ch05-background-extension-view`, `ch06-split-view-controller`, `ch06-tab-sidebar-placement`, `ch06-sheet-preferred-placement`, `ch07-preferred-vertical-bar-behavior`, `ch07-uikit-axis-behavior`, `ch07-vertical-bar-edge-trait`, `ch07-uikit-compression`, `ch07-uikit-overflow`, `ch08-uikit-query-regions`, `ch08-uikit-layout-timing`, `ch09-uikit-arrangement`, `ch09-uikit-split-dimensions`, `ch09-uikit-overlay`, `ch10-uikit-hinge-interaction`, `ch12-activation-action`, `ch12-request-scene-error`, `ch14-uikit-register-accessory`, `ch14-uikit-accessory-role`, `ch17-uikit-reduce-transparency`. Same rules as §3.

## 5. DuoProbe — the instrument

Purpose: reproduce every number in the book and settle the measurable conflicts (C-01, C-03…C-08, C-11, C-14 keyboard notifications).

- UI: a SwiftUI shell with a pose picker (`PoseLabel`: `closedPortrait, closedLandscape, openTall, openWide, book, laptop, tent, splitLeft, splitRight, pipStacked, sheetOuter, sheetInner, rtl, reduceTransparency, custom`), a "Record now" button, a live readout of the last record, a "Share log" button (share sheet for `Documents/probe.jsonl`), and a second tab hosting the UIKit probe view controller.
- On every layout pass (SwiftUI `onGeometryChange`, UIKit `viewDidLayoutSubviews`), every hinge update, every scene activation change, every keyboard notification, and every "Record now": append ONE JSON line to `Documents/probe.jsonl` and log it with `os_log` (subsystem `pro.ihor.unfolded.DuoProbe`, category `probe`). Debounce layout records to at most 5/s.
- `ProbeRecord` (Codable, in Shared) fields, all present in every line (`null` when unavailable, and `source: "swiftui" | "uikit"`):
  `ts` (ISO8601 with ms), `pose` (label), `source`, `event` (`layout | hinge | scene | keyboard | manual`), `sceneSize {w,h}`, `effectiveGeometryBounds {x,y,w,h}`, `uiScreenMainBounds {w,h}`, `windowSceneScreenBounds {w,h}`, `displayScale`, `nativeScale`, `hSizeClass`, `vSizeClass`, `interfaceOrientation`, `userInterfaceIdiom`, `safeAreaInsets {top,leading,bottom,trailing}`, `layoutMargins {…}`, `toolbarVerticalEdge` (SwiftUI) / `verticalBarEdge` (UIKit trait), `regionsDivisionActive [ {frame, margins, isActive} ]`, `regionsDivisionAll` (with `.includeInactive`), `regionsOcclusionActive`, `regionsOcclusionAll`, `hingeStatus`, `hingeAngleDegrees`, `hingeAngleRadians` (UIKit), `hingeIsNil`, `sceneActivationState`, `scenePhase` (SwiftUI), `keyboardFrame` (when the event is keyboard), `layoutDirection`, `reduceTransparency`, `bundleSDKBuild` (from Info.plist `DTSDKBuild`), `runtimeVersion` (`ProcessInfo.operatingSystemVersionString`).
- The UIKit screen uses `UIHingeInteraction`, `reservedRegions(kind:options:)`, `traitCollection.verticalBarEdge`, `registerForTraitChanges` for size classes and the vertical-bar-edge trait; the SwiftUI screen uses `onHingeChange`, `GeometryReader` + `reservedRegions(kind:options:layoutDirectionBehavior:)`, `toolbarVerticalEdge`.
- Snippet `ch03-probe-record` wraps the `ProbeRecord` struct declaration (field names only, ≤ 40 lines; shorten with a nested `Insets` type if needed) so Chapter 3 can show the log schema.
- A `ProbeSummary` script is NOT part of the app; `research/measurements/summarize.py` (sdk-inspector) turns the jsonl into tables.
- Everything 27.1 is availability-gated; on a non-Duo device the app still runs and logs `null` for Duo-only fields.

## 6. README.md (ships in the zip)

Sections: What this is (one paragraph, no marketing), Requirements (Xcode 27.1 beta 27A9269 or later, iOS 27.1 simulator runtime, macOS version), Build (`xcodegen generate` optional; open `DuoLab.xcodeproj`; select the iPhone Duo simulator; three schemes), Where the book's snippets are (the marker convention and a table id → file), DuoProbe usage (poses, log location, `xcrun simctl get_app_container booted pro.ihor.unfolded.DuoProbe data`), Known limitations (simulator has no camera; ch13/ch14 need a device; Catalyst not supported in 27.1 beta), License (MIT, Ihor Malovanyi).

## 6. Postcards — the showcase app (added 2026-09-25)

- Target `Postcards` (SwiftUI only, bundle id `pro.ihor.unfolded.Postcards`, iOS 27.0 deployment, iOS 27.1 API behind `@available`), sources in `Postcards/`: `Model/` (`Postcard`, `PostcardStore` = JSON in Documents, six sample cards), `Views/` (`RootView` TabView; `CardsSplitView` NavigationSplitView; `CardDetail` = `ArrangementView` `.split` in regular widths, `FlipCard` in compact; `PostcardFront`, `PostcardBack` with the stamp displaced below any active occlusion region; `HingeTilt` from `onHingeChange`; `Blueprint` overlay (toggle in the list and on a card; no top panel, labels of two or three words; no separate tab: a map without the app under it explained nothing); `EditCardSheet` (`.sheet` with `.presentationDetents([.medium, .large])`: half height when closed, a form sheet on the inner display); `AboutView`). Debug launch arguments for screenshots: `-showFirstCard YES`, `-edit YES`, `-blueprint YES` (the last one is the `@AppStorage` key).
- Purpose: one product that shows the book's approaches together; no snippet markers (the chapters print DuoLab code), so its code may change freely. Keep it visually restrained: flat colours, serif for the written side, no gradients.
- Verified 2026-09-25 in the simulator through Device Hub: closed portrait and landscape (vertical bar follows the camera side), open tall and wide, book (split view columns land on the fold), laptop (front above, back and keyboard below), Blueprint overlay in every pose. Screenshots in `Postcards/Screenshots/`. Orientation note: the target supports all four orientations (Apple's FAQ for multitasking apps), so after Device Hub rotations the inner display can show the app upside down, while the outer display keeps the last landscape orientation (iOS never rotates iPhone apps to upside-down portrait); this is the system's behaviour, not the app's.
