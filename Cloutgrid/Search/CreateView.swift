//
//  CreateView.swift
//  Cloutgrid
//
//  Created by Afthash on 25/3/2026.
//

import SwiftUI
import PhotosUI

enum ImageAction: Identifiable, Hashable {
    case raw(UIImage)
    case cropped(UIImage)
    case profile(UIImage)
    
    var id: String {
        switch self {
        case .raw: return "1"
        case .cropped: return "2"
        case .profile: return "3"
        }
    }
}

struct CreateView: View {
    @Environment(AuthManager.self) private var auth
    
    @Binding var selectedTab: TabIdentifier
    @Binding var createPath: NavigationPath
    
    @State private var imageAction: ImageAction? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        List {
            Section {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Post")
                                .font(.headline)
                                .bold()
                                .foregroundStyle(Color.primary)

                            Text("Upload an image from a previous brand collaboration or campaign you've been part of")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Image("megaphone")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        
                        createPath.append(ImageAction.raw(uiImage))
                    }
                }
            }
            
            if auth.type == "business" {
                Section {
                    HStack(spacing: 20) {
                        Image("handshake")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Collaboration")
                                .font(.headline)
                                .bold()
                            
                            Text("Post a collaboration opportunity to connect with creators who match your brand")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .onTapGesture {
                    createPath.append("collab")
                }
            }
        }
    }
}

#Preview {
    CreateView(
        selectedTab: .constant(.post),
        createPath: .constant(NavigationPath())
    )
        .environment(AuthManager())
        .environment(SearchManager())
        .environment(JobManager())
}

