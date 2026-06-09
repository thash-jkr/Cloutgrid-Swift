//
//  IntegrationModels.swift
//  Cloutgrid
//
//  Created by Afthash on 6/6/2026.
//

import Foundation

struct InstagramPageModel: Codable, Identifiable {
    let id: Int
    let igUserId: String
    let username: String
    let profilePicture: String
    let followers: Int
    let followings: Int
    let mediaCount: Int
    let insights: [ProfileInsightModel]
    
    enum CodingKeys: String, CodingKey {
        case id
        case igUserId = "ig_user_id"
        case username
        case profilePicture = "profile_picture_url"
        case followers
        case followings
        case mediaCount = "media_count"
        case insights = "insights_raw"
    }
}

struct InsightValue: Codable {
    let value: Int
}

struct ProfileInsightModel: Codable, Identifiable {
    let id: String
    let name: String
    let title: String
    let period: String
    let description: String
    let totalValue: InsightValue
    
    enum CodingKeys: String, CodingKey {
        case id, name, title, period, description
        
        case totalValue = "total_value"
    }
}

struct InstagramMediaModel: Codable, Identifiable {
    let id: Int
    let owner: Int
    let mediaId: String
    let mediaType: String
    let mediaUrl: String
    let thumbnailUrl: String
    let link: String
    let caption: String
    let likeCount: Int
    let commentsCount: Int
    let insights: [MediaInsightModel]
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case mediaId = "media_id"
        case mediaType = "media_type"
        case mediaUrl = "media_url"
        case thumbnailUrl = "thumbnail_url"
        case link
        case caption
        case likeCount = "like_count"
        case commentsCount = "comments_count"
        case insights = "insights_raw"
    }
}

struct MediaInsightModel: Codable, Identifiable {
    let id: String
    let name: String
    let title: String
    let period: String
    let description: String
    let values: [InsightValue]
}

struct InstagramResponseModel: Codable {
    let fb_page: String
    let ig_page: String
}

struct InstagramPageResponse: Codable {
    let profileData: InstagramPageModel
    
    enum CodingKeys: String, CodingKey {
        case profileData = "profile_data"
    }
}

struct InstagramMediaResponse: Codable {
    let media: [InstagramMediaModel]
}
