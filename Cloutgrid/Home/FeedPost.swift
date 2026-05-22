//
//  FeedPost.swift
//  Cloutgrid
//
//  Created by Afthash on 26/3/2026.
//

import SwiftUI

struct FeedPost: View {
    @Environment(HomeManager.self) private var home
    @Environment(AuthManager.self) private var auth
    
    var post: PostModel
    @Binding var path: NavigationPath
    @Binding var activeAction: PostAction?
    @Binding var selectedTab: TabIdentifier

    @State var likeTrigger: Int = 0
    
    var body: some View {
        VStack {
            HStack(spacing: 3) {
                HStack {
                    AsyncImage(
                        url: URL(
                            string: post.author.profilePhoto
                        )
                    ) {image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }.frame(width: 25)
                    
                    Text(post.author.name)
                        .heading4()
                        .bold()
                        .foregroundStyle(Color.dualBlack)
                }
                .onTapGesture {
                    if post.postedBy.profile.username == auth.user?.profile.username {
                        selectedTab = .profile
                    } else {
                        path.append(post.postedBy)
                    }
                }
                
                if let collab = post.collaboration {
                    Text("with").heading4()
                    
                    Text(collab.profile.name)
                        .heading4()
                        .bold()
                        .onTapGesture {
                            if collab.profile.username == auth.user?.profile.username {
                                selectedTab = .profile
                            } else {
                                path.append(collab)
                            }
                        }
                }
                
                Spacer()
                
                Button {
                    activeAction = .options(post)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.dualBlack)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            
            AsyncImage(url: URL(string: post.image)) {image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 300)
                    .overlay(ProgressView())
            }
            .frame(maxWidth: .infinity)
            .onTapGesture(count: 2) {
                likeTrigger += 1
                
                if !post.isLiked {
                    Task {
                        await home.likePost(postID: post.id)
                    }
                }
            }
            
            HStack {
                Spacer()
                
                Button {
                    Task {
                        if !post.isLiked {
                            likeTrigger += 1
                        }
                        await home.likePost(postID: post.id)
                    }
                } label: {
                    Image(systemName: post.isLiked ? "arrowshape.up.circle.fill" : "arrowshape.up.circle")
                        .font(.system(size: 25))
                        .foregroundStyle(
                            post.isLiked ? Color.second : Color.dualBlack
                        )
                        .symbolEffect(.bounce, value: likeTrigger)
                }
                .sensoryFeedback(.impact, trigger: post.isLiked)
                
                Spacer()
                
                Text(
                    "\(post.likeCount) hits • \(post.commentCount) comments"
                )
                .heading4()
                
                Spacer()
                
                Button {
                    activeAction = .comments(post)
                } label: {
                    Image(systemName: "square")
                        .font(.system(size: 25))
                        .foregroundStyle(Color.dualBlack)
                }
                
                Spacer()
            }
            
            Text(post.caption).regular2()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
            
            Divider()
        }

    }
}

#Preview {
    FeedPost(
        post: PostModel.postPreview2,
        path: .constant(NavigationPath()),
        activeAction: .constant(nil),
        selectedTab: .constant(.home)
    )
    .environment(HomeManager())
    .environment(AuthManager())
}
