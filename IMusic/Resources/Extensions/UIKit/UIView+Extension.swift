//
//  UIView+Extension.swift
//  IMusic
//
//  Created by user on 24/03/25.
//

import UIKit

extension UIView {
  class func loadFromNib<T: UIView>() -> T {
    return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil)![0] as! T
  }
}
