import SwiftUI

class AppDetailWindowManager {
    static let shared = AppDetailWindowManager()
    private var windows: [String: NSWindow] = [:]

    private init() {}

    func openAppDetail(appId: String, title: String = "应用详情") {
        let windowId = "app_\(appId)"

        if let existingWindow = windows[windowId] {
            existingWindow.makeKeyAndOrderFront(nil)
            return
        }

        let contentView = MaclubAppDetailLoaderView(appId: appId)
            .frame(minWidth: 850, minHeight: 620)

        let hostingView = NSHostingView(rootView: contentView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 850, height: 620),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.contentView = hostingView
        window.center()
        window.isReleasedWhenClosed = false

        window.delegate = WindowDelegate { [weak self] in
            self?.windows.removeValue(forKey: windowId)
        }

        windows[windowId] = window
        window.makeKeyAndOrderFront(nil)
    }
}

private class WindowDelegate: NSObject, NSWindowDelegate {
    let onClose: () -> Void

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }

    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}
