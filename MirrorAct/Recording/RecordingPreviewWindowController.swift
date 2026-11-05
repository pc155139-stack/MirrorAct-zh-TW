// SPDX-License-Identifier: GPL-3.0-or-later
import AppKit
import AVKit

/// Opens the finished recording immediately, while keeping the original file on the Desktop.
@MainActor
final class RecordingPreviewWindowController: NSWindowController, NSWindowDelegate {
    let url: URL
    var onClose: (() -> Void)?
    private let player: AVPlayer

    init(url: URL) {
        self.url = url
        player = AVPlayer(url: url)

        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 820, height: 600),
                              styleMask: [.titled, .closable, .miniaturizable, .resizable],
                              backing: .buffered, defer: false)
        window.title = "\(String(localized: "Video")) – \(url.lastPathComponent)"
        window.isReleasedWhenClosed = false

        let video = AVPlayerView()
        video.player = player
        video.controlsStyle = .inline
        video.showsFullScreenToggleButton = true

        let reveal = NSButton(title: String(localized: "Show in Finder"), target: nil, action: nil)
        let copy = NSButton(title: String(localized: "Copy"), target: nil, action: nil)
        let buttons = NSStackView(views: [reveal, copy])
        buttons.orientation = .horizontal
        buttons.spacing = 10
        buttons.translatesAutoresizingMaskIntoConstraints = false
        video.translatesAutoresizingMaskIntoConstraints = false

        let content = NSView()
        content.addSubview(video)
        content.addSubview(buttons)
        NSLayoutConstraint.activate([
            video.topAnchor.constraint(equalTo: content.topAnchor),
            video.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            video.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            video.bottomAnchor.constraint(equalTo: buttons.topAnchor, constant: -12),
            buttons.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            buttons.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -12),
        ])
        window.contentView = content
        super.init(window: window)
        window.delegate = self
        window.center()
        reveal.target = self
        reveal.action = #selector(showInFinder)
        copy.target = self
        copy.action = #selector(copyFile)
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func showInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    @objc private func copyFile() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([url as NSURL])
    }

    func windowWillClose(_ notification: Notification) {
        player.pause()
        onClose?()
    }
}
