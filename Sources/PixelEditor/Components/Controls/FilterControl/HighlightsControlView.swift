//
//  HighlightsControlView.swift
//  PixelEditor
//
//  Created by Hiroshi Kimura on 2018/10/19.
//  Copyright © 2018 muukii. All rights reserved.
//

import Foundation

import PixelEngine


open class HighlightsControlViewBase : FilterControlViewBase {
  
  public required init(context: PixelEditContext) {
    super.init(context: context)
  }
}

open class HighlightsControlView : HighlightsControlViewBase {
  
  open override var title: String {
    return L10n.editHighlights
  }
  
  private let navigationView = NavigationView()
  
  public let slider = StepSlider(frame: .zero)
  
  open override func setup() {
    super.setup()
    
    backgroundColor = Style.default.control.backgroundColor
    
    TempCode.layout(navigationView: navigationView, slider: slider, in: self)
    
    slider.mode = .plus
    slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    
    navigationView.didTapCancelButton = { [weak self] in
      
      self?.context.action(.revert)
      self?.pop()
    }
    
    navigationView.didTapSaveButton = { [weak self] in
      
      self?.context.action(.commit)
      self?.pop()
    }
  }
  
  open override func didReceiveCurrentEdit(_ edit: EditingStack.Edit) {
    
    slider.set(value: edit.filters.highlights?.value ?? 0, in: FilterHighlights.range)
    
  }
  
  @objc
  private func valueChanged() {
    
    let value = slider.transition(in: FilterHighlights.range)
    
    guard value != 0 else {
      context.action(.setFilter({ $0.highlights = nil }))
      return
    }
    
    var f = FilterHighlights()
    f.value = value
    context.action(.setFilter({ $0.highlights = f }))
  }
  
}
