//
//  OtherInstagram.swift
//  Cloutgrid
//
//  Created by Afthash on 26/4/2026.
//

import SwiftUI

struct OtherInstagram: View {
    @Environment(IntegrationManager.self) private var integration
    
    var user: UserContainer
    
    private var otherInstagramStatic: some View {
        VStack {
            Image("Graph")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            Text(
                "@\(user.profile.username) hasn't connected their Instagram yet!"
            )
                .foregroundStyle(.secondary)
                .font(.callout)
        }
    }
    
    var body: some View {
        ScrollView {
            if user.instagramConnected ?? false {
                VStack {
                    if let instagramProfile = integration.instagramPage {
                        HStack {
                            VStack {
                                AsyncImage(
                                    url: URL(
                                        string: instagramProfile.profilePicture
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
                                
                                Link(
                                    destination: URL(
                                        string: "https://instagram.com/\(instagramProfile.username)"
                                    )!
                                ) {
                                    Text("@\(instagramProfile.username)")
                                        .customButton()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 10) {
                                Text("\(instagramProfile.followers) Followers")
                                Text("\(instagramProfile.followings) Followings")
                                Text("\(instagramProfile.mediaCount) Posts")
                            }
                            .frame(
                                maxWidth: .infinity,
                                alignment: .trailing
                            )
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                        
                        StatsRow(instagramProfile: instagramProfile)
                        
                        MediaRow(integration: integration, type: "IMAGE")
                        
                        MediaRow(integration: integration, type: "VIDEO")
                    } else if integration.isLoading {
                        VStack(spacing: 10) {
                            Image("Graph")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150)
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                            
                            LoadingView()
                        }
                    }
                }
                .task {
                    await integration
                        .readInstagramProfile(username: user.profile.username)
                    
                    await integration
                        .readInstagramMedia(username: user.profile.username)
                }
            } else {
                otherInstagramStatic
            }
        }
    }
}

#Preview {
    OtherInstagram(user: PostModel.creatorPreview)
        .environment(IntegrationManager())
}
