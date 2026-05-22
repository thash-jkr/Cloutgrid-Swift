//
//  PostCreate.swift
//  Cloutgrid
//
//  Created by Afthash on 5/4/2026.
//

import SwiftUI
import PhotosUI

struct PostCreate: View {
    @Environment(SearchManager.self) private var search
    
    var image: UIImage
    @Binding var path: NavigationPath
    @Binding var selectedTab: TabIdentifier
    
    @State private var caption: String = ""
    @State private var query: String = ""
    @State private var collab: UserContainer? = nil
    
    @State private var collabSheet: Bool = false
    
    private func handleDismiss() {
        query = ""
        search.collabs = []
    }
    
    private var collabContent: some View {
        NavigationStack {
            VStack {
                if search.collabs.count > 0 {
                    AnyView(
                        List {
                            ForEach(search.collabs, id: \.profile.id) { user in
                                Button {
                                    collab = user
                                    query = ""
                                    search.collabs = []
                                    collabSheet = false
                                } label: {
                                    HStack {
                                        AsyncImage(
                                            url: URL(
                                                string: APIConfig.current.baseURL + user.profile.profilePhoto
                                            )
                                        ) {image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(Circle())
                                        } placeholder: {
                                            ProgressView()
                                        }.frame(width: 50)
                                        
                                        VStack(alignment: .leading) {
                                            Text(user.profile.name)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(Color.dualBlack)
                                            
                                            Text(CategoryList.label(user.targetAudience ?? ""))
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    )
                } else {
                    if query.isEmpty {
                        AnyView(
                            Empty(type: "general", message: "Start typing...")
                        )
                    } else {
                        AnyView(
                            search.isLoading ? Empty(
                                type: "general",
                                message: "Loading..."
                            ) : Empty(type: "general", message: "Nothing to see here!")
                        )
                    }
                }
            }
            .navigationTitle("Select Collaboration")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search for Businesses")
            .onChange(of: query) { _, newValue in
                Task {
                    if newValue != "" {
                        await search.handleSearchBusiness(query: query)
                    }
                }
            }
        }
        
    }
    
    var body: some View {
        ScrollView {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            
            if search.isLoading {
                LoadingView()
            }
            
            VStack(spacing: 20) {
                VStack(spacing: 5) {
                    Text("Caption:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                    
                    TextField("Enter a caption for your post", text: $caption, axis: .vertical)
                        .lineLimit(5...10)
                        .padding(.vertical, 5)
                        .customField()
                }
                
                
                
                VStack(alignment: .leading, spacing: 5, ) {
                    Text("Collaboration:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                    
                    if collab != nil {
                        AnyView(
                            HStack {
                                Text(collab?.profile.name ?? "")
                                
                                Spacer()
                                
                                Button {
                                    collab = nil
                                } label: {
                                    Image(systemName: "xmark.circle")
                                        .font(.title3)
                                        .foregroundStyle(Color.red)
                                }
                            }
                            .frame(height: 45)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 10)
                            .background(Color.textfield)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .font(.system(size: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Color.primary,
                                        lineWidth: 1
                                    )
                            )
                        )
                    } else {
                        Button {
                            collabSheet = true
                        } label: {
                            Text("Add collab").customButton()
                        }
                        .sheet(
                            isPresented: $collabSheet,
                            onDismiss: handleDismiss
                        ) {
                            collabContent
                                .presentationDetents([.fraction(0.5), .fraction(0.75)])
                                .presentationDragIndicator(.visible)
                                
                        }
                    }
                        
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
        .ignoresSafeArea()
        .navigationTitle("Add caption")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    Task {
                        await search
                            .handlePostImage(
                                image: image,
                                caption: caption,
                                collab: collab?.profile.username ?? "null"
                            )
                        
                        if search.errorMessage == nil {
                            selectedTab = .home
                            path.removeLast(path.count)
                        }
                    }
                } label: {
                    Image(systemName: "plus.app")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PostCreate(
            image: UIImage(named: "testImage1")!,
            path: .constant(NavigationPath()),
            selectedTab: .constant(.post)
        )
    }
    .environment(SearchManager())
}
