//
//  OtherYoutube.swift
//  Cloutgrid
//
//  Created by Afthash on 26/4/2026.
//

import SwiftUI

struct OtherYoutube: View {
    @Environment(IntegrationManager.self) private var integration
    
    var user: UserContainer
    
    private var otherYoutubeStatic: some View {
        VStack {
            Image("Graph")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            Text(
                "@\(user.profile.username) hasn't connected their Youtube yet!"
            )
                .foregroundStyle(.secondary)
                .font(.callout)
        }
    }
    
    var body: some View {
        ScrollView {
            if user.youtubeConnected ?? false {
                VStack {
                    if let channel = integration.youtubeChannel {
                        ChannelDetail(channel: channel)
                    }
                    
                    Divider()
                    
                    YoutubeMediaRow(media: integration.youtubeMedia)
                }
                .ignoresSafeArea(edges: .top)
                .task {
                    await integration
                        .readYoutubeChannel(username: user.profile.username)
                    await integration
                        .readYoutubeMedia(username: user.profile.username)
                }
            } else {
                otherYoutubeStatic
            }
        }
        .ignoresSafeArea(edges: user.youtubeConnected ?? false ? .top : [])
    }
}

#Preview {
    OtherYoutube(user: PostModel.creatorPreview)
        .environment(IntegrationManager())
}
