//
//  Youtube.swift
//  Cloutgrid
//
//  Created by Afthash on 23/4/2026.
//

import SwiftUI

struct Youtube: View {
    var body: some View {
        VStack {
            Text("YouTube Analytics 📊")
                .font(.title2)
                .bold()
                .padding(.bottom)
            
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
            
            Spacer()
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    Youtube()
}
