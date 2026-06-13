//
//  Instagram.swift
//  Cloutgrid
//
//  Created by Afthash on 23/4/2026.
//

import SwiftUI
import KeychainSwift

struct StatsRow: View {
    var instagramProfile: InstagramPageModel
    
    var body: some View {
        VStack {
            Text("Profile Insights")
                .font(.title3)
                .bold()
                .padding(.leading)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            
            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                HStack(alignment: .top, spacing: 20) {
                    ForEach(instagramProfile.insights) { metric in
                        VStack(spacing: 5) {
                            Text("\(metric.totalValue.value)").bold().font(.title)
                            Text(" \(metric.title)")
                                .font(.caption)
                        }
                        .frame(width: 200, height: 100)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(
                            color: Color.black.opacity(0.1),
                            radius: 5,
                            x: 0,
                            y: 5
                        )
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct MediaRow: View {
    var integration: IntegrationManager
    var type: String
    
    private func getIconName(for metricName: String) -> String {
        switch metricName.lowercased() {
        case "engagement":
            return "chart.line.uptrend.xyaxis"
        case "impressions", "views":
            return "eye"
        case "reach":
            return "chart.line.uptrend.xyaxis"
        case "saves":
            return "bookmark"
        default:
            return "chart.bar"
        }
    }
    
    var body: some View {
        VStack {
            Text(type == "IMAGE" ? "Top Posts" : "Top Reels")
                .font(.title3)
                .bold()
                .padding(.leading)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            
            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                HStack(alignment: .top) {
                    ForEach(integration.instagramMedia) { media in
                        if media.mediaType == type {
                            ZStack(
                                alignment: .bottomLeading
                            ) {
                                AsyncImage(
                                    url: URL(
                                        string: media.mediaType == "VIDEO" ? media.thumbnailUrl : media.mediaUrl
                                    )
                                ) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(
                                            width: 200
                                        )
                                        .clipShape(
                                            RoundedRectangle(
                                                cornerRadius: 20
                                            )
                                        )
                                } placeholder: {
                                    ProgressView().frame(width: 200)
                                }
                                .padding(.bottom, 20)
                                
                                HStack {
                                    HStack(spacing: 0) {
                                        Image(systemName: "heart.fill")
                                            .foregroundStyle(
                                                Color.red
                                            )
                                        Text("\(media.likeCount)").bold()
                                    }
                                    
                                    ForEach(media.insights) { insight in
                                        HStack(spacing: 0) {
                                            Image(systemName: getIconName(for: insight.name))
                                            
                                            ForEach(insight.values) { insightValue in
                                                Text("\(insightValue.value)")
                                                    .bold()
                                            }
                                        }
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
                }
                .padding(.horizontal)
            }
        }
    }
}

struct Instagram: View {
    @Environment(AuthManager.self) private var auth
    @Environment(IntegrationManager.self) private var integration
    
    @State private var purgeConfirm: Bool = false
    
    private var instagramConstant: some View {
        VStack {
            VStack {
                Link(
                    destination: URL(
                        string: "\(APIConfig.current.baseURL)/auth/facebook/start?token=\(auth.access ?? "")&medium=app"
                    )!
                ) {
                    Text("Connect Instagram")
                        .customButton()
                }
            }
            .padding(.bottom)
            
            InstagramConstant()
        }
    }
    
    var body: some View {
        ScrollView {
            if auth.user?.instagramConnected ?? false {
                VStack {
                    if let instagramProfile = integration.instagramPage {
                        HStack(alignment: .top) {
                            VStack {
                                AsyncImage(
                                    url: URL(
                                        string: instagramProfile.profilePicture
                                    )
                                ) { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: 75, height: 75)
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProgressView().frame(width: 75, height: 75)
                                }
                                .padding(.bottom, 20)
                                
                                Link(
                                    destination: URL(
                                        string: "https://instagram.com/\(instagramProfile.username)"
                                    )!
                                ) {
                                    Text("@\(instagramProfile.username)")
                                        .customButton()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 10) {
                                HStack {
                                    Text("\(instagramProfile.followers)")
                                        .bold()
                                    Text("Followers")
                                        .foregroundStyle(.secondary)
                                }
                                
                                HStack {
                                    Text("\(instagramProfile.followings)")
                                        .bold()
                                    Text("Followings")
                                        .foregroundStyle(.secondary)
                                }
                                
                                HStack {
                                    Text("\(instagramProfile.mediaCount)")
                                        .bold()
                                    Text("Posts")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(
                                maxWidth: .infinity,
                                alignment: .trailing
                            )
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                        
                        StatsRow(instagramProfile: instagramProfile)
                        
                        MediaRow(integration: integration, type: "IMAGE")
                        
                        MediaRow(integration: integration, type: "VIDEO")
                    } else if integration.isLoading {
                        VStack(spacing: 10) {
                            Image("Graph")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150)
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                            
                            LoadingView()
                        }
                    }
                }
                .task {
                    await integration
                        .readInstagramProfile(
                            username: auth.user?.profile
                                .username ?? "")
                    
                    await integration
                        .readInstagramMedia(
                            username: auth.user?.profile
                                .username ?? "")
                }
            } else {
                instagramConstant
            }
        }
        .toolbar {
            if let user = auth.user, user.instagramConnected ?? false {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            Task {
                                await integration.fetchInstagramProfile()
                                await integration
                                    .readInstagramProfile(
                                        username: user.profile
                                            .username)
                                
                                await integration.fetchInstagramMedia()                                
                                await integration
                                    .readInstagramMedia(
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
        Instagram()
            .environment(AuthManager())
            .environment(IntegrationManager())
    }
}
