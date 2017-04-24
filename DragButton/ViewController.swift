//
//  ViewController.swift
//  DragButton
//
//  Created by yanghuang on 2017/4/24.
//  Copyright © 2017年 com.yang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var dragBtn : DragButton = {
        var dragBtn = DragButton(frame: CGRect(x: 0, y: 400, width: 50, height: 50))
        dragBtn.clickClosure = {
            [weak self]
            (dragBtn) in
            //单击回调
            self?.dragButtonClickAction(dragBtn)
        }
        dragBtn.doubleClickClosure = {
            [weak self]
            (dragBtn) in
            //双击回调
            self?.dragButtonDoubleClickAction(dragBtn)
        }
        dragBtn.draggingClosure = {
            [weak self]
            (dragBtn) in
            //拖拽回调
            self?.dragButtonDragingAction(dragBtn)
        }
        dragBtn.dragDoneClosure = {
            [weak self]
            (dragBtn) in
            //拖拽结束回调
            self?.dragButtonDragDoneAction(dragBtn)
        }
        dragBtn.autoDockEndClosure = {
            [weak self]
            (dragBtn) in
            //自动吸附回调
            self?.dragButtonAutoDockEndAction(dragBtn)
        }
        
        return dragBtn;
    }();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(dragBtn);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func dragButtonClickAction(_ btn : DragButton) {
        print("buttonClick")
    }
    
    func dragButtonDoubleClickAction(_ btn : DragButton) {
        print("buttonDoubleClick")
    }
    
    func dragButtonDragingAction(_ btn : DragButton) {
        print("buttonDraging")
    }
    func dragButtonAutoDockEndAction(_ btn : DragButton) {
        print("buttonAutoDockEnd")
    }
    func dragButtonDragDoneAction(_ btn : DragButton) {
        print("buttonDragDone")
    }

}

