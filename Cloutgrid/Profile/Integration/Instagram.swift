//
//  Instagram.swift
//  Cloutgrid
//
//  Created by Afthash on 23/4/2026.
//

import SwiftUI
import KeychainSwift

struct Instagram: View {
    @Environment(AuthManager.self) private var auth
    
    private struct IdURL: Identifiable {
        let id = UUID()
        let rawValue: String
    }
    
    @State private var sheetURL: IdURL?
    
    var body: some View {
        VStack {
            Text("Instagram Insights 📸")
                .font(.title2)
                .bold()
                .padding(.bottom)
            
            VStack {
                Button {
                    sheetURL = IdURL(
                        rawValue: "\(APIConfig.current.baseURL)/auth/facebook/start?token=\(auth.access ?? "")&medium=app"
                    )
                } label: {
                    Text("Connect Instagram")
                        .customButton()
                }
                
//                Text("This feature is in development")
//                    .foregroundStyle(Color.secondary)
//                    .font(.caption)
            }
            .padding(.bottom)
            
            InstagramConstant()
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .sheet(item: $sheetURL) { urlString in
            NavigationStack {
                BrowserView(url: URL(string: urlString.rawValue)!)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                sheetURL = nil
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            ShareLink(item: sheetURL?.rawValue ?? "") {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    Instagram()
        .environment(AuthManager())
}
