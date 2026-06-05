//
//  Settings.swift
//  Cloutgrid
//
//  Created by Afthash on 27/3/2026.
//

import SwiftUI
import WebKit

struct Settings: View {
    @Environment(AuthManager.self) private var auth
    
    @State private var helpAlert: Bool = false
    @State private var feedbackAlert: Bool = false
    @State private var deleteConfirm: Bool = false
    @State private var logoutConfirm: Bool = false
    @State private var text: String = ""
    
    private struct IdURL: Identifiable {
        let id = UUID()
        let rawValue: String
    }
    
    @State private var sheetURL: IdURL?
    
    private func settingsItem(icon: String, body: String, danger: Bool = false, action: @escaping () -> Void) -> some View {
        return Button {
            action()
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(danger ? Color.red : Color.primary)
                    .fontWeight(.semibold)
                    
                Text(body)
                    .foregroundStyle(danger ? Color.red : Color.primary)
                    .fontWeight(.semibold)
            }
        }
    }
    
    var body: some View {
        List {
            settingsItem(icon: "lifepreserver", body: "Help") {
                helpAlert = true
            }
            .alert("Get Help", isPresented: $helpAlert) {
                TextField(
                    "Describe the issue...",
                    text: $text,
                    axis: .vertical
                )
                
                Button("Send Request") {
                    text = ""
                }
                
                Button("Cancel", role: .cancel) {
                    text = ""
                }
            } message: {
                Text("Please describe the problem you're having. Our support team will get back to you via email.")
            }
            
//            settingsItem(icon: "info.circle", body: "About") {
//                
//            }
            
            settingsItem(icon: "doc.text", body: "Privacy Policy") {
                sheetURL = IdURL(rawValue: "https://cloutgrid.com/privacypolicy")
            }
            
            settingsItem(icon: "checkmark.seal.text.page", body: "EULA") {
                sheetURL = IdURL(rawValue: "https://cloutgrid.com/eula")
            }
            
            settingsItem(icon: "lightbulb.max", body: "Feedback") {
                feedbackAlert = true
            }
            .alert("Give Feedback", isPresented: $feedbackAlert) {
                TextField(
                    "How can we improve Cloutgrid?",
                    text: $text,
                    axis: .vertical
                )
                
                Button("Submit") {
                    text = ""
                }
                
                Button("Cancel", role: .cancel) {
                    text = ""
                }
            } message: {
                Text("We'd love to hear your thoughts or any features you'd like to see.")
            }
            
            settingsItem(icon: "trash", body: "Delete Account", danger: true) {
                deleteConfirm = true
            }
            .confirmationDialog(
                "Are you sure?",
                isPresented: $deleteConfirm,
                titleVisibility: .visible
            ) {
                Button(role: .destructive) {
                    Task {
                        await auth.deleteAccount(type: auth.type ?? "creator")
                    }
                } label: {
                    Text("Delete")
                }
            } message: {
                Text("This will permanently delete your account and this action cannot be undone")
            }
            
            settingsItem(
                icon: "rectangle.portrait.and.arrow.right",
                body: "Logout",
                danger: true
            ) {
                logoutConfirm = true
            }
            .confirmationDialog(
                "Are you sure you want to logout?",
                isPresented: $logoutConfirm,
                titleVisibility: .visible
            ) {
                Button(role: .destructive) {
                    Task {
                        await auth.logout()
                    }
                } label: {
                    Text("Logout")
                }
            }
        }
        .sheet(item: $sheetURL) { urlString in
            NavigationStack {
                BrowserView(url: URL(string: urlString.rawValue)!)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                sheetURL = nil
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            ShareLink(item: sheetURL?.rawValue ?? "") {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
            }
        }
    }
        
}

#Preview {
    Settings()
        .environment(AuthManager())
}
