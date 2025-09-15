//
//  ModelTime.swift
//  utils-core
//
//  Created by tutuzhou on 2025/1/11.
//

import Foundation
import Fluent

/// 这几个的好处是可以自动更新
public protocol ModelTime: AnyObject {
    var createAt: Date? { get set }
    var updateAt: Date? { get set }
    var deleteAt: Date? { get set }
}

extension SchemaBuilder {
    @discardableResult
    public func timeFields() -> Self {
        self.field("create_at", .datetime)
            .field("update_at", .datetime)
            .field("delete_at", .datetime)
    }
}
