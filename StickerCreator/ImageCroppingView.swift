//
//  ImageCroppingView.swift
//  StickerCreator
//
//  Created by g.lofrumento on 16/10/21.
//

import SwiftUI

struct ImageCroppingView: View {
    
    let uiImage: UIImage!
    
    @StateObject private var viewModel = ImageCroppingViewModel()
    
    @State private var windowCenter: CGPoint?
    
    @State private var lastOffset: CGSize?
    @State private var lastScale: CGFloat?
    
    @State private var processing = false
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(uiImage: viewModel.uiImage)
                    .onAppear {
                        viewModel.window.origin = CGPoint(x: viewModel.uiImage.size.width/2, y: viewModel.uiImage.size.height/2)
                        viewModel.window.size = CGSize(width: viewModel.uiImage.size.width/4, height: viewModel.uiImage.size.width/4)
                    }
                    .overlay {
                        GridView(viewModel: viewModel)
                            .position(viewModel.window.origin)
                            .gesture(DragGesture()
                                        .onChanged({ value in
                                if windowCenter == nil {
                                    windowCenter = viewModel.window.origin
                                }
                                
                                viewModel.window.origin = windowCenter!.applying(CGAffineTransform(translationX: value.translation.width, y: value.translation.height))
                                
                                if viewModel.window.origin.x - viewModel.window.size.width/2 < 0 {
                                    viewModel.window.origin.x = viewModel.window.size.width/2
                                } else if viewModel.window.origin.x + viewModel.window.size.width/2 > viewModel.uiImage.size.width {
                                    viewModel.window.origin.x = viewModel.uiImage.size.width - viewModel.window.size.width/2
                                }
                                
                                if viewModel.window.origin.y - viewModel.window.size.height/2 < 0 {
                                    viewModel.window.origin.y = viewModel.window.size.height/2
                                } else if viewModel.window.origin.y + viewModel.window.size.height/2 > viewModel.uiImage.size.height {
                                    viewModel.window.origin.y = viewModel.uiImage.size.height - viewModel.window.size.height/2
                                }
                            }).onEnded({ _ in
                                windowCenter = nil
                            }))
                    }
                    .alert("An error has occurred", isPresented: $showError) {
                        
                    }
            }
            .offset(viewModel.offset)
            .scaleEffect(viewModel.scale)
            .gesture(MagnificationGesture()
                        .onChanged({ value in
                var delta: CGFloat
                if lastScale == nil {
                    delta = value
                } else {
                    delta = value / lastScale!
                }
                lastScale = value
                if delta > 0.94 {
                    viewModel.scale *= delta
                    viewModel.scale = max(min(viewModel.scale, 3), viewModel.fitScale)
                }
            }).onEnded({ _ in
                lastScale = nil
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
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Reset", action: viewModel.reset)
                        .disabled(processing)
                    
                    Spacer()
                    
                    if processing {
                        ProgressView()
                    } else {
                        Button("Process") {
                            processing = true
                            Task {
                                showError = !(await viewModel.process())
                                processing = false
                            }
                        }
                    }
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
            .strokeBorder(Color.white, lineWidth: 2/viewModel.scale)
            .background(Circle().foregroundColor(Color.blue))
            .frame(width: 20/viewModel.scale, height: 20/viewModel.scale)
            .offset(CGSize(width: position.rawValue.width * viewModel.window.size.width/2, height: position.rawValue.height * viewModel.window.size.height/2))
            .highPriorityGesture(DragGesture().onChanged({ value in
                if lastCenter == nil || lastSize == nil {
                    lastCenter = viewModel.window.origin
                    lastSize = viewModel.window.size
                }
                
                viewModel.window.size = CGSize(width: abs(lastSize!.width + value.translation.width * position.rawValue.width * 2), height: abs(lastSize!.height + value.translation.height * position.rawValue.height * 2))
                
                if viewModel.window.origin.y - viewModel.window.size.height/2 < 0 {
                    viewModel.window.size.height = viewModel.window.origin.y*2
                } else if viewModel.window.origin.y + viewModel.window.size.height/2 > viewModel.uiImage.size.height {
                    viewModel.window.size.height = (viewModel.uiImage.size.height - viewModel.window.origin.y)*2
                }
                
                if viewModel.window.origin.x - viewModel.window.size.width/2 < 0 {
                    viewModel.window.size.width = viewModel.window.origin.x*2
                } else if viewModel.window.origin.x + viewModel.window.size.width/2 > viewModel.uiImage.size.width {
                    viewModel.window.size.width = (viewModel.uiImage.size.width - viewModel.window.origin.x)*2
                }
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
    
    let uiImage = UIImage(named: "cocconegro")!
    
    @Published var scale: CGFloat
    @Published var offset = CGSize.zero
    
    @Published var window = CGRect(origin: .zero, size: .zero)
    
    init() {
        scale = min(UIScreen.screenWidth / uiImage.size.width, UIScreen.screenHeight / uiImage.size.height)
    }
    
    lazy var fitScale: CGFloat = {
        min(UIScreen.screenWidth / uiImage.size.width, UIScreen.screenHeight / uiImage.size.height)
    }()
    
    func reset() {
        self.scale = fitScale
        self.offset = CGSize.zero
    }
    
    func process() async -> Bool {
        guard let result = ImageProcessor.process(uiImage: uiImage, window: window) else {
            return false
        }
        
        share(items: [result])
        
        return false
    }
    
    @discardableResult
    func share(
        items: [Any],
        excludedActivityTypes: [UIActivity.ActivityType]? = nil
    ) -> Bool {
        guard let source = UIApplication.shared.windows.last?.rootViewController else {
            return false
        }
        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        vc.excludedActivityTypes = excludedActivityTypes
        vc.popoverPresentationController?.sourceView = source.view
        source.present(vc, animated: true)
        return true
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
