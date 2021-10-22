//
//  ContentView.swift
//  StickerCreator
//
//  Created by g.lofrumento on 16/10/21.
//

import SwiftUI
import ImagePickerView

struct ContentView: View {
    
    @State private var uiImage: UIImage?
    @State private var presentImagePicker = false
    
    var body: some View {
        if let uiImage = uiImage {
            ImageCroppingView(uiImage: uiImage, onDismiss: {
                withAnimation {
                    self.uiImage = nil
                }
            })
        } else {
            NavigationView {
                Button("Pick a photo") {
                    presentImagePicker = true
                }
            }
            .sheet(isPresented: $presentImagePicker) {
                UIImagePickerView(allowsEditing: false, sourceType: .savedPhotosAlbum, delegate: UIImagePickerView.Delegate(isPresented: $presentImagePicker, didCancel: { _ in }, didSelect: { result in
                    withAnimation {
                        self.uiImage = result.image
                    }
                }))
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
