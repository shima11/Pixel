//
//  GPUImageView.swift
//  PixelEngine
//
//  Created by muukii on 10/9/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import Foundation

public protocol HardwareImageViewType : class {
  var image: CIImage? { get set }
}