//
//  ForgotPassword.swift
//  Cloutgrid
//
//  Created by Afthash on 10/4/2026.
//

import SwiftUI

struct ForgotPassword: View {
    @Environment(AuthManager.self) private var auth
    
    @Binding var path: NavigationPath
    
    @State private var email: String = ""
    
    var body: some View {
        List {
            Section {
                TextField("Enter your email here", text: $email)
                    .frame(height: 45)
                    .customField()
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            } header: {
                Text("Enter the email address you use to register with us. If you have an account with us, you will recieve a mail with a link to reset your password")
            } footer: {
                Button {
                    Task {
                        await auth.passwordReset(email: email)
                        
                        if auth.errorMessage == nil {
                            path.removeLast()
                        }
                    }
                } label: {
                    Text("Submit").customButton()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .navigationTitle("Password Reset")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ForgotPassword(path: .constant(NavigationPath()))
            .environment(AuthManager())
    }
}
