//
//  APIService.swift
//  Cloutgrid
//
//  Created by Afthash on 18/3/2026.
//

import Foundation
import KeychainSwift
import SwiftUI

enum APIError: Error {
    case invalidURL
    case serverError(String)
    case decodingError(String)
}

struct APIService {
    static let shared = APIService()
    let baseURL = APIConfig.current.baseURL
    let keychain = KeychainSwift()
    
    func request<T: Codable>(
        endpoint: String,
        method: String,
        body: [String: Any]?,
        requireAuth: Bool,
        fullURL: Bool = false,
        contentType: String = "application/json",
        rawData: Data? = nil
    ) async throws -> T {
        var isRefreshing = false
        let urlString = fullURL ? endpoint : "\(baseURL)\(endpoint)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        if requireAuth, let token = keychain.get("access") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if rawData != nil {
            request.httpBody = rawData
        } else {
            if let body = body {
                request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            }
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
//            print("No response from server")
            throw APIError.serverError(Constants.errorText)
        }
        
        if httpResponse.statusCode == 204 {
            if let empty = EmptyResponse() as? T {
                return empty
            }
        }

        if !(200...299).contains(httpResponse.statusCode) {
            if httpResponse.statusCode == 401 && requireAuth && !isRefreshing {
                isRefreshing = true
                
                guard let refreshToken = keychain.get("refresh") else {
                    throw APIError.serverError("Session expired")
                }
                
                guard let refereshURL = URL(string: "\(baseURL)/token/refresh/") else {
                    throw APIError.invalidURL
                }
                
                var refreshRequest = URLRequest(url: refereshURL)
                refreshRequest.httpMethod = "POST"
                refreshRequest
                    .setValue(
                        "application/json",
                        forHTTPHeaderField: "Content-Type"
                    )
                refreshRequest.httpBody = try? JSONSerialization
                    .data(withJSONObject: ["refresh": refreshToken])
                
//                let (refreshData, refreshResponse) = try await URLSession.shared.data(
//                    for: refreshRequest
//                )
//                
//                guard let httpRefreshResponse = refreshResponse as? HTTPURLResponse else {
//                    print("Failed to refresh tokens")
//                    throw APIError.serverError(Constants.errorText)
//                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    print("Session expired. Logging out")
                } else {
                    print("New tokens received")
                }
                
                // what next?
                
            } else {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let serverMessage = json["message"] as? String {
                    print(data)
                    throw APIError.serverError(serverMessage)
                } else {
                    print("DEBUG: Server Error \(httpResponse.statusCode) - Could not find 'message' key.")
                    throw APIError.serverError(Constants.errorText)
                }
            }
        }
        
//        if let httpResponse = response as? HTTPURLResponse {
//            print("HTTP Status: \(httpResponse.statusCode)")
//        }
//
//        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
//           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
//           let prettyString = String(data: prettyData, encoding: .utf8) {
//            print("API Response Body (JSON):\n\(prettyString)")
//        } else if let text = String(data: data, encoding: .utf8) {
//            print("API Response Body (text):\n\(text)")
//        }

        do {
            if data.isEmpty && T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            return try decoder.decode(T.self, from: data)
        } catch {
            print("DEBUG: The decode error is: \(error)")
            throw APIError.decodingError(Constants.errorText)
        }
    }
    
    func multipartBodyBuilder(image: UIImage?, imageKey: String?, params: [String: String]) -> (
        data: Data,
        boundary: String
    ) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        let lineBreak = "\r\n"

        for (key, value) in params {
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak)\(lineBreak)")
            body.append("\(value)\(lineBreak)")
        }

        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\(imageKey!); filename=\"post.jpg\"\(lineBreak)")
            body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)")
            body.append(imageData)
            body.append(lineBreak)
        }

        body.append("--\(boundary)--\(lineBreak)")

        return (body, boundary)
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
