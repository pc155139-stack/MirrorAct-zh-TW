// SPDX-License-Identifier: GPL-3.0-or-later
import AppKit

/// A native, resizable video-only window. It displays an existing MirrorSession;
/// USB and AirPlay capture stay in MirrorAct and are never opened a second time.
@MainActor
final class PictureInPictureWindow: NSWindow, NSWindowDelegate {
    let videoView = VideoDisplayView(frame: .zero)
    private let placeholder = NSTextField(labelWithString: "")
    var onClose: (() -> Void)?

    init(title: String, videoSize: CGSize, alwaysOnTop: Bool) {
        let initialSize = Self.fittedSize(for: videoSize, on: NSScreen.main)
        super.init(contentRect: NSRect(origin: .zero, size: initialSize),
                   styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                   backing: .buffered, defer: false)
        self.title = title
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        isReleasedWhenClosed = false
        backgroundColor = .black
        level = alwaysOnTop ? .floating : .normal
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        contentAspectRatio = videoSize
        contentMinSize = CGSize(width: 180, height: 120)
        delegate = self

        videoView.displayLayer.videoGravity = .resizeAspect
        videoView.autoresizingMask = [.width, .height]
        videoView.frame = NSRect(origin: .zero, size: initialSize)
        contentView = videoView

        placeholder.textColor = .white
        placeholder.font = .systemFont(ofSize: 15, weight: .medium)
        placeholder.alignment = .center
        placeholder.maximumNumberOfLines = 3
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        videoView.addSubview(placeholder)
        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: videoView.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: videoView.centerYAnchor),
            placeholder.widthAnchor.constraint(lessThanOrEqualTo: videoView.widthAnchor, multiplier: 0.9),
        ])
        center()
    }

    func updateVideoSize(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let old = contentAspectRatio
        guard abs(old.width / max(1, old.height) - size.width / size.height) > 0.01 else { return }
        let topLeft = CGPoint(x: frame.minX, y: frame.maxY)
        let fitted = Self.fittedSize(for: size, on: screen, preferredWidth: frame.width)
        contentAspectRatio = size
        setContentSize(fitted)
        setFrameOrigin(CGPoint(x: topLeft.x, y: topLeft.y - frame.height))
    }

    func updatePlaceholder(_ state: MirrorSession.State) {
        switch state {
        case .live:
            placeholder.isHidden = true
        case .connecting:
            placeholder.stringValue = String(localized: "Connecting …\nUnlock the device if needed")
            placeholder.isHidden = false
        case let .disconnected(reason):
            placeholder.stringValue = reason ?? String(localized: "Disconnected")
            placeholder.isHidden = false
        }
    }

    func windowWillClose(_ notification: Notification) { onClose?() }

    private static func fittedSize(for size: CGSize, on screen: NSScreen?, preferredWidth: CGFloat = 720) -> CGSize {
        let safe = size.width > 0 && size.height > 0 ? size : CGSize(width: 16, height: 9)
        let visible = screen?.visibleFrame.size ?? CGSize(width: 1440, height: 900)
        let width = min(preferredWidth, visible.width * 0.8, visible.height * 0.8 * safe.width / safe.height)
        return CGSize(width: max(180, width), height: max(120, width * safe.height / safe.width))
    }
}
