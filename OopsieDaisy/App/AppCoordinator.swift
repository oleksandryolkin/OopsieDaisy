//
//  AppCoordinator.swift
//  OopsieDaisy
//
//  Wires the keyboard monitor to the correction engine and owns app-level
//  lifecycle concerns (permissions, app-switch buffer resets).
//

import AppKit
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    static let shared = AppCoordinator()

    @Published private(set) var hasInputMonitoringAccess = PermissionsManager.hasInputMonitoringAccess()
    @Published private(set) var hasAccessibilityAccess = PermissionsManager.hasAccessibilityAccess()

    private let monitor = KeyboardMonitor()
    private let engine = CorrectionEngine()
    private var appSwitchObserver: NSObjectProtocol?

    private init() {
        monitor.delegate = self
    }

    func start() {
        // Only request Input Monitoring eagerly. Accessibility is left to be
        // requested lazily by the OS the first time CorrectionEngine actually
        // calls CGEventPost/TISSelectInputSource — firing both prompts back
        // to back at launch caused macOS to drop the Input Monitoring one
        // entirely (only the Accessibility dialog showed up).
        PermissionsManager.requestInputMonitoringAccess()
        let started = monitor.start()
        hasInputMonitoringAccess = started
        hasAccessibilityAccess = PermissionsManager.hasAccessibilityAccess()

        appSwitchObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.monitor.resetBuffer()
        }
    }

    func refreshPermissionStatus() {
        hasInputMonitoringAccess = PermissionsManager.hasInputMonitoringAccess()
        hasAccessibilityAccess = PermissionsManager.hasAccessibilityAccess()
        if hasInputMonitoringAccess, !monitor.isRunning {
            monitor.start()
        }
    }

    func openInputMonitoringSettings() {
        PermissionsManager.openInputMonitoringSettings()
    }

    func openAccessibilitySettings() {
        PermissionsManager.openAccessibilitySettings()
    }
}

extension AppCoordinator: KeyboardMonitorDelegate {
    func keyboardMonitor(_ monitor: KeyboardMonitor, didCompleteWord buffer: WordBuffer, boundary: BoundaryKey) {
        engine.evaluate(buffer: buffer, boundary: boundary)
    }
}
