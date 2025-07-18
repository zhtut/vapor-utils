//
//  DataExtension.swift
//  UtilsCore
//
//  Created by tutuzhou on 2025/1/6.
//

import Foundation

public extension Data {
    var bytes: [UInt8] {
        withUnsafeBytes({ Array($0) })
    }
}
