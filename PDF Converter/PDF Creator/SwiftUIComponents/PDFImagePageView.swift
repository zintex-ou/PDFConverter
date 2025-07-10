//
//  PDFImagePageView.swift
//  PDF Converter
//
//  Created by Oleg on 10.07.25.
//


import SwiftUI

struct PDFImagePageView: View {
    private let uiImage: UIImage
    
    init(uiImage: UIImage) {
        self.uiImage = uiImage
    }
    
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .padding(.all, 16)
            .frame(width: PageConstants.pageWidth * PageConstants.dotsPerInch,
                   height: PageConstants.pageHeight * PageConstants.dotsPerInch)
    }
}

