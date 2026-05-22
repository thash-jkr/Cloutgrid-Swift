//
//  Options.swift
//  Cloutgrid
//
//  Created by Afthash on 5/4/2026.
//

import SwiftUI

struct Options: View {
    @Environment(HomeManager.self) private var home
    @Environment(ProfileManager.self) private var profile
    
    var post: PostModel
    @Binding var activeAction: PostAction?
    var username: String
    
    @State private var showDeleteAlert: Bool = false
    @State private var showBlockAlert: Bool = false
    @State private var showReportAlert: Bool = false
    @State private var reportContent: String = ""
    
    var body: some View {
        List {
            if username == post.author.username {
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Text("Delete Post")
                }
                .alert("Delete Post?", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        Task {
                            await home.deletePost(postID: post.id)
                            await home.fetchPosts()
                            activeAction = nil
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
                    Text("Report Post").foregroundStyle(Color.primary)
                }
                
                Button {
                    showReportAlert = true
                } label: {
                    Text("Report @\(post.author.username)").foregroundStyle(Color.primary)
                }
                
                Button(role: .destructive) {
                    showBlockAlert = true
                } label: {
                    Text("Block @\(post.author.username)")
                }
                .alert(
                    "Block @\(post.author.username)?",
                    isPresented: $showBlockAlert
                ) {
                    Button("Block", role: .destructive) {
                        Task {
                            await profile
                                .handleBlock(
                                    username: post.author.username,
                                    block: true
                                )
                            await home.fetchPosts()
                            activeAction = nil
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to block this user?")
                }
            }
        }
        .presentationDetents([.fraction(0.3)])
        .presentationDragIndicator(.visible)
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
}

#Preview {
    Options(
        post: PostModel.postPreview1,
        activeAction: .constant(nil),
        username: "brandco0"
    )
    .environment(HomeManager())
    .environment(ProfileManager())
}
