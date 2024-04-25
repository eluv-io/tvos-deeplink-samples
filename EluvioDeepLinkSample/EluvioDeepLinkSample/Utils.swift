//
//  Utils.swift
//  EluvioDeepLinkSample
//
//  Created by Wayne Tran on 2024-03-07.
//

import Foundation
import CoreImage.CIFilterBuiltins
import SwiftUI

func GenerateQRCode(from string: String) -> UIImage {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    filter.message = Data(string.utf8)

    if let outputImage = filter.outputImage {
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }
    }


    return UIImage(systemName: "xmark.circle") ?? UIImage()
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
