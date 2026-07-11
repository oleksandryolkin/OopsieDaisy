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
        if !coordinator.hasInputMonitoringAccess {
            Text("No keyboard access")
            Button("Open Privacy Settings…") {
                coordinator.openInputMonitoringSettings()
            }
            Button("Check Again") {
                coordinator.refreshPermissionStatus()
            }
            Divider()
        }

        if !coordinator.hasAccessibilityAccess {
            Text("No accessibility access")
            Button("Open Privacy Settings…") {
                coordinator.openAccessibilitySettings()
            }
            Button("Check Again") {
                coordinator.refreshPermissionStatus()
            }
            Divider()
        }

        Toggle("Enabled", isOn: $settings.isEnabled)

        Toggle("Launch at Login", isOn: Binding(
            get: { launchAtLogin.isEnabled },
            set: { launchAtLogin.setEnabled($0) }
        ))
        .onAppear { launchAtLogin.refresh() }

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
    }
}
