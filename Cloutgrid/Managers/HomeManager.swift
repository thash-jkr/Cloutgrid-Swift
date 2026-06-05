//
//  HomeManager.swift
//  Cloutgrid
//
//  Created by Afthash on 22/3/2026.
//

import SwiftUI

@Observable
class HomeManager {
    var notifications: [NotificationModel] = []
    var posts: [PostModel] = []
    var nextCursor: String?
    var comments: [CommentModel] = []
    
    var isLoading: Bool = false
    var errorMessage: String?
        
    @MainActor
    func fetchNotifications() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response: [NotificationModel] = try await APIService.shared.request(
                endpoint: "/notifications/?all=false/",
                method: "GET",
                body: nil,
                requireAuth: true
            )
            
            self.notifications = response
            self.isLoading = false
            self.errorMessage = nil
        } catch {
            self.isLoading = false
            self.errorMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func readNotification(id: Int) async {
        self.errorMessage = nil
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/notifications/\(id)/mark_as_read/",
                method: "POST",
                body: nil,
                requireAuth: true
            )
            
            if let i = notifications.firstIndex(where: { $0.id == id }) {
                notifications.remove(at: i)
            }
        } catch {
            self.errorMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func fetchPosts(isFirstPage: Bool = true) async {
        var url: String
        
        if isFirstPage {
            url = "/posts/"
        } else {
            guard let nextURL = self.nextCursor, !nextURL.isEmpty else {return}
            url = nextURL
        }
        
        guard !self.isLoading else {return}
        self.isLoading = true
        
        do {
            let response: PostResponse = try await APIService.shared.request(
                endpoint: url,
                method: "GET",
                body: nil,
                requireAuth: true,
                fullURL: !isFirstPage
            )
            
            if isFirstPage {
                self.posts = response.results
            } else {
                self.posts.append(contentsOf: response.results)
            }
            
            self.nextCursor = response.next
            self.isLoading = false
        } catch {
            self.isLoading = false
            errorMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    func addNewPost(post: PostModel) {
        posts.insert(post, at: 0)
    }
    
    @MainActor
    func likePost(postID: Int) async {
        do {
            let response: LikeResponse = try await APIService.shared.request(
                endpoint: "/posts/\(postID)/like/",
                method: "POST",
                body: [:],
                requireAuth: true
            )
            
            if let i = posts.firstIndex(where: { $0.id == postID }) {
                posts[i].likeCount = response.likeCount
                posts[i].isLiked = response.liked
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func fetchComments(postID: Int) async {
        self.isLoading = true
        self.errorMessage = nil
        self.comments = []
        
        do {
            let response: [CommentModel] = try await APIService.shared.request(
                endpoint: "/posts/\(postID)/comments/",
                method: "GET",
                body: nil,
                requireAuth: true
            )
            
            comments = response
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func addComment(postID: Int, content: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response: CommentModel = try await APIService.shared.request(
                endpoint: "/posts/\(postID)/comments/",
                method: "POST",
                body: ["content": content],
                requireAuth: true
            )
            
            if let i = posts.firstIndex(where: { $0.id == postID }) {
                posts[i].commentCount += 1
            }
            
            comments.insert(response, at: 0)
            
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func deleteComment(postID: Int, commentID: Int) async {
        self.errorMessage = nil
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/posts/\(postID)/comment/\(commentID)/",
                method: "DELETE",
                body: nil,
                requireAuth: true
            )
            
            if let i = comments.firstIndex(where: { $0.id == commentID}) {
                comments.remove(at: i)
            }
            
            if let i = posts.firstIndex(where: { $0.id == postID}) {
                posts[i].commentCount -= 1
            }
            
            ToastManager.shared
                .showToast(message: "Comment deleted", isSuccess: true)
        } catch {
            self.errorMessage = error.localizedDescription
            ToastManager.shared
                .showToast(message: "Something is wrong", isSuccess: false)
        }
    }
    
    @MainActor
    func deletePost(postID: Int) async {
        self.errorMessage = nil
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/posts/\(postID)/",
                method: "DELETE",
                body: nil,
                requireAuth: true
            )
            
            if let i = posts.firstIndex(where: { $0.id == postID}) {
                posts.remove(at: i)
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
