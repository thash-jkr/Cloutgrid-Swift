//
//  LandingView.swift
//  Cloutgrid
//
//  Created by Afthash on 15/3/2026.
//

import SwiftUI

enum AuthDestination: Hashable {
    case login
    case reset
    case basicInfo(type: String)
    case moreInfo(type: String)
}

struct LandingView: View {
    @State var authPath = NavigationPath()
    
    @State var data: [String: String] = [:]
    
    var body: some View {
        NavigationStack(path: $authPath) {
            VStack() {
                HStack {
                    Text("Join").heading1()
                    
                    HStack(spacing: 0) {
                        Text("Clout").foregroundStyle(Color.first).heading1()
                        Text("grid").foregroundStyle(Color.second).heading1()
                    }
                }
                
                Button {
                    authPath.append(AuthDestination.basicInfo(type: "creator"))
                } label: {
                    VStack {
                        Text(Constants.creatorText)
                            .heading2()
                            .foregroundStyle(Color.dualBlack)
                        Image(systemName: "arrow.right")
                            .bold()
                            .foregroundColor(.black)
                            .padding(.top, 10)
                    }.homeCard()
                }
                .padding(.bottom, 10)
                
                Button {
                    authPath.append(AuthDestination.basicInfo(type: "business"))
                } label: {
                    VStack {
                        Text(Constants.businessText)
                            .heading2()
                            .foregroundStyle(Color.dualBlack)
                        Image(systemName: "arrow.right")
                            .bold()
                            .foregroundColor(.black)
                            .padding(.top, 10)
                    }.homeCard()
                }
                .padding(.bottom, 10)
                
                Button {
                    authPath.append(AuthDestination.login)
                } label: {
                    Text("Already have an account? Login")
                        .font(.footnote)
                        .foregroundStyle(Color.dualBlack)
                }
                .padding(.top, 10)
            }
            .navigationDestination(for: AuthDestination.self) { value in
                switch value {
                case .login:
                    LoginView(path: $authPath)
                case .reset:
                    ForgotPassword(path: $authPath)
                case .basicInfo(let type):
                    BasicInfoView(type: type, path: $authPath, data: $data)
                        .navigationTitle("\(type.capitalized) Registration")
                case .moreInfo(let type):
                    MoreInfoView(type: type, path: $authPath, data: $data)
                        .navigationTitle("\(type.capitalized) Registration")
                }
            }
        }
    }
}

#Preview {
    LandingView()
        .environment(AuthManager())
}
