//
//  PostGrid.swift
//  Cloutgrid
//
//  Created by Afthash on 4/4/2026.
//

import SwiftUI

struct PostGrid: View {
    @Environment(ProfileManager.self) private var profile
    
    var posts: [PostModel]
    @Binding var path: NavigationPath
    
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    private func gridItem(post: PostModel) -> some View {
        Rectangle()
                .fill(Color.gray.opacity(0.1))
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    AsyncImage(url: URL(string: post.image)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else if phase.error != nil {
                            Image(systemName: "exclamationmark.triangle")
                        } else {
                            ProgressView()
                        }
                    }
                }
                .clipped()
    }
    
    private var profilePosts: some View {
        if posts.count > 0 {
            AnyView(
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(posts) { post in
                        Button {
                            path.append(post)
                        } label: {
                            gridItem(post: post)
                        }
                    }
                }
            )
        } else {
            AnyView(
                Empty(
                    type: "post",
                    message: "No posts to show!",
                    isLoading: profile
                        .isLoading)
            )
        }
    }
    
    var body: some View {
        VStack {
            profilePosts
            Spacer()
        }
    }
}

#Preview {
    PostGrid(
        posts: [PostModel.postPreview1, PostModel.postPreview2],
        path: .constant(NavigationPath())
    )
    .environment(AuthManager())
    .environment(ProfileManager())
    .environment(HomeManager())
}
