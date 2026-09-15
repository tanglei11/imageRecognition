//
//  ObjectCaptureController.swift
//  Demo
//
//  Created by 汤磊 on 2026/7/29.
//

import UIKit
import RealityKit
import PhotosUI
import ARKit

@available(iOS 17.0, *)
class ObjectCaptureController: UIViewController {

    // MARK: - UI 组件
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "物品3D重建"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "请选择物品多角度照片（建议≥10张）"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.isHidden = true
        return progress
    }()
    
    private let selectPhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("从相册选择照片", for: .normal)
        btn.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.layer.cornerRadius = 12
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return btn
    }()
    
    private let startReconstructButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("开始3D重建", for: .normal)
        btn.setImage(UIImage(systemName: "cube.transparent"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.isEnabled = false
        btn.alpha = 0.5
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return btn
    }()
    
    private let previewButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("查看3D模型", for: .normal)
        btn.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.isHidden = true
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return btn
    }()
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("取消重建", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.isHidden = true
        return btn
    }()
    
    // MARK: - 私有属性
    private var selectedImages: [UIImage] = []
    private var tempInputFolderURL: URL?
    private var reconstructedModelURL: URL?
    private var photogrammetrySession: PhotogrammetrySession?
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - UI 搭建
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(statusLabel)
        view.addSubview(progressView)
        view.addSubview(selectPhotoButton)
        view.addSubview(startReconstructButton)
        view.addSubview(previewButton)
        view.addSubview(cancelButton)
        
        [titleLabel, statusLabel, progressView,
         selectPhotoButton, startReconstructButton,
         previewButton, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 40),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            cancelButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            previewButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            previewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            previewButton.widthAnchor.constraint(equalToConstant: 200),
            previewButton.heightAnchor.constraint(equalToConstant: 50),
            
            selectPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            selectPhotoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            selectPhotoButton.heightAnchor.constraint(equalToConstant: 52),
            selectPhotoButton.bottomAnchor.constraint(equalTo: startReconstructButton.topAnchor, constant: -16),
            
            startReconstructButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            startReconstructButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            startReconstructButton.heightAnchor.constraint(equalToConstant: 52),
            startReconstructButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupActions() {
        selectPhotoButton.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        startReconstructButton.addTarget(self, action: #selector(handleStartReconstruct), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(handlePreviewModel), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(handleCancelReconstruct), for: .touchUpInside)
    }
    
    // MARK: - 按钮事件
    @objc private func handleSelectPhoto() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 200
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func handleStartReconstruct() {
        guard #available(iOS 17.0, *) else {
            return
        }
        
        guard let inputFolder = tempInputFolderURL,
              selectedImages.count >= 10 else {
            showAlert(message: "请至少选择10张有效照片")
            return
        }
        
        // 重置UI状态
        reconstructedModelURL = nil
        previewButton.isHidden = true
        progressView.isHidden = false
        progressView.progress = 0
        cancelButton.isHidden = false
        startReconstructButton.isEnabled = false
        selectPhotoButton.isEnabled = false
        statusLabel.text = "正在生成3D模型... 0%"
        
        // 模型输出路径
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("reconstructed_model.usdz")
        
        // 清理旧模型文件
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        do {
            var config = PhotogrammetrySession.Configuration()
            config.sampleOrdering = .unordered
            config.featureSensitivity = .normal
            
            let session = try PhotogrammetrySession(
                input: inputFolder,
                configuration: config
            )
            self.photogrammetrySession = session
            
            // 启动重建并监听结果
            Task {
                let request = PhotogrammetrySession.Request.modelFile(
                    url: outputURL
                )
                try session.process(requests: [request])
                
                for try await output in session.outputs {
                    await MainActor.run {
                        self.handleSessionOutput(output, outputURL: outputURL)
                    }
                }
            }
            
        } catch {
            resetUIAfterProcessing()
            showAlert(message: "启动重建失败：\(error.localizedDescription)")
        }
    }
    
    @objc private func handleCancelReconstruct() {
        photogrammetrySession?.cancel()
        photogrammetrySession = nil
        resetUIAfterProcessing()
        statusLabel.text = "重建已取消"
    }
    
    @objc private func handlePreviewModel() {
        guard let modelURL = reconstructedModelURL else { return }
        
        let previewVC = ModelPreviewController()
        previewVC.modelURL = modelURL
        let nav = UINavigationController(rootViewController: previewVC)
        present(nav, animated: true)
    }
    
    // MARK: - 重建会话输出处理
    @available(iOS 17.0, *)
    private func handleSessionOutput(_ output: PhotogrammetrySession.Output, outputURL: URL) {
    switch output {
        // 进度更新
        case .requestProgress(_, let fraction):
            progressView.progress = Float(fraction)
            statusLabel.text = "正在生成3D模型... \(Int(fraction * 100))%"
            
        // 单条请求完成，保存模型路径
        case .requestComplete(_, let result):
            if case .modelFile(let url) = result {
                reconstructedModelURL = url
            }
            
        // 重建失败（所有运行时错误都走这里）
        case .requestError(_, let error):
            let nsError = error as NSError
            print("=== 重建失败详情 ===")
            print("错误域: \(nsError.domain)")
            print("错误码: \(nsError.code)")
            print("完整错误: \(nsError)")
            
            DispatchQueue.main.async {
                self.resetUIAfterProcessing()
                self.showAlert(message: "重建失败：\(error.localizedDescription)\n错误码：\(nsError.code)")
            }
            
        // 整个会话处理完成
        case .processingComplete:
            resetUIAfterProcessing()
            if reconstructedModelURL != nil {
                statusLabel.text = "3D模型生成完成"
                previewButton.isHidden = false
            } else {
                statusLabel.text = "处理结束，但未生成模型"
            }
            
        // 会话被主动取消
        case .processingCancelled:
            resetUIAfterProcessing()
            statusLabel.text = "重建已取消"
            
        @unknown default:
            break
        }
    }
    
    // MARK: - 辅助方法
    private func savePhotosToTempFolder(_ images: [UIImage]) {
        // 清理旧临时文件夹
        if let oldFolder = tempInputFolderURL {
            try? FileManager.default.removeItem(at: oldFolder)
        }
        
        let fileManager = FileManager.default
        let inputDir = fileManager.temporaryDirectory
            .appendingPathComponent("photogrammetry_input", isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: inputDir, withIntermediateDirectories: true)
            tempInputFolderURL = inputDir
            
            for (index, image) in images.enumerated() {
                guard let imageData = image.jpegData(compressionQuality: 0.9) else { continue }
                let fileName = String(format: "photo_%04d.jpg", index)
                let fileURL = inputDir.appendingPathComponent(fileName)
                try imageData.write(to: fileURL)
            }
            
            statusLabel.text = "已选择 \(images.count) 张照片"
            startReconstructButton.isEnabled = images.count >= 10
            startReconstructButton.alpha = images.count >= 10 ? 1.0 : 0.5
            
        } catch {
            showAlert(message: "照片处理失败：\(error.localizedDescription)")
        }
    }
    
    private func resetUIAfterProcessing() {
        progressView.isHidden = true
        cancelButton.isHidden = true
        startReconstructButton.isEnabled = true
        selectPhotoButton.isEnabled = true
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - 相册多选代理
@available(iOS 17.0, *)
extension ObjectCaptureController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        selectedImages.removeAll()
        let group = DispatchGroup()
        
        for result in results {
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
            group.enter()
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                defer { group.leave() }
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self?.selectedImages.append(image)
                    }
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.savePhotosToTempFolder(self.selectedImages)
        }
    }
}
