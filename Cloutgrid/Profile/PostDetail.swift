//
//  PostDetail.swift
//  Cloutgrid
//
//  Created by Afthash on 27/3/2026.
//

import SwiftUI

struct PostDetail: View {
    @Environment(AuthManager.self) private var auth
    @Environment(HomeManager.self) private var home
    @Environment(ProfileManager.self) private var profile
    
    @State private var post: PostModel
    
    init(profilePost: PostModel) {
        _post = State(initialValue: profilePost)
    }
    
    @State private var reportContent: String = ""
    @State private var showOptions: Bool = false
    @State private var showComments: Bool = false
    @State private var showReportAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    @State var likeTrigger: Int = 0
    
    private var postOptions: some View {
        List {
            if auth.user?.profile.username == post.author.username {
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Text("Delete Post")
                }
                .alert("Delete Post?", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        Task {
                            await home.deletePost(postID: post.id)
                            
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to permanently remove this post? This action cannot be undone.")
                }
            } else {
                Button {
                    showReportAlert = true
                } label: {
                    Text("Report post")
                        .foregroundStyle(Color.primary)
                }
                
                Button {
                    showReportAlert = true
                } label: {
                    Text("Report @\(post.author.username)")
                        .foregroundStyle(Color.primary)
                }
            }
        }
        .alert("Report Content", isPresented: $showReportAlert) {
            TextField(
                "Reason (e.g., Spam, Harassment)",
                text: $reportContent,
                axis: .vertical
            )
            
            Button("Submit", action: {})
            Button("Cancel", role: .cancel) { reportContent = "" }
        } message: {
            Text("Please tell us why you are reporting this. Our team will review it shortly.")
        }
    }
    
    var body: some View {
        ScrollView {
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
                
                Text(post.author.name).heading4().bold()
                
                if post.collaboration != nil {
                    Text("with").heading4()
                    Text(post.collaboration?.profile.name ?? "").heading4().bold()
                }
                
                Spacer()
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
                        post.isLiked = true
                        post.likeCount += 1
                    }
                }
            }
            
            HStack {
                Spacer()
                
                Button {
                    if !post.isLiked {
                        likeTrigger += 1
                    }
                    
                    Task {
                        await home.likePost(postID: post.id)
                        
                        if post.isLiked {
                            post.isLiked = false
                            post.likeCount -= 1
                        } else {
                            post.isLiked = true
                            post.likeCount += 1
                        }
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
                    "\(post.likeCount) hits | \(post.commentCount) comments"
                )
                .heading4()
                
                Spacer()
                
                Image(systemName: "square")
                    .font(.system(size: 25))
                    .onTapGesture {
                        showComments = true
                    }
                
                Spacer()
            }
            
            Text(post.caption).regular2()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
        }
        .sheet(isPresented: $showComments, content: {
            Comments(postID: post.id)
                .presentationDetents([.fraction(0.5), .fraction(1)])
                .presentationDragIndicator(.visible)
        })
        .sheet(isPresented: $showOptions) {
            postOptions
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    showOptions = true
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PostDetail(profilePost: PostModel.postPreview1)
            .environment(HomeManager())
            .environment(AuthManager())
            .environment(ProfileManager())
    }
}
