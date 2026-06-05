//
//  HomeView.swift
//  Cloutgrid
//
//  Created by Afthash on 16/3/2026.
//

import SwiftUI

enum PostAction: Identifiable {
    case comments(PostModel)
    case options(PostModel)
    
    var id: String {
        switch self {
        case .comments(let post): return "comment-\(post.id)"
        case .options(let post): return "options-\(post.id)"
        }
    }
}

struct HomeView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(HomeManager.self) private var home
    
    @Binding var selectedTab: TabIdentifier
    @Binding var homePath: NavigationPath
    @Binding var notificationSheet: Bool
    @Binding var scrollY: ScrollPosition
    
    @State private var activeAction: PostAction? = nil
    @State var selectedPost: PostModel? = nil
    
    @State private var headerOffset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    
    private func handleScroll(oldValue: CGFloat, newValue: CGFloat) {
        guard newValue > 0 else {
            headerOffset = 0
            return
        }
        
        if newValue > oldValue {
            headerOffset = -150
        } else {
            headerOffset = 0
        }
    }
    
    var body: some View {
        VStack {
            if home.posts.count > 0 {
                ScrollView {
                    VStack {
                        ForEach(home.posts) { post in
                            FeedPost(
                                post: post,
                                path: $homePath,
                                activeAction: $activeAction,
                                selectedTab: $selectedTab
                            )
                        }
                    }
                    
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            Task {
                                await home.fetchPosts(isFirstPage: false)
                            }
                        }
                }
                .scrollPosition($scrollY)
                .refreshable {
                    await home.fetchPosts(isFirstPage: true)
                }
            } else if home.isLoading {
                FeedLoading()
            }
        }
        .sheet(isPresented: $notificationSheet) {
            NotificationView()
        }
        .sheet(item: $activeAction) { action in
            switch action {
            case .comments(let post):
                Comments(postID: post.id)
                    .presentationDetents([.fraction(0.5), .fraction(1)])
                    .presentationDragIndicator(.visible)
            case .options(let post):
                Options(
                    post: post,
                    activeAction: $activeAction,
                    username: auth.user?.profile.username ?? ""
                )
            }
        }
        .task {
            await home.fetchNotifications()
            await home.fetchPosts(isFirstPage: true)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(
            selectedTab: .constant(.home),
            homePath: .constant(NavigationPath()),
            notificationSheet: .constant(false),
            scrollY: .constant(ScrollPosition())
        )
            .environment(AuthManager())
            .environment(HomeManager())
            .environment(ProfileManager())
    }
}

