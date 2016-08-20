//
//  ViewsMoveWithKeyBoardController.swift
//
//  Created by ameerkat on 16/8/16.
//
//  Any suggestion or question, please contact me: ameerkat81@gmail.com


import Foundation
import UIKit
/**
 The user of ViewsMoveWithKeyBoardController should implement this protocal.
 Suppose the user is ````exampleController````, the implement of each func should exactly be:
 ````
 func handleTouches(sender:UITapGestureRecognizer){
 exampleController?.handleTouches(sender)
 }
 
 func keyBoardWillShow(note:NSNotification){
 exampleController?.keyBoardWillShow(note)
 }
 
 func keyBoardWillHide(note:NSNotification)
 {
 exampleController?.keyBoardWillHide(note)
 }
 ````
 */
protocol NeedTheViewsMoveWithKeyBoardController {
    func handleTouches(sender:UITapGestureRecognizer)
    func keyBoardWillShow(note:NSNotification)
    func keyBoardWillHide(note:NSNotification)
}

/**
 ViewsMoveWithKeyBoardController control views move up and down together with keyboard.
 ## Usage Example ##
 In the viewcontroller who's using ViewsMoveWithKeyBoardController:
 ````
 var moveController:ViewsMoveWithKeyBoardController?
 
 override func viewDidLoad() {
 super.viewDidLoad()
 // Do any additional setup after loading the view, typically from a nib.
 let objects:[UIView] = [userIdTF,userpwdTF,signUpBtn,signInBtn,userPwdLabel,userIdLabel]
 moveController = ViewsMoveWithKeyBoardController(observerVc: self, objectsNeedsToMove: objects)
 ````
 Add protocal name to viewcontroller who's using ViewsMoveWithKeyBoardController.
 Then implenment the NeedTheViewsMoveWithKeyBoardController protocal.
 ````
 func handleTouches(sender:UITapGestureRecognizer){
 moveController?.handleTouches(sender)
 }
 
 func keyBoardWillShow(note:NSNotification){
 moveController?.keyBoardWillShow(note)
 }
 
 func keyBoardWillHide(note:NSNotification)
 {
 moveController?.keyBoardWillHide(note)
 }
 ````
 */
class ViewsMoveWithKeyBoardController {
    /// This is the reference of the viewcontroller who's using this ViewsMoveWithKeyBoardController, observer touches an recieving notification.
    weak var observerViewController:UIViewController?
    /// Default distance between the lowest view and keyboard.
    var distanceBetweenKeybordAndObject:Double = 70
    /// Contain views need to move together with keyboard.
    var objectsNeedsToMove:[UIView]!
    
    /**
     initializer, Don't Call!, call convenience initializer
     ## Important ##
     **Don't call this one to initialize! !**
     Call the convenience init to add NSNotifiacation Observer and TapGestureRecongnizer
     
     */
    init(observerVc: UIViewController, objects: [UIView]){
        self.observerViewController = observerVc
        objectsNeedsToMove = objects
    }
    
    /**
     convenience initializer
     */
    convenience init(observerVc: UIViewController,objectsNeedsToMove: [UIView]) {
        
        self.init(observerVc: observerVc, objects: objectsNeedsToMove)
        
        SetTapGestureRecongnizerAndObeserver()
        
    }
    /**
     convenience initializer (can set distance)
     */
    convenience init(observerVc: UIViewController,objectsNeedsToMove: [UIView], distanceBetweenLowestViewAndKeyBoard: Double) {
        
        self.init(observerVc: observerVc, objects: objectsNeedsToMove)
        distanceBetweenKeybordAndObject = distanceBetweenLowestViewAndKeyBoard
        
        SetTapGestureRecongnizerAndObeserver()
        
    }
    
    func SetTapGestureRecongnizerAndObeserver() {
        // add tapGestureRecongnizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: observerViewController, action: #selector(handleTouches(_:)))
        self.observerViewController!.view.addGestureRecognizer(tapGestureRecognizer)
        
        // add observer in NSNotificationCenter for KeyBoard
        NSNotificationCenter.defaultCenter().addObserver(observerViewController!, selector: #selector(keyBoardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyBoardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
    }
    
    @objc func handleTouches(sender:UITapGestureRecognizer){
        
        if sender.locationInView(observerViewController!.view).y < observerViewController!.view.bounds.height - 250{
            for object in objectsNeedsToMove {
                if object.classForCoder == UITextView.classForCoder()
                    || object.classForCoder == UITextField.classForCoder() {
                    object.resignFirstResponder()
                }
            }
        }
    }
    
    @objc func keyBoardWillShow(note:NSNotification){
        // Include: duration of animation and position, height of keyboard
        let userInfo  = note.userInfo!
        // position of keyboard
        let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        // duration pf animition
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        // distance objects will move
        let deltaY = keyBoardBounds.size.height - 70
        
        let animations:(() -> Void) = {
            
            for object in self.objectsNeedsToMove {
                object.transform = CGAffineTransformMakeTranslation(0,-deltaY)
            }
        }
        
        
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue:UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    @objc func keyBoardWillHide(note:NSNotification)
    {
        
        let userInfo  = note.userInfo!
        
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let animations:(() -> Void) = {
            for object in self.objectsNeedsToMove {
                object.transform = CGAffineTransformIdentity
            }
            
        }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue:UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
            
        }else{
            
            animations()
        }
    }
}
