//
//  MenuBarView.swift
//  OopsieDaisy
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var coordinator = AppCoordinator.shared
    @ObservedObject var launchAtLogin = LaunchAtLoginManager.shared

    var body: some View {
        Toggle("Enabled", isOn: $settings.isEnabled)

        Toggle("Launch at Login", isOn: Binding(
            get: { launchAtLogin.isEnabled },
            set: { launchAtLogin.setEnabled($0) }
        ))
        .onAppear { launchAtLogin.refresh() }

        Divider()

        Button("Open Input Monitoring Settings…") {
            coordinator.openInputMonitoringSettings()
        }

        Button("Open Accessibility Settings…") {
            coordinator.openAccessibilitySettings()
        }

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
    }
}
