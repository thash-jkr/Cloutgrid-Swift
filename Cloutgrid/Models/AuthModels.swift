//
//  Models.swift
//  Cloutgrid
//
//  Created by Afthash on 17/3/2026.
//

import Foundation

struct UserContainer: Codable, Hashable {
    var profile: UserProfile
    
    let area: String?
    let instagramConnected: Bool?
    let youtubeConnected: Bool?
    
    let targetAudience: String?
    let website: String?

    var isFollowing: Bool?
    var isBlocking: Bool?
    var isBlocker: Bool?
    
    enum CodingKeys: String, CodingKey {
        case area, website
        
        case targetAudience = "target_audience"
        case profile = "user"
        case instagramConnected = "instagram_connected"
        case youtubeConnected = "youtube_connected"
        case isFollowing = "is_following"
        case isBlocking = "is_blocking"
        case isBlocker = "is_blocker"
    }
}

struct UserProfile: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let bio: String?
    let userType: String
    let profilePhoto: String
    var followersCount: Int
    var followingCount: Int

    enum CodingKeys: String, CodingKey {
        case id, name, username, email, bio
        
        case userType = "user_type"
        case profilePhoto = "profile_photo"
        case followersCount = "followers_count"
        case followingCount = "following_count"
    }
}

struct LoginResponse: Codable {
    let user: UserContainer
    let access: String
    let refresh: String
}

struct EmptyResponse: Codable {
    init() {}
}
