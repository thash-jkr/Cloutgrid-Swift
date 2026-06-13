//
//  Youtube.swift
//  Cloutgrid
//
//  Created by Afthash on 23/4/2026.
//

import SwiftUI

struct ChannelDetail: View {
    var channel: YoutubeChannelModel
    
    var body: some View {
        VStack {
            VStack {
                AsyncImage(
                    url: URL(
                        string: channel.banner
                    )
                ) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                
                AsyncImage(
                    url: URL(
                        string: channel.profilePicture
                    )
                ) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView().frame(width: 100, height: 100)
                }
                .offset(x: 0, y: -50)
            }
            
            VStack {
                Text(channel.title)
                    .font(.title)
                    .bold()
                
                Text(channel.description)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Spacer()
                
                VStack {
                    Text("\(channel.subscriberCount)")
                        .bold()
                    Text("Subscribers")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                
                Spacer()
                
                VStack {
                    Text("\(channel.viewCount)")
                        .bold()
                    Text("Views")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                
                Spacer()
                
                VStack {
                    Text("\(channel.videoCount)")
                        .bold()
                    Text("Videos")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

struct YoutubeMediaRow: View {
    var media: [YoutubeMediaModel]
    
    var body: some View {
        VStack {
            Text("Recent Posts")
                .font(.title3)
                .bold()
                .padding(.leading)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(media) { media in
                        ZStack(alignment: .bottomLeading) {
                            AsyncImage(
                                url: URL(
                                    string: media.thumbnail
                                )
                            ) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(
                                        width: 180,
                                        height: 300
                                    )
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 20
                                        )
                                    )
                            } placeholder: {
                                ProgressView().frame(width: 180)
                            }
                            .padding(.bottom, 20)
                            
                            HStack {
                                HStack(spacing: 0) {
                                    Image(systemName: "hand.thumbsup")
                                    Text("\(media.likes)").bold()
                                }
                                
                                HStack(spacing: 0) {
                                    Image(systemName: "message")
                                    Text("\(media.comments)").bold()
                                }
                                
                                HStack(spacing: 0) {
                                    Image(systemName: "eye")
                                    Text("\(media.views)").bold()
                                }
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 10
                                )
                            )
                            .offset(x: 10, y: -30)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct Youtube: View {
    @Environment(AuthManager.self) private var auth
    @Environment(IntegrationManager.self) private var integration
    
    @State private var purgeConfirm: Bool = false
    
    private var youtubeStatic: some View {
        VStack {
            VStack {
                Link(
                    destination: URL(
                        string: "\(APIConfig.current.baseURL)/auth/google/start?token=\(auth.access ?? "")&medium=app"
                    )!
                ) {
                    Text("Connect Youtube")
                        .customButton()
                }
            }
            .padding(.bottom)
            
            YoutubeConstants()
        }
    }
    
    var body: some View {
        ScrollView {
            if let user = auth.user {
                if user.youtubeConnected ?? false {
                    VStack {
                        if let channel = integration.youtubeChannel {
                            ChannelDetail(channel: channel)
                        }
                        
                        Divider()
                        
                        YoutubeMediaRow(media: integration.youtubeMedia)
                    }
                    .task {
                        await integration
                            .readYoutubeChannel(username: user.profile.username)
                        await integration
                            .readYoutubeMedia(username: user.profile.username)
                    }
                } else {
                    youtubeStatic
                }
            }
        }
        .ignoresSafeArea(edges: auth.user?.youtubeConnected ?? false ? .top : [])
        .toolbar {
            if let user = auth.user, user.youtubeConnected ?? false {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            Task {
                                await integration.fetchYoutubeChannel()
                                await integration
                                    .readYoutubeChannel(
                                        username: user.profile
                                            .username)
                                
                                await integration.fetchYoutubeMedia()
                                await integration
                                    .readYoutubeMedia(
                                        username: user.profile.username
                                    )
                            }
                        } label: {
                            Label("Sync Profile", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
                        }
                        
                        Button {
                            
                        } label: {
                            Label("Check connection", systemImage: "wifi.exclamationmark")
                        }
                        

                        Section {
                            Button(role: .destructive) {
                                purgeConfirm = true
                            } label: {
                                Label("Disconnect", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .confirmationDialog(
                        "Are you sure you want to disconnect your Instagram integration and purge all your data?",
                        isPresented: $purgeConfirm,
                        titleVisibility: .visible
                    ) {
                        Button(role: .destructive) {
                            Task {
                                await integration.disconnectInstagram(auth: auth)
                            }
                        } label: {
                            Text("Purge")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        Youtube()
            .environment(AuthManager())
            .environment(IntegrationManager())
    }
}
