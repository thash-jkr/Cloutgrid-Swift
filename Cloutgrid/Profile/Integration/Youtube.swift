//
//  Youtube.swift
//  Cloutgrid
//
//  Created by Afthash on 23/4/2026.
//

import SwiftUI

struct Youtube: View {
    var body: some View {
        ScrollView {
            VStack {
                Button {
                    
                } label: {
                    Text("Connect YouTube")
                        .customButton(disabled: true)
                }
                
                Text("This feature is in development")
                    .foregroundStyle(Color.secondary)
                    .font(.caption)
            }
            .padding(.bottom)
            
            YoutubeConstants()
        }
    }
}

#Preview {
    NavigationStack {
        Youtube()
    }
}
