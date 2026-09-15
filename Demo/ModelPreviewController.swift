//
//  ModelPreviewController.swift
//  Demo
//
//  Created by 汤磊 on 2026/7/29.
//

import UIKit
import RealityKit
import ARKit

class ModelPreviewController: UIViewController {

    var modelURL: URL!
    private var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupARView()
        loadReconstructedModel()
    }
    
    private func setupNavigationBar() {
        title = "3D模型预览"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(handleDismiss)
        )
    }
    
    private func setupARView() {
        arView = ARView(frame: .zero)
        arView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arView)
        
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadReconstructedModel() {
        do {
            let modelEntity = try ModelEntity.loadModel(contentsOf: modelURL)
            
            // 自动缩放到适合预览的尺寸（约0.3米）
            let bounds = modelEntity.visualBounds(relativeTo: nil)
            let maxDimension = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
            let scale = 0.3 / maxDimension
            modelEntity.scale = SIMD3<Float>(repeating: Float(scale))
            
            let anchor = AnchorEntity()
            anchor.addChild(modelEntity)
            arView.scene.addAnchor(anchor)
            
            // 开启交互手势：单指旋转、双指缩放/平移
            arView.installGestures([.scale, .rotation, .translation], for: modelEntity)
            
        } catch {
            showAlert(message: "模型加载失败：\(error.localizedDescription)")
        }
    }
    
    @objc private func handleDismiss() {
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
