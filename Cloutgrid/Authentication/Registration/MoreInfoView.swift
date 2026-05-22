//
//  MoreInfoView.swift
//  Cloutgrid
//
//  Created by Afthash on 16/3/2026.
//

import SwiftUI

struct MoreInfoView: View {
    @Environment(AuthManager.self) private var auth
    
    var type: String
    @Binding var path: NavigationPath
    @Binding var data: [String: String]
    
    @State var password = ""
    @State var confirmPassword = ""
    @State var category = ""
    
    @State private var passwordSheet = false
    @State private var categorySheet = false
    @State private var categoryListSheet = false
    @State private var privacySheet = false
    @State private var eulaSheet = false
    
    private var formChecker: Bool {
        return (
            password != "" &&
            confirmPassword != "" &&
            password == confirmPassword &&
            category != ""
        )
    }
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 20) {
                    VStack(spacing: 5) {
                        HStack(spacing: 3) {
                            Text("Password:").font(.subheadline)
                            
                            Button {
                                passwordSheet = true
                            } label: {
                                Image(systemName: "info.circle").font(.subheadline)
                            }
                            .foregroundStyle(Color.black)
                            .sheet(isPresented: $passwordSheet) {
                                InfoDetails(description: "Choose a strong password to keep your account secure. Use at least 8 characters with a mix of letters, numbers, or symbols")
                            }
                            .buttonStyle(.borderless)
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        
                        SecureField(
                            "Choose a strong password",
                            text: $password
                        )
                        .frame(height: 45)
                        .customField()
                    }
                    
                    VStack(spacing: 5) {
                        HStack(spacing: 3) {
                            Text("Confirm Password:").font(.subheadline)
                        }.frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        
                        SecureField(
                            "Enter the password again",
                            text: $confirmPassword
                        )
                        .frame(height: 45)
                        .customField()
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 3) {
                            Text("Category:").font(.subheadline)
                            
                            Button {
                                categorySheet = true
                            } label: {
                                Image(systemName: "info.circle").font(.subheadline)
                            }
                            .foregroundStyle(Color.black)
                            .sheet(isPresented: $categorySheet) {
                                InfoDetails(description: type == "creator" ? "Select the category that best represents your content or expertise. This helps businesses discover you based on relevant campaigns and collaborations" : "Pick the category that best describes your business or brand. This helps you reach the right creators and audience when posting job collaborations")
                            }
                            .buttonStyle(.borderless)
                        }.frame(
                            alignment: .leading
                        )
                        
                        Button {
                            categoryListSheet = true
                        } label: {
                            HStack {
                                Text(
                                    category != "" ? CategoryList
                                        .label(category) : "Choose your category"
                                )
                                .foregroundStyle(Color.primary)
                                
                                Spacer()
                                
                                Image(systemName: category == "" ? "arrow.down.app.fill" : "checkmark.square.fill")
                                    .font(.title2)
                                    .foregroundStyle(
                                        category == "" ? Color.secondary : Color.second
                                    )
                            }
                            .frame(height: 45)
                            .frame(maxWidth: .infinity)
                            .customField()
                        }
                        .frame(alignment: .leading)
                        .buttonStyle(.borderless)
                    }
                    .sheet(isPresented: $categoryListSheet) {
                        VStack {
                            List(CategoryList.allOptions) {item in
                                Button {
                                    category = item.value
                                    categoryListSheet = false
                                } label: {
                                    HStack {
                                        Text(item.label)
                                            .foregroundStyle(category == item.value ? Color.second : Color.primary)
                                            .fontWeight(
                                                category == item.value ? .bold : .regular
                                            )
                                        
                                        Spacer()
                                        
                                        if category == item.value {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(Color.second)
                                                .bold()
                                        }
                                    }
                                }
                            }
                        }
                        .presentationDragIndicator(.visible)
                    }
                    .buttonStyle(.borderless)
                }
            } footer: {
                Button {
                    data["user.password"] = password
                    if type == "creator" {
                        data["area"] = category
                    } else {
                        data["target_audience"] = category
                    }
                    
                    Task {
                        await auth.register(data: data, type: type)
                        
                        if auth.errorMessage == nil {
                            path.removeLast(path.count)
                            path.append(AuthDestination.login)
                        }
                    }
                } label: {
                    Text("Submit").customButton(disabled: !formChecker)
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
                .disabled(!formChecker)
            }
        }
    }
}

#Preview {
    MoreInfoView(type: "creator", path: .constant(NavigationPath()), data: .constant([
        "user[name]": "Afthash",
        "user[username]": "thash_dev",
        "area": "Developer"
    ]))
    .environment(AuthManager())
}
