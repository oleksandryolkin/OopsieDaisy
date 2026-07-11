//
//  OopsieDaisyApp.swift
//  OopsieDaisy
//
//  Created by Oleksandr Yolkin on 11/7/26.
//

import SwiftUI

@main
struct OopsieDaisyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("OopsieDaisy", systemImage: "keyboard") {
            MenuBarView()
        }
        .menuBarExtraStyle(.menu)
    }
}
