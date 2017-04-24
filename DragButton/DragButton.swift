//
//  DragButton.swift
//  FingerPrintDemo
//
//  Created by yanghuang on 16/12/5.
//  Copyright © 2016年 yanghuang. All rights reserved.
//

import UIKit


class DragButton: UIButton {
    
    typealias btnClosure = (_ btn : DragButton) ->()
    
    let DOUBLE_CLICK_TIME = 0.36
    let ANIMATION_DURATION_TIME = 0.2
    
    //是否拖拽ing
    var isDragging : Bool?
    //是否单击被取消(比如双击或者拖拽取消掉单击事件)
    var singleClickBeenCancled : Bool?
    //拖拽开始center
    var beginLocation : CGPoint?
    //长按手势
    var longPressGestureRecognizer : UILongPressGestureRecognizer?
    //是否可拖拽
    var draggable : Bool?
    //是否自动吸附
    var autoDocking : Bool?
    
    //单击回调
    var _clickClosure : btnClosure?
    var clickClosure : btnClosure? {
        get {
            return _clickClosure
        }
        set(newValue) {
            guard (newValue != nil) else {
                return
            }
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.draggable = true;
        self.autoDocking = true;
        self.singleClickBeenCancled = false;
        self.longPressGestureRecognizer =
            UILongPressGestureRecognizer(target: self, action: #selector(gestureRecognizerHandle(_:)));
        self.longPressGestureRecognizer!.allowableMovement = 0;
        //添加长按事件
        self.addGestureRecognizer(self.longPressGestureRecognizer!);
        self.backgroundColor = UIColor.blue

    }
    
    //MARK: - 添加到keyWindow
    func addButtonToKeyWindow() {
        UIApplication.shared.keyWindow?.addSubview(self);
    }
    
    //MARK: - 要区分开单双击
    func buttonClick(_ btn : DragButton) {
        
        let time : Double = self.doubleClickClosure == nil ? 0 : DOUBLE_CLICK_TIME
        
        self.perform(#selector(singleClickAction(_:)), with: nil, afterDelay: time)
    }
    
    //MARK:单击响应
    
    func singleClickAction(_ btn : DragButton) {
        //单击被取消 或者 拖拽、 无闭包都不执行
//        print("singleClickAction" )
//        print(self.isDragging)
        guard (self.singleClickBeenCancled == false && self.isDragging == false && self.clickClosure != nil) else {
            return
        }
        self.clickClosure!(self);
    }

    //MARK: - 长按
    func gestureRecognizerHandle(_ gestureRecognizer : UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            print("")//长按block
            break
        default:
            break
        }
    }
    //MARK: - 拖拽开始
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDragging = false; //开始将dragging置为否
        super.touchesBegan(touches, with: event);
        
        let touch = touches.first;
        if touch?.tapCount == 2 {
            //截断单击
            self.singleClickBeenCancled = true;
            //双击回调
            guard (self.doubleClickClosure != nil) else {
                return
            }
            self.doubleClickClosure!(self);
        } else {
            self.singleClickBeenCancled = false;
//            print("touchesBegan" )
//            print(self.isDragging)
        }
        self.beginLocation = touch?.location(in: self);

    }
    //MARK: - 拖拽过程
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.draggable! {
            self.isDragging = true;
            let touch = touches.first;
            let currentLocation : CGPoint = (touch?.location(in: self))!
            let offsetX : CGFloat = currentLocation.x - (self.beginLocation?.x)!;
            let offsetY : CGFloat = currentLocation.y - (self.beginLocation?.y)!;
            self.center = CGPoint(x: self.center.x+offsetX, y: self.center.y+offsetY);
            
            let superviewFrame : CGRect = (self.superview?.frame)!;
            let frame = self.frame;
            let leftLimitX = frame.size.width / 2.0;
            let rightLimitX = superviewFrame.size.width - leftLimitX;
            let topLimitY = frame.size.height / 2.0;
            let bottomLimitY = superviewFrame.size.height - topLimitY;
            
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
            guard (self.draggingClosure != nil) else {
                return
            }
            self.draggingClosure!(self);
        }
    }
    //MARK: - 拖拽结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event);
        //是否之前处于拖拽状态,单击之前不处于拖拽
        if self.isDragging!{
            self.singleClickBeenCancled = true;
            //拖拽结束回调
            if self.dragDoneClosure != nil {
                self.dragDoneClosure!(self);
            }
        }

        if self.isDragging! && self.autoDocking! {
            let superviewFrame : CGRect = (self.superview?.frame)!;
            let frame = self.frame;
            let middleX = superviewFrame.size.width / 2.0;
            if self.center.x >= middleX {
                UIView.animate(withDuration: ANIMATION_DURATION_TIME, animations: { 
                     self.center = CGPoint(x: superviewFrame.size.width - frame.size.width / 2, y: self.center.y) ;
                    //自动吸附中
                }, completion: { (success) in
                    //自动吸附结束回调
                    guard (self.autoDockEndClosure != nil) else {
                        return
                    }
                    self.autoDockEndClosure!(self);
                })
                
            } else {
                
                UIView.animate(withDuration: ANIMATION_DURATION_TIME, animations: {
                    self.center = CGPoint(x:frame.size.width / 2, y: self.center.y);
                    //自动吸附中
                }, completion: { (success) in
                    //自动吸附结束回调
                    guard (self.autoDockEndClosure != nil) else {
                        return
                    }
                    self.autoDockEndClosure!(self);
                })
            }
        }
        self.isDragging = false;
//        print("touchesEnded" )
//        print(self.isDragging)
    }
    
    //MARK: - 拖拽取消
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isDragging = false;
        super.touchesCancelled(touches, with: event);
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
