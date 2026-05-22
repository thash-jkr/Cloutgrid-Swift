//
//  LoginView.swift
//  Cloutgrid
//
//  Created by Afthash on 15/3/2026.
//

import SwiftUI

struct LoginView: View {
    @Binding var path: NavigationPath
    
    @Environment(AuthManager.self) private var auth
    
    @State private var isCreator: Bool = true
    @State private var email = ""
    @State private var password = ""
    
    private var footer: some View {
        VStack(spacing: 10) {
            Button {
                path.removeLast()
            } label: {
                Text("Don't have an account? Register")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
            }
            
            Button {
                isCreator.toggle()
            } label: {
                Text(
                    "Not a \(isCreator ? "creator? Business" : "business? Creator") Login"
                )
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primary)
            }
            
            Button {
                path.append(AuthDestination.reset)
            } label: {
                Text("Forgot password?")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
            }
        }
    }
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 5) {
                    HStack {
                        Text("Email:").font(.subheadline)
                    }.frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    
                    TextField("Enter your email address", text: $email)
                        .frame(height: 45)
                        .customField()
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                
                VStack(spacing: 5) {
                    HStack {
                        Text("Password:").font(.subheadline)
                    }.frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    
                    SecureField("Password", text: $password)
                        .frame(height: 45)
                        .customField()
                }
            } footer: {
                VStack {
                    Button {
                        Task {
                            await auth
                                .login(
                                    email: email,
                                    password: password,
                                    type: isCreator ? "creator" : "business"
                                )
                        }
                    } label: {
                        if auth.isLoading {
                            LoadingView()
                        } else {
                            Text("Login").customButton(disabled: email.isEmpty || password.isEmpty || auth.isLoading)
                        }
                    }
                    .padding(.vertical)
                    .disabled(
                        email.isEmpty || password.isEmpty || auth.isLoading
                    )
                    .opacity(auth.isLoading ? 0.5 : 1.0)
                    
                    footer
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("\(isCreator ? "Creator" : "Business") Login")
        .navigationBarTitleDisplayMode(.inline)
//        VStack(spacing: 5) {
//            ZStack {
//                LoginCard(type: "creator")
//                    .rotation3DEffect(.degrees(isCreator ? 0 : -90), axis: (x: 0, y: 1, z: 0))
//                    .opacity(isCreator ? 1 : 0)
//                    .allowsHitTesting(isCreator)
//                    .animation(isCreator ? .linear.delay(0.35) : .linear, value: isCreator)
//                
//                LoginCard(type: "business")
//                    .rotation3DEffect(.degrees(isCreator ? 90 : 0), axis: (x: 0, y: 1, z: 0))
//                    .opacity(isCreator ? 0 : 1)
//                    .allowsHitTesting(!isCreator)
//                    .animation(isCreator ? .linear : .linear.delay(0.35), value: isCreator)
//            }
//            
//            footer
//        }
    }
}

#Preview {
    NavigationStack {
        LoginView(path: .constant(NavigationPath()))
            .environment(AuthManager())
    }
}
