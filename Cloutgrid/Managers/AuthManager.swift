//
//  AuthManager.swift
//  Cloutgrid
//
//  Created by Afthash on 17/3/2026.
//

import SwiftUI
import KeychainSwift

@Observable
class AuthManager {
    let keychain = KeychainSwift()
    
    var user: UserContainer?
    var access: String?
    var isAuth: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    var type: String?
    
    init() {
        if let accessToken = keychain.get("access"),
           let userData = UserDefaults.standard.data(forKey: "user"),
           let decodedUser = try? JSONDecoder().decode(UserContainer.self, from: userData) {
            self.user = decodedUser
            self.type = UserDefaults.standard.string(forKey: "type") ?? "creator"
            self.isAuth = true
            self.access = accessToken
        }
    }
    
    @MainActor
    func fetchProfile(username: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response: UserContainer = try await APIService.shared.request(
                endpoint: "/profiles/\(username)/",
                method: "GET",
                body: nil,
                requireAuth: true
            )
            
            self.user = response
            
            if let encoded = try? JSONEncoder().encode(response) {
                UserDefaults.standard.set(encoded, forKey: "user")
            }
            
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func updateProfile(data: [String: String], image: UIImage?) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let (mulitpartBody, boundary) = APIService.shared.multipartBodyBuilder(
                image: image,
                imageKey: "user[profile_photo]",
                params: data
            )
            
            let response: UserContainer = try await APIService.shared.request(
                endpoint: "/profile/\(self.type ?? "creator")/",
                method: "PUT",
                body: nil,
                requireAuth: true,
                contentType: "multipart/form-data; boundary=\(boundary)",
                rawData: mulitpartBody
            )
            
            ToastManager.shared.showToast(
                message: "Profile updated",
                isSuccess: true
            )
            
            self.user = response
            
            if let encoded = try? JSONEncoder().encode(response) {
                UserDefaults.standard.set(encoded, forKey: "user")
            }
            
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
    
    func updateUser(profile: UserContainer) {
        self.user = profile
        
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "user")
        }
    }
    
    @MainActor
    func register(data: [String: String], type: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let (multipartBody, boundary) = APIService.shared.multipartBodyBuilder(
                image: nil,
                imageKey: nil,
                params: data
            )
            
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/register/\(type)/",
                method: "POST",
                body: nil,
                requireAuth: false,
                contentType: "multipart/form-data; boundary=\(boundary)",
                rawData: multipartBody
            )
            
            ToastManager.shared.showToast(
                message: "Registration complete. Please Login",
                isSuccess: true
            )
                                
            self.isLoading = false
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared.showToast(
                message: "Error: \(errorMessage ?? Constants.errorText)",
                isSuccess: false
            )
        } catch {
            self.errorMessage = Constants.errorText
            self.isLoading = false
            
            ToastManager.shared.showToast(
                message: "Error: \(Constants.errorText)",
                isSuccess: false
            )
        }
    }
    
    @MainActor
    func handleOTP(type: String, data: [String: String]) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let (multipartBody, boundary) = APIService.shared.multipartBodyBuilder(
                image: nil,
                imageKey: nil,
                params: data
            )
            
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/otp/\(type)/",
                method: "POST",
                body: nil,
                requireAuth: false,
                contentType: "multipart/form-data; boundary=\(boundary)",
                rawData: multipartBody
            )
            
            if type == "verify" {
                ToastManager.shared.showToast(
                    message: "Email verified",
                    isSuccess: true
                )
            }
            
            self.isLoading = false
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared.showToast(
                message: "Error: \(errorMessage ?? Constants.errorText)",
                isSuccess: false
            )
        } catch {
            self.errorMessage = Constants.errorText
            self.isLoading = false
            
            ToastManager.shared.showToast(
                message: "Error: \(Constants.errorText)",
                isSuccess: false
            )
        }
    }
    
    @MainActor
    func login(email: String, password: String, type: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response: LoginResponse = try await APIService.shared.request(
                endpoint: "/login/\(type)/",
                method: "POST",
                body: ["email": email, "password": password],
                requireAuth: false
            )
            
            saveSession(response: response, type: type)
            
            self.user = response.user
            self.type = type
            self.isAuth = true
            self.isLoading = false
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared.showToast(
                message: "Error: \(errorMessage ?? Constants.errorText)",
                isSuccess: false
            )
        } catch {
            self.errorMessage = Constants.errorText
            self.isLoading = false
            
            ToastManager.shared.showToast(
                message: "Error: \(Constants.errorText)",
                isSuccess: false
            )
        }
    }
    
    @MainActor
    func logout() async {
        self.isLoading = true
        self.errorMessage = nil
        
        let refresh = keychain.get("refresh") ?? ""
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/logout/",
                method: "POST",
                body: ["refresh": refresh],
                requireAuth: true
            )
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
        self.user = nil
        self.isAuth = false
        self.type = nil
        
        UserDefaults.standard.removeObject(forKey: "user")
        UserDefaults.standard.removeObject(forKey: "type")
        
        keychain.delete("access")
        keychain.delete("refresh")
    }
    
    @MainActor
    func passwordReset(email: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/password-reset/",
                method: "POST",
                body: ["email": email],
                requireAuth: false
            )
            
            ToastManager.shared.showToast(
                message: "Password reset link has been sent to your email",
                isSuccess: true
            )
            
            self.isLoading = false
        } catch APIError.serverError(let message) {
            self.errorMessage = message
            self.isLoading = false
            
            ToastManager.shared.showToast(
                message: "Error: \(errorMessage ?? Constants.errorText)",
                isSuccess: false
            )
        } catch {
            self.errorMessage = Constants.errorText
            self.isLoading = false
            
            ToastManager.shared.showToast(
                message: "Error: \(Constants.errorText)",
                isSuccess: false
            )
        }
    }
    
    @MainActor
    func deleteAccount(type: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/delete/\(type)/",
                method: "DELETE",
                body: nil,
                requireAuth: true
            )
            
            self.isLoading = false
            self.user = nil
            self.isAuth = false
            self.type = nil
            
            UserDefaults.standard.removeObject(forKey: "user")
            UserDefaults.standard.removeObject(forKey: "type")
            
            keychain.delete("access")
            keychain.delete("refresh")
        } catch {
            self.errorMessage = Constants.errorText
            self.isLoading = false
            
            ToastManager.shared.showToast(
                message: "Error: \(Constants.errorText)",
                isSuccess: false
            )
        }
    }
    
    private func saveSession(response: LoginResponse, type: String) {
        if let encoded = try? JSONEncoder().encode(response.user) {
            UserDefaults.standard.set(encoded, forKey: "user")
        }
        
        UserDefaults.standard.set(type, forKey: "type")
        keychain.set(response.access, forKey: "access")
        keychain.set(response.refresh, forKey: "refresh")
    }
}


@Observable
class ToastManager {
    static let shared = ToastManager()
    
    var message: String = ""
    var isSuccess: Bool = true
    var show: Bool = false
    
    func showToast(message: String, isSuccess: Bool) {
        self.message = message
        self.isSuccess = isSuccess
        self.show = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.show = false
        }
    }
}


@Observable
class ReportManager {
    static let shared = ReportManager()
    
    var title: String = ""
    var content: String = ""
    var show: Bool = false
    
    func showReport(title: String, content: String) {
        self.title = title
        self.content = content
        self.show = true
    }
}
