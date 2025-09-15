import FluentKit
import Vapor

/// 按照时间戳分页
public struct TimePagination<T: Content>: Content {
    /// 元素
    public var items: [T]
    /// 分页大小
    public var pageSize: Int?
    /// 总数
    public var total: Int?
    /// 最后一个的时间戳
    public var lastItemTime: Int?
    /// 是否升序
    public var ascending: Bool?
    /// 是否还有更多
    public var hasMore: Bool?
    
    /// 转换item的类型
    public func mapItems<O: Content>(transform: (T) -> O) -> TimePagination<O> {
        TimePagination<O>(
            items: items.map(transform),
            pageSize: pageSize,
            total: total,
            lastItemTime: lastItemTime,
            ascending: ascending,
            hasMore: hasMore
        )
    }
    
    public init(items: [T],
                pageSize: Int? = nil,
                total: Int? = nil,
                lastItemTime: Int? = nil,
                ascending: Bool? = nil,
                hasMore: Bool? = nil) {
        self.items = items
        self.pageSize = pageSize
        self.total = total
        self.lastItemTime = lastItemTime
        self.ascending = ascending
        self.hasMore = hasMore
    }
}

// MARK: - Request 扩展
public extension Request {
    func anyGet<D: Decodable>(_: D.Type = D.self, at path: CodingKeyRepresentable...) throws -> D {
        if let v = try? query.get(D.self, at: path) {
            return v
        }
        return try content.get(D.self, at: path)
    }
    
    var ascending: Bool? {
        let key = "ascending"
        if let asc = try? anyGet(Bool.self, at: key) {
            return asc
        }
        if let asc = try? anyGet(Int.self, at: key), asc == 1 {
            return true
        }
        return nil
    }
    
    var fromTime: Date? {
        let key = "fromTime"
        let timestamp = try? anyGet(Int.self, at: key)
        return timestamp?.date
    }
    
    var pageSize: Int? {
        let key = "pageSize"
        if let size = try? anyGet(Int.self, at: key), size > 0 {
            return min(size, 100) // 限制最大100条
        }
        return nil
    }
}

// MARK: - Model 扩展
public extension Model where Self: Content {
    
    static func timePagination(
        from query: QueryBuilder<Self>,
        fromTimeKeyPath: KeyPath<Self, FieldProperty<Self, Date>>,
        request: Request,
        defaultSize: Int = 20
    ) async throws -> TimePagination<Self> {
        
        var query = query
        
        // 设置排序方向
        let direction: DatabaseQuery.Sort.Direction
        if let asc = request.ascending {
            direction = asc ? .ascending : .descending
        } else {
            direction = .descending // 默认倒序
        }
        query.sort(fromTimeKeyPath, direction)
        
        // 处理时间过滤
        if let fromTime = request.fromTime {
            switch direction {
            case .ascending:
                query.filter(fromTimeKeyPath > fromTime)
            case .descending:
                query.filter(fromTimeKeyPath < fromTime)
            case .custom(let sendable):
                query.filter(fromTimeKeyPath < fromTime)
            }
        }
        
        // 获取实际页面大小
        let pageSize = request.pageSize ?? defaultSize
        let actualLimit = pageSize + 1 // 多取一条用于判断 hasMore
        
        // 执行查询
        let results = try await query
            .limit(actualLimit)
            .all()
        
        // 判断是否有更多数据
        let hasMore = results.count > pageSize
        
        // 截取实际需要的数据
        let items = Array(results.prefix(pageSize))
        
        // 获取最后一条的时间戳（用于下一页）
        let lastItemTime = items.last?[keyPath: fromTimeKeyPath].value
        
        // 计算总数（可选，如果性能要求高可以去掉）
        let total = try? await query.count()
        
        return TimePagination(
            items: items,
            pageSize: pageSize,
            total: total,
            lastItemTime: lastItemTime?.timestamp,
            ascending: request.ascending,
            hasMore: hasMore
        )
    }
}
