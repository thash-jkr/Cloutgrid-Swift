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
    
    @Binding var profilePath: NavigationPath
    
    enum CurrentTab: String {
        case posts
        case instagram
        case youtube
        case collabs
    }
    
    @State private var selectedTab: CurrentTab = .posts
    
    private var availableTabs: [CurrentTab] {
        if auth.type == "business" {
            return [.posts, .collabs]
        } else {
            return [.posts, .instagram, .youtube]
        }
    }
    
    private func tabButton(for tab: CurrentTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            if tab == .instagram {
                Awesome.Brand.instagram.image
                    .size(30)
                    .foregroundColor(selectedTab == tab ? .second : .first)
            } else if tab == .youtube {
                Awesome.Brand.youtube.image
                    .size(30)
                    .foregroundColor(selectedTab == tab ? .second : .first)
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
    
    var body: some View {
        ScrollView {
            ProfileHeader(user: auth.user ?? PostModel.creatorPreview)
            
            tabPicker
            
//            switch selectedTab {
//            case .posts:
//                PostGrid(posts: profile.posts, path: $profilePath)
//            case .instagram:
//                Instagram()
//            case .youtube:
//                Youtube()
//            case .collabs:
//                PostGrid(posts: profile.collabs, path: $profilePath)
//            }
            
            ZStack(alignment: .top) {
                PostGrid(posts: profile.posts, path: $profilePath)
                    .opacity(selectedTab == .posts ? 1 : 0)
                    .allowsHitTesting(selectedTab == .posts)

                Instagram()
                    .opacity(selectedTab == .instagram ? 1 : 0)
                    .allowsHitTesting(selectedTab == .instagram)

                Youtube()
                    .opacity(selectedTab == .youtube ? 1 : 0)
                    .allowsHitTesting(selectedTab == .youtube)

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
        }
        .onChange(of: deepLinkManager.profileAction) { oldValue, newValue in
            if newValue == .connectInstagram {
                selectedTab = .instagram
                
                DispatchQueue.main.async {
                    deepLinkManager.profileAction = nil
                }
            } else if newValue == .connectYoutube {
                selectedTab = .youtube
                
                DispatchQueue.main.async {
                    deepLinkManager.profileAction = nil
                }
            }
        }
    }
}

#Preview {
    ProfileView(profilePath: .constant(NavigationPath()))
        .environment(AuthManager())
        .environment(ProfileManager())
        .environment(HomeManager())
        .environmentObject(DeepLinkManager())
}
