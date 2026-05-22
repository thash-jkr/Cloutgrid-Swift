//
//  SearchBar.swift
//  Cloutgrid
//
//  Created by Afthash on 3/5/2026.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
        
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search for Creators and Businesses", text: $text)
                    .submitLabel(.search)
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.dualWhite)
    }
}

#Preview {
    SearchBar(text: .constant(""), placeholder: "Search for Creators and Businesses")
}
