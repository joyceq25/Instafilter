//
//  ImagePicker.swift
//  Instafilter
//
//  Created by Ping Yun on 10/7/20.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        //method called when user has selected an image and will be given a dictionary of information about the selected image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            //sets image property of parent ImagePicker
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            //dismiss view 
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    //tells SwiftUI to use Coordinator class for ImagePicker coordinator
    func makeCoordinator() -> Coordinator {
        //creates Coordinator object and passes in self
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        //makes coordinator class delegate of UIKit image picker
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
}
