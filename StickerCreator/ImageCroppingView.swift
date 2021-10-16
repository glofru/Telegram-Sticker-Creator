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
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: viewModel.window.size.width, height: viewModel.window.size.height)
                .opacity(0.3)
                .border(Color.white.opacity(0.8), width: 2)
            
            Line()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                .frame(width: viewModel.window.size.width, height: 2)
            
            Line()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                .frame(width: viewModel.window.size.width, height: 2)
                .rotationEffect(.degrees(90))
        }
            .overlay {
                getPivot(.topLeft)
                getPivot(.topRight)
                getPivot(.bottomLeft)
                getPivot(.bottomRight)
                
                getPivot(.midTop)
                getPivot(.midBottom)
                getPivot(.midRight)
                getPivot(.midLeft)
            }
    }
    
    private func getPivot(_ position: PivotPosition) -> some View {
        Circle()
            .strokeBorder(Color.white, lineWidth: 1)
            .background(Circle().foregroundColor(Color.blue))
            .frame(width: 10, height: 10)
            .offset(CGSize(width: position.rawValue.width * viewModel.window.size.width/2, height: position.rawValue.height * viewModel.window.size.height/2))
    }
    
    enum PivotPosition: CGSize {
        case topLeft = "{-1, -1}"
        case topRight = "{1, 1}"
        case bottomRight = "{1, -1}"
        case bottomLeft = "{-1, 1}"
        case midTop = "{0, -1}"
        case midBottom = "{0, 1}"
        case midRight = "{1, 0}"
        case midLeft = "{-1, 0}"
    }
}

private class ImageCroppingViewModel: ObservableObject {
    struct Window {
        var center: CGPoint;
        var size: CGSize;
    }
    
    @Published var window = Window(center: CGPoint.zero, size: CGSize(width: 100, height: 100))
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

#if DEBUG
struct ImageCroppingView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCroppingView(uiImage: UIImage(named: "testcat")!)
    }
}
#endif
