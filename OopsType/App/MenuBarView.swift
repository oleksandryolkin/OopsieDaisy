//
//  MenuBarView.swift
//  OopsType
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var coordinator = AppCoordinator.shared

    var body: some View {
        if !coordinator.hasInputMonitoringAccess {
            Text("Нет доступа к клавиатуре")
            Button("Открыть настройки конфиденциальности…") {
                coordinator.openInputMonitoringSettings()
            }
            Button("Проверить снова") {
                coordinator.refreshPermissionStatus()
            }
            Divider()
        }

        Toggle("Включено", isOn: $settings.isEnabled)

        Divider()

        Button("Выход") {
            NSApplication.shared.terminate(nil)
        }
    }
}
