//
//  ProbeLog.swift
//  DuoProbe
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import Foundation
import Observation
import os

/// Appends records to `Documents/probe.jsonl`, one JSON object per line,
/// and mirrors every line to the unified log (subsystem
/// `pro.ihor.unfolded.DuoProbe`, category `probe`).
///
/// Layout records are throttled to at most five per second per source:
/// a layout pass inside the 200 ms window replaces the pending record,
/// and the latest one is written when the window ends, so the final
/// state of a fold or a resize is always in the log. Every other event
/// is written at once.
@MainActor @Observable
final class ProbeLog {
    /// The pose the person says the device is in. Stamped on every record.
    var pose: PoseLabel = LaunchOptions.pose ?? .custom

    /// The last record written, pretty-printed for the on-screen readout.
    private(set) var lastRecordText = "No records yet"

    /// How many lines this session has appended.
    private(set) var count = 0

    /// The log file. It survives relaunches; "Share log" sends it as is.
    let fileURL = URL.documentsDirectory.appending(path: "probe.jsonl")

    @ObservationIgnored
    private let logger = Logger(
        subsystem: "pro.ihor.unfolded.DuoProbe", category: "probe"
    )

    @ObservationIgnored
    private var lastLayoutWrite: [ProbeRecord.Source: ContinuousClock.Instant]
        = [:]

    @ObservationIgnored
    private var pendingLayout: [ProbeRecord.Source: ProbeRecord] = [:]

    @ObservationIgnored
    private var flushScheduled: Set<ProbeRecord.Source> = []

    private static let layoutInterval = Duration.milliseconds(200)

    /// Writes a record, throttling layout records as described above.
    func record(_ record: ProbeRecord) {
        guard record.event == .layout else {
            write(record)
            return
        }
        let source = record.source
        let now = ContinuousClock.now
        guard let last = lastLayoutWrite[source],
              now - last < Self.layoutInterval
        else {
            // Anything still pending is older than this record.
            pendingLayout[source] = nil
            lastLayoutWrite[source] = now
            write(record)
            return
        }
        pendingLayout[source] = record
        guard flushScheduled.insert(source).inserted else { return }
        let delay = Self.layoutInterval - (now - last)
        Task { [weak self] in
            try? await Task.sleep(for: delay)
            self?.flushLayout(for: source)
        }
    }

    private func flushLayout(for source: ProbeRecord.Source) {
        flushScheduled.remove(source)
        guard let record = pendingLayout.removeValue(forKey: source) else {
            return
        }
        lastLayoutWrite[source] = .now
        write(record)
    }

    private func write(_ record: ProbeRecord) {
        do {
            let line = try record.jsonLine()
            try append(Data((line + "\n").utf8))
            logger.log("\(line, privacy: .public)")
            count += 1
            lastRecordText = try Self.prettyText(record)
        } catch {
            logger.error(
                "Could not write a record: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    private func append(_ data: Data) throws {
        let manager = FileManager.default
        let path = fileURL.path(percentEncoded: false)
        guard manager.fileExists(atPath: path) else {
            try data.write(to: fileURL, options: .atomic)
            return
        }
        let handle = try FileHandle(forWritingTo: fileURL)
        defer { try? handle.close() }
        try handle.seekToEnd()
        try handle.write(contentsOf: data)
    }

    private static func prettyText(_ record: ProbeRecord) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted, .sortedKeys, .withoutEscapingSlashes,
        ]
        return String(decoding: try encoder.encode(record), as: UTF8.self)
    }
}
