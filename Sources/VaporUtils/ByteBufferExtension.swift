//
//  File.swift
//  
//
//  Created by zhtg on 2023/4/22.
//

import Vapor
import NIOCore

public extension ByteBuffer {
    
    /// ByteBuffer转成Data
    /// - Returns: 返回转成的data
    func requireData() throws -> Data {
        var byte = self
        guard let data = byte.readData(length: readableBytes) else {
            throw Abort(.internalServerError, reason: "转换byte为Data失败=)")
        }
        return data
    }
    
    /// ByteBuffer转成String
    /// - Returns: 返回转成的String
    func requireString() throws -> String {
        var byte = self
        guard let str = byte.readString(length: readableBytes) else {
            throw Abort(.internalServerError, reason: "转换byte为Data失败)")
        }
        return str
    }
    
    func readData() -> Data? {
        var byte = self
        return byte.readData(length: readableBytes)
    }
    
    func readString() -> String? {
        var byte = self
        return byte.readString(length: readableBytes)
    }
}

public extension Optional where Wrapped == ByteBuffer {
    
    /// ByteBuffer转成Data
    /// - Returns: 返回转成的data
    func requireData() throws -> Data {
        if let self {
            return try self.requireData()
        }
        throw Abort(.internalServerError, reason: "Optional解包失败，无法转为data")
    }
    
    /// ByteBuffer转成String
    /// - Returns: 返回转成的String
    func requireString() throws -> String {
        if let self {
            return try self.requireString()
        }
        throw Abort(.internalServerError, reason: "Optional解包失败，无法转为string")
    }
    
    func requireString(def: String) -> String {
        if let self, let str = self.readString() {
            return str
        }
        return  def
    }
}
