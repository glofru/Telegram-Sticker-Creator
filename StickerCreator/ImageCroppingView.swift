//
//  ImageCroppingView.swift
//  StickerCreator
//
//  Created by g.lofrumento on 16/10/21.
//

import SwiftUI

struct ImageCroppingView: View {
    
    let uiImage: UIImage
    
    @StateObject private var viewModel = ImageCroppingViewModel()
    
    @State private var windowCenter: CGPoint?
    
    @State private var offset = CGSize.zero
    @State private var lastOffset: CGSize?
    @State private var scale = 1.0
    @State private var lastScale = 1.0
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(uiImage: uiImage)
                    .onAppear {
                        viewModel.window.center.x = uiImage.size.width/2
                        viewModel.window.center.y = uiImage.size.height/2
                    }
                    .overlay {
                        GridView(viewModel: viewModel)
                            .position(viewModel.window.center)
                            .gesture(DragGesture()
                                        .onChanged({ value in
                                if windowCenter == nil {
                                    windowCenter = viewModel.window.center
                                }
                                
                                viewModel.window.center = windowCenter!.applying(CGAffineTransform(translationX: value.translation.width, y: value.translation.height))
                                
                                if viewModel.window.center.x - viewModel.window.size.width/2 < 0 {
                                    viewModel.window.center.x = viewModel.window.size.width/2
                                } else if viewModel.window.center.x + viewModel.window.size.width/2 > uiImage.size.width {
                                    viewModel.window.center.x = uiImage.size.width - viewModel.window.size.width/2
                                }
                                
                                if viewModel.window.center.y - viewModel.window.size.height/2 < 0 {
                                    viewModel.window.center.y = viewModel.window.size.height/2
                                } else if viewModel.window.center.y + viewModel.window.size.height/2 > uiImage.size.height {
                                    viewModel.window.center.y = uiImage.size.height - viewModel.window.size.height/2
                                }
                            }).onEnded({ _ in
                                windowCenter = nil
                            }))
                    }
            }
            .offset(offset)
            .scaleEffect(scale)
            .gesture(MagnificationGesture()
                        .onChanged({ value in
                let delta = value / lastScale
                lastScale = value
                if delta > 0.94 {
                    scale *= delta
                    scale = max(min(scale, 3), 0.8)
                }
            }).onEnded({ _ in
                lastScale = 1.0
            }).simultaneously(with: DragGesture()
                                .onChanged({ value in
                if lastOffset == nil {
                    lastOffset = offset
                }
                offset = CGSize(width: lastOffset!.width + value.translation.width / scale, height: lastOffset!.height + value.translation.height / scale)
            }).onEnded({ _ in
                lastOffset = nil
            })))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        scale = 1.0
                        offset = CGSize.zero
                    }
                }
            }
        }
    }
}

private struct GridView: View {
    
    @ObservedObject var viewModel: ImageCroppingViewModel
    
    @State private var size = CGSize(width: 100, height: 100)
    
    var body: some View {
        Rectangle()
            .frame(width: viewModel.window.size.width, height: viewModel.window.size.height)
            .opacity(0.3)
            .border(Color.white.opacity(0.8), width: 2)
            
    }
}

private class ImageCroppingViewModel: ObservableObject {
    struct Window {
        var center: CGPoint;
        var size: CGSize;
    }
    
    @Published var window = Window(center: CGPoint.zero, size: CGSize(width: 100, height: 100))
}

#if DEBUG
struct ImageCroppingView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCroppingView(uiImage: UIImage(named: "testcat")!)
    }
}
#endif
