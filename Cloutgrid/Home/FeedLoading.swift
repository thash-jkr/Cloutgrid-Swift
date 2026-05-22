//
//  FeedLoading.swift
//  Cloutgrid
//
//  Created by Afthash on 19/5/2026.
//

import SwiftUI

struct FeedLoading: View {
    @State private var animationOffset: CGFloat = -1
    
    private func loadingBox(geo: GeometryProxy) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .padding()
                .frame(height: 50)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.7),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: animationOffset * geo.size.width)
                )
                .clipped()
            
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .padding(.horizontal)
                .frame(height: 300)
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.7),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: animationOffset * geo.size.width)
                )
                .clipped()
            
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .padding()
                    .frame(height: 50)
                    .overlay(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color.white.opacity(0.7),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: animationOffset * geo.size.width)
                    )
                    .clipped()
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .padding()
                    .frame(height: 50)
                    .overlay(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color.white.opacity(0.7),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: animationOffset * geo.size.width)
                    )
                    .clipped()
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animationOffset = 2
            }
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                loadingBox(geo: geo)
                
                loadingBox(geo: geo)
                
                loadingBox(geo: geo)
            }
        }
    }
}

#Preview {
    FeedLoading()
}
