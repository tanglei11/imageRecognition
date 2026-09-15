//
//  LoopBannerView.swift
//  Demo
//
//  Created by 汤磊 on 2026/7/16.
//

import UIKit

class LoopBannerView: UIView {
    
    // 原始图片数据
    private var originImageUrls: [String] = []
    // 轮播复用数组（首尾补图）[C, A, B, C, A]
    private var loopImageUrls: [String] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = self.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: "BannerCell")
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.edges.equalTo(0)
        }
    }
    
    func config(withImageUrls imageUrls: [String]) {
        guard !imageUrls.isEmpty else {
            return
        }
        
        originImageUrls = imageUrls
        loopImageUrls = [originImageUrls.last ?? ""] + originImageUrls + [originImageUrls.first ?? ""]
        collectionView.reloadData()
        DispatchQueue.main.async {
            self.collectionView.setContentOffset(CGPointMake(self.collectionView.bounds.width, 0), animated: false)
        }
    }
}

extension LoopBannerView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        loopImageUrls.count
        }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as! BannerCell
        cell.config(withUrl: loopImageUrls[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 120)
    }
    
    // 滑动停止判读边界
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = collectionView.bounds.width
        let offsetX = scrollView.contentOffset.x
        let totalWidth = pageWidth * CGFloat(loopImageUrls.count - 1)
        
        switch offsetX {
        case 0:
            scrollView.setContentOffset(CGPointMake(totalWidth - pageWidth, 0), animated: false)
        case totalWidth:
            scrollView.setContentOffset(CGPoint(x: pageWidth, y: 0), animated: false)
        default:
            break
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
}


// MARK: Banner Cell
class BannerCell: UICollectionViewCell {
    private lazy var imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func initUI() {
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { maker in
            maker.edges.equalTo(0)
        }
    }
    
    func config(withUrl url: String) {
        imgView.kf.setImage(with: URL(string: url))
    }
}
