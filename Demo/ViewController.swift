//
//  ViewController.swift
//  Demo
//
//  Created by 汤磊 on 2026/7/7.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {

    private let selectButton = UIButton(type: .system)
    
    private lazy var studyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("学习", for: .normal)
        button.addTarget(self, action: #selector(handleStudy), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(studyButton)
        studyButton.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.equalTo(120)
            maker.height.equalTo(44)
        }
        
//        if let path = Bundle.main.path(forResource: "career_db", ofType: "sqlite") {
//            print("✅ 数据库文件存在，路径：\(path)")
//        } else {
//            print("❌ 数据库文件未找到，请检查导入和文件名大小写")
//        }
        
        
//        BluetoothManager.shared.start()
        
//        setupSelectButton()
    }
    
    deinit {
        BluetoothManager.shared.stopScan()
    }

    private func setupSelectButton() {
        selectButton.setTitle("选择图片", for: .normal)
        selectButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        selectButton.addTarget(self, action: #selector(selectImageTapped), for: .touchUpInside)
        view.addSubview(selectButton)
        selectButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(44)
        }
    }

    @objc private func selectImageTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func openPreview(with image: UIImage) {
        let previewVC = ImagePreviewViewController(image: image)
        navigationController?.pushViewController(previewVC, animated: true)
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first, result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self?.openPreview(with: image)
            }
        }
    }
}

extension ViewController {
    
    @objc private func handleStudy() {
//        let controller = StudyController()
//        navigationController?.pushViewController(controller, animated: true)
        
        if #available(iOS 17.0, *) {
            let controller = ObjectCaptureController()
            navigationController?.pushViewController(controller, animated: true)
        } else {
            // Fallback on earlier versions
        }
    }
}

//@available(iOS 17, *)
//#Preview {
//    UINavigationController(rootViewController: ViewController())
//}
