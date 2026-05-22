//
//  Empty.swift
//  Cloutgrid
//
//  Created by Afthash on 5/4/2026.
//

import SwiftUI

struct Empty: View {
    var type: String
    var message: String
    var isLoading: Bool = false
    
    private func photo(name: String) -> some View {
        VStack(spacing: 10) {
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            if isLoading {
                LoadingView()
            } else {
                Text(message)
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var body: some View {
        switch type {
        case "post":
            photo(name: "postEmpty")
        case "collab":
            photo(name: "collabEmpty")
        case "comment":
            photo(name: "commentEmpty")
        default:
            photo(name: "generalEmpty")
        }
    }
}

#Preview {
    Empty(type: "comment", message: "Nothing to see here!")
}
