//
//  TestView.swift
//  Cloutgrid
//
//  Created by Afthash on 9/4/2026.
//

import SwiftUI
import WebKit


struct TestView: View {
    @State private var animationOffset: CGFloat = -1
 
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
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
                        .offset(x: animationOffset * geometry.size.width)
                )
                .clipped()
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animationOffset = 2
            }
        }
    }
}



#Preview {
    TestView()
}
