//
// Copyright (c) 2018 Muukii <muukii.app@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import CoreImage

public protocol ImageRendererDelegate : class {

}

public final class ImageRenderer {

  public struct Edit {
    public var croppingRect: CGRect?
    public var modifiers: [Filtering] = []
    public var drawer: [GraphicsDrawing] = []
  }

  private let cicontext = CIContext(options: [
    .useSoftwareRenderer : false,
    .highQualityDownsample : true,
    ])
  
  public weak var delegate: ImageRendererDelegate?

  public let source: ImageSource

  public var edit: Edit = .init()

  public init(source: ImageSource) {
    self.source = source
  }

  public func render() -> UIImage {

    let resultImage: CIImage = {

      let targetImage = source.image
      let sourceImage: CIImage

      if var croppingRect = edit.croppingRect {
        croppingRect.origin.x.round(.up)
        croppingRect.origin.y.round(.up)
        croppingRect.size.width.round(.up)
        croppingRect.size.height.round(.up)
        croppingRect.origin.y = targetImage.extent.height - croppingRect.minY - croppingRect.height
        sourceImage = targetImage.cropped(to: croppingRect)
      } else {
        sourceImage = targetImage
      }

      let result = edit.modifiers.reduce(sourceImage, { image, modifier in
        return modifier.apply(to: image, sourceImage: sourceImage)
      })

      return result

    }()

    let canvasSize = resultImage.extent.size

    UIGraphicsBeginImageContextWithOptions(canvasSize, true, 1)

    let cgContext = UIGraphicsGetCurrentContext()!

    let cgImage = cicontext.createCGImage(resultImage, from: resultImage.extent, format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())!

    cgContext.saveGState()
    cgContext.translateBy(x: 0, y: resultImage.extent.height)
    cgContext.scaleBy(x: 1, y: -1)
    cgContext.draw(cgImage, in: CGRect(origin: .zero, size: resultImage.extent.size))
    cgContext.restoreGState()

    self.edit.drawer.forEach { drawer in
      drawer.draw(in: cgContext, canvasSize: canvasSize)
    }

    let image = UIGraphicsGetImageFromCurrentImageContext()!

    UIGraphicsEndImageContext()

    return image

  }
}

