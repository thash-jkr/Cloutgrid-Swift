//
//  ProfileHeader.swift
//  Cloutgrid
//
//  Created by Afthash on 4/4/2026.
//

import SwiftUI

struct ProfileHeader: View {
    var user: UserContainer
    
    private func statVStack(value: String, label: String) -> some View {
        HStack(spacing: 5) {
            Text(value)
                .font(.footnote)
                .fontWeight(.semibold)
            Text(label)
                .font(.footnote)
                .foregroundStyle(Color.secondary)
        }
    }
    
    private var statsRow: some View {
        HStack {
            Spacer()
            statVStack(
                value: "\(user.profile.followersCount)",
                label: "Followers"
            )
            Spacer()
            statVStack(
                value: "\(user.profile.followingCount)",
                label: "Following"
            )
            Spacer()
        }
    }
    
    private var profileHeader: some View {
        HStack(spacing: 25) {
            AsyncImage(
                url: URL(
                    string: APIConfig.current.baseURL + user.profile.profilePhoto
                )
            ) { image in
                image.resizable()
                    .scaledToFill()
                    .frame(width: 75, height: 75)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView().frame(width: 75, height: 75)
            }
            
            Spacer()
            
            statsRow
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
    
    private var bioSection: some View {
        VStack(alignment: .leading) {
            Text(user.profile.name).font(.system(size: 15, weight: .bold))
            Text(user.profile.bio ?? "").font(.system(size: 14))
            Text(CategoryList.label(user.area ?? user.targetAudience ?? ""))
                .font(.caption2)
                .bold()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.second)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    private var profileLeft: some View {
        VStack(alignment: .leading) {
            AsyncImage(
                url: URL(
                    string: APIConfig.current.baseURL + user.profile.profilePhoto
                )
            ) { image in
                image.resizable()
                    .scaledToFill()
                    .frame(width: 75, height: 75)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView().frame(width: 75, height: 75)
            }
            .padding(.bottom, 20)
            Text(user.profile.name).font(.system(size: 15, weight: .bold))
            Text(user.profile.bio ?? "").font(.system(size: 14))
            
            HStack(spacing: 10) {
                Text(CategoryList.label(user.area ?? user.targetAudience ?? ""))
                    .font(.caption2)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.second, in: Capsule())
                    .foregroundColor(.white)
                
                if let website = user.website, website != "" {
                    HStack(spacing: 3) {
                        Image(systemName: "globe")
                        
                        Text(website)
                    }
                    .font(.caption2)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.first, in: Capsule())
                    .foregroundColor(.white)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    private var profileRight: some View {
        HStack(spacing: 5) {
            statVStack(
                value: "\(user.profile.followersCount)",
                label: "Followers"
            )
            
            Text("•")
            
            statVStack(
                value: "\(user.profile.followingCount)",
                label: "Following"
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    var body: some View {
        VStack {
            profileLeft
            
            profileRight
        }
    }
}

#Preview {
    ProfileHeader(user: PostModel.businessPreview)
}
