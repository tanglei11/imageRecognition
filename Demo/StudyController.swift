//
//  StudyController.swift
//  Demo
//
//  Created by 汤磊 on 2026/7/13.
//

import UIKit

enum MyError: Error {
    case nullString
    case outOfRang
    case custom(String)
}

typealias SuccessBlock = () -> Void

class StudyController: UIViewController {
    
    private var blockArray = [() -> Void]()
    
    private var successStr = "成功"
    
    private var timer: Timer?
    
    private var block: (() -> Void)?
    
    private var age: Int = 34 {
        willSet(newValue) {
            Swift.print("newValue:\(newValue)")
        }
        didSet(oldValue) {
            Swift.print("oldValue:\(oldValue)")
        }
    }

    deinit {
        Swift.print("销毁")
    }
    
    private lazy var bannerView: LoopBannerView = {
        let bannerView = LoopBannerView(frame: .zero)
        return bannerView
    }()
    
   private lazy var collectionView: UICollectionView = {
        let layout = WaterfallLayout(config: .default)
        layout.delegate = self
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    let dataHeights: [CGFloat] = [120,180,150,220,130,190,140,170]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        Task {
            await fetchResult()
        }
//        let a = A()
//        a.test()
        
//        view.addSubview(bannerView)
//        bannerView.snp.makeConstraints { maker in
//            maker.top.equalTo(120)
//            maker.leading.equalTo(10)
//            maker.trailing.equalTo(-10)
//            maker.height.equalTo(120)
//        }
//        
//        view.addSubview(collectionView)
//        collectionView.snp.makeConstraints { maker in
//            maker.top.equalTo(bannerView.snp.bottom).offset(10)
//            maker.leading.trailing.bottom.equalTo(0)
//        }
//        
//        bannerView.config(withImageUrls: ["https://fargoodexpress.com/static/upload/image/20251110/1762764272964496.jpg", "https://img0.baidu.com/it/u=3761524248,3948578222&fm=253&fmt=auto&app=138&f=JPEG?w=1000&h=500", "https://www.lami100.com/uploads/211221/2-211221163625J4.jpg"])
        
        // 异步转同步，wait()信号量-1就立马阻塞线程了，要等异步任务完成执行signal()才恢复
        // value > 0 就是同时让几个线程进行， value = 1 就是只允许1个线程进来其他等待，做互斥锁， 都一个线程进来时wait()信号量1-1=0，立即执行该线程任务，然后第二个线程进来0-1=-1，阻塞等待，等第一个线程任务执行完成时signal()信号量+1,-1+1=0，唤醒下一个线程开始执行任务
//        let sem = DispatchSemaphore(value: 0)
//        
//        DispatchQueue.global().async {
//            print("请求1完成")
//            sem.signal()
//        }
//        
//        sem.wait()
//        print("往下执行")

        //
        
//        let group = DispatchGroup()
//        
//        group.enter()
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            print("任务1")
//            group.leave()
//        }
//        
//        group.enter()
//        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
//            print("任务2")
//            group.leave()
//        }
//        
//        group.notify(queue: .main) {
//            print("完成")
//        }
        
        // 用栅栏barrier必须自定义并行队列
//        let currentQueue = DispatchQueue(label: "com.Demo.current", attributes: .concurrent)
//        
//        currentQueue.async {
//            print("读取数据1")
//        }
//        
//        currentQueue.async(flags: .barrier) {
//            print("写数据")
//        }
//        
//        currentQueue.async {
//            print("读取数据2")
//        }
        
        
        
//        Task {
//            let data = try? await fetchData()
//            let safeData = SafeData()
//            await safeData.add()
//        }
        
//        let safeData = SafeData()
//        let queue = DispatchQueue(label: "com.Demo.current", attributes: .concurrent)
//        queue.async {
//            safeData.getCount()
//        }
//        
//        queue.async {
//            safeData.add()
//        }
//        
//        queue.async {
//            safeData.getCount()
//        }
        
//        let serialQueue = DispatchQueue(label: "com.Demo.serial")
//        serialQueue.async {
//
//        }
        
//        var x = 10, y = 20
//        
//        var s1 = "a", s2 = "b"
//        
//        swapValue(a: &x, b: &y)
//        swapValue(a: &s1, b: &s2)
//        
//        print("x:\(x), y:\(y)")
//        print("s1:\(s1), s2:\(s2)")
        
        // 拓展Extension:在不修改原有类/结构体/枚举/协议前提下，给类型添加新功能
        // 1.可以添加实例方法/类方法 2.计算属性 3.构造器 4.嵌套类型 5.遵循协议
        // 不可添加存储属性 属性观测器
        
        // 外部 do-catch捕获
//        do {
//            try checkText("")
//        } catch MyError.nullString {
//            print("字符串为空")
//        } catch {
//            print("其他错误:\(error)")
//        }
//        
//        if let result = try? checkText("") {
//            
//        } else {
//        }

//        let p = Person(name: "", age: 34)
//        let c = Cat()
//        p.cat = c
//        c.master = p
//        
//        timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] _ in
//            self?.doSomething()
//        })
        
//        doTaskAsync {
//            self.doSomething()
//        }
        
//        block = { [weak self] in
//            self?.doSomething()
//        }
        
//        doTaskAsync { [weak self] in
//            guard let self = self else {
//                return
//            }
//
//            print(self.successStr)
//        }
        
//        print(NetworkManage.stared.baseUrl)
//
//        // 父类指针指向子类对象，向上转换，自动的
//        let a: Animal = Cat()
//        let b: Animal = Pid()
//
//        // 向上转换可访问父类的属性和方法，多态,子类的方法隐藏
//        a.eat()
//        b.eat()
//
//        // 向下转换，手动转换 as? 可选最安全 as!慎用会崩溃
//        if let cat = a as? Cat {
//            cat.dance()
//        }
        
//        // 尾随闭包：闭包作为函数的最后一个参数，可写到函数括号外边，省略参数标签，语法糖更简介
//        doTask(times: 5) { index in
//            print("执行第\(index)次操作")
//        }
        
//        age = 35
//
//        // 结构体是值类型，传参和赋值时拷贝新值
//        let dog = Dog(name: "安安", age: 8)
//        var dog2 = dog
//        dog2.name = "小花"
//        print(dog.name, dog2.name)
//
//        // 类是引用类型，传参和赋值时拷贝地址，还是共享同一份数据
//        let person = Person(name: "小汤", age: 35)
//        let person2 = person
//        person2.name = "汤磊"
//        print(person.name, person2.name)
    }
    
    private func fetchResult() async {
        async let a = delay(3, result: "成功")
        async let b = delay(5, result: 666)
        
        let result: (String, Int) = await (a, b)
        print(result.0)
        print(result.1)
    }
    
    private func delay<T>(_ time: Int, result: T) -> T {
        sleep(UInt32(time))
        return result
    }
    
    private func fecthData(success: @escaping SuccessBlock) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            success()
        }
    }
    
    // throws 函数标记  thorw 函数内抛错
    func checkText(_ text: String) throws -> Bool {
        if text.isEmpty {
            throw MyError.nullString
        }
        return true
    }
    
    func doSomething() {}
    
    // 非逃逸闭包：在函数生命周期结束之前执行的闭包
    func doTask(times: Int, handleAction: (_ time: Int) -> Void) {
        for index in 0...times {
            handleAction(index)
        }
    }
    
    // 逃逸闭包: 闭包被保存时需要逃逸，escaping修饰
    func saveBlock(withBlock block: @escaping () -> Void)  {
        blockArray.append(block)
    }
    
    // 逃逸闭包：在函数生命周期结束之后执行的闭包
    func doTaskAsync(complete: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            complete()
        }
    }
}


// MARK: - 泛型
extension StudyController {
    
    // 泛型：不指定具体类型，用占位类型<T>替代，代码复用，避免写多个逻辑相同类型不同的方法
    func swapValue<T>(a: inout T, b: inout T) {
        let temp = a
        a = b
        b = temp
    }
}

extension StudyController: TestProtocol {
    var projectName: String {
        get {
            return "项目"
        }
        set {
            
        }
    }
}

extension String {
    var projectName: String {
        get {
            return "项目名:\(self)"
        }
        set(newValue) {
            
        }
    }
    
    func print() {
        Swift.print(self)
    }
    
    func hello() -> String {
        return "hello:\(self)"
    }
    
    var isEmptyStr: Bool {
        return self.isEmpty
    }
    
    init?(withNum num: Int) {
        return nil
    }
}

// 协议是方法、属性的规则模版，只申明不实现
// 协议只申明不实现，加AnyObject只能类遵守，一般用在代理回调，避免值类型拷贝，循环引用问题
protocol TestProtocol: AnyObject {
    var projectName: String { get set }
    func console()
}

// 可以协议拓展里默认实现
extension TestProtocol {
    
    func console() {
        Swift.print("打印")
    }
}

// ARC自动引用计数：Swift 自动管理类实例内存，自动帮你计算引用计数，不要手动alloc/release
// 只对类class 引用类型 生效
// 结构体、枚举、基本数据类型 值类型不参与ARC
// 一个对象被强引用时：引用计数+1
// 强引用断开、变量销毁：计数-1
// 当引用计数降到0，ARC自动销毁对象，释放内存、调用deinit析构方法
// 默认var/let 都是强引用 计数+1 只要用强引用指向，对象就不会销毁
// 弱引用 weak weak var obj: Person?  不增加引用计数 对象销毁后，自动置为nil weak只能修饰可选类型  避免循环引用
// 无主引用 unowned 同样不会增加引用计数 对象销毁后不会置nil，继续访问会野指针崩溃，不安全 不用可选
// 非逃逸闭包函数执行完毕就立即销毁了，不会被任何对象长期持有。没有双向强引用。因此不会造成循环引用
// 逃逸闭包作为函数参数，函数执行完毕闭包还会被外部保存、延迟调用(存到属性、全局变量、网络请求)是必须加escaping


// 内存安全：程序运行时，不会非法访问内存，不会野指针，不会数据竞争（多线程同一时间读写变量），不会内存泄露，访问内存始终合法、可控
// 1.编译时严格的类型校验 2.自动引用计数ARC 3.独占访问规则，不能同时读+写，会崩溃 4.值类型拷贝，各自独立内存，不会共享引用，项目篡改，天然线程安全，内存安全 5.可选类型if let/guard let 解包3·


// MARK: - 并发
extension StudyController {
    
    // GCD
    func gcdMethod() {
        DispatchQueue.global().async {
            // 异步执行
            DispatchQueue.main.async {
                // 主队列更新UI
            }
        }
        
        // 延迟处理
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            
        }
    }
    
    // Swift 新并发 async/await
    func fetchData() async throws -> Data {
        return Data()
    }
}

// 自动线程安全的引用类型，Swift里专门解决多线程数据竞争的引用类型，就是线程安全的class类型, 自带串行隔离，保证同一时间只有一个线程能访问内部属性和方法
class SafeData {
    var count = 0
    func add() {
        count += 1
    }
    func getCount() -> Int {
        return count
    }
}

// MARK: - inout
extension StudyController {
    
    // inout 用于让函数修改外部变量值的关键字，它实现了引用传递（传引用），而不是Swift默认的值传递
    func swapValues(_ a: inout Int, b: inout Int) {
        let temp = a
        a = b
        b = temp
    }
}

extension StudyController: UICollectionViewDataSource, UICollectionViewDelegate, WaterfallLayoutDelete {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataHeights.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemBlue
        cell.layer.cornerRadius = 8
        return cell
    }
    
    // 代理返回对应cell高度
    func waterfallLayout(_ layout: WaterfallLayout, itemWidth: CGFloat, indexPath: IndexPath) -> CGFloat {
        dataHeights[indexPath.item]
    }
}

// MARK: - Enum

extension StudyController {
    
    // 枚举：定义一组相关的固定常量集合，规范取值, 枚举不能被继承，不能有存储属性，可以用计算属性,可以添加方法
    enum Direction {
        case up
        case down
    }
    
    // 关联值：枚举成员绑定自定义数据，每个case可以带不同类型参数
    enum payType {
        case cash
        case wechatPay(String)
        case aliPay(Double)
    }
    
    func showPaytype() {
        let wechatPay = payType.wechatPay("1111")
        switch wechatPay {
        case .cash:
            print("现金")
        case .wechatPay(let account):
            print("卡号:\(account)")
        case .aliPay(let money):
            print("金额:\(money)")
        }
    }
}

// 存储属性：存数据，占内存，常量/变量，实实在在存值，只能用于结构体、类，枚举不能有存储属性
// 计算属性：不存数据，实时算，没有内存占用，靠getter/setter动态返回值， 可以用于类、结构体、枚举

struct People {
    var birthYear: Int
    
    var age: Int {
        get {
            return 2026 - birthYear
        }
        set(newValue) {
            birthYear = 2026 - newValue
        }
    }
    
}

// 属性观测器willSet/didSet，监听存储属性值的变化, 初始化赋值时不会触发，后续修改才会触发
// willSet:即将从旧值变成新值，获取新值 newValue
// didSet: 已经从旧值变成新值，获取旧值 oldValue， 在didSet里给自身赋值不会重复触发观测器，底层有判读


// 构造器：关键字init，类、结构体、枚举创建实例时，给所有存储属性初始化赋值的过程
// 结构体会自动生成成员构造器，类不会
// 构造器重载：一个类/结构体有多个init，参数个数，类型，标签不同即可
// 便利构造器convenience,必须调用本类其他构造器

// 内存安全：程序运行时，不会访问非法内存，不会野指针，不会数据竞争，不会内存泄漏，访问内存始终合法可控
// 1.严格的类型安全：编译期强类型校验 2.自动引用计算ARC：自动管理类的内存 3.独占访问规则：不能同时读写一个变量 4.值类型拷贝：数据各自独立，不会共享不会篡改


// ============================ Swift 面试题 ====================================
// Swift 优先推荐使用Struct,值类型无循环引用风险
// 优先推荐guard let,条件不满足直接return，避免嵌套
// == 两个等号调用Equatable协议的值相等判读
// === 用于引用类型，判读是否同一个对象（地址相同）
// 懒加载 lazy lazy var 用到的时候才初始化，只能var，不能let
// 访问权限：open > public > internal > fileprivate > private
// open: 模块外可继承、重写 public: 模块外可见可访问 internal(默认): 模块内可见可访问 fileprivate: 当前文件 private: 当前作用域
// ARC 自动引用计数，只用于引用类型class,stuct、enum不参与
// 新建对象引用计算+1，变量脱落作用域(变量出生在某个{}内，代码走到 } 之后，它就脱离了作用域)引用计数-1，计数为0时，对象释放调用deinit
// 三种引用：strong(let、var修饰)强引用，计数+1，weak弱引用，不增加计数，对象销毁后自动置nil,只能修饰可选，unowned无主引用，不增加计算，对象销毁后不会置nil，再访问野指针崩溃

// 循环引用场景：1.两个class相互持有，一端要改成weak修饰 2.class持有闭包，闭包捕获self

// weak为什么必须修饰可选类型？ 答：weak指向的对象销毁后，指针需要自动置为nil，nil是可选特有概念

// @MainActor标记代码必须在主线程执行，和GCD dispatchQueue.main.async 一致

// await 只能存在async函数内部

// enum 关联值：枚举成员绑定自定义数据，每个case可以带不同类型参数
// enum payType {
//    case cash
//    case wechatPay(String)
//    case aliPay(Double)
//}

// Any：可以代表任何类型(值类型+引用类型)  AnyObject:只能代表类实例(引用类型)

// Swift的派发方式：1.静态派发 Stuct、final class、static/class func、final func、private func；编译确定地址，性能最高，所以推荐用struct 2.动态派发 class 未 final、internal func 虚表派发 3.消息派发 @objc 走OC objc_msgSend,所以不需要继承优先选Struct,共享数据但是不需要继承用final class,性能高

// 如何避免隐式解包! 1.使用可选+guard解包 var user: User? guard let user = user else {} 2.构造器注入,初始化赋值 priater var user: User! init(withUser user: User) { self.user = user } 3.懒加载lazy lazy var user: user = { User() }()

// Swift对比OC优势 1.语法更简洁、可读性强 2.类型安全，强类型系统，可选类型杜绝空指针野指针大量崩溃，编译器拦截 3.值类型优先，struct、enum，天然规避循环引用问题，适合数据模型 4.面向协议编程POP，突破OC单继承限制 5.现代化特性：泛型、元组、闭包、async/await 6.编译优化更好，支持静态派发

// 如何优化Swift编译速度？减少泛型、避免过多协议扩展、合理使用final

// 项目中什么时候用 struct，什么时候用 class？ 优先使用stuct,如果需要使用共享同一份数据状态或者需要继承、重写时需要用class


protocol P {
    func test()
}

extension P {
    func test() {
        print("协议默认")
    }
}

class A: P, Container {
    typealias T = String
    
    func test() {
        print("A实现")
    }
    
    func add(_ t: String) {
        
    }
}

// 协议泛型
protocol Container {
    associatedtype T
    func add(_ t: T)
}

// 函数中泛型使用
extension StudyController: Container {
    typealias T = Int
    
    
    func swapValue<T>(_ a: inout T, _ b: inout T) {
        
    }
    
    func add(_ t: Int) {
        
    }
}
