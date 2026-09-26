//
//  Ch03Probe.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 3: a pointer to DuoProbe, the instrument app. No snippet;
//  the ProbeRecord schema is in Shared/ProbeRecord.swift.
//

import SwiftUI

struct ProbeWalkthroughScreen: View {
    /// The log's field names, read from the record type itself so the
    /// list can't drift from the schema.
    private let fields = Mirror(
        reflecting: ProbeRecord(pose: .custom, source: .swiftui, event: .manual)
    ).children.compactMap(\.label)

    var body: some View {
        List {
            Section {
                Text("""
                    DuoProbe writes one JSON line to Documents/probe.jsonl \
                    on every layout pass, hinge update, scene activation \
                    change, keyboard notification and Record Now tap.
                    """)
            } header: {
                Text("What DuoProbe records")
            }

            Section("Walkthrough") {
                Label("Run the DuoProbe scheme on the iPhone Duo simulator.",
                      systemImage: "1.circle")
                Label("Pick the pose you are about to set.",
                      systemImage: "2.circle")
                Label("Set that pose with the Device Hub controls.",
                      systemImage: "3.circle")
                Label("Tap Record Now, then Share Log.",
                      systemImage: "4.circle")
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Or copy the log from the simulator:")
                        Text("""
                            xcrun simctl get_app_container booted \
                            pro.ihor.unfolded.DuoProbe data
                            """)
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                    }
                } icon: {
                    Image(systemName: "5.circle")
                }
            }

            Section("Fields in every line (\(fields.count))") {
                ForEach(fields, id: \.self) { field in
                    Text(field)
                        .font(.callout.monospaced())
                }
            }
        }
    }
}
