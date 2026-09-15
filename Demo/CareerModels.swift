//
//  CareerModels.swift
//  Demo
//
//  Created by 汤磊 on 2026/7/10.
//

// 表1：学科大类
struct SubjectArea: TableRecord, FetchableRecord {
    var areaId: Int64
    var areaName: String
    
    static let databaseTableName = "SubjectArea"
    
    init(row: GRDB.Row) throws {
        areaId = row["areaId"]
        areaName = row["areaName"]
    }
}
