//
//  FeedHeaderView.swift
//  Cloutgrid
//
//  Created by Afthash on 26/3/2026.
//

import SwiftUI

struct FeedHeader: View {
    let home: HomeManager
    @Binding var notificationSheet: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TitleView()
                
                Spacer()
                
                Button {
                    notificationSheet = true
                } label: {
                    HStack(spacing: 0) {
                        Image(systemName: "bell.fill")
                        
                        if home.notifications.count > 0 {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .offset(x: -2, y: -5)
                        }
                    }
                }
                .foregroundStyle(Color.dualBlack)
                .sheet(isPresented: $notificationSheet) {
                    NotificationView()
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 50)
            
            Divider()
        }
        .background(Color.dualWhite)
    }
}

#Preview {
    FeedHeader(home: HomeManager(), notificationSheet: .constant(false))
}
