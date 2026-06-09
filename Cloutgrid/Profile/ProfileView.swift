//
//  ProfileView.swift
//  Cloutgrid
//
//  Created by Afthash on 25/3/2026.
//

import SwiftUI
import Awesome

struct ProfileView: View {
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    
    @Environment(AuthManager.self) private var auth
    @Environment(ProfileManager.self) private var profile
    @Environment(IntegrationManager.self) private var integration
    
    @Binding var profilePath: NavigationPath
    
    enum CurrentIntegration: String, Identifiable {
        case instagram
        case youtube
        
        var id: String { self.rawValue }
    }
    
    enum CurrentTab: String {
        case posts
        case instagram
        case youtube
        case collabs
    }
    
    @State private var selectedTab: CurrentTab = .posts
    @State private var selectedIntegration: CurrentIntegration? = nil
    
    private var availableTabs: [CurrentTab] {
        if auth.type == "business" {
            return [.posts, .collabs]
        } else {
            return [.posts, .instagram, .youtube]
        }
    }
    
    private func tabButton(for tab: CurrentTab) -> some View {
        Button {
            if tab == .instagram {
                selectedIntegration = .instagram
            } else if tab == .youtube {
                selectedIntegration = .youtube
            } else {
                selectedTab = tab
            }
        } label: {
            if tab == .instagram {
                HStack(spacing: 0) {
                    Awesome.Brand.instagram.image
                        .size(30)
                        .foregroundColor(selectedTab == tab ? .second : .first)
                    
                    if auth.user?.instagramConnected ?? false {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            } else if tab == .youtube {
                HStack(spacing: 0) {
                    Awesome.Brand.youtube.image
                        .size(30)
                        .foregroundColor(selectedTab == tab ? .second : .first)
                    
                    if auth.user?.youtubeConnected ?? false {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            } else {
                Image(systemName: iconName(for: tab))
                    .font(.system(size: 20))
                    .foregroundStyle(selectedTab == tab ? Color.second : Color.first)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func iconName(for tab: CurrentTab) -> String {
        switch tab {
        case .posts:
            return selectedTab == .posts ? "square.grid.3x3.fill" : "square.grid.3x3"
        case .instagram:
            return selectedTab == .instagram ? "camera.fill" : "camera"
        case .youtube:
            return selectedTab == .youtube ? "play.rectangle.fill" : "play.rectangle"
        case .collabs:
            return selectedTab == .collabs ? "person.2.fill" : "person.2"
        }
    }
    
    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(availableTabs, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.vertical, 10)
    }
    
    private var socialIntegration: some View {
        HStack(spacing: 30) {
            Button {
                selectedIntegration = .instagram
            } label: {
                HStack(spacing: 5) {
                    HStack(spacing: 0) {
                        Awesome.Brand.instagram.image
                            .size(20)
                            .foregroundColor(.white)
                            
                        Text("Instagram")
                            .foregroundStyle(Color.white)
                            .bold()
                    }
                    
                    if auth.user?.instagramConnected ?? false {
                        Image(systemName: "checkmark.circle.fill")
                            .symbolRenderingMode(.multicolor)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Color.first, in: Capsule())
            }
            
            Button {
                selectedIntegration = .youtube
            } label: {
                HStack(spacing: 0) {
                    Awesome.Brand.youtube.image
                        .size(20)
                        .foregroundColor(.white)
                        
                    Text("Youtube")
                        .foregroundStyle(Color.white)
                        .bold()
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(Color.first, in: Capsule())
            }
        }
    }
    
    private var instaCard : some View {
        VStack {
            Text("Instagram Insights 📸")
                .font(.caption)
            
            Image("Insights")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
            
            HStack(spacing: 0) {
                Text("Connected")
                    .font(.caption2)
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption2)
            }
        }
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 5,
            x: 0,
            y: 5
        )
        .onTapGesture {
            selectedIntegration = .instagram
        }
    }
    
    private var tubeCard : some View {
        VStack {
            Text("YouTube Analytics 📊")
                .font(.caption)
            
            Image("Analytics")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
            
            HStack(spacing: 0) {
                Text("Not Connected")
                    .font(.caption2)
                
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .font(.caption2)
            }
        }
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 5,
            x: 0,
            y: 5
        )
    }
    
    var body: some View {
        ScrollView {
            ProfileHeader(user: auth.user ?? PostModel.creatorPreview)
            
//            HStack {
//                Spacer()
//                
//                instaCard
//                
//                Spacer()
//                
//                tubeCard
//                
//                Spacer()
//            }
//            .padding(.vertical)
            
            if auth.type == "creator" {
//                socialIntegration
            }
            
            tabPicker
            
            ZStack(alignment: .top) {
                PostGrid(posts: profile.posts, path: $profilePath)
                    .opacity(selectedTab == .posts ? 1 : 0)
                    .allowsHitTesting(selectedTab == .posts)

                PostGrid(posts: profile.collabs, path: $profilePath)
                    .opacity(selectedTab == .collabs ? 1 : 0)
                    .allowsHitTesting(selectedTab == .collabs)
            }
        }
        .refreshable {
            await auth.fetchProfile(username: auth.user!.profile.username)
            await profile.fetchPosts(username: auth.user!.profile.username)
        }
        .task {
            await profile.fetchPosts(username: auth.user?.profile.username ?? "")
            
            if auth.type == "creator" {
                if let user = auth.user, user.instagramConnected ?? false {
                    await integration
                        .readInstagramProfile(username: user.profile.username)
                    await integration
                        .readInstagramMedia(username: user.profile.username)
                }
            } else {
                await profile
                    .fetchCollabs(username: auth.user?.profile.username ?? "")
            }
        }
        .onChange(of: deepLinkManager.profileAction) { oldValue, newValue in
            if newValue == .connectInstagram {
                selectedIntegration = .instagram
                
                Task {
                    await integration.connectInstagram(auth: auth)
                    await integration.fetchInstagramProfile()
                    await integration.fetchInstagramMedia()
                    
                    if let user = auth.user {
                        await integration
                            .readInstagramProfile(
                                username: user.profile.username
                            )
                        await integration
                            .readInstagramMedia(username: user.profile.username)
                    }
                }
                
                DispatchQueue.main.async {
                    deepLinkManager.profileAction = nil
                }
            } else if newValue == .connectYoutube {
                selectedIntegration = .youtube
                
                DispatchQueue.main.async {
                    deepLinkManager.profileAction = nil
                }
            }
        }
        .sheet(item: $selectedIntegration) { integration in
            NavigationStack {
                switch integration {
                case .instagram:
                    Instagram()
                        .navigationTitle("Instagram Insights 📸")
                        .navigationBarTitleDisplayMode(.inline)
                case .youtube:
                    Youtube()
                        .navigationTitle("YouTube Analytics 📊")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .presentationDetents([.fraction(1)])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ProfileView(profilePath: .constant(NavigationPath()))
        .environment(AuthManager())
        .environment(ProfileManager())
        .environment(HomeManager())
        .environmentObject(DeepLinkManager())
        .environment(IntegrationManager())
}
