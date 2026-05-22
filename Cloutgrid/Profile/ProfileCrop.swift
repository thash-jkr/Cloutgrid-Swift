//
//  ProfileCrop.swift
//  Cloutgrid
//
//  Created by Afthash on 3/5/2026.
//

import SwiftUI

struct ProfileCrop: View {
    let image: UIImage
    @Binding var croppedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    @Environment(\.displayScale) private var displayScale

    // Gesture States
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let maskSize: CGFloat = 300 // The size of our square crop

    var body: some View {
        VStack {
            ZStack {
                // The Background Color
                Color.black.ignoresSafeArea()

                // 1. The actual image with gestures
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(scale)
                    .offset(offset)
                    .frame(width: maskSize, height: maskSize)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )

                // 2. The Overlays (Dimmed areas)
                Color.black.opacity(0.5)
                    .mask(
                        Rectangle()
                            .overlay(
                                Rectangle()
                                    .frame(width: maskSize, height: maskSize)
                                    .blendMode(.destinationOut)
                            )
                    )
                
                // 3. The Guide Frame
                Rectangle()
                    .stroke(.white, lineWidth: 2)
                    .frame(width: maskSize, height: maskSize)
            }
            .compositingGroup()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    generateCrop()
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                }
            }
        }
    }

    // 2. High-Quality Render Function
    @MainActor
    private func generateCrop() {
        let renderer = ImageRenderer(content:
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: maskSize, height: maskSize)
                .clipped()
        )
        
        // Prefer the SwiftUI environment's displayScale; it reflects the current traits/context
        renderer.scale = displayScale
        
        if let uiImage = renderer.uiImage {
            self.croppedImage = uiImage
        }
    }
}

#Preview {
    NavigationStack {
        ProfileCrop(image: UIImage(named: "testImage1")!, croppedImage: .constant(UIImage(named: "testImage1")!))
    }
}
