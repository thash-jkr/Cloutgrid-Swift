//
//  Youtube.swift
//  Cloutgrid
//
//  Created by Afthash on 23/4/2026.
//

import SwiftUI

struct Youtube: View {
    struct InfoSection<Content: View>: View {
        let title: String
        let content: Content

        init(title: String, @ViewBuilder content: () -> Content) {
            self.title = title
            self.content = content()
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 12) {
                    content
                }
                .padding(.leading, 5)
            }
        }
    }

    struct BulletPoint: View {
        let text: String
        
        init(_ text: String) {
            self.text = text
        }
        
        var body: some View {
            HStack(alignment: .top, spacing: 10) {
                Text("•")
                    .fontWeight(.bold)
                
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("YouTube Analytics 📊")
                .font(.title2)
                .bold()
                .padding(.bottom)
            
            Text("Connecting your YouTube channel unlocks verified metrics that demonstrate your influence 🚀. Providing real-time data builds professional credibility and makes it easier for brands to partner with you 🤝.")
                .padding(.bottom)
                .font(.footnote)
            
            VStack {
                Button {
                    
                } label: {
                    Text("Connect YouTube")
                        .customButton(disabled: true)
                }
                
                Text("This feature is in development")
                    .foregroundStyle(Color.secondary)
                    .font(.caption)
            }
            .padding(.bottom)
            
            VStack(spacing: 20) {
                InfoSection(title: "What you’ll get once connected:") {
                    BulletPoint("Verified subscriber count and lifetime video views displayed on your profile.")
                    BulletPoint("Real-time data on your average view duration, watch time, and click-through rates.")
                    BulletPoint("Audience demographics including age, gender, and top geographic locations.")
                    BulletPoint("Performance trends for your latest uploads and most popular content.")
                }

                InfoSection(title: "What you need before connecting:") {
                    BulletPoint("A YouTube channel with active content (public or unlisted videos).")
                    BulletPoint("The Google Account credentials associated with your YouTube channel.")
                    BulletPoint("Approval for Cloutgrid to view your YouTube Analytics reports via Google’s secure login.")
                }

                InfoSection(title: "How to connect:") {
                    BulletPoint("Ensure you are logged into the Google Account that manages your YouTube channel.")
                    BulletPoint("Click “Connect YouTube” above to open the secure Google Sign-In prompt.")
                    BulletPoint("Select the specific channel you wish to link to Cloutgrid.")
                    BulletPoint("Grant the requested permissions so we can securely display your analytics to potential partners.")
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    Youtube()
}
