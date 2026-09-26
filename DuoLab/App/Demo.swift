//
//  Demo.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

/// Every demo screen in DuoLab, in the order the book introduces them.
enum Demo: String, CaseIterable, Identifiable, Hashable {
    // Chapter 1
    case sizeClassReadout
    // Chapter 2
    case sceneGeometry
    // Chapter 3
    case probeWalkthrough
    // Chapter 4
    case viewThatFits, anyLayout, geometryChange, containerRelativeFrame
    case rootBranch
    // Chapter 5
    case safeAreaEdges, backgroundBleed, concentricCorners
    case backgroundExtension
    // Chapter 6
    case splitView, tabSidebar, sheetPlacement, popoverMenuAlert
    // Chapter 7
    case toolbarOrdering, axisBehavior, verticalBehavior, compression
    case overflow, verticalEdge, badges
    // Chapter 8
    case queryRegions, drawRegions, customBar, evenColumns
    case layoutDirection
    // Chapter 9
    case arrangementBasic, splitRatio, splitSize, splitFixedSize
    case splitAxes, overlayEdge, overlayZIndex, customStyle
    case secondaryVanishes
    // Chapter 10
    case hingeReadout, hingeEffect
    // Chapter 11
    case poseMatrix
    // Chapter 12
    case openWindow, scenePhaseLog
    // Chapter 13
    case camera
    // Chapter 14
    case captureAccessory
    // Chapter 15
    case metal, spriteKit, letterbox
    // Chapter 16
    case web
    // Chapter 17
    case biometry, accessibility
    // Chapter 19
    case availabilityGate

    var id: Self { self }

    struct Info {
        var chapter: Int
        var title: String
        var systemImage: String
        /// The screen uses iOS 27.1 API and shows a note on iOS 27.0.
        var needsIOS27_1 = false
    }

    var info: Info {
        switch self {
        case .sizeClassReadout:
            Info(chapter: 1, title: "Hello Duo", systemImage: "hand.wave",
                 needsIOS27_1: true)
        case .sceneGeometry:
            Info(chapter: 2, title: "Scene Geometry",
                 systemImage: "rectangle.dashed")
        case .probeWalkthrough:
            Info(chapter: 3, title: "DuoProbe Walkthrough",
                 systemImage: "waveform.path.ecg")
        case .viewThatFits:
            Info(chapter: 4, title: "ViewThatFits",
                 systemImage: "rectangle.3.group")
        case .anyLayout:
            Info(chapter: 4, title: "AnyLayout with Lifted State",
                 systemImage: "square.split.2x1")
        case .geometryChange:
            Info(chapter: 4, title: "onGeometryChange Columns",
                 systemImage: "square.grid.3x2")
        case .containerRelativeFrame:
            Info(chapter: 4, title: "containerRelativeFrame Grid",
                 systemImage: "rectangle.split.3x1")
        case .rootBranch:
            Info(chapter: 4, title: "Pitfall: Root Branch",
                 systemImage: "exclamationmark.triangle")
        case .safeAreaEdges:
            Info(chapter: 5, title: "Safe Area per Edge",
                 systemImage: "rectangle.inset.filled")
        case .backgroundBleed:
            Info(chapter: 5, title: "Background Bleed",
                 systemImage: "square.fill.on.square")
        case .concentricCorners:
            Info(chapter: 5, title: "Concentric Corners",
                 systemImage: "app.connected.to.app.below.fill")
        case .backgroundExtension:
            Info(chapter: 5, title: "Background Extension",
                 systemImage: "photo.stack")
        case .splitView:
            Info(chapter: 6, title: "NavigationSplitView",
                 systemImage: "sidebar.left")
        case .tabSidebar:
            Info(chapter: 6, title: "TabView Sidebar",
                 systemImage: "rectangle.leadinghalf.inset.filled")
        case .sheetPlacement:
            Info(chapter: 6, title: "Sheet Placement",
                 systemImage: "rectangle.bottomhalf.inset.filled")
        case .popoverMenuAlert:
            Info(chapter: 6, title: "Popover, Menu, Alert",
                 systemImage: "text.bubble")
        case .toolbarOrdering:
            Info(chapter: 7, title: "Toolbar Ordering",
                 systemImage: "list.number")
        case .axisBehavior:
            Info(chapter: 7, title: "Axis Behavior",
                 systemImage: "arrow.up.and.down.and.arrow.left.and.right",
                 needsIOS27_1: true)
        case .verticalBehavior:
            Info(chapter: 7, title: "Vertical Bar Opt-Out",
                 systemImage: "rectangle.portrait.slash")
        case .compression:
            Info(chapter: 7, title: "Compression Behavior",
                 systemImage: "arrow.down.right.and.arrow.up.left")
        case .overflow:
            Info(chapter: 7, title: "Overflow and Priority",
                 systemImage: "ellipsis.circle")
        case .verticalEdge:
            Info(chapter: 7, title: "Vertical Bar Edge",
                 systemImage: "sidebar.right", needsIOS27_1: true)
        case .badges:
            Info(chapter: 7, title: "Badges", systemImage: "app.badge")
        case .queryRegions:
            Info(chapter: 8, title: "Query Regions",
                 systemImage: "list.bullet.rectangle", needsIOS27_1: true)
        case .drawRegions:
            Info(chapter: 8, title: "Draw Regions",
                 systemImage: "rectangle.dashed.and.paperclip",
                 needsIOS27_1: true)
        case .customBar:
            Info(chapter: 8, title: "Displaced Custom Bar",
                 systemImage: "dock.rectangle", needsIOS27_1: true)
        case .evenColumns:
            Info(chapter: 8, title: "Even Columns",
                 systemImage: "square.grid.4x3.fill", needsIOS27_1: true)
        case .layoutDirection:
            Info(chapter: 8, title: "Fixed vs Mirrors",
                 systemImage: "arrow.left.arrow.right", needsIOS27_1: true)
        case .arrangementBasic:
            Info(chapter: 9, title: "ArrangementView",
                 systemImage: "rectangle.split.2x1", needsIOS27_1: true)
        case .splitRatio:
            Info(chapter: 9, title: "Split Ratio",
                 systemImage: "percent", needsIOS27_1: true)
        case .splitSize:
            Info(chapter: 9, title: "Split Size",
                 systemImage: "ruler", needsIOS27_1: true)
        case .splitFixedSize:
            Info(chapter: 9, title: "Split Fixed Size",
                 systemImage: "lock.rectangle", needsIOS27_1: true)
        case .splitAxes:
            Info(chapter: 9, title: "Split Axes",
                 systemImage: "rectangle.split.1x2", needsIOS27_1: true)
        case .overlayEdge:
            Info(chapter: 9, title: "Overlay Edge",
                 systemImage: "square.on.square", needsIOS27_1: true)
        case .overlayZIndex:
            Info(chapter: 9, title: "Overlay Z-Index",
                 systemImage: "square.3.layers.3d", needsIOS27_1: true)
        case .customStyle:
            Info(chapter: 9, title: "Custom Arrangement Style",
                 systemImage: "paintbrush", needsIOS27_1: true)
        case .secondaryVanishes:
            Info(chapter: 9, title: "Pitfall: Secondary Vanishes",
                 systemImage: "eye.slash", needsIOS27_1: true)
        case .hingeReadout:
            Info(chapter: 10, title: "Hinge Readout",
                 systemImage: "angle", needsIOS27_1: true)
        case .hingeEffect:
            Info(chapter: 10, title: "Hinge Effect",
                 systemImage: "camera.filters")
        case .poseMatrix:
            Info(chapter: 11, title: "Pose Layout Matrix",
                 systemImage: "square.grid.2x2", needsIOS27_1: true)
        case .openWindow:
            Info(chapter: 12, title: "Open a Window",
                 systemImage: "plus.rectangle.on.rectangle")
        case .scenePhaseLog:
            Info(chapter: 12, title: "Scene Phase Log",
                 systemImage: "clock.arrow.circlepath")
        case .camera:
            Info(chapter: 13, title: "Camera by Direction",
                 systemImage: "camera", needsIOS27_1: true)
        case .captureAccessory:
            Info(chapter: 14, title: "Capture Accessory",
                 systemImage: "text.viewfinder", needsIOS27_1: true)
        case .metal:
            Info(chapter: 15, title: "Metal Drawable Resize",
                 systemImage: "cube.transparent")
        case .spriteKit:
            Info(chapter: 15, title: "SpriteKit Scale Mode",
                 systemImage: "gamecontroller")
        case .letterbox:
            Info(chapter: 15, title: "Letterbox Math",
                 systemImage: "aspectratio")
        case .web:
            Info(chapter: 16, title: "WKWebView and CSS",
                 systemImage: "globe")
        case .biometry:
            Info(chapter: 17, title: "Biometry Copy",
                 systemImage: "touchid")
        case .accessibility:
            Info(chapter: 17, title: "Accessibility Readout",
                 systemImage: "accessibility")
        case .availabilityGate:
            Info(chapter: 19, title: "Availability Gate",
                 systemImage: "checkmark.shield")
        }
    }

    var chapter: Int { info.chapter }
    var title: String { info.title }

    /// Short forms of the book's chapter titles.
    static func chapterTitle(_ chapter: Int) -> String {
        let title = switch chapter {
        case 1: "iPhone Duo for developers"
        case 2: "iPhone apps are resizable now"
        case 3: "Tooling"
        case 4: "Size classes, not idioms"
        case 5: "Safe areas, margins and corners"
        case 6: "System containers"
        case 7: "Vertical toolbars and tab bars"
        case 8: "Reserved regions"
        case 9: "Arrangement views"
        case 10: "The hinge"
        case 11: "Designing for poses"
        case 12: "Split View, PiP and windows"
        case 13: "The camera"
        case 14: "The camera capture accessory"
        case 15: "Games and video"
        case 16: "Web content"
        case 17: "System surfaces"
        case 19: "The migration playbook"
        default: ""
        }
        return "Chapter \(chapter): \(title)"
    }

    /// The chapters that have demos, in order.
    static var chapters: [Int] {
        var seen: [Int] = []
        for demo in allCases where !seen.contains(demo.chapter) {
            seen.append(demo.chapter)
        }
        return seen
    }
}
