//
//  ProCamApp.swift
//  ProCam
//
//  Created by Ahmed Mgua on 16/11/22.
//

import SwiftUI

@main
struct ProCamApp: App {
    @StateObject private var hapticFeedback = HapticFeedback.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(hapticFeedback)
                .preferredColorScheme(.dark)
                .statusBarHidden()
        }
    }
}
