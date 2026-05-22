//
//  HomeModels.swift
//  Cloutgrid
//
//  Created by Afthash on 22/3/2026.
//

import Foundation

struct NotificationModel: Codable {
    let id: Int
    let message: String
    let isRead: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case message
        
        case isRead = "is_read"
    }
}

struct PostModel: Codable, Identifiable, Hashable {
    let id: Int
    let author: UserProfile
    let postedBy: UserContainer
    let collaboration: UserContainer?
    var likeCount: Int
    var commentCount: Int
    var isLiked: Bool
    let image: String
    let caption: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case collaboration
        case image
        case caption
        
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case isLiked = "is_liked"
        case postedBy = "posted_by"
    }
    
    static var creatorProfilePreview = UserProfile(
        id: 2352345,
        name: "Ava Martinez",
        username: "creator1",
        email: "ava.martinez@example.com",
        bio: "iOS engineer & educator. I share tips, code walkthroughs, and behind‑the‑scenes of building indie apps. Weekly SwiftUI threads, occasional memes. 🎯 Collabs: ava@martinez.dev | 🌐 martinez.dev",
        userType: "creator",
        profilePhoto: "/media/profile_pics/image.jpg",
        followersCount: 28400,
        followingCount: 512
    )
    
    static var businessProfilePreview = UserProfile(
        id: 234234,
        name: "Brand Co.",
        username: "brandco",
        email: "contact@brandco.com",
        bio: "We build tools that help creators grow their audience and monetize sustainably. From analytics to automation, our platform empowers teams to create, collaborate, and scale with confidence. Trusted by thousands of creators and brands worldwide. Partnerships open — let’s grow together. 📈✨",
        userType: "business",
        profilePhoto: "https://picsum.photos/400/300",
        followersCount: 58200,
        followingCount: 145
    )
    
    static var creatorPreview = UserContainer(
        profile: creatorProfilePreview,
        area: "education",
        instagramConnected: false,
        youtubeConnected: false,
        targetAudience: nil,
        website: nil,
        isFollowing: true,
        isBlocking: true,
        isBlocker: false
    )
    
    static var businessPreview = UserContainer(
        profile: businessProfilePreview,
        area: nil,
        instagramConnected: nil,
        youtubeConnected: nil,
        targetAudience: "business",
        website: "brandco.com",
        isFollowing: false,
        isBlocking: false,
        isBlocker: false
    )
    
    static var postPreview1 = PostModel(
        id: 1,
        author: businessProfilePreview,
        postedBy: businessPreview,
        collaboration: nil,
        likeCount: 342,
        commentCount: 27,
        isLiked: true,
        image: "https://picsum.photos/400/300",
        caption: "Sunset shoot behind the scenes 🌅📸 #bts #creatorlife"
    )
    
    static var postPreview2 = PostModel(
        id: 2,
        author: creatorProfilePreview,
        postedBy: creatorPreview,
        collaboration: businessPreview,
        likeCount: 1280,
        commentCount: 64,
        isLiked: true,
        image: "https://picsum.photos/400/300",
        caption: "Collab announcement! Partnering with @avamakesapps on an analytics deep dive. 🚀📊"
    )
}

struct CommentModel: Codable, Identifiable {
    let id: Int
    let user: UserProfile
    let content: String
    let commentedAt: String
    
    var timeAgo: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: commentedAt) else {
            return "Just now"
        }
        
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .abbreviated
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
    
    enum CodingKeys: String, CodingKey {
        case id, user, content
        
        case commentedAt = "commented_at"
    }
}

struct LikeResponse: Codable {
    let liked: Bool
    let likeCount: Int
    
    enum CodingKeys: String, CodingKey {
        case liked
        case likeCount = "like_count"
    }
}

struct PostResponse: Codable {
    let results: [PostModel]
    let next: String?
}

