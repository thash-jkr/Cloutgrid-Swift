//
//  Comments.swift
//  Cloutgrid
//
//  Created by Afthash on 4/4/2026.
//

import SwiftUI

struct Comments: View {
    @Environment(HomeManager.self) private var home
    @Environment(AuthManager.self) private var auth
    
    var postID: Int
    
    @State private var showReportAlert: Bool = false
    @State private var comment: String = ""
    @State private var reportContent: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack {
                    if home.comments.count > 0 {
                        List {
                            ForEach(home.comments) { comment in
                                HStack {
                                    AsyncImage(
                                        url: URL(
                                            string: APIConfig.current.baseURL + comment.user.profilePhoto
                                        )
                                    ) {image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                    }.frame(width: 35)
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(comment.user.name) • \(comment.timeAgo)")
                                            .font(.caption2)
                                        Text(comment.content)
                                            .font(.caption)
                                    }
                                }
                                .swipeActions {
                                    if comment.user.username == auth.user?.profile.username {
                                        Button(role: .destructive) {
                                            Task {
                                                await home
                                                    .deleteComment(
                                                        postID: postID,
                                                        commentID: comment.id
                                                    )
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        .tint(.red)
                                    } else {
                                        Button() {
                                            showReportAlert = true
                                        } label: {
                                            Label("Report", systemImage: "exclamationmark.triangle.fill")
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    } else {
                        Empty(
                            type: "comment",
                            message: "No comments to show",
                            isLoading: home.isLoading
                        )
                    }
                }
                .navigationTitle("Comments")
                .navigationBarTitleDisplayMode(.inline)
                .task(id: postID) {
                    await home.fetchComments(postID: postID)
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
                
                HStack {
                    AsyncImage(
                        url: URL(
                            string: APIConfig.current.baseURL + (auth.user?.profile.profilePhoto ?? "")
                        )
                    ) {image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 40    )
                    .padding(.leading, 10)
                    
                    TextField("Add comment", text: $comment)
                        .frame(height: 40)
                        .padding(.horizontal, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .font(.system(size: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    Color.black,
                                    lineWidth: 1
                                )
                        )
                    
                    Button {
                        Task {
                            await home.addComment(postID: postID, content: comment)
                            comment = ""
                        }
                    } label: {
                        Image(systemName: "paperplane.circle")
                            .foregroundStyle(Color.primary)
                            .font(.system(size: 40, weight: .thin))
                            .padding(.trailing, 5)
                    }
                }
            }
        }
    }
}

#Preview {
    Comments(postID: 1)
        .environment(HomeManager())
        .environment(AuthManager())
}
