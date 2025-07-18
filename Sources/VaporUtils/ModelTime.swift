//
//  ModelTime.swift
//  utils-core
//
//  Created by tutuzhou on 2025/1/11.
//

import Foundation
import Fluent

public protocol ModelTime: AnyObject {
    var createAt: Int { get set }
    var updateAt: Int { get set }
}

extension ModelTime {
    public func onCreateModel() {
        createAt = Date.timestamp
        updateAt = Date.timestamp
    }
    
    public func onUpdateModel() {
        updateAt = Date.timestamp
    }
}

extension SchemaBuilder {
    @discardableResult
    public func timeFields() -> Self {
        self.field("create_at", .int, .required)
            .field("update_at", .int, .required)
    }
}
