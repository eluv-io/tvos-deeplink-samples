//
//  EluvioDeepLinkSampleApp.swift
//  EluvioDeepLinkSample
//
//  Created by Wayne Tran on 2024-02-13.
//

import SwiftUI

@main
struct EluvioDeepLinkSampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(.thinMaterial)
            .onOpenURL { url in
                debugPrint("url opened: ", url)
            }
            .preferredColorScheme(.dark)
            .onAppear() {
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
    }
}
