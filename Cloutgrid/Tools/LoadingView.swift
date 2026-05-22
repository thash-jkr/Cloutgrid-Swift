//
//  LoadingView.swift
//  Cloutgrid
//
//  Created by Afthash on 10/4/2026.
//

import SwiftUI

struct LoadingView: View {
    var size: CGFloat = 20
    
    @State private var rotationDegrees = 0.0
    
    var body: some View {
        Image(systemName: "gearshape.arrow.triangle.2.circlepath")
            .font(.system(size: size))
            .foregroundStyle(Color.primary)
            .padding(10)
            .rotationEffect(.degrees(rotationDegrees))
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    rotationDegrees = 360.0
                }
            }
    }
}

#Preview {
    LoadingView()
}
