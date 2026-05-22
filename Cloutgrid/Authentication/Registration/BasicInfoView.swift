//
//  BasicInfoView.swift
//  Cloutgrid
//
//  Created by Afthash on 15/3/2026.
//

import SwiftUI

struct BasicInfoView: View {
    @Environment(AuthManager.self) private var auth
    
    let type: String
    @Binding var path: NavigationPath
    @Binding var data: [String:String]
    
    @State var name = ""
    @State var username = ""
    @State var email = ""
    @State var otp = ""
    
    @State private var usernameSheet = false
    @State private var emailSheet = false
    @State private var showOTP = false
    @State private var emailVerified = false
    
    private var formChecker: Bool {
        return (
            name != "" &&
            username != "" &&
            email != ""
        )
    }
    
    private var section1: some View {
        VStack(spacing: 20) {
            VStack(spacing: 5) {
                HStack {
                    Text("Name:").font(.subheadline)
                }.frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                
                TextField("Enter your full name", text: $name)
                    .frame(height: 45)
                    .customField()
            }
            
            VStack(spacing: 5) {
                HStack(spacing: 3) {
                    Text("Username:").font(.subheadline)
                    
                    Button {
                        usernameSheet = true
                    } label: {
                        Image(systemName: "info.circle").font(.subheadline)
                    }
                    .foregroundStyle(Color.black)
                    .sheet(isPresented: $usernameSheet) {
                        InfoDetails(description: "Your username is your unique identifier on Cloutgrid. Choose wisely, it cannot be changed later.")
                    }
                    .buttonStyle(.borderless)
                }.frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                
                TextField("Enter a username", text: $username)
                    .frame(height: 45)
                    .customField(disabled: showOTP)
                    .disabled(showOTP)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            
            VStack(spacing: 5) {
                HStack(spacing: 3) {
                    Text("Email:").font(.subheadline)
                    
                    Button {
                        emailSheet = true
                    } label: {
                        Image(systemName: "info.circle").font(.subheadline)
                    }
                    .foregroundStyle(Color.black)
                    .sheet(isPresented: $emailSheet) {
                        InfoDetails(description: "This email will be used to verify your account and help you log in securely. Make sure to enter an email you actively use")
                    }
                    .buttonStyle(.borderless)
                }.frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                
                TextField("Enter your email address", text: $email)
                    .frame(height: 45)
                    .customField(disabled: showOTP)
                    .disabled(showOTP)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
        }
    }
    
    var body: some View {
        List {
            Section {
                section1
            } footer: {
                if !showOTP || emailVerified {
                    Button {
                        if emailVerified {
                            path.append(AuthDestination.moreInfo(type: type))
                        } else {
                            Task {
                                var otpData: [String: String] = [:]
                                otpData["name"] = name
                                otpData["username"] = username
                                otpData["email"] = email
                                
                                await auth.handleOTP(type: "send", data: otpData)
                                
                                if auth.errorMessage == nil {
                                    showOTP = true
                                }
                            }
                        }
                    } label: {
                        if auth.isLoading {
                            LoadingView()
                        } else {
                            Text("Continue").customButton(disabled: !formChecker)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    .disabled(!formChecker)
                }
            }
            
            if showOTP && !emailVerified {
                Section {
                    VStack(spacing: 5) {
                        HStack {
                            Text("OTP:").font(.subheadline)
                        }.frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        
                        TextField(
                            "Enter the OTP sent to your email",
                            text: $otp
                        )
                            .frame(height: 45)
                            .customField()
                            .keyboardType(.numberPad)
                    }
                } header: {
                    Text("Enter the otp sent to your mail")
                } footer: {
                    Button {
                        Task {
                            var otpData: [String: String] = [:]
                            
                            otpData["username"] = username
                            otpData["otp"] = otp
                            
                            await auth.handleOTP(type: "verify", data: otpData)
                            
                            if auth.errorMessage == nil {
                                data["user.name"] = name
                                data["user.username"] = username
                                data["user.email"] = email
                                
                                emailVerified = true
                                
                                path.append(AuthDestination.moreInfo(type: type))
                            }
                        }
                    } label: {
                        if auth.isLoading {
                            LoadingView()
                        } else {
                            Text("Continue").customButton(disabled: otp == "")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    .disabled(otp == "")
                }
            }
        }
    }
}

#Preview {
    BasicInfoView(type: "creator", path: .constant(NavigationPath()), data: .constant([
        "user[name]": "Afthash",
        "user[username]": "thash_dev",
        "area": "Developer"
    ]))
    .environment(AuthManager())
}
