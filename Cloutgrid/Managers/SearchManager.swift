//
//  SearchManager.swift
//  Cloutgrid
//
//  Created by Afthash on 4/4/2026.
//

import SwiftUI

@Observable
class SearchManager {
    var homeManager: HomeManager?
    
    var suggetions: [UserContainer] = []
    var results: [UserContainer] = []
    var collabs: [UserContainer] = []
    
    var isLoading: Bool = false
    var errorMessage: String?
    
    @MainActor
    func fetchSuggetions() async {
        do {
            self.isLoading = true
            self.errorMessage = nil
            
            let response: AllUsersResponse = try await APIService.shared.request(
                endpoint: "/users/",
                method: "GET",
                body: nil,
                requireAuth: true
            )
            
            let all_creators = response.creators
            let all_businesses = response.businesses
            let all_users = all_creators + all_businesses
            let number = min(all_users.count, 5)
            
            let shuffled = all_users.shuffled()
            if shuffled.isEmpty {
                self.suggetions = []
            } else {
                let upperBound = min(shuffled.count, number)
                self.suggetions = Array(shuffled.prefix(upperBound))
            }
            
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func handleSearch(query: String) async {
        do {
            self.errorMessage = nil
            
            let response: AllUsersResponse = try await APIService.shared.request(
                endpoint: "/search?q=\(query)",
                method: "GET",
                body: nil,
                requireAuth: true
            )
            
            let all_creators = response.creators
            let all_businesses = response.businesses
            let all_users = all_creators + all_businesses
            
            self.results = all_users
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func handleSearchBusiness(query: String) async {
        do {
            self.isLoading = true
            self.errorMessage = nil
            
            let response: [UserContainer] = try await APIService.shared.request(
                endpoint: "/search-business?q=\(query)",
                method: "GET",
                body: nil,
                requireAuth: true
            )
            
            self.collabs = response
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func handlePostImage(image: UIImage, caption: String, collab: String) async {
        do {
            self.isLoading = true
            self.errorMessage = nil
            
            let (multipartBody, boundary) = APIService.shared.multipartBodyBuilder(
                image: image,
                imageKey: "image",
                params: ["caption": caption, "collaboration": collab]
            )
            
            let response: PostModel = try await APIService.shared.request(
                endpoint: "/posts/",
                method: "POST",
                body: nil,
                requireAuth: true,
                contentType: "multipart/form-data; boundary=\(boundary)",
                rawData: multipartBody
            )
            
            await MainActor.run {
                homeManager?.addNewPost(post: response)
            }
            
            ToastManager.shared.showToast(
                message: "Posted",
                isSuccess: true
            )
            
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
}

