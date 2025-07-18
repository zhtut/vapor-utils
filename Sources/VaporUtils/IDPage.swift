//
//  File.swift
//  
//
//  Created by shutut on 2022/10/25.
//

import FluentKit
import Vapor

/// 按照id分页
public struct IDPage<T: Content>: Content {
    public var items: [T]
    public var total: Int
    public var size: Int
    public var lastId: Int?

    /// 转换item的类型
    public func mapItems<O>(transform: (T) -> O) -> IDPage<O> {
        let newItems = items.map(transform)
        let new = IDPage<O>(items: newItems, total: total, size: size)
        return new
    }
    
    public init(items: [T], total: Int, size: Int, lastId: Int? = nil) {
        self.items = items
        self.total = total
        self.size = size
        self.lastId = lastId
    }
}

public extension Request {
    
    var ascending: Bool? {
        let key = "ascending"
        if let asc = try? query.get(Bool.self, at: key) {
            return asc
        }
        if let asc = try? content.get(Bool.self, at: key) {
            return asc
        }
        if let asc = try? query.get(Int.self, at: key),
           asc == 1 {
            return true
        }
        if let asc = try? content.get(Int.self, at: key),
           asc == 1 {
            return true
        }
        return nil
    }
    
    var lastId: Int? {
        let key = "lastId"
        var id = 0
        if let lastId = try? query.get(Int.self, at: key) {
            id = lastId
        }
        if let lastId = try? content.get(Int.self, at: key) {
            id = lastId
        }
        if id > 0 {
            return id
        }
        return nil
    }
    
    var size: Int? {
        let key = "size"
        var s = 0
        if let size = try? query.get(Int.self, at: key) {
            s = size
        }
        if let size = try? content.get(Int.self, at: key) {
            s = size
        }
        if s > 0 {
            return s
        }
        return nil
    }
}

public extension Model {
    
    static func idPage(from query: QueryBuilder<Self>,
                       id: KeyPath<Self, FieldProperty<Self, Int>>,
                       req: Request,
                       defaultSort: DatabaseQuery.Sort.Direction = .descending,
                       defaultSize: Int = 10) async throws -> IDPage<Self> where Self: Content {
        var query = query
        // 正序或者倒序
        var ascending: Bool
        switch defaultSort {
        case .ascending:
            ascending = true
        case .descending:
            ascending = false
        case .custom(_):
            ascending = false
        }
        if let asc = req.ascending {
            if asc {
                ascending = true
                query = query.sort(id, .ascending)
            } else {
                ascending = false
                query = query.sort(id, .descending)
            }
        } else {
            query = query.sort(id, defaultSort)
        }
        
        // total
        let total = try await query.count()
        
        // lastId
        let lastId = req.lastId
        if let lastId {
            if ascending {
                query.filter(id > lastId)
            } else {
                query.filter(id < lastId)
            }
        }
        
        // size
        let size = req.size ?? defaultSize
        let items = try await query
            .limit(size)
            .all()
        
        return IDPage(items: items, total: total, size: size, lastId: lastId)
    }
}
