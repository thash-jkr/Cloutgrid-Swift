//
//  Instagram.swift
//  Cloutgrid
//
//  Created by Afthash on 23/4/2026.
//

import SwiftUI

struct Instagram: View {
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
            Text("Instagram Insights 📸")
                .font(.title2)
                .bold()
                .padding(.bottom)
            
            Text("Connecting your Instagram unlocks analytics that help you stand out to businesses 🙋🏻‍♂️. This transparency builds trust, boosts your credibility, and increases your chances of securing collaborations 🤝.")
                .padding(.bottom)
                .font(.footnote)
            
            VStack {
                Button {
                    
                } label: {
                    Text("Connect Instagram")
                        .customButton(disabled: true)
                }
                
                Text("This feature is in development")
                    .foregroundStyle(Color.secondary)
                    .font(.caption)
            }
            .padding(.bottom)
            
            VStack(spacing: 20) {
                InfoSection(title: "What you’ll get once connected:") {
                    BulletPoint("Verified display of your follower count, followings, and media count.")
                    BulletPoint("Insights into your reach, profile views, and audience engagement shown on your Cloutgrid profile.")
                    BulletPoint("Access to detailed media insights (likes, comments, impressions, video views) that brands care about.")
                    BulletPoint("A stronger, more credible profile that businesses can evaluate at a glance.")
                }

                InfoSection(title: "What you need before connecting:") {
                    BulletPoint("Your Instagram must be a Creator or Business account (personal accounts cannot connect).")
                    BulletPoint("Your Instagram account must be linked to a Facebook Page (Meta requires this link for insights).")
                    BulletPoint("You’ll log in with your Facebook credentials to complete the connection.")
                }

                InfoSection(title: "How to connect:") {
                    BulletPoint("Make sure your Instagram is switched to a Creator or Business account (you can change this in Instagram Settings → Account).")
                    BulletPoint("Ensure your Instagram is linked to a Facebook Page you manage.")
                    BulletPoint("Click “Connect Instagram” above and log in with Facebook.")
                    BulletPoint("Grant the requested permissions (needed to pull your analytics securely).")
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    Instagram()
}
