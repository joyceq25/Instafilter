//
//  ContentView.swift
//  Instafilter
//
//  Created by Ping Yun on 10/7/20.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    //optional image property
    @State private var image: Image?
    //stores intensity of Core Image filter
    @State private var filterIntensity = 0.5
    
    //stores whether action sheet is showing or not
    @State private var showingFilterSheet = false
    //tracks whether image picker is being shown or not
    @State private var showingImagePicker = false
    //optional UIImage property to pass into image picker
    @State private var inputImage: UIImage?
    
    //stores current filter being used
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    //stores intermediate UIImage
    @State private var processedImage: UIImage?
    
    var body: some View {
        //custom binding that returns filterIntensity when it is read, updates filterInsenity and calls applyProcessing() when it is written
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )
        
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    
                    //shows selected image if there is one
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    //if not, shows prompt telling user to tap area to trigger image selection
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }

                }
                .onTapGesture {
                    //sets showingImagePicker to true when rectangle is tapped 
                    self.showingImagePicker = true
                }

                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                }.padding(.vertical)

                HStack {
                    Button("Change Filter") {
                        //shows action sheet
                        self.showingFilterSheet = true
                    }

                    Spacer()

                    Button("Save") {
                        guard let processedImage = self.processedImage else { return }
                        
                        let imageSaver = ImageSaver()
                        
                        //provides success and error closures when using ImageSaver class 
                        imageSaver.successHandler = {
                            print("Sucess!")
                        }
                        
                        imageSaver.errorHandler = {
                            print("Oops: \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Instafilter")
            //sheet() modifier that uses showingImagePicker as condition, references loadImage as onDismiss parameter
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                //presents ImagePicker bound to inputImage 
                ImagePicker(image: self.$inputImage)
            }
            //actionSheet that is shown as soon as showingFilterSheet is true
            .actionSheet(isPresented: $showingFilterSheet) {
                //series of buttons that try out various Core Image filters
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Crystallize")) { self.setFilter(CIFilter.crystallize()) },
                    .default(Text("Edges")) { self.setFilter(CIFilter.edges()) },
                    .default(Text("Gaussian Blur")) { self.setFilter(CIFilter.gaussianBlur()) },
                    .default(Text("Pixellate")) { self.setFilter(CIFilter.pixellate()) },
                    .default(Text("Sepia Tone")) { self.setFilter(CIFilter.sepiaTone()) },
                    .default(Text("Unsharp Mask")) { self.setFilter(CIFilter.unsharpMask()) },
                    .default(Text("Vignette")) { self.setFilter(CIFilter.vignette()) },
                    .cancel()
                ])
            }
        }
    }
    //method called when ImagePicker has been dismissed, places image directly into UI
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        //sends chosen image to filter
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        //applies filter
        applyProcessing()
    }
    
    //method that processes imported image
    func applyProcessing() {
        //reads all the valid keys we can use with setValue(_:forKey:), only sets intensity key if it is supported by current filter 
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        
        
        //reads output image back from filter
        guard let outputImage = currentFilter.outputImage else { return }
        
        //asks CIContext to render it and places result into image property so it is visible on screen
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            //stores uiImage in processedImage for later
            processedImage = uiImage
        }
    }
    
    //method that change filter to something else, then calls loadImage()
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 11")
    }
}
