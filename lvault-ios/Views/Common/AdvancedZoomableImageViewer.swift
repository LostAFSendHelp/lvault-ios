//
//  AdvancedZoomableImageViewer.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 9/13/25.
//

import SwiftUI

struct AdvancedZoomableImageViewer: View {
    let image: Image
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var dismissOffset: CGFloat = 0
    @State private var backgroundOpacity: Double = 1.0
    @State private var imageSize: CGSize = .zero
    
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 4.0
    private let dismissThreshold: CGFloat = 100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(backgroundOpacity)
                    .ignoresSafeArea()
                
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(x: offset.width, y: offset.height + dismissOffset)
                    .background(
                        GeometryReader { imageGeometry in
                            Color.clear
                                .onAppear {
                                    imageSize = imageGeometry.size
                                }
                        }
                    )
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let newScale = lastScale * value
                                    scale = min(max(newScale, minScale), maxScale)
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        if scale < minScale {
                                            scale = minScale
                                            lastScale = minScale
                                            offset = .zero
                                            lastOffset = .zero
                                        } else {
                                            // Constrain offset to image bounds
                                            offset = constrainOffset(offset, scale: scale, geometry: geometry)
                                            lastOffset = offset
                                        }
                                    }
                                },
                            
                            DragGesture()
                                .onChanged { value in
                                    if scale > minScale {
                                        let newOffset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                        offset = constrainOffset(newOffset, scale: scale, geometry: geometry)
                                    } else {
                                        dismissOffset = value.translation.height
                                        let progress = abs(dismissOffset) / dismissThreshold
                                        backgroundOpacity = max(0.3, 1.0 - progress * 0.7)
                                    }
                                }
                                .onEnded { value in
                                    if scale <= minScale {
                                        let velocity = value.predictedEndLocation.y - value.location.y
                                        let shouldDismiss = abs(dismissOffset) > dismissThreshold || abs(velocity) > 500
                                        
                                        if shouldDismiss {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                dismissOffset = dismissOffset > 0 ? 1000 : -1000
                                                backgroundOpacity = 0
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                isPresented = false
                                            }
                                        } else {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                dismissOffset = 0
                                                backgroundOpacity = 1.0
                                            }
                                        }
                                    } else {
                                        lastOffset = offset
                                    }
                                }
                        )
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if scale > minScale {
                                scale = minScale
                                lastScale = minScale
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                            }
                        }
                    }
                    .onTapGesture {
                        if scale <= minScale {
                            withAnimation(.easeOut(duration: 0.25)) {
                                backgroundOpacity = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                isPresented = false
                            }
                        }
                    }
            }
        }
        .transition(.opacity)
    }
    
    private func constrainOffset(_ offset: CGSize, scale: CGFloat, geometry: GeometryProxy) -> CGSize {
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        
        let maxOffsetX = max(0, (scaledWidth - geometry.size.width) / 2)
        let maxOffsetY = max(0, (scaledHeight - geometry.size.height) / 2)
        
        return CGSize(
            width: min(max(offset.width, -maxOffsetX), maxOffsetX),
            height: min(max(offset.height, -maxOffsetY), maxOffsetY)
        )
    }
}
