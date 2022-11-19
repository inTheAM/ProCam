//
//  ScrollViewOffset.swift
//  ProCam
//
//  Created by Ahmed Mgua on 19/11/22.
//

import SwiftUI

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
  static var defaultValue = CGFloat.zero

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value += nextValue()
  }
}
