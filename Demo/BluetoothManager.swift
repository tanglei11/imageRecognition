//
//  BluetoothManager.swift
//  Demo
//
//  Created by 汤磊 on 2026/7/9.
//

import Foundation
import CoreBluetooth

class BluetoothManager: NSObject {
    
    enum ConnectSate {
        case idle
        case waitingForBluetooth
        case scanning
        case connecting
        case discoveringService
        case discoveringCharacteristics
        case ready
        case disConnect(Error?)
        case failed(Error?)
    }
    
    static let shared = BluetoothManager()
    
    private var centralManager: CBCentralManager!
    private var state: ConnectSate = .idle {
        didSet {
            print("BLE State:", state)
        }
    }
    
    private var targetPeripheral: CBPeripheral?
    
    private override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue(label: "com.Taniel.blueTooth"))
    }
    
    func start() {
        switch centralManager.state {
        case .unknown, .resetting:
            state = .waitingForBluetooth
        case .unsupported:
            print("当前设备不支持 BLE")
        case .unauthorized:
            print("用户未授权蓝牙权限")
        case .poweredOff:
            print("蓝牙已关闭")
        case .poweredOn:
            startScan()
        @unknown default:
            print("未知蓝牙状态")
        }
    }
    
    func stopScan() {
        centralManager.stopScan()
        if let targetPeripheral = targetPeripheral {
            centralManager.cancelPeripheralConnection(targetPeripheral)
        }
        state = .idle
    }
}

// MARK: - Private

extension BluetoothManager {
    
    private func startScan() {
        state = .scanning
        
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
        print("开始扫描 BLE 服务")
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("蓝牙状态未知")
            state = .waitingForBluetooth
        case .resetting:
            print("蓝牙系统重置中")
            state = .waitingForBluetooth
        case .unsupported:
            print("设备不支持 BLE")
            state = .failed(nil)
        case .unauthorized:
            print("蓝牙未授权")
            state = .failed(nil)
        case .poweredOff:
            print("蓝牙关闭")
            state = .waitingForBluetooth
        case .poweredOn:
            startScan()
        @unknown default:
            print("未知状态")
            state = .waitingForBluetooth
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
//        let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
//        print("""
//              发现设备:
//              name: \(peripheral.name ?? localName ?? "unknown")
//              id: \(peripheral.identifier)
//              RSSI: \(RSSI)
//              services: \(serviceUUIDs ?? [])
//              """)
        guard let name = peripheral.name, name.localizedCaseInsensitiveContains("AirPods") else {
            return
        }
        
        print("🎧 发现目标设备：\(name)，信号强度：\(RSSI) dBm")
        stopScan()
        targetPeripheral = peripheral
        peripheral.delegate = self
        // 连接外设
        centralManager.connect(peripheral, options: nil)
        print("🔗 正在连接设备...")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ 连接成功，开始读取所有服务...\n")
        // 传 nil 表示读取设备的全部服务
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        print("❌ 连接失败：\(error?.localizedDescription ?? "未知错误")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("\n🔌 设备已断开连接")
        targetPeripheral = nil
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error = error {
            print("❌ 发现服务失败：\(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services, !services.isEmpty else {
            print("⚠️ 未读取到任何服务")
            return
        }
        
        print("📋 共发现 \(services.count) 个服务：")
        print("----------------------------------------")
        
        for (index, service) in services.enumerated() {
            print("\n[\(index+1)] 服务 UUID：\(service.uuid.uuidString)")
            print("    是否为主服务：\(service.isPrimary ? "是" : "否")")
            
            // 继续读取该服务下的所有特征（传 nil 读取全部）
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error = error {
            print("    ❌ 发现特征失败：\(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("    包含 \(characteristics.count) 个特征：")
        
        for char in characteristics {
            print("    └─ 特征 UUID：\(char.uuid.uuidString)")
            print("       权限属性：\(char.properties.description)")
            
            // 如果特征支持读，主动读取一次值
            if char.properties.contains(.read) {
                peripheral.readValue(for: char)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            print("       ⚠️ 读取值失败：\(error.localizedDescription)")
            return
        }
        
        if let data = characteristic.value, !data.isEmpty {
            print("       当前值：\(data as NSData)")
        }
    }
}

// MARK: - 给CBCharacteristicProperties拓展description计算属性
extension CBCharacteristicProperties {
    var description: String {
        var props: [String] = []
        if contains(.broadcast) { props.append("广播") }
        if contains(.read) { props.append("读") }
        if contains(.writeWithoutResponse) { props.append("无响应写") }
        if contains(.write) { props.append("有响应写") }
        if contains(.notify) { props.append("通知") }
        if contains(.indicate) { props.append("指示") }
        if contains(.authenticatedSignedWrites) { props.append("签名写") }
        if contains(.extendedProperties) { props.append("扩展属性") }
        return props.joined(separator: "、")
    }
}
