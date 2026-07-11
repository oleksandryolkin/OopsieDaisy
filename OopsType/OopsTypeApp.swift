//
//  OopsTypeApp.swift
//  OopsType
//
//  Created by Oleksandr Yolkin on 11/7/26.
//

import SwiftUI

@main
struct OopsTypeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("OopsType", systemImage: "keyboard") {
            MenuBarView()
        }
        .menuBarExtraStyle(.menu)
    }
}
