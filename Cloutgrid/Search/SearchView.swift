//
//  SearchView.swift
//  Cloutgrid
//
//  Created by Afthash on 25/3/2026.
//

import SwiftUI

struct SearchView: View {
    @Environment(SearchManager.self) private var search
    @Environment(AuthManager.self) private var auth
    
    @Binding var selectedTab: TabIdentifier
    @Binding var searchPath: NavigationPath
    
    @State private var query: String = ""
    
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    private func gridImage(imageURL: String) -> some View {
        AsyncImage(
            url: URL(string: APIConfig.current.baseURL + imageURL)
        ) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .clipped()
        } placeholder: {
            Color.gray.opacity(0.1)
                .aspectRatio(1, contentMode: .fill)
        }
    }
    
    private func userList(arr: [UserContainer]) -> some View {
        if arr.count > 0 {
            AnyView(
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(arr, id: \.profile.id) { user in
                        Button {
                            if user.profile.username == auth.user?.profile.username {
                                selectedTab = .profile
                            } else {
                                searchPath.append(user)
                            }
                        } label: {
                            VStack(spacing: 10) {
                                gridImage(imageURL: user.profile.profilePhoto)
                                
                                Text(user.profile.name)
                                    .font(.headline)
                                    .lineLimit(1)
                                    .foregroundStyle(Color.dualBlack)

                                Text(CategoryList.label(user.area ?? user.targetAudience ?? ""))
                                    .font(.caption2)
                                    .bold()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.second)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                    .padding(.bottom, 15)
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.dualBlack.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                }
                .padding(.horizontal, 15)
            )
        } else {
            AnyView(
                Empty(type: "general", message: "No results found for \(query)")
            )
        }
    }
    
    var body: some View {
        ScrollView {
            SearchBar(text: $query, placeholder: "Search")
            
            userList(
                arr: query.isEmpty ? search.suggetions : search.results
            )
        }
        .refreshable {
            await search.fetchSuggetions()
        }
        .onChange(of: query) { _, newValue in
            Task {
                if newValue != "" {
                    await search.handleSearch(query: query)
                }
            }
        }
        .task {
            await search.fetchSuggetions()
        }
    }
}

#Preview {
    SearchView(selectedTab: .constant(.search), searchPath: .constant(NavigationPath()))
        .environment(SearchManager())
        .environment(ProfileManager())
        .environment(AuthManager())
}
