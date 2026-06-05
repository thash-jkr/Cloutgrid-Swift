//
//  CloutgridApp.swift
//  Cloutgrid
//
//  Created by Afthash on 15/3/2026.
//

import SwiftUI

@main
struct CloutgridApp: App {
    @State private var authManager = AuthManager()
    @State private var homeManager = HomeManager()
    @State private var profileManager = ProfileManager()
    @State private var jobManager = JobManager()
    @State private var searchManager = SearchManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(homeManager)
                .environment(profileManager)
                .environment(jobManager)
                .environment(searchManager)
                .environmentObject(DeepLinkManager())
        }
    }
}
