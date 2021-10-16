//
//  ImageCroppingView.swift
//  StickerCreator
//
//  Created by g.lofrumento on 16/10/21.
//

import SwiftUI

struct ImageCroppingView: View {
    
    @StateObject private var viewModel = ImageCroppingViewModel()
    
    @State private var windowCenter: CGPoint?
    
    let uiImage: UIImage!
    
    @State private var lastOffset: CGSize?
    @State private var lastScale = 1.0
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(uiImage: viewModel.uiImage)
                    .onAppear {
                        viewModel.window.center = CGPoint(x: viewModel.uiImage.size.width/2, y: viewModel.uiImage.size.height/2)
                        viewModel.window.size = CGSize(width: viewModel.uiImage.size.width/4, height: viewModel.uiImage.size.width/4)
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
                                } else if viewModel.window.center.x + viewModel.window.size.width/2 > viewModel.uiImage.size.width {
                                    viewModel.window.center.x = viewModel.uiImage.size.width - viewModel.window.size.width/2
                                }
                                
                                if viewModel.window.center.y - viewModel.window.size.height/2 < 0 {
                                    viewModel.window.center.y = viewModel.window.size.height/2
                                } else if viewModel.window.center.y + viewModel.window.size.height/2 > viewModel.uiImage.size.height {
                                    viewModel.window.center.y = viewModel.uiImage.size.height - viewModel.window.size.height/2
                                }
                            }).onEnded({ _ in
                                windowCenter = nil
                            }))
                    }
            }
            .offset(viewModel.offset)
            .scaleEffect(viewModel.scale)
            .gesture(MagnificationGesture()
                        .onChanged({ value in
                let delta = value / lastScale
                lastScale = value
                if delta > 0.94 {
                    viewModel.scale *= delta
                    viewModel.scale = max(min(viewModel.scale, 3), 0.8)
                }
            }).onEnded({ _ in
                lastScale = 1.0
            }).simultaneously(with: DragGesture()
                                .onChanged({ value in
                if lastOffset == nil {
                    lastOffset = viewModel.offset
                }
                viewModel.offset = CGSize(width: lastOffset!.width + value.translation.width / viewModel.scale, height: lastOffset!.height + value.translation.height / viewModel.scale)
            }).onEnded({ _ in
                lastOffset = nil
            })))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset", action: viewModel.reset)
                }
            }
        }
    }
}

private struct GridView: View {
    
    @ObservedObject var viewModel: ImageCroppingViewModel
    
    @State private var lastCenter: CGPoint?
    @State private var lastSize: CGSize?
    
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
                .frame(width: viewModel.window.size.height, height: 2)
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
            .highPriorityGesture(DragGesture().onChanged({ value in
                if lastCenter == nil || lastSize == nil {
                    lastCenter = viewModel.window.center
                    lastSize = viewModel.window.size
                }
                
//                viewModel.window.size = CGSize(width: abs(lastSize!.width + value.translation.width * position.rawValue.width * 2), height: abs(lastSize!.height + value.translation.height * position.rawValue.height * 2))
                
                viewModel.window.size = CGSize(width: abs(lastSize!.width + value.translation.width * position.rawValue.width), height: abs(lastSize!.height + value.translation.height * position.rawValue.height))
            }).onEnded({ _ in
                lastCenter = nil
                lastSize = nil
            }))
    }
    
    enum PivotPosition: CGSize {
        case topLeft = "{-1, -1}"
        case topRight = "{1, -1}"
        case bottomRight = "{1, 1}"
        case bottomLeft = "{-1, 1}"
        
        case midTop = "{0, -1}"
        case midBottom = "{0, 1}"
        case midRight = "{1, 0}"
        case midLeft = "{-1, 0}"
    }
}

private class ImageCroppingViewModel: ObservableObject {
    struct Window {
        var center = CGPoint.zero;
        var size = CGSize.zero;
    }
    
    let uiImage = UIImage(named: "testcat")!
    
    @Published var scale = 1.0
    @Published var offset = CGSize.zero
    
    @Published var window = Window()
    
    func reset() {
        self.scale = 1.0
        self.offset = CGSize.zero
    }
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
