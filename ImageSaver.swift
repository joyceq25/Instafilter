//
//  ImageSaver.swift
//  Instafilter
//
//  Created by Ping Yun on 10/7/20.
//

import UIKit

class ImageSaver: NSObject {
    //properties to represent closures handling success and failure
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        //checks whether error was provided, calls one of two closures 
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}
