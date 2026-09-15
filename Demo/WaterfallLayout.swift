//
//  WaterfallLayout.swift
//  Demo
//
//  Created by 汤磊 on 2026/7/16.
//

import UIKit

struct WaterfallLayoutConfig {
    /// 瀑布流列数
    var columnCount: Int = 2
    /// 行间距
    var lineSpacing: CGFloat = 10
    /// 列间距
    var interitemSpacing: CGFloat = 10
    /// sectionInsets
    var sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    static let `default` = Self()
}

protocol WaterfallLayoutDelete: AnyObject {
    func waterfallLayout(_ layout: WaterfallLayout, itemWidth: CGFloat, indexPath: IndexPath) -> CGFloat
}

class WaterfallLayout: UICollectionViewLayout {
    
    weak var delegate: WaterfallLayoutDelete?
    
    /// 配置信息
    private var config: WaterfallLayoutConfig = .default
    /// 缓存每个cell的布局属性
    private var attrsArr: [UICollectionViewLayoutAttributes] = []
    /// 记录每一列当前累计高度
    private var columnHeights: [CGFloat] = []
    /// 内容总高度
    private var totalContentHeight: CGFloat = 0
    
    init(config: WaterfallLayoutConfig) {
        super.init()
        self.config = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 布局前计算
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else {
            return
        }
        
        // 清空缓存
        attrsArr.removeAll()
        columnHeights.removeAll()
        totalContentHeight = 0
        
        // 初始化每列高度
        for _ in 0..<config.columnCount {
            columnHeights.append(config.sectionInsets.top)
        }
        
        // 单个cell的宽度
        let itemWidth = (collectionView.bounds.width - config.sectionInsets.left - config.sectionInsets.right - CGFloat(config.columnCount - 1) * config.interitemSpacing) / CGFloat(config.columnCount)
        
        // 遍历所有cell
        let itemCount = collectionView.numberOfItems(inSection: 0)
        for index in 0..<itemCount {
            let indexPath = IndexPath(item: index, section: 0)
            // 外部代理获取cell高度
//            guard let delegate = collectionView.delegate as? WaterfallLayoutDelete else {
//                return
//            }
            
            guard let delegate = delegate else {
                return
            }
            
            let itemHeight = delegate.waterfallLayout(self, itemWidth: itemWidth, indexPath: indexPath)
            
            // 找到高度最小的列
            var minCol = 0
            var minHeight = columnHeights[minCol]
            for (i, columnHeight) in columnHeights.enumerated() {
                if columnHeight < minHeight {
                    minCol = i
                    minHeight = columnHeight
                }
            }
            
            // 计算x/y坐标
            let x = config.sectionInsets.left + CGFloat(minCol) * (itemWidth + config.interitemSpacing)
            let y = minHeight
            
            // 创建布局属性
            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attr.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            attrsArr.append(attr)
            
            // 更新该列总高度
            columnHeights[minCol] = y + itemHeight + config.lineSpacing
        }
        
        // 最高列高度即总高度，加上底部边距
        totalContentHeight = (columnHeights.max() ?? 0) + config.sectionInsets.bottom
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }
        
        return CGSize(width: collectionView.bounds.width, height: totalContentHeight)
    }
    
    // 返回屏幕可视区域内所有cell布局
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArr.filter({ $0.frame.intersects(rect) })
    }
    
    // 根据indexPath获取单个cell布局
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attrsArr[indexPath.item]
    }
}
