//
//  ImagePreviewViewController.swift
//  Demo
//
//  Created by 汤磊 on 2026/7/8.
//

import UIKit
import Vision

class ImagePreviewViewController: UIViewController {
    private let image: UIImage
    // MARK: - 核心视图
    /// 滚动缩放容器
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.delegate = self
        // 交互效果（与系统照片一致）
        scroll.bounces = true
        scroll.bouncesZoom = true
        scroll.alwaysBounceHorizontal = false
        scroll.alwaysBounceVertical = false
        // 隐藏滚动指示器
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    /// 图片显示视图（缩放用 frame 布局，符合 UIScrollView 缩放机制）
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    private lazy var doubleTap: UITapGestureRecognizer = {
        let doubleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDoubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        return doubleTap
    }()
    
    private lazy var singleTap: UITapGestureRecognizer = {
        let singleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleSingleTap(_:))
        )
        singleTap.numberOfTapsRequired = 1
        return singleTap
    }()
    private let pickButton = UIButton(type: .system)
    private let maskView = UIView()
    private let selectionOverlay = SelectionOverlayView()
    private let doubleTapZoomScale: CGFloat = 2.5
    private let zoomAnimationDuration: TimeInterval = 0.35

    private var isSelecting = false
    private var isSelectionCompleted = false

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupUI()
        setupGestures()
        setupMaskView()
        setupSelectionOverlay()
        setupPickButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 屏幕旋转/布局变化时重新计算缩放比例与居中
        updateZoomScaleLimits()
        centerImageInScrollView()
    }
    
    // 状态栏样式（与系统照片一致，隐藏时平滑淡出）
    override var prefersStatusBarHidden: Bool {
        navigationController?.isNavigationBarHidden ?? false
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }

    private func setupNavigationBar() {
        navigationItem.title = "图片预览"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = true
        extendedLayoutIncludesOpaqueBars = true
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        // SnapKit 约束：scrollView 铺满整个控制器视图
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.image = image
        // 初始 frame 设为图片真实尺寸，保证缩放清晰度
        imageView.frame = CGRect(origin: .zero, size: image.size)
        scrollView.contentSize = image.size
    }

    private func setupGestures() {
        // 双击缩放手势
        scrollView.addGestureRecognizer(doubleTap)
        
        // 单击隐藏/显示导航栏（贴近系统体验）
        singleTap.require(toFail: doubleTap)
        scrollView.addGestureRecognizer(singleTap)
    }

    private func setupPickButton() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        pickButton.setImage(UIImage(systemName: "crosshair", withConfiguration: imageConfig), for: .normal)
        pickButton.backgroundColor = .white
        pickButton.layer.cornerRadius = 20
        pickButton.layer.shadowColor = UIColor.black.cgColor
        pickButton.layer.shadowOpacity = 0.5
        pickButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        pickButton.layer.shadowRadius = 4
        pickButton.addTarget(self, action: #selector(pickButtonTapped), for: .touchUpInside)
        view.addSubview(pickButton)
        pickButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.width.height.equalTo(40)
        }
    }

    private func setupMaskView() {
        maskView.backgroundColor = .black.withAlphaComponent(0.5)
        maskView.isHidden = true
        maskView.isUserInteractionEnabled = false
        view.addSubview(maskView)
        maskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupSelectionOverlay() {
        selectionOverlay.isHidden = true
        view.addSubview(selectionOverlay)
        selectionOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        selectionOverlay.delegate = self
    }
    
    /// 计算最小/最大缩放比例
    func updateZoomScaleLimits() {
        let scrollBounds = scrollView.bounds.size
        let imageSize = image.size
        
        // 最小缩放比例：让图片完整显示在屏幕内（等比例适配）
        let widthFitScale = scrollBounds.width / imageSize.width
        let heightFitScale = scrollBounds.height / imageSize.height
        let minScale = min(widthFitScale, heightFitScale)
        
        // 最大缩放比例：参考系统照片，最小比例的3倍 或 原图1:1像素，取较大值
        let maxScale = max(minScale * 3, 1.0)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale
        // 默认以最小比例显示（完整预览）
        if scrollView.zoomScale < minScale || scrollView.zoomScale == 1.0 {
            scrollView.zoomScale = minScale
        }
    }
    
    /// 让图片在滚动视图中居中
    func centerImageInScrollView() {
        // 当图片尺寸小于滚动视图时，通过内边距实现居中
        let insetX = max(0, (scrollView.bounds.width - scrollView.contentSize.width) / 2)
        let insetY = max(0, (scrollView.bounds.height - scrollView.contentSize.height) / 2)
        scrollView.contentInset = UIEdgeInsets(
            top: insetY, left: insetX, bottom: insetY, right: insetX
        )
    }

    @objc private func pickButtonTapped() {
        if isSelectionCompleted {
            confirmSelection()
        } else {
            startSelection()
        }
    }

    private func startSelection() {
        isSelecting = true
        selectionOverlay.isHidden = false
        pickButton.isHidden = true
        doubleTap.isEnabled = false
        singleTap.isEnabled = false
    }

    private func completeSelection(with rect: CGRect) {
        isSelecting = false
        isSelectionCompleted = true
        disableScrollViewInteractions()
        selectionOverlay.isUserInteractionEnabled = false
        updateMaskView(with: rect)
        selectionOverlay.startGlowAnimation()
        updatePickButtonToConfirm()
    }

    private func disableScrollViewInteractions() {
        scrollView.isScrollEnabled = false
        scrollView.panGestureRecognizer.isEnabled = false
        if let pinchGesture = scrollView.pinchGestureRecognizer {
            pinchGesture.isEnabled = false
        }
        doubleTap.isEnabled = false
        singleTap.isEnabled = false
    }

    private func enableScrollViewInteractions() {
        scrollView.isScrollEnabled = true
        scrollView.panGestureRecognizer.isEnabled = true
        if let pinchGesture = scrollView.pinchGestureRecognizer {
            pinchGesture.isEnabled = true
        }
        doubleTap.isEnabled = true
        singleTap.isEnabled = true
    }

    private func updateMaskView(with selectionRect: CGRect) {
        maskView.isHidden = false

        let path = UIBezierPath(rect: view.bounds)
        let selectionPath = UIBezierPath(rect: selectionRect)
        path.append(selectionPath)
        path.usesEvenOddFillRule = true

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        maskView.layer.mask = maskLayer
    }

    private func updatePickButtonToConfirm() {
        pickButton.isHidden = false
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        pickButton.setImage(UIImage(systemName: "checkmark", withConfiguration: imageConfig), for: .normal)
    }

    private func confirmSelection() {
        guard let selectedRect = selectionOverlay.selectionRect else {
            return
        }
        recognizeNumbers(in: selectedRect)
    }

    private func recognizeNumbers(in rect: CGRect) {
        guard let cgImage = image.cgImage else {
            showResult(message: "未匹配到数字")
            return
        }

        let imageRectInImageView = scrollView.convert(rect, to: imageView)
        let zoomScale = scrollView.zoomScale

        let imageScale = image.size.width / CGFloat(cgImage.width)
        let imageRect = CGRect(
            x: imageRectInImageView.origin.x / zoomScale / imageScale,
            y: imageRectInImageView.origin.y / zoomScale / imageScale,
            width: imageRectInImageView.width / zoomScale / imageScale,
            height: imageRectInImageView.height / zoomScale / imageScale
        )

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                DispatchQueue.main.async {
                    self?.showResult(message: "未匹配到数字")
                }
                return
            }

            var totalSum = 0
            var foundNumbers = false

            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else {
                    continue
                }

                let textRect = observation.boundingBox
                let observationImageRect = CGRect(
                    x: textRect.origin.x * CGFloat(cgImage.width),
                    y: (1 - textRect.origin.y - textRect.height) * CGFloat(cgImage.height),
                    width: textRect.width * CGFloat(cgImage.width),
                    height: textRect.height * CGFloat(cgImage.height)
                )

                if observationImageRect.intersects(imageRect) {
                    let text = topCandidate.string
                    let numberPattern = try! NSRegularExpression(pattern: "\\d+", options: [])
                    let matches = numberPattern.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

                    for match in matches {
                        if let range = Range(match.range, in: text), let number = Int(text[range]) {
                            print("number:\(number)")
                            totalSum += number
                            foundNumbers = true
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                if foundNumbers {
                    self?.showResult(message: "数字总和: \(totalSum)")
                } else {
                    self?.showResult(message: "未匹配到数字")
                }
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        do {
            try requestHandler.perform([request])
        } catch {
            DispatchQueue.main.async {
                self.showResult(message: "未匹配到数字")
            }
        }
    }

    private func showResult(message: String) {
        let alert = UIAlertController(title: "识别结果", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            self?.resetSelection()
        })
        present(alert, animated: true)
    }

    private func resetSelection() {
        isSelecting = false
        isSelectionCompleted = false
        enableScrollViewInteractions()
        selectionOverlay.isUserInteractionEnabled = true
        maskView.isHidden = true
        maskView.layer.mask = nil
        selectionOverlay.reset()
        selectionOverlay.isHidden = true

        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        pickButton.setImage(UIImage(systemName: "crosshair", withConfiguration: imageConfig), for: .normal)
    }
}

// MARK: - 手势处理
extension ImagePreviewViewController {
    /// 双击缩放：点哪里放大哪里，再次双击还原
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.location(in: imageView)
        
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            // 当前为完整显示 → 放大2倍，以点击点为中心
            let zoomRect = calculateZoomRect(
                scale: scrollView.minimumZoomScale * 2,
                center: tapPoint
            )
            scrollView.zoom(to: zoomRect, animated: true)
        } else {
            // 当前为放大状态 → 还原到完整显示
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    /// 单击切换导航栏显示/隐藏
    @objc func handleSingleTap(_ gesture: UITapGestureRecognizer) {
        guard let nav = navigationController else { return }
        nav.setNavigationBarHidden(!nav.isNavigationBarHidden, animated: true)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    /// 根据缩放比例 + 中心点，计算缩放目标区域
    func calculateZoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        var rect = CGRect.zero
        rect.size.height = imageView.frame.height / scale
        rect.size.width = imageView.frame.width / scale
        rect.origin.x = center.x - rect.width / 2
        rect.origin.y = center.y - rect.height / 2
        return rect
    }
}

extension ImagePreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if isSelectionCompleted, let rect = selectionOverlay.selectionRect {
            updateMaskView(with: rect)
        }
        centerImageInScrollView()
    }
}

// MARK: - SelectionOverlayViewDelegate
extension ImagePreviewViewController: SelectionOverlayViewDelegate {
    func selectionOverlay(_ overlay: SelectionOverlayView, didCompleteSelection rect: CGRect) {
        completeSelection(with: rect)
    }
}

// MARK: - UIGestureRecognizerDelegate 手势共存
extension ImagePreviewViewController: UIGestureRecognizerDelegate {
    /// 允许自定义手势与 scrollView 内置手势同时识别
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
