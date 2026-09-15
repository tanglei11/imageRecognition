//
//  Study.swift
//  Demo
//
//  Created by 汤磊 on 2026/7/13.
//

import Foundation

class Animal {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    convenience init() {
        self.init(name: "", age: 18)
    }
    
    func eat() {
        print("吃")
    }
    
    deinit {
        print("父类销毁")
    }
}

class Cat: Animal {
    
    weak var master: Person?
    
    override func eat() {
        print("吃猫粮")
    }
    
    func dance() {
        print("猫在跳舞")
    }
    
    deinit {
        print("子类销毁")
    }
}

class Pid: Animal {
    
    override func eat() {
        print("吃猪食")
    }
    
    func sing() {
        print("猪在唱歌")
    }
}

struct Dog {
    var name: String
    var age: Int
    
}

class Person {
    var name: String
    var age: Int
    
    static var sex: Int = 1
    
    var cat: Cat?
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    func showInfo() {
        print("name:\(name), age:\(age), Sex:\(Person.sex)")
    }
    
    static func makeGuest(_ name: String) -> Person {
        return Person(name: name, age: 18)
    }
}

class student: Person {
    var score: Int
    
    init(name: String, age: Int, score: Int) {
        // 先给自己的属性初始化
        self.score = score
        // 再调用父类构造器
        super.init(name: name, age: age)
        // 最后可以修改父类属性
        self.name = "学生" + name
    }
}

enum Sex: Int {
    case man = 1
    case woman = 2
    
    // 枚举不能包含存储属性
//    var trueSex = "真是性别"
    
    // 枚举可以包含计算属性
    var sexStr: String {
        switch self {
        case .man:
            return "性别:男"
        case .woman:
            return "性别:女"
        }
    }
    
    // 可以包含方法
    func showSexStr() {
        print(sexStr)
    }
}

class NetworkManage {
    static let stared = NetworkManage()
    
    private init() {}
    
    var baseUrl = "http://www.baidu.com"
}
