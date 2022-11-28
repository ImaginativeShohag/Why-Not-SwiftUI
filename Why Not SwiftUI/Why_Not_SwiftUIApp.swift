//
//  Why_Not_SwiftUIApp.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 8/8/22.
//

import SwiftUI

@main
struct Why_Not_SwiftUIApp: App {
    private let trackingService = TrackingService.shared

    var body: some Scene {
        WindowGroup {
            MainScreen()
        }
    }
}
