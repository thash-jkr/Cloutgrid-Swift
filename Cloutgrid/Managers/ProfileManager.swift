//
//  ProfileManager.swift
//  Cloutgrid
//
//  Created by Afthash on 26/3/2026.
//

import Foundation
import KeychainSwift
import SwiftUI

@Observable
class ProfileManager {
    var auth: AuthManager?
    
    var posts: [PostModel] = []
    var collabs: [PostModel] = []
    
    var otherProfile: UserContainer?
    var otherPosts: [PostModel] = []
    var otherCollabs: [PostModel] = []
    
    var isLoading: Bool = false
    var errorMessage: String?
    
    @MainActor
    func fetchProfile(username: String, other: Bool) async {
        self.isLoading = true
        self.errorMessage = nil
        self.otherProfile = nil
        
        do {
            let response: UserContainer = try await APIService.shared.request(
                endpoint: "/profiles/\(username)/",
                method: "GET",
                body: nil,
                requireAuth: true
            )
            
            if other {
                self.otherProfile = response
            } else {
                await MainActor.run {
                    auth?.updateUser(profile: response)
                }
            }
            
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func fetchPosts(username: String, other: Bool = false) async {
        self.isLoading = true
        self.errorMessage = nil
        self.otherPosts = []
        
        do {
            let response: [PostModel] = try await APIService.shared.request(
                endpoint: "/posts/\(username)/",
                method: "GET",
                body: nil,
                requireAuth: true,
                fullURL: false
            )
            
            if other {
                self.otherPosts = response
            } else {
                self.posts = response
            }
            
            self.isLoading = false
            self.errorMessage = nil
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func fetchCollabs(username: String, other: Bool = false) async {
        self.isLoading = true
        self.errorMessage = nil
        self.otherCollabs = []
        
        var endpoint = ""
        
        if other {
            endpoint = "/posts/collabs/\(username)/"
        } else {
            endpoint = "/posts/collabs/"
        }
        
        do {
            let response: [PostModel] = try await APIService.shared.request(
                endpoint: endpoint,
                method: "GET",
                body: nil,
                requireAuth: true,
                fullURL: false
            )
            
            if other {
                self.otherCollabs = response
            } else {
                self.collabs = response
            }
            
            self.isLoading = false
            self.errorMessage = nil
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func handleBlock(username: String, block: Bool) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/profiles/\(username)/\(block ? "block" : "unblock")/",
                method: "POST",
                body: nil,
                requireAuth: true
            )
            
            ToastManager.shared.showToast(
                message: "You have \(block ? "blocked" : "unblocked") @\(username)",
                isSuccess: true
            )
            
            self.otherProfile?.isBlocking = block
            self.isLoading = false
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.errorMessage = Constants.errorText
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(Constants.errorText)",
                    isSuccess: false
                )
        }
    }
    
    @MainActor
    func handleFollow(username: String, follow: Bool) async {
        self.errorMessage = nil
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/profiles/\(username)/\(follow ? "follow" : "unfollow")/",
                method: "POST",
                body: nil,
                requireAuth: true
            )
            
            ToastManager.shared.showToast(
                message: "You have \(follow ? "followed" : "unfollowed") @\(username)",
                isSuccess: true
            )
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                self.otherProfile?.isFollowing = follow
                self.otherProfile?.profile.followersCount += follow ? 1 : -1
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
