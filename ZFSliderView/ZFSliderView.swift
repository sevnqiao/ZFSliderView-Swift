//
//  ZFSliderView.swift
//  ZFSliderView
//
//  Created by Xiong on 2018/3/8.
//  Copyright © 2018年 Xiong. All rights reserved.
//

import UIKit

typealias HandleClickItemViewBlock = (_ tag:Int) ->()

public enum ZFSliderViewAlignment : Int
{
    case sliderViewAlignmentJustified // justified justifying
    case sliderViewAlignmentLeft      // left justifying
}

protocol ZFSliderViewProtocol: NSObjectProtocol{
    func sliderView(sliderView:ZFSliderView, atIndex:Int)
}

class ZFSliderView: UIView{
// MARK: -  private 变量
    /// 底部滑动的 scrollview
    private var scrollView:UIScrollView?
    
    /// 存放子 itemView 的数组
    private var sliderItemViewArray:NSMutableArray = NSMutableArray.init()
    
    /// 底部指示标 view
    private var sliderBottomView:UIView?
    
// MARK: - public 变量
    /// 标题数据源
    public var itemArray:NSMutableArray?{
        didSet{
            self.createSliderItemView()
        }
    }
    
    /// 默认的标题颜色 default：lightGray
    public var normalItemColor:UIColor = UIColor.lightGray {
        didSet{
            self.createSliderItemView()
        }
    }
    
    /// 选中的标题颜色 default：red
    public var selectItemColor:UIColor = UIColor.red {
        didSet{
            self.createSliderItemView()
        }
    }
    
    /// itemview 的间距 default：30
    public var itemSpace:CGFloat = 30 {
        didSet{
            self.createSliderItemView()
        }
    }
    
    /// 从外部调整选中时需传入的位移量
    public var indexOffset:CGFloat = 0{
        didSet{
            self.updateItemView(index: indexOffset)
            self.updateBottomView(with: indexOffset)
        }
    }
    
    /// 标题的字体 default：UIFont.systemFont(ofSize: 14)
    public var titleFont:UIFont = UIFont.systemFont(ofSize: 14) {
        didSet{
            self.createSliderItemView()
        }
    }
    
    /// 底部指示标 view的颜色 default; red
    public var bottomViewColor:UIColor = UIColor.red {
        didSet{
            self.createSliderItemView()
        }
    }
    
    /// 底部指示标 view 的高度 default：5
    public var bottomViewHeight:CGFloat = 5 {
        didSet{
            self.createSliderItemView()
        }
    }
    
    /// 对齐方式 default：left
    public var sliderAlignment:ZFSliderViewAlignment = ZFSliderViewAlignment.sliderViewAlignmentLeft
    
    /// 协议
    weak open var delegate: ZFSliderViewProtocol?

// MARK: - 方法
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSubViews()
    }
    
    
    /// 初始化 scrollview  bottomView
    private func initSubViews() {
        scrollView = UIScrollView.init(frame: self.bounds)
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.showsVerticalScrollIndicator = false
        self.addSubview(scrollView!)
        
        sliderBottomView = UIView.init(frame: CGRect.zero)
        sliderBottomView?.backgroundColor = bottomViewColor
        sliderBottomView?.layer.masksToBounds = true
        scrollView!.addSubview(sliderBottomView!)
    }

    
    /// 创建 滑动的子 itemView
    private func createSliderItemView() {
        self.removeAllSubViews(targetView: scrollView!)
        self.sliderItemViewArray.removeAllObjects()
        
        for (value) in itemArray! {
            /// 初始化一个 itemView
            let itemView:ZFSliderItemView = ZFSliderItemView.init(frame: CGRect.zero)
            itemView.text = value as? String
            itemView.textAlignment = NSTextAlignment.center
            itemView.textColor = normalItemColor
            itemView.fillColor = selectItemColor
            itemView.isUserInteractionEnabled = true
            scrollView?.addSubview(itemView)
            sliderItemViewArray.add(itemView)
            
            /// 设置默认选中的 itemView
            let index:Int = itemArray!.index(of: value)
            if index == Int(self.indexOffset) {
                itemView.progress = 1
                itemView.font = UIFont.boldSystemFont(ofSize: titleFont.pointSize)
            }else {
                itemView.progress = 0
                itemView.font = self.titleFont
            }
            
            /// 设置 itemView 的 frame
            var width:CGFloat = 0
            var x:CGFloat = 0
            if sliderAlignment == ZFSliderViewAlignment.sliderViewAlignmentLeft
            {
                width = self.getStringWidth(string: itemView.text!) + itemSpace
            } else {
                width = self.frame.size.width / CGFloat((self.itemArray?.count)!)
            }
            if index > 0 {
                x = (sliderItemViewArray.object(at: index-1) as! ZFSliderItemView).frame.maxX
            }
            itemView.frame = CGRect.init(x: x, y: 0, width: width, height: self.frame.size.height)
            itemView.tag = index
            
            /// 设置 itemView 的点击事件
            itemView.handleClickItemViewBlock =  { (_ tag:Int) ->() in
                self.tapItemView(index: tag)
            }
        }
        /// 计算 scrollView 的 contenSize
        let maxX:CGFloat = (self.sliderItemViewArray.lastObject as! ZFSliderItemView).frame.maxX
        scrollView?.contentSize = CGSize.init(width: maxX, height: self.frame.size.height)
        
        /// 计算默认选中的 itemView 的底部 bottomView 的位置
        let sliderItemView:ZFSliderItemView = self.sliderItemViewArray.object(at: Int(self.indexOffset)) as! ZFSliderItemView
        let width:CGFloat = self.getStringWidth(string: sliderItemView.text!)
        sliderBottomView?.layer.cornerRadius = bottomViewHeight / 2
        sliderBottomView?.frame = CGRect.init(x: sliderItemView.frame.origin.x + width/2,
                                              y: frame.size.height-bottomViewHeight,
                                              width: sliderItemView.frame.size.width - width,
                                              height: bottomViewHeight)
    }
    
    /// 移除 scrollview 上的所有 itemView
    private func removeAllSubViews(targetView:UIScrollView) {
        for view in targetView.subviews {
            if view.isKind(of: ZFSliderItemView.classForCoder()) {
                view.removeFromSuperview()
            }
        }
    }
    
    /// 点击了某一个 itemView
    private func tapItemView(index:Int)  {
        UIView.animate(withDuration: 0.25) {
            self.indexOffset = CGFloat(index)
        }
    }
    
    /// 获取摸个字符串的宽度
    private func getStringWidth(string:String) -> (CGFloat) {
        let attributes = [NSAttributedStringKey.font:titleFont] as Any as? [NSAttributedStringKey : Any]
        let width:CGFloat = string.boundingRect(with: CGSize.init(width: Int(INT_MAX), height: 40),
                                            options: NSStringDrawingOptions.usesFontLeading,
                                            attributes:attributes,
                                            context: nil).width
        return width
    }
    
    /// 更新 itemView 的颜色和字体
    ///
    /// - Parameter index: 选中的 itemView 的 index
    private func updateItemView(index:CGFloat)  {
        
        let leftItem:ZFSliderItemView = self.sliderItemViewArray.object(at: Int(index)) as! ZFSliderItemView
        var rightItem:ZFSliderItemView!
        if (Int(index) < self.itemArray!.count - 1) {
            rightItem = self.sliderItemViewArray.object(at: Int(index + 1)) as! ZFSliderItemView
        }
        /// 恢复默认状态
        for (itemView) in sliderItemViewArray {
            (itemView as! ZFSliderItemView).textColor = normalItemColor
            (itemView as! ZFSliderItemView).fillColor = selectItemColor
            (itemView as! ZFSliderItemView).progress = 0
        }
        
        // 相对于屏幕的宽度
        let rightPageLeftDelta:CGFloat = index - CGFloat(Int(index))
        let progress:CGFloat = rightPageLeftDelta
        
        /// 设置选中状态
        leftItem.textColor = selectItemColor
        leftItem.fillColor = normalItemColor
        leftItem.progress = progress
        
        if rightItem != nil {
            rightItem.textColor = normalItemColor
            rightItem.fillColor = selectItemColor
            rightItem.progress = progress
        }
    }
    
    ///  更新底部 bottomView
    ///
    /// - Parameter index: 选中的 itemView 的位置
    private func updateBottomView(with index:CGFloat) {
        
        let a:Int = Int(index - CGFloat.leastNormalMagnitude)
        
        
        let progress:CGFloat = index - CGFloat(a)
        
        let currentItemView:ZFSliderItemView = sliderItemViewArray.object(at: a) as! ZFSliderItemView
        var nextItemView:ZFSliderItemView?
        
        if a < sliderItemViewArray.count - 1 {
            nextItemView = sliderItemViewArray.object(at: a + 1) as? ZFSliderItemView
        }
        
        var x:CGFloat = 0
        var w:CGFloat = 0
        if (a == 0 && progress < 0) || (a == sliderItemViewArray.count - 1 && progress > 0) {
            x = currentItemView.frame.minX + itemSpace / 2 + (currentItemView.frame.maxX - currentItemView.frame.minX) * progress
            w = currentItemView.frame.size.width - itemSpace + (currentItemView.frame.size.width - currentItemView.frame.size.width) * progress
        } else {
            var nextMaxX:CGFloat = 0
            var nextWidth:CGFloat = 0
            if  nextItemView != nil {
                nextMaxX = (nextItemView?.frame.minX)!
                nextWidth = (nextItemView?.frame.size.width)!
            }
            if progress < 0.5 {
                x = currentItemView.frame.minX + itemSpace / 2 + (nextMaxX - currentItemView.frame.minX) * progress - progress*itemSpace
                w = currentItemView.frame.size.width - itemSpace + (nextWidth - currentItemView.frame.size.width) * progress + progress * itemSpace * 2
            }else {
                x = currentItemView.frame.minX + itemSpace / 2 + (nextMaxX - currentItemView.frame.minX) * progress  - (1-progress) * itemSpace
                w = currentItemView.frame.size.width - itemSpace + (nextWidth - currentItemView.frame.size.width) * progress + (1-progress) * itemSpace * 2
            }
        }
        sliderBottomView?.frame = CGRect.init(x: x, y: frame.size.height - bottomViewHeight, width: w, height: bottomViewHeight)
        
        // 将选中的 itemView 移动到屏幕中间 延时调整
        self.perform(#selector(scrollSelectItemToMiddle(itemView:)), with: currentItemView, afterDelay: 0.3)
    }
    
    
    /// 移动 itemView 到屏幕中间
    ///
    /// - Parameter itemView: 选中的 itemView
    @objc private func scrollSelectItemToMiddle(itemView:ZFSliderItemView) {
        let offsetX:CGFloat = (frame.size.width - itemView.frame.size.width) / 2
        if itemView.frame.origin.x <= frame.size.width / 2 {
            scrollView?.setContentOffset(CGPoint.zero, animated: true)
        } else if itemView.frame.maxX >= ((scrollView?.contentSize.width)! - frame.size.width / 2) {
            scrollView?.setContentOffset(CGPoint.init(x: (scrollView?.contentSize.width)! - frame.size.width, y: 0), animated: true)
        } else {
            scrollView?.setContentOffset(CGPoint.init(x: itemView.frame.minX - offsetX, y: 0), animated: true)
        }
    }
}



class ZFSliderItemView: UILabel {
    
    public var fillColor:UIColor?
    var handleClickItemViewBlock:HandleClickItemViewBlock?
    
    public var progress:CGFloat = 0.0{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 重写 draw 绘制 label 的颜色
    ///
    /// - Parameter rect:  rect
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.fillColor?.set()
        var newRect:CGRect = rect
        newRect.size.width = rect.size.width * self.progress
        UIRectFillUsingBlendMode(newRect, CGBlendMode.sourceIn)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapG(tapG:)))
        self.addGestureRecognizer(tap)
    }
    
    
    /// 点击了当前的 itemView
    ///
    /// - Parameter tapG:  点击手势
    @objc private func tapG(tapG:UITapGestureRecognizer) {
        if ((handleClickItemViewBlock) != nil) {
            handleClickItemViewBlock!( self.tag)
        }
    }
}

