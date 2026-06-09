//
//  ProfileConstants.swift
//  Cloutgrid
//
//  Created by Afthash on 26/3/2026.
//

import Foundation
import SwiftUI

extension Text {
    func profileText1() -> some View {
        self
            .font(.system(size: 14, weight: .semibold))
    }
}

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

struct InstagramConstant: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Connecting your Instagram unlocks analytics that help you stand out to businesses 🙋🏻‍♂️. This transparency builds trust, boosts your credibility, and increases your chances of securing collaborations 🤝.")
                .padding(.bottom)
                .font(.footnote)

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
        .padding(.horizontal)
    }
}

struct YoutubeConstants: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Connecting your YouTube channel unlocks verified metrics that demonstrate your influence 🚀. Providing real-time data builds professional credibility and makes it easier for brands to partner with you 🤝.")
                .padding(.bottom)
                .font(.footnote)
                
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
        .padding(.horizontal)
    }
}
