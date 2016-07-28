//
//  SwipeableCell.swift
//  SwipeableCellDelete
//
//  Created by Sujan Vaidya on 7/21/16.
//  Copyright © 2016 lftechnology. All rights reserved.
//

import UIKit

protocol SwipeableCellDelegate {
    func button1ClickedForAction(sender: UIButton)
    func button2ClickedForAction(sender: UIButton)
    func cellDidOpen(cell: UITableViewCell)
    func cellDidClose(cell: UITableViewCell)
}

class SwipeableCell: UITableViewCell {
    
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var myContentView: UIView!
    @IBOutlet var myTextLabel: UILabel!
    
    var panRecognizer: UIPanGestureRecognizer?
    var panStartPoint: CGPoint?
    var startingRightLayoutConstraintConstant: CGFloat?
    
    @IBOutlet var contentViewRightConstraint: NSLayoutConstraint?
    @IBOutlet var contentViewLeftConstraint: NSLayoutConstraint?

    let kBounceValue: CGFloat = 20.0
    
    var delegate: SwipeableCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SwipeableCell.panThisCell(_:)))
        guard let gesture = self.panRecognizer else { return }
        gesture.delegate = self
        self.myContentView.addGestureRecognizer(gesture)
    }
    
    func panThisCell(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began :
            self.panStartPoint = recognizer.translationInView(self.myContentView)
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint!.constant
            
        case .Changed :
            let currentPoint = recognizer.translationInView(self.myContentView)
            let deltaX = currentPoint.x - self.panStartPoint!.x
            var panningLeft = false
            
            if (currentPoint.x < self.panStartPoint!.x) {
                panningLeft = true
            }
            
            if (self.startingRightLayoutConstraintConstant == 0) {
                if (!panningLeft) {
                    let constant = max(-deltaX, 0)
                    if (constant == 0) {
                        self.resetConstraintConstantsToZero(true, notifyDelegateDidClose: false)
                    } else {
                        self.contentViewRightConstraint!.constant = constant
                    }
                } else {
                    let constant = min(-deltaX, self.buttonTotalWidth())
                    if (constant == self.buttonTotalWidth()) { 
                        self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: false)
                    } else {
                        self.contentViewRightConstraint!.constant = constant
                    }
                }
            } else {
                var adjustment = self.startingRightLayoutConstraintConstant! - deltaX
                if (!panningLeft) {
                    let constant = max(adjustment, 0)
                    if (constant == 0) {
                        self.resetConstraintConstantsToZero(true, notifyDelegateDidClose: false)
                    } else {
                        self.contentViewRightConstraint!.constant = constant
                    }
                } else {
                    let constant = min(adjustment, self.buttonTotalWidth())
                    if (constant == self.buttonTotalWidth()) {
                        self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: false)
                    } else {
                        self.contentViewRightConstraint!.constant = constant
                    }
                }
            }
            self.contentViewLeftConstraint!.constant = -self.contentViewRightConstraint!.constant
            
        case .Ended :
            if self.startingRightLayoutConstraintConstant == 0 {
                var halfOfButtonOne: CGFloat = CGRectGetWidth(self.button1.frame) / 2
                if self.contentViewRightConstraint!.constant >= halfOfButtonOne {
                    self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: true)
                }
                else {
                    self.resetConstraintConstantsToZero(true, notifyDelegateDidClose: true)
                }
            }
            else {
                var buttonOnePlusHalfOfButton2: CGFloat = CGRectGetWidth(self.button1.frame) + (CGRectGetWidth(self.button2.frame) / 2)
                if self.contentViewRightConstraint!.constant >= buttonOnePlusHalfOfButton2 {
                    self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: true)
                }
                else {
                    self.resetConstraintConstantsToZero(true, notifyDelegateDidClose: true)
                }
            }
            
        case .Cancelled :
            if self.startingRightLayoutConstraintConstant == 0 {
                self.resetConstraintConstantsToZero(true, notifyDelegateDidClose: true)
            }
            else {
                self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: true)
            }

        default :
            break
        }
    }
    
    func buttonTotalWidth() -> CGFloat {
        return CGRectGetWidth(self.frame) - CGRectGetMinX(self.button2.frame)
    }
    
    func resetConstraintConstantsToZero(animated: Bool, notifyDelegateDidClose notifyDelegate: Bool) {
        if (notifyDelegate) {
            self.delegate!.cellDidClose(self)
        }
        
        if self.startingRightLayoutConstraintConstant == 0 && self.contentViewRightConstraint!.constant == 0 {
            return
        }
        self.contentViewRightConstraint!.constant = -kBounceValue
        self.contentViewLeftConstraint!.constant = kBounceValue
        self.updateConstraintsIfNeeded(animated, completion: {(finished: Bool) -> Void in
            self.contentViewRightConstraint!.constant = 0
            self.contentViewLeftConstraint!.constant = 0
            self.updateConstraintsIfNeeded(animated, completion: {(finished: Bool) -> Void in
                self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint!.constant
            })
        })

    }
    
    func setConstraintsToShowAllButtons(animated: Bool, notifyDelegateDidOpen notifyDelegate: Bool) {
        if (notifyDelegate) {
            self.delegate!.cellDidOpen(self)
        }
        
        if self.startingRightLayoutConstraintConstant == self.buttonTotalWidth() && self.contentViewRightConstraint!.constant == self.buttonTotalWidth() {
            return
        }
        self.contentViewLeftConstraint!.constant = -self.buttonTotalWidth() - kBounceValue
        self.contentViewRightConstraint!.constant = self.buttonTotalWidth() + kBounceValue
        self.updateConstraintsIfNeeded(animated, completion: {(finished: Bool) -> Void in
            self.contentViewLeftConstraint!.constant = -self.buttonTotalWidth()
            self.contentViewRightConstraint!.constant = self.buttonTotalWidth()
            self.updateConstraintsIfNeeded(animated, completion: {(finished: Bool) -> Void in
                self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint!.constant
            })
        })

    }
    
    func updateConstraintsIfNeeded(animated: Bool, completion: (finished: Bool) -> Void) {
        var duration: Double = 0
        if animated {
        duration = 0.1
        }
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: {() -> Void in
            self.layoutIfNeeded()
            }, completion: completion)
    }
    
    @IBAction func button1Clicked(sender: UIButton) {
        self.delegate!.button1ClickedForAction(sender)
    }
    
    @IBAction func button2Clicked(sender: UIButton) {
        self.delegate!.button2ClickedForAction(sender)
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func openCell() {
        self.setConstraintsToShowAllButtons(false, notifyDelegateDidOpen: false)
    }
    
    func closeCell() {
        self.resetConstraintConstantsToZero(true, notifyDelegateDidClose: true)
    }
}
