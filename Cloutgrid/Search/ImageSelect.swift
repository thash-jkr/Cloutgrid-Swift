//
//  ImageSelect.swift
//  Cloutgrid
//
//  Created by Afthash on 5/4/2026.
//

import SwiftUI
import PhotosUI

struct ImageSelect: View {
    var image: UIImage
    @Binding var path: NavigationPath
    
    @State private var selectedRatio: CropRatio = .square
    @State private var cropTrigger: Bool = false
    @State private var finalImage: UIImage? = nil
    
    enum CropRatio: CGFloat, CaseIterable {
        case square = 1.0
        case portrait = 0.75
        case landscape = 1.33
        
        var title: String {
            switch self {
            case .square:
                return "1:1"
            case .portrait:
                return "3:4"
            case .landscape:
                return "4:3"
            }
        }
    }
    
    private var CropSelect: some View {
        HStack(alignment: .top) {
            Spacer()
            
            Button {
                selectedRatio = .square
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "square")
                        .foregroundStyle(
                            selectedRatio == .square ? Color.second : Color.primary
                        )
                        .font(.title)
                    Text(CropRatio.square.title)
                        .foregroundStyle(selectedRatio == .square ? Color.second : Color.primary)
                        .font(.footnote)
                }
            }
            
            Spacer()
            
            Button {
                selectedRatio = .portrait
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "rectangle")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(
                            selectedRatio == .portrait ? Color.second : Color.primary
                        )
                        .font(.title)
                    Text(CropRatio.portrait.title)
                        .foregroundStyle(selectedRatio == .portrait ? Color.second : Color.primary)
                        .font(.footnote)
                }
            }
            
            Spacer()
            
            Button {
                selectedRatio = .landscape
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "rectangle")
                        .foregroundStyle(
                            selectedRatio == .landscape ? Color.second : Color.primary
                        )
                        .font(.title)
                    Text(CropRatio.landscape.title)
                        .foregroundStyle(selectedRatio == .landscape ? Color.second : Color.primary)
                        .font(.footnote)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 30)
    }

    struct CropView: View {
        let image: UIImage
        @Binding var selectedRatio: CropRatio
        @Binding var triggerCrop: Bool
        var onComplete: (UIImage) -> Void
        
        @State private var frameOffset: CGSize = .zero
        @State private var lastFrameOffset: CGSize = .zero

        private func cropLayout(for containerWidth: CGFloat) -> (width: CGFloat, height: CGFloat, maxW: CGFloat, maxH: CGFloat) {
            let imageRatio = image.size.height / image.size.width
            let displayedImageHeight = containerWidth * imageRatio

            var fWidth: CGFloat
            var fHeight: CGFloat

            if imageRatio > 1 {
                fWidth = containerWidth
                fHeight = fWidth / selectedRatio.rawValue
                if fHeight > displayedImageHeight {
                    fHeight = displayedImageHeight
                    fWidth = fHeight * selectedRatio.rawValue
                }
            } else {
                fHeight = displayedImageHeight
                fWidth = fHeight * selectedRatio.rawValue
                if fWidth > containerWidth {
                    fWidth = containerWidth
                    fHeight = fWidth / selectedRatio.rawValue
                }
            }

            let maxW = max(0, (containerWidth - fWidth) / 2)
            let maxH = max(0, (displayedImageHeight - fHeight) / 2)

            return (fWidth, fHeight, maxW, maxH)
        }
        
        func cropImage() -> UIImage? {
            let containerWidth = UIScreen.main.bounds.width
            let layout = cropLayout(for: containerWidth)
            
            // 1. Calculate the scale between the UI and the actual Pixels
            let scale = image.size.width / containerWidth
            
            // 2. Determine the center point of the image in UI points
            let imageCenterX = containerWidth / 2
            let imageCenterY = (containerWidth * (image.size.height / image.size.width)) / 2
            
            // 3. Calculate the Top-Left corner of the crop frame in UI points
            // We start at the center, adjust for the frame size, and add the user's offset
            let cropXPoints = (imageCenterX - (layout.width / 2)) + frameOffset.width
            let cropYPoints = (imageCenterY - (layout.height / 2)) + frameOffset.height
            
            // 4. Convert UI points to actual Pixels
            let cropRect = CGRect(
                x: cropXPoints * scale,
                y: cropYPoints * scale,
                width: layout.width * scale,
                height: layout.height * scale
            )
            
            // 5. Perform the actual crop
            guard let cgImage = image.cgImage?.cropping(to: cropRect) else { return nil }
            
            // We maintain the original orientation (important for iPhone photos!)
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }

        var body: some View {
            GeometryReader { geo in
                let containerWidth = geo.size.width
                let layout = cropLayout(for: containerWidth)

                VStack {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: containerWidth)

                        Rectangle()
                            .stroke(.white, lineWidth: 2)
                            .frame(width: layout.width, height: layout.height)
                            .background(Color.white.opacity(0.001))
                            .offset(frameOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let intendedX = lastFrameOffset.width + value.translation.width
                                        let intendedY = lastFrameOffset.height + value.translation.height

                                        frameOffset = CGSize(
                                            width: min(max(intendedX, -layout.maxW), layout.maxW),
                                            height: min(max(intendedY, -layout.maxH), layout.maxH)
                                        )
                                    }
                                    .onEnded { _ in
                                        lastFrameOffset = frameOffset
                                        triggerCrop = true
                                    }
                            )
                    }
                    .ignoresSafeArea()
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            }
            .onChange(of: triggerCrop) { _, newValue in
                if newValue {
                    if let cropped = cropImage() {
                        onComplete(cropped)
                    }
                    triggerCrop = false
                }
            }
            .onChange(of: selectedRatio, { _, _ in
                triggerCrop = true
            })
            .onAppear() {
                triggerCrop = true
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CropView(
                image: image,
                selectedRatio: $selectedRatio,
                triggerCrop: $cropTrigger
            ) { croppedResult in
                finalImage = croppedResult
            }
            
            CropSelect
        }
        .navigationTitle("Crop photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    path.append(ImageAction.cropped(finalImage ?? UIImage(named: "testImage1")!))
                } label: {
                    Image(systemName: "arrow.right")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ImageSelect(
            image: UIImage(named: "testImage1")!,
            path: .constant(NavigationPath())
        )
    }
}
