//
//  ProfileMain.swift
//  Cloutgrid
//
//  Created by Afthash on 4/4/2026.
//

import SwiftUI

struct ProfileMain: View {
    @Binding var path: NavigationPath
    var posts: [PostModel]
    var type: String
    
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
            selectedTab = tab
        } label: {
            Image(systemName: iconName(for: tab))
                .font(.system(size: 20))
                .foregroundStyle(selectedTab == tab ? Color.second : Color.first)
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
    
    @ViewBuilder
    private func tabContent(posts: [PostModel]) -> some View {
        switch selectedTab {
        case .posts:
            PostGrid(posts: posts, path: $path)
        case .instagram:
            Instagram()
        case .youtube:
            Youtube()
        case .collabs:
            PostGrid(posts: posts, path: $path)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            tabPicker
            
            ZStack(alignment: .top) {
                PostGrid(posts: posts, path: $path)
                    .opacity(selectedTab == .posts ? 1 : 0)
                    .allowsHitTesting(selectedTab == .posts)
                
                Instagram()
                    .opacity(selectedTab == .instagram ? 1 : 0)
                    .allowsHitTesting(selectedTab == .instagram)
                
                Youtube()
                    .opacity(selectedTab == .youtube ? 1 : 0)
                    .allowsHitTesting(selectedTab == .youtube)
                
                PostGrid(posts: posts, path: $path)
                    .opacity(selectedTab == .collabs ? 1 : 0)
                    .allowsHitTesting(selectedTab == .collabs)
            }
        }
    }
}

#Preview {
    ProfileMain(
        path: .constant(NavigationPath()),
        posts: [PostModel.postPreview1, PostModel.postPreview2],
        type: "creator"
    )
}
