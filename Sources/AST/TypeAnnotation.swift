//
//  TypeAnnotation.swift
//  compiler
//
//  Created by Jared Halpern on 5/19/25.
//

import Foundation

public enum TypeAnnotation: String {
  case int = "Int"
  case bool = "Bool"
  case string = "String"
  // TODO: case array(TypeAnnotation), case custom(String)
}

extension TypeAnnotation: CustomStringConvertible {
    public var description: String {
        return self.rawValue
    }
}
