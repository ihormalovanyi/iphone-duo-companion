//
//  Ch16Web.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 16: a web page that adapts with CSS alone, in a WKWebView.
//

import SwiftUI
import WebKit

// snippet:begin ch16-wkwebview
/// Hosts a local page in a WKWebView. The page asks for
/// viewport-fit=cover and pads each edge with env().
struct DuoWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        #if DEBUG
        webView.isInspectable = true  // Safari's Web Inspector
        #endif
        webView.loadFileURL(
            url, allowingReadAccessTo: url.deletingLastPathComponent())
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

/// DuoLab's screen ignores the safe area, so the page spans the scene.
struct WebScreen: View {
    var body: some View {
        if let url = DuoPage.bundledURL {
            DuoWebView(url: url)
                .ignoresSafeArea()
        } else {
            ContentUnavailableView("duo.html is missing",
                                   systemImage: "globe")
        }
    }
}
// snippet:end ch16-wkwebview

/// The page DuoLab ships as Web/duo.html. The book prints it from this
/// constant; the two must stay identical, which a debug build checks.
enum DuoPage {
    // snippet:begin ch16-duo-html
    static let html = #"""
    <!doctype html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1, viewport-fit=cover">
    <title>iPhone Duo on the web</title>
    <style>
      :root { color-scheme: light dark; font: -apple-system-body; }
      body {
        margin: 0;
        min-height: 100dvh;
        box-sizing: border-box;
        /* Each edge on its own: insets on iPhone Duo are often asymmetric. */
        padding: env(safe-area-inset-top) env(safe-area-inset-right)
          env(safe-area-inset-bottom) env(safe-area-inset-left);
      }
      main { container-type: inline-size; padding: 16px; }
      .cards { display: grid; gap: 12px; }
      @container (min-width: 560px) {
        .cards { grid-template-columns: repeat(2, 1fr); }
      }
      .card { padding: 16px; border-radius: 16px; background: #8882; }
      td { padding: 2px 12px 2px 0; font-variant-numeric: tabular-nums; }
      #probe {
        position: fixed;
        visibility: hidden;
        padding-top: env(safe-area-inset-top);
        padding-right: env(safe-area-inset-right);
        padding-bottom: env(safe-area-inset-bottom);
        padding-left: env(safe-area-inset-left);
      }
    </style>
    </head>
    <body>
    <div id="probe"></div>
    <main>
      <div class="cards">
        <section class="card">
          <h1>iPhone Duo</h1>
          <p>No user-agent checks: this page adapts with CSS alone.</p>
        </section>
        <section class="card">
          <h2>Safe-area insets</h2>
          <table><tbody id="insets"></tbody></table>
        </section>
        <section class="card">
          <h2>Container</h2>
          <p id="size">Measuring…</p>
          <p>Two columns from 560 CSS px wide, by a container query.</p>
        </section>
      </div>
    </main>
    <script>
      const probe = document.getElementById("probe");
      const insets = document.getElementById("insets");
      const size = document.getElementById("size");
      const edges = ["top", "right", "bottom", "left"];

      function showInsets() {
        const style = getComputedStyle(probe);
        insets.innerHTML = edges.map((edge) => {
          const value = style.getPropertyValue(`padding-${edge}`);
          return `<tr><td>${edge}</td><td>${value}</td></tr>`;
        }).join("");
      }

      // Reprints whenever main changes size.
      new ResizeObserver(([entry]) => {
        const box = entry.contentRect;
        size.textContent =
          `${Math.round(box.width)} × ${Math.round(box.height)} CSS px`;
        showInsets();
      }).observe(document.querySelector("main"));
    </script>
    </body>
    </html>
    """#
    // snippet:end ch16-duo-html

    /// The bundled copy of the page. Debug builds stop if Web/duo.html
    /// and `html` drift apart.
    static let bundledURL: URL? = {
        let url = Bundle.main.url(forResource: "duo", withExtension: "html")
        #if DEBUG
        if let url {
            do {
                let bundled = try String(contentsOf: url, encoding: .utf8)
                assert(bundled == html + "\n",
                       "Web/duo.html differs from DuoPage.html")
            } catch {
                assertionFailure("Web/duo.html is unreadable: \(error)")
            }
        }
        #endif
        return url
    }()
}
