//
//  ProbeRecord.swift
//  Shared (DuoLab, DuoLabUIKit, DuoProbe)
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import Foundation

/// One line of `Documents/probe.jsonl`. Every field is written on every
/// line; a field that is unavailable is written as `null`.
// snippet:begin ch03-probe-record
struct ProbeRecord: Codable {
    struct Size: Codable { var w, h: Double }
    struct Rect: Codable { var x, y, w, h: Double }
    struct Insets: Codable {
        var top, leading, bottom, trailing: Double
    }
    struct Region: Codable {
        var frame: Rect
        var margins: Insets
        var isActive: Bool
    }
    enum Source: String, Codable { case swiftui, uikit }
    enum Event: String, Codable {
        case layout, hinge, scene, keyboard, manual
    }
    var ts: String                        // ISO 8601 with milliseconds
    var pose: PoseLabel
    var source: Source
    var event: Event
    var sceneSize: Size?
    var effectiveGeometryBounds: Rect?
    var uiScreenMainBounds, windowSceneScreenBounds: Size?
    var displayScale, nativeScale: Double?
    var hSizeClass, vSizeClass: String?
    var interfaceOrientation, userInterfaceIdiom: String?
    var safeAreaInsets, layoutMargins: Insets?
    var toolbarVerticalEdge: String?      // SwiftUI environment value
    var verticalBarEdge: String?          // UIKit trait
    var regionsDivisionActive, regionsDivisionAll: [Region]?
    var regionsOcclusionActive, regionsOcclusionAll: [Region]?
    var hingeStatus: String?
    var hingeAngleDegrees, hingeAngleRadians: Double?
    var hingeIsNil: Bool?
    var sceneActivationState, scenePhase: String?
    var keyboardFrame: Rect?
    var keyboardNotification: String?     // willShow, didHide, ...
    var layoutDirection: String?
    var reduceTransparency: Bool?
    var bundleSDKBuild, runtimeVersion: String?
}
// snippet:end ch03-probe-record

extension ProbeRecord {
    /// Creates a record stamped with the current time, the SDK build the
    /// app was linked against, and the running OS version. Every other
    /// field starts as `nil` and is filled in by the caller.
    init(pose: PoseLabel, source: Source, event: Event, date: Date = .now) {
        self.ts = ProbeRecord.timestamp(date)
        self.pose = pose
        self.source = source
        self.event = event
        self.bundleSDKBuild = Bundle.main.object(
            forInfoDictionaryKey: "DTSDKBuild"
        ) as? String
        self.runtimeVersion = ProcessInfo.processInfo
            .operatingSystemVersionString
    }

    /// ISO 8601 with milliseconds, for example `2026-10-23T09:41:00.123Z`.
    static func timestamp(_ date: Date) -> String {
        date.formatted(
            Date.ISO8601FormatStyle(includingFractionalSeconds: true)
        )
    }

    /// The record as one line of JSON, without the trailing newline.
    func jsonLine() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return String(decoding: try encoder.encode(self), as: UTF8.self)
    }

    // Synthesized `Encodable` skips `nil` optionals. The log schema wants
    // every key on every line, so optionals are encoded explicitly and a
    // missing value becomes `null`.
    func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(ts, forKey: .ts)
        try c.encode(pose, forKey: .pose)
        try c.encode(source, forKey: .source)
        try c.encode(event, forKey: .event)
        try c.encode(sceneSize, forKey: .sceneSize)
        try c.encode(effectiveGeometryBounds, forKey: .effectiveGeometryBounds)
        try c.encode(uiScreenMainBounds, forKey: .uiScreenMainBounds)
        try c.encode(windowSceneScreenBounds, forKey: .windowSceneScreenBounds)
        try c.encode(displayScale, forKey: .displayScale)
        try c.encode(nativeScale, forKey: .nativeScale)
        try c.encode(hSizeClass, forKey: .hSizeClass)
        try c.encode(vSizeClass, forKey: .vSizeClass)
        try c.encode(interfaceOrientation, forKey: .interfaceOrientation)
        try c.encode(userInterfaceIdiom, forKey: .userInterfaceIdiom)
        try c.encode(safeAreaInsets, forKey: .safeAreaInsets)
        try c.encode(layoutMargins, forKey: .layoutMargins)
        try c.encode(toolbarVerticalEdge, forKey: .toolbarVerticalEdge)
        try c.encode(verticalBarEdge, forKey: .verticalBarEdge)
        try c.encode(regionsDivisionActive, forKey: .regionsDivisionActive)
        try c.encode(regionsDivisionAll, forKey: .regionsDivisionAll)
        try c.encode(regionsOcclusionActive, forKey: .regionsOcclusionActive)
        try c.encode(regionsOcclusionAll, forKey: .regionsOcclusionAll)
        try c.encode(hingeStatus, forKey: .hingeStatus)
        try c.encode(hingeAngleDegrees, forKey: .hingeAngleDegrees)
        try c.encode(hingeAngleRadians, forKey: .hingeAngleRadians)
        try c.encode(hingeIsNil, forKey: .hingeIsNil)
        try c.encode(sceneActivationState, forKey: .sceneActivationState)
        try c.encode(scenePhase, forKey: .scenePhase)
        try c.encode(keyboardFrame, forKey: .keyboardFrame)
        try c.encode(keyboardNotification, forKey: .keyboardNotification)
        try c.encode(layoutDirection, forKey: .layoutDirection)
        try c.encode(reduceTransparency, forKey: .reduceTransparency)
        try c.encode(bundleSDKBuild, forKey: .bundleSDKBuild)
        try c.encode(runtimeVersion, forKey: .runtimeVersion)
    }
}
