//
//  EditProfile.swift
//  Cloutgrid
//
//  Created by Afthash on 6/4/2026.
//

import SwiftUI
import PhotosUI

struct EditProfile: View {
    @Environment(AuthManager.self) private var auth
    @Environment(ProfileManager.self) private var profile
    
    @Binding var path: NavigationPath
    
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var category: String = ""
    @State private var website: String = ""
    @State private var profilePhoto: UIImage? = nil
    
    @State private var categorySheet: Bool = false
    @State private var changed: Bool = false
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    private func handleSave() async {
        var data: [String: String] = [:]
        
        data["user[name]"] = name
        data["user[bio]"] = bio
        
        if auth.type == "creator" {
            data["area"] = category
        } else {
            data["target_audience"] = category
            data["website"] = website
        }
        
        await auth.updateProfile(data: data, image: profilePhoto)
    }
    
    private var sheetContent: some View {
        VStack {
            NavigationStack {
                List(CategoryList.allOptions) {item in
                    Button {
                        category = item.value
                        categorySheet = false
                    } label: {
                        HStack {
                            Text(item.label)
                                .foregroundStyle(
                                    category == item.value ? Color.second : Color.primary
                                )
                                .fontWeight(
                                    category == item.value ? .bold
                                    : .regular)
                            Spacer()
                            
                            if category == item.value {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.second)
                            }
                        }
                    }
                }
                .navigationTitle("Choose your category")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    private func cropSheet(image: UIImage) -> some View {
        NavigationStack {
            ProfileCrop(image: image, croppedImage: $profilePhoto)
                .navigationTitle("Crop Photo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            selectedImage = nil
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
        }
    }
    
    var body: some View {
        ZStack {
            List {
                Section {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let chosen = profilePhoto {
                            Image(uiImage: chosen)
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .frame(width: 150)
                                .frame(maxWidth: .infinity)
                        } else {
                            AsyncImage(
                                url: URL(
                                    string: APIConfig.current.baseURL + (auth.user?.profile.profilePhoto ?? "")
                                )
                            ) {image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 150)
                            .frame(maxWidth: .infinity)
                        }
                        
                        Image(systemName: "square.and.pencil")
                            .bold()
                            .foregroundStyle(Color.black)
                            .padding(5)
                            .background(Color.white)
                            .clipShape(Circle())
                            .offset(x: 0, y: -50)
                    }
                }
                .listRowBackground(Color.clear)
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                        }
                    }
                }
                .onChange(of: profilePhoto) {
                    changed = true
                }
                
                Section {
                    VStack(spacing: 5) {
                        Text("Name:")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                        
                        TextField(
                            "Enter your name",
                            text: $name,
                        )
                        .frame(height: 45)
                            .customField()
                            .onChange(of: name) {
                                changed = true
                            }
                    }
                    
                    VStack(spacing: 5) {
                        Text("Bio:")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                        
                        TextField("Enter bio here", text: $bio, axis: .vertical)
                            .lineLimit(5...10)
                            .padding(.vertical, 5)
                            .customField()
                            .onChange(of: bio) {
                                changed = true
                            }
                    }
                    
                    VStack(spacing: 5) {
                        Text("Category:")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                        
                        Button {
                            categorySheet = true
                        } label: {
                            HStack {
                                Text(CategoryList.label(category))
                                    .foregroundStyle(Color.primary)
                                
                                Spacer()
                            }
                            .frame(height: 45)
                            .frame(maxWidth: .infinity)
                            .customField()
                        }
                        .onChange(of: category) {
                            changed = true
                        }
                    }
                    .sheet(isPresented: $categorySheet) {
                        sheetContent
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.fraction(0.7)])
                    }
                    
                    if auth.type == "business" {
                        VStack(spacing: 5) {
                            Text("Webiste:")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.subheadline)
                            
                            TextField(
                                "Enter your company website",
                                text: $website,
                            )
                            .onChange(of: website) {
                                changed = true
                            }
                            .frame(height: 45)
                                .customField()
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        Task {
                            await handleSave()
                            
                            if auth.errorMessage == nil {
                                path.removeLast()
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }.disabled(!changed)
                }
            }
            .sheet(isPresented: .init(
                get: { selectedImage != nil },
                set: { if !$0 { selectedImage = nil } }
            )) {
                if let image = selectedImage {
                    cropSheet(image: image)
                } else {
                    Text("No image selected")
                }
            }
            .onAppear() {
                name = auth.user?.profile.name ?? ""
                bio = auth.user?.profile.bio ?? ""
                category = auth.user?.area ?? auth.user?.targetAudience ?? ""
                website = auth.user?.website ?? ""
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfile(path: .constant(NavigationPath()))
            .environment(AuthManager())
            .environment(ProfileManager())
    }
}

