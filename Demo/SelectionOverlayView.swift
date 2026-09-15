//
//  SelectionOverlayView.swift
//  Demo
//
//  Created by 汤磊 on 2026/7/8.
//

import UIKit

protocol SelectionOverlayViewDelegate: AnyObject {
    func selectionOverlay(_ overlay: SelectionOverlayView, didCompleteSelection rect: CGRect)
}

class SelectionOverlayView: UIView {

    weak var delegate: SelectionOverlayViewDelegate?

    private var startPoint: CGPoint = .zero
    private var currentPoint: CGPoint = .zero
    private var isDragging = false

    private let selectionLayer = CAShapeLayer()
    private let animatedBorderLayer = CAShapeLayer()

    private let minimumSize: CGFloat = 20
    var selectionRect: CGRect?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupGestureRecognizer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayers() {
        selectionLayer.fillColor = UIColor.clear.cgColor
        selectionLayer.strokeColor = UIColor.white.cgColor
        selectionLayer.lineWidth = 2
        selectionLayer.lineDashPattern = [6, 4]
        layer.addSublayer(selectionLayer)

        animatedBorderLayer.fillColor = UIColor.clear.cgColor
        animatedBorderLayer.strokeColor = UIColor.white.cgColor
        animatedBorderLayer.lineWidth = 1
        animatedBorderLayer.shadowColor = UIColor.white.cgColor
        animatedBorderLayer.shadowOpacity = 1.0
        animatedBorderLayer.shadowRadius = 4
        animatedBorderLayer.isHidden = true
        layer.addSublayer(animatedBorderLayer)
    }

    private func setupGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)

        switch gesture.state {
        case .began:
            isDragging = true
            startPoint = location
            currentPoint = location
            updateSelectionPath()

        case .changed:
            currentPoint = location
            updateSelectionPath()

        case .ended, .cancelled:
            isDragging = false
            let rect = calculateSelectionRect()
            if rect.width >= minimumSize && rect.height >= minimumSize {
                selectionRect = rect
                delegate?.selectionOverlay(self, didCompleteSelection: rect)
            } else {
                reset()
            }

        default:
            break
        }
    }

    private func calculateSelectionRect() -> CGRect {
        let minX = min(startPoint.x, currentPoint.x)
        let minY = min(startPoint.y, currentPoint.y)
        let maxX = max(startPoint.x, currentPoint.x)
        let maxY = max(startPoint.y, currentPoint.y)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    private func updateSelectionPath() {
        let rect = calculateSelectionRect()
        let path = UIBezierPath(rect: rect)
        selectionLayer.path = path.cgPath
    }

    func startGlowAnimation() {
        selectionLayer.isHidden = true
        animatedBorderLayer.isHidden = false

        if let rect = selectionRect {
            let path = UIBezierPath(rect: rect)
            animatedBorderLayer.path = path.cgPath
        }

        animatedBorderLayer.strokeStart = 0
        animatedBorderLayer.strokeEnd = 1

        let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        glowAnimation.fromValue = 0.3
        glowAnimation.toValue = 1.0
        glowAnimation.duration = 0.8
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity
        glowAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animatedBorderLayer.add(glowAnimation, forKey: "glow")

        let pulseAnimation = CABasicAnimation(keyPath: "lineWidth")
        pulseAnimation.fromValue = 1
        pulseAnimation.toValue = 3
        pulseAnimation.duration = 0.8
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animatedBorderLayer.add(pulseAnimation, forKey: "pulse")
    }

    func reset() {
        startPoint = .zero
        currentPoint = .zero
        selectionRect = nil
        selectionLayer.path = nil
        animatedBorderLayer.path = nil
        animatedBorderLayer.removeAllAnimations()
        selectionLayer.isHidden = false
        animatedBorderLayer.isHidden = true
    }
}