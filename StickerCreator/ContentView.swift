//
//  ContentView.swift
//  StickerCreator
//
//  Created by g.lofrumento on 16/10/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    var body: some View {
        ImageCroppingView(uiImage: UIImage(named: "testcat")!)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
