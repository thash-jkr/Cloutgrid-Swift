//
//  LoginCard.swift
//  Cloutgrid
//
//  Created by Afthash on 9/4/2026.
//

import SwiftUI

struct LoginCard: View {
    @Environment(AuthManager.self) private var auth
    
    var type: String
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 15) {
            if type == "creator" {
                Text("Creator Login").heading1()
            } else {
                Text("Business Login").heading1()
            }
            
            VStack {
                TextField("Email", text: $email)
                    .frame(height: 45)
                    .customField()
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                
                SecureField("Password", text: $password)
                    .frame(height: 45)
                    .customField()
            }.padding(10)
            
            Button {
                Task {
                    await auth
                        .login(
                            email: email,
                            password: password,
                            type: type
                        )
                }
            } label: {
                if auth.isLoading {
                    LoadingView()
                } else {
                    Text("Login").customButton(disabled: email.isEmpty || password.isEmpty || auth.isLoading)
                }
            }
            .disabled(
                email.isEmpty || password.isEmpty || auth.isLoading
            )
            .opacity(auth.isLoading ? 0.5 : 1.0)
        }
        .padding(.vertical, 40)
        .homeCard()
        .padding(30)
    }
}

#Preview {
    LoginCard(type: "creator")
        .environment(AuthManager())
}
