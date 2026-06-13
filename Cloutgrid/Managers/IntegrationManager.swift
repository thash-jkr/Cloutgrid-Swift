//
//  IntegrationManager.swift
//  Cloutgrid
//
//  Created by Afthash on 5/6/2026.
//

import Foundation

@Observable
class IntegrationManager {
    var instagramPage: InstagramPageModel?
    var instagramMedia: [InstagramMediaModel] = []
    
    var youtubeChannel: YoutubeChannelModel?
    var youtubeMedia: [YoutubeMediaModel] = []
    
    var isLoading: Bool = false
    var errorMessage: String?
    
    @MainActor
    func connectInstagram(auth: AuthManager) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response: InstagramResponseModel = try await APIService.shared.request(
                endpoint: "/instagram/connect/",
                method: "POST",
                body: [:],
                requireAuth: true
            )
            
            ToastManager.shared
                .showToast(
                    message: "@\(response.ig_page) connect via \(response.fb_page)",
                    isSuccess: true
                )
            
            auth.user?.instagramConnected = true
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func disconnectInstagram(auth: AuthManager) async {
        self.isLoading = true
        self.errorMessage = nil
        
        auth.user?.instagramConnected = false
        self.instagramPage = nil
        self.instagramMedia = []
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/auth/facebook/deauthorize/",
                method: "POST",
                body: [:],
                requireAuth: true
            )
            
            ToastManager.shared
                .showToast(
                    message: "Instagram disconnected",
                    isSuccess: true
                )
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func fetchInstagramProfile() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/instagram/profile/fetch/",
                method: "POST",
                body: [:],
                requireAuth: true
            )
            
            ToastManager.shared
                .showToast(
                    message: "Instagram Profile fetched successfully",
                    isSuccess: true
                )
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print(error)
        }
    }
    
    @MainActor
    func readInstagramProfile(username: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response: InstagramPageResponse = try await APIService.shared.request(
                endpoint: "/instagram/profile/read/\(username)/",
                method: "GET",
                body: nil,
                requireAuth: true
            )
            
            instagramPage = response.profileData
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print(error)
        }
    }
    
    @MainActor
    func fetchInstagramMedia() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/instagram/media/fetch/",
                method: "POST",
                body: [:],
                requireAuth: true
            )
            
            ToastManager.shared
                .showToast(
                    message: "Instagram Media fetched successfully",
                    isSuccess: true
                )
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print(error)
        }
    }
    
    @MainActor
    func readInstagramMedia(username: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response: InstagramMediaResponse = try await APIService.shared.request(
                endpoint: "/instagram/media/read/\(username)/",
                method: "GET",
                body: nil,
                requireAuth: true
            )
            
            instagramMedia = response.media
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print(error)
        }
    }
    
    @MainActor
    func fetchYoutubeChannel() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/youtube/channel/fetch/",
                method: "POST",
                body: [:],
                requireAuth: true
            )
            
            ToastManager.shared
                .showToast(
                    message: "YouTube channel details fetched successfully",
                    isSuccess: true
                )
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func readYoutubeChannel(username: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response: YoutubeChannelResppnse = try await APIService.shared.request(
                endpoint: "/youtube/channel/read/\(username)/",
                method: "GET",
                body: nil,
                requireAuth: true
            )
            
            self.youtubeChannel = response.channelData
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func fetchYoutubeMedia() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/youtube/media/fetch/",
                method: "POST",
                body: [:],
                requireAuth: true
            )
            
            ToastManager.shared
                .showToast(
                    message: "YouTube media details fetched successfully",
                    isSuccess: true
                )
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func readYoutubeMedia(username: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response: YoutubeMediaResponse = try await APIService.shared.request(
                endpoint: "/youtube/media/read/\(username)/",
                method: "GET",
                body: nil,
                requireAuth: true
            )
            
            self.youtubeMedia = response.data
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared
                .showToast(
                    message: "Error: \(errorMessage ?? Constants.errorText)",
                    isSuccess: false
                )
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
}
