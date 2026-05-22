//
//  OtherYoutube.swift
//  Cloutgrid
//
//  Created by Afthash on 26/4/2026.
//

import SwiftUI

struct OtherYoutube: View {
    var username: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image("Graph")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            Text("@\(username) hasn't connected their Youtube yet!")
                .foregroundStyle(.secondary)
                .font(.callout)
        }
    }
}

#Preview {
    OtherYoutube(username: "creator1")
}
