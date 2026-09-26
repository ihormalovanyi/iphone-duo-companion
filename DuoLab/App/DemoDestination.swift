//
//  DemoDestination.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

/// Routes a demo to its screen. Screens that need iOS 27.1 are reached
/// only inside `if #available`, and only outside Mac Catalyst, where
/// iOS 27.1 symbols don't compile in Xcode 27.1 beta (185924957).
struct DemoDestination: View {
    let demo: Demo

    var body: some View {
        switch demo {
        case .sceneGeometry: SceneGeometryScreen()
        case .probeWalkthrough: ProbeWalkthroughScreen()
        case .viewThatFits: ViewThatFitsScreen()
        case .anyLayout: AnyLayoutScreen()
        case .geometryChange: GeometryChangeScreen()
        case .containerRelativeFrame: ContainerRelativeFrameScreen()
        case .rootBranch: RootBranchScreen()
        case .safeAreaEdges: SafeAreaEdgesScreen()
        case .backgroundBleed: BackgroundBleedScreen()
        case .concentricCorners: ConcentricCornersScreen()
        case .backgroundExtension: BackgroundExtensionScreen()
        case .splitView: SplitViewScreen()
        case .tabSidebar: TabSidebarScreen()
        case .sheetPlacement: SheetPlacementScreen()
        case .popoverMenuAlert: PopoverMenuAlertScreen()
        case .toolbarOrdering: ToolbarOrderingScreen()
        case .overflow: OverflowScreen()
        case .badges: BadgesScreen()
        case .openWindow: OpenWindowScreen()
        case .scenePhaseLog: ScenePhaseLogScreen()
        case .metal: MetalScreen()
        case .spriteKit: SpriteKitScreen()
        case .letterbox: LetterboxScreen()
        case .web: WebScreen()
        case .biometry: BiometryScreen()
        case .accessibility: AccessibilityScreen()
        case .availabilityGate: AvailabilityGateScreen()
        #if !targetEnvironment(macCatalyst)
        // These run on iOS 27.0 too; each gates one 27.1 modifier.
        case .compression: CompressionScreen()
        case .hingeEffect: HingeEffectScreen()
        // These need iOS 27.1 throughout.
        case .sizeClassReadout, .axisBehavior, .verticalBehavior,
             .verticalEdge, .queryRegions, .drawRegions, .customBar,
             .evenColumns, .layoutDirection, .arrangementBasic,
             .splitRatio, .splitSize, .splitFixedSize, .splitAxes,
             .overlayEdge, .overlayZIndex, .customStyle,
             .secondaryVanishes, .hingeReadout, .poseMatrix, .camera,
             .captureAccessory:
            if #available(iOS 27.1, *) {
                DuoScreen(demo: demo)
            } else {
                DemoUnavailable(demo: demo, reason: """
                    This demo uses iOS 27.1 API. Run DuoLab on iPhone Duo \
                    or in the iPhone Duo simulator.
                    """)
            }
        #else
        default:
            DemoUnavailable(demo: demo, reason: """
                This demo uses iOS 27.1 API, which Mac Catalyst builds \
                can't use yet.
                """)
        #endif
        }
    }
}

#if !targetEnvironment(macCatalyst)
/// The screens that use iOS 27.1 API throughout.
@available(iOS 27.1, *)
private struct DuoScreen: View {
    let demo: Demo

    var body: some View {
        switch demo {
        case .sizeClassReadout: SizeClassReadout()
        case .axisBehavior: AxisBehaviorScreen()
        case .verticalBehavior: KeypadScreen()
        case .verticalEdge: VerticalEdgeScreen()
        case .queryRegions: QueryRegionsScreen()
        case .drawRegions: DrawRegionsScreen()
        case .customBar: CustomBarScreen()
        case .evenColumns: EvenColumnsScreen()
        case .layoutDirection: LayoutDirectionScreen()
        case .arrangementBasic: ArrangementBasicScreen()
        case .splitRatio: SplitRatioScreen()
        case .splitSize: SplitSizeScreen()
        case .splitFixedSize: SplitFixedSizeScreen()
        case .splitAxes: SplitAxesScreen()
        case .overlayEdge: OverlayEdgeScreen()
        case .overlayZIndex: OverlayZIndexScreen()
        case .customStyle: CustomStyleScreen()
        case .secondaryVanishes: SecondaryVanishesScreen()
        case .hingeReadout: HingeReadoutScreen()
        case .poseMatrix: PoseAdaptiveScreen()
        case .camera: CameraScreen()
        case .captureAccessory: CaptureAccessoryScreen()
        default: EmptyView()
        }
    }
}
#endif
