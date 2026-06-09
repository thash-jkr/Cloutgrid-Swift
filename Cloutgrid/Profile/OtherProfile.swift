//
//  OtherProfile.swift
//  Cloutgrid
//
//  Created by Afthash on 4/4/2026.
//

import SwiftUI
import Awesome

struct OtherProfile: View {
    @Environment(ProfileManager.self) private var profile
    
    var username: String
    var type: String
    @Binding var path: NavigationPath
    
    @State var optionSheet: Bool = false
    @State private var showBlockAlert: Bool = false
    @State private var unFollowConfirm: Bool = false
    @State private var selectedIntegration: CurrentIntegration? = nil
    
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
        
    private var availableTabs: [CurrentTab] {
        if type == "business" {
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
                    
                    if profile.otherProfile?.instagramConnected ?? false {
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
                    
                    if profile.otherProfile?.youtubeConnected ?? false {
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

    private var optionContent: some View {
        NavigationStack {
            List {
                Button {
                    
                } label: {
                    Text("Report @\(profile.otherProfile?.profile.username ?? "")")
                }
                
                Button(role: .destructive) {
                    showBlockAlert = true
                } label: {
                    Text(
                        "\(profile.otherProfile?.isBlocking ?? false ? "Unblock" : "Block") @\(profile.otherProfile?.profile.username ?? "")"
                    )
                }
            }
            .listStyle(.plain)
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.visible)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                "\(profile.otherProfile?.isBlocking ?? false ? "Unblock" : "Block") @\(profile.otherProfile?.profile.username ?? "")?",
                isPresented: $showBlockAlert
            ) {
                Button("\(profile.otherProfile?.isBlocking ?? false ? "Unblock" : "Block")", role: .destructive) {
                    Task {
                        await profile
                            .handleBlock(
                                username: profile.otherProfile?.profile.username ?? "",
                                block: !(profile.otherProfile?.isBlocking ?? false)
                            )
                        
                        optionSheet = false
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to \(profile.otherProfile?.isBlocking ?? false ? "unblock" : "block") this user?")
            }
        }
    }
    
    private func blockedView(blocker: Bool) -> some View {
        VStack(spacing: 20) {
            Image("blocked")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            Text(
                blocker ?
                "This user has blocked you. You cannot view this profile" :
                "You have blocked this user. Unblock to view this profile"
            )
                .foregroundStyle(Color.secondary)
                .font(.footnote)
            
            if !blocker {
                Button {
                    Task {
                        await profile
                            .handleBlock(
                                username: profile.otherProfile?.profile.username ?? "",
                                block: false
                            )
                    }
                } label: {
                    Text("Unblock").customButton()
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if profile.otherProfile?.isBlocking ?? false {
                blockedView(blocker: false)
            } else if profile.otherProfile?.isBlocker ?? false {
                blockedView(blocker: true)
            } else {
                ScrollView {
                    if let user = profile.otherProfile {
                        ProfileHeader(
                            user: user
                        )
                    }
                    
                    tabPicker
                    
                    ZStack(alignment: .top) {
                        PostGrid(posts: profile.otherPosts, path: $path)
                            .opacity(selectedTab == .posts ? 1 : 0)
                            .allowsHitTesting(selectedTab == .posts)
                        
                        PostGrid(posts: profile.otherCollabs, path: $path)
                            .opacity(selectedTab == .collabs ? 1 : 0)
                            .allowsHitTesting(selectedTab == .collabs)
                    }
                }
            }
        }
        .navigationTitle(
            "@\(username)"
        )
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $optionSheet, content: {
            optionContent
        })
        .toolbar {
            ToolbarItem {
                Button {
                    Task {
                        if (profile.otherProfile?.isFollowing ?? true) {
                            unFollowConfirm = true
                        } else {
                            await profile
                                .handleFollow(username: username, follow: true)
                        }
                    }
                } label: {
                    Image(systemName: profile.otherProfile?.isFollowing ?? false ? "person.crop.circle.fill.badge.xmark" : "person.crop.circle.fill.badge.plus")
                        .symbolRenderingMode(.multicolor)
                }
                .confirmationDialog(
                    "Are you sure you want to unfollow @\(username)?",
                    isPresented: $unFollowConfirm,
                    titleVisibility: .visible
                ) {
                    Button(role: .destructive) {
                        Task {
                            await profile
                                .handleFollow(username: username, follow: false)
                        }
                    } label: {
                        Text("Unfollow")
                    }
                }
            }
            
            ToolbarItem {
                Button {
                    optionSheet = true
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .task {
            await profile.fetchProfile(username: username, other: true)
            await profile
                .fetchPosts(username: username, other: true)
            if type == "business" {
                await profile.fetchCollabs(username: username, other: true)
            }
        }
        .sheet(item: $selectedIntegration) { integration in
            NavigationStack {
                switch integration {
                case .instagram:
                    if let user = profile.otherProfile {
                        OtherInstagram(user: user)
                            .navigationTitle("Instagram Insights 📸")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                case .youtube:
                    OtherYoutube(username: username)
                        .navigationTitle("YouTube Analytics 📊")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .presentationDetents([.fraction(0.7) ,.fraction(1)])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationStack {
        OtherProfile(
            username: "creator1",
            type: "creator",
            path: .constant(NavigationPath())
        )
        .environment(ProfileManager())
        .environment(AuthManager())
        .environment(IntegrationManager())
    }
}
