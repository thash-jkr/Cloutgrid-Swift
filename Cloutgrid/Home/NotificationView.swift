//
//  NotificationView.swift
//  Cloutgrid
//
//  Created by Afthash on 22/3/2026.
//

import SwiftUI

struct NotificationView: View {
    @Environment(HomeManager.self) private var home
    
    var body: some View {
        NavigationStack {
            VStack {
                if home.notifications.count > 0 {
                    AnyView(
                        List(home.notifications, id: \.self.id) { item in
                            Text(item.message)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        Task {
                                            await home.readNotification(id: item.id)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    )
                } else {
                    Empty(type: "general", message: "No new notifications!")
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.fraction(0.5), .fraction(1)])
            .presentationDragIndicator(.visible)
            .task {
                await home.fetchNotifications()
            }
        }
    }
}

#Preview {
    NotificationView()
        .environment(HomeManager())
}
