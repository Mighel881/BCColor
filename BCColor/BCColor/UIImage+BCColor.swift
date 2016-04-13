//
//  UIImage+BCColor.swift
//  BCColor
//
//  Created by Boyce on 3/21/16.
//  Copyright © 2016 Boyce. All rights reserved.
//

import UIKit

public struct BCImageColors {
    public var backgroundColor: UIColor!
    public var primaryColor: UIColor!
    public var secondaryColor: UIColor!
    public var minorColor: UIColor!
}

private class BCCountedColor {
    let color: UIColor
    let count: Int
    
    init(color: UIColor, count: Int) {
        self.color = color
        self.count = count
    }
}

extension UIImage {
    private func resize(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    public func bc_getColors() -> BCImageColors {
        var result = BCImageColors()
        
        let ratio = self.size.width/self.size.height
        let r_width: CGFloat = 100
        let r_height: CGFloat = r_width/ratio
        let cgImage = self.resize(CGSizeMake(r_width, r_height)).CGImage
        
        let width = CGImageGetWidth(cgImage)
        let height = CGImageGetHeight(cgImage)
        
        let bytesPerPixel: Int = 4
        let bytesPerRow: Int = width * bytesPerPixel
        let bitsPerComponent: Int = 8
        let sortedColorComparator: NSComparator = { (main, other) -> NSComparisonResult in
            let m = main as! BCCountedColor, o = other as! BCCountedColor
            if m.count < o.count {
                return NSComparisonResult.OrderedDescending
            } else if m.count == o.count {
                return NSComparisonResult.OrderedSame
            } else {
                return NSComparisonResult.OrderedAscending
            }
        }
        let blackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let whiteColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let raw = malloc(bytesPerRow * height)
        let bitmapInfo = CGImageAlphaInfo.PremultipliedFirst.rawValue
        let ctx = CGBitmapContextCreate(raw, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        CGContextDrawImage(ctx, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), cgImage)
        let data = UnsafePointer<UInt8>(CGBitmapContextGetData(ctx))
        let imageColors = NSCountedSet(capacity: width * height)
        
        for x in 0..<width {
            for y in 0..<height {
                let pixel = ((width * y) + x) * bytesPerPixel
                let color = UIColor(
                    red: round(CGFloat(data[pixel + 1]) / 255 * 120) / 120,
                    green: round(CGFloat(data[pixel + 2]) / 255 * 120) / 120,
                    blue: round(CGFloat(data[pixel + 3]) / 255 * 120) / 120,
                    alpha: 1
                )
                
                imageColors.addObject(color)
            }
        }
        free(raw)
        
        // preprocess and filter colors that appear seldomly or close to black or white
        let enumerator = imageColors.objectEnumerator()
        let sortedColors = NSMutableArray(capacity: imageColors.count)
        while let kolor = enumerator.nextObject() as? UIColor {
            let colorCount = imageColors.countForObject(kolor)
            if 3 < colorCount && !kolor.bc_isBlackOrWhite {
                sortedColors.addObject(BCCountedColor(color: kolor, count: colorCount))
            }
        }
        sortedColors.sortUsingComparator(sortedColorComparator)
        
        // get the background colour
        var backgroundColor: BCCountedColor
        if 0 < sortedColors.count {
            backgroundColor = sortedColors.objectAtIndex(0) as! BCCountedColor
        } else {
            backgroundColor = BCCountedColor(color: blackColor, count: 1)
        }
        result.backgroundColor = backgroundColor.color
        
        // create theme colors, contrast theme color with background color in lightness, and select cognizable chromatic aberration among theme colors
        let isDarkBackgound = result.backgroundColor.bc_isDark
        for curContainer in sortedColors {
            let kolor = (curContainer as! BCCountedColor).color
            if (kolor.bc_isDark && isDarkBackgound) || (!kolor.bc_isDark && !isDarkBackgound) {continue}
            
            if result.primaryColor == nil {
                if kolor.bc_isContrasting(result.backgroundColor) {
                    result.primaryColor = kolor
                }
            } else if result.secondaryColor == nil {
                if result.primaryColor.bc_isDistinct(kolor) && kolor.bc_isContrasting(result.backgroundColor) {
                    result.secondaryColor = kolor
                }
            } else if result.minorColor == nil {
                if result.secondaryColor.bc_isDistinct(kolor) && result.primaryColor.bc_isDistinct(kolor) && kolor.bc_isContrasting(result.backgroundColor) {
                    result.minorColor = kolor
                    break
                }
            }
        }
        
        if result.primaryColor == nil {
            result.primaryColor = isDarkBackgound ? whiteColor:blackColor
        }
        if result.secondaryColor == nil {
            result.secondaryColor = isDarkBackgound ? whiteColor:blackColor
        }
        if result.minorColor == nil {
            result.minorColor = isDarkBackgound ? whiteColor:blackColor
        }
        
        return result
    }
    
    public func bc_monochrome() -> UIImage {
        let originalImage = CoreImage.CIImage(image: self)
        let filter = CIFilter(name: "CIPhotoEffectMono")
        filter!.setDefaults()
        filter!.setValue(originalImage, forKey: kCIInputImageKey)
        let outputImage = filter!.outputImage
        return UIImage(CIImage: outputImage!)
    }
}
