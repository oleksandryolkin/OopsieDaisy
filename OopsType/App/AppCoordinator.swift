//
//  AppCoordinator.swift
//  OopsType
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

    private let monitor = KeyboardMonitor()
    private let engine = CorrectionEngine()
    private var appSwitchObserver: NSObjectProtocol?

    private init() {
        monitor.delegate = self
    }

    func start() {
        PermissionsManager.requestInputMonitoringAccess()
        let started = monitor.start()
        hasInputMonitoringAccess = started

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
        if hasInputMonitoringAccess, !monitor.isRunning {
            monitor.start()
        }
    }

    func openInputMonitoringSettings() {
        PermissionsManager.openInputMonitoringSettings()
    }
}

extension AppCoordinator: KeyboardMonitorDelegate {
    func keyboardMonitor(_ monitor: KeyboardMonitor, didCompleteWord buffer: WordBuffer, boundary: BoundaryKey) {
        engine.evaluate(buffer: buffer, boundary: boundary)
    }
}
