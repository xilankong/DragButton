//
//  DragButton.swift
//  自动拖拽吸附悬浮块
//
//  Created by yanghuang on 16/12/5.
//  Copyright © 2016年 yanghuang. All rights reserved.
//

import UIKit

class DragButton: UIButton {
    
    typealias btnClosure = (_ btn : DragButton) ->()
    
    let DOUBLE_CLICK_TIME = 0.1
    let ANIMATION_DURATION_TIME = 0.2
    
    //是否拖拽中
    var isDragging : Bool?
    //是否可拖拽
    var draggable : Bool?
    //是否自动吸附
    var autoDocking : Bool?
    //是否单击被取消(比如双击或者拖拽取消掉单击事件)
    var singleClickBeenCancled : Bool?
    //拖拽开始center
    var beginLocation : CGPoint?
    //长按手势
    var longPressGestureRecognizer : UILongPressGestureRecognizer?

    //单击回调
    var _clickClosure : btnClosure?
    var clickClosure : btnClosure? {
        get {
            return _clickClosure
        }
        set(newValue) {
            _clickClosure = newValue
            self.addTarget(self, action: #selector(buttonClick(_:)), for: UIControlEvents.touchUpInside)
        }
    }
    
    //双击回调
    var doubleClickClosure : btnClosure?
    //拖拽回调
    var draggingClosure : btnClosure?
    //拖拽结束回调
    var dragDoneClosure : btnClosure?
    //自动吸附结束回调
    var autoDockEndClosure : btnClosure?
    
    //MARK: - 初始化
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        draggable = true
        autoDocking = true
        singleClickBeenCancled = false
//        longPressGestureRecognizer =
//            UILongPressGestureRecognizer(target: self, action: #selector(gestureRecognizerHandle(_:)))
//        
//        guard let longPressGestureRecognizer = self.longPressGestureRecognizer else {
//            return
//        }
//        longPressGestureRecognizer.allowableMovement = 0
//        //添加长按事件
//        self.addGestureRecognizer(longPressGestureRecognizer)
    }

    //MARK: - 要区分开单双击
    func buttonClick(_ btn : DragButton) {
        
        let time : Double = doubleClickClosure == nil ? 0 : DOUBLE_CLICK_TIME
        self.perform(#selector(singleClickAction(_:)), with: nil, afterDelay: time)
    }
    
    //MARK:单击响应
    
    func singleClickAction(_ btn : DragButton) {
        //单击被取消 或者 拖拽、 无闭包都不执行
        guard let clickClosure = self.clickClosure,
            singleClickBeenCancled == false,
            isDragging == false else {
            return
        }
        clickClosure(self)
    }

    //MARK: - 长按，暂时不需要
//    func gestureRecognizerHandle(_ gestureRecognizer : UILongPressGestureRecognizer) {
//        switch gestureRecognizer.state {
//        case .began:
//            print("")//长按block
//            break
//        default:
//            break
//        }
//    }
    
    //MARK: - 拖拽开始
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false; //开始将dragging置为否
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first
        if touch?.tapCount == 2 {
            //截断单击
            singleClickBeenCancled = true
            //双击回调
            guard let doubleClickClosure = self.doubleClickClosure else {
                return
            }
            doubleClickClosure(self)
        } else {
            singleClickBeenCancled = false
        }
        beginLocation = touch?.location(in: self)
    }
    
    //MARK: - 拖拽过程
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if draggable! {
            isDragging = true
            let touch = touches.first
            let currentLocation : CGPoint = (touch?.location(in: self))!
            let offsetX : CGFloat = currentLocation.x - (beginLocation?.x)!
            let offsetY : CGFloat = currentLocation.y - (beginLocation?.y)!
            self.center = CGPoint(x: self.center.x+offsetX, y: self.center.y+offsetY)
            
            let superviewFrame : CGRect = (self.superview?.frame)!
            let frame = self.frame
            let leftLimitX = frame.size.width / 2.0
            let rightLimitX = superviewFrame.size.width - leftLimitX
            let topLimitY = frame.size.height / 2.0
            let bottomLimitY = superviewFrame.size.height - topLimitY
            
            if self.center.x > rightLimitX {
                self.center = CGPoint(x: rightLimitX, y: self.center.y)
            } else if self.center.x <= leftLimitX {
                self.center = CGPoint(x: leftLimitX, y: self.center.y)
            }
            
            if self.center.y > bottomLimitY {
                self.center = CGPoint(x: self.center.x, y: bottomLimitY)
            } else if self.center.y <= topLimitY{
                 self.center = CGPoint(x: self.center.x, y: topLimitY)
            }
            //拖拽回调
            guard let draggingClosure = self.draggingClosure else {
                return
            }
            draggingClosure(self)
        }
    }
    //MARK: - 拖拽结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event);
        //是否之前处于拖拽状态,单击之前不处于拖拽
        if isDragging! {
            
            singleClickBeenCancled = true
            //拖拽结束回调
            guard let dragDoneClosure = self.dragDoneClosure else {
                return
            }
            dragDoneClosure(self)
        }

        if isDragging! && autoDocking! {
            
            let superviewFrame : CGRect = (self.superview?.frame)!
            let frame = self.frame
            let middleX = superviewFrame.size.width / 2.0
            
            if self.center.x >= middleX {
                UIView.animate(withDuration: ANIMATION_DURATION_TIME, animations: { 
                     self.center = CGPoint(x: superviewFrame.size.width - frame.size.width / 2, y: self.center.y)
                    //自动吸附中
                }, completion: { _ in
                    //自动吸附结束回调
                    guard let autoDockEndClosure = self.autoDockEndClosure else {
                        return
                    }
                    autoDockEndClosure(self)
                })
            } else {
                
                UIView.animate(withDuration: ANIMATION_DURATION_TIME, animations: {
                    self.center = CGPoint(x:frame.size.width / 2, y: self.center.y)
                    //自动吸附中
                }, completion: { _ in
                    //自动吸附结束回调
                    guard let autoDockEndClosure = self.autoDockEndClosure else {
                        return
                    }
                    autoDockEndClosure(self)
                })
            }
        }
        isDragging = false
    }
    
    //MARK: - 拖拽取消
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
        super.touchesCancelled(touches, with: event)
    }
    
    
    //MARK: - 添加到keyWindow
    func addButtonToKeyWindow() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    //MARK: - 移除
    func removeFromKeyWindow() {
        for view : UIView in (UIApplication.shared.keyWindow?.subviews)! {
            if view.isKind(of: DragButton.classForCoder()) {
                view.removeFromSuperview()
            }
        }
    }
    
}
