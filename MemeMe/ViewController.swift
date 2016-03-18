//
//  ViewController.swift
//  MemeMe
//
//  Created by Luppino, Angelo on 2/28/16.
//  Copyright © 2016 Angelo Luppino. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navbar: UIToolbar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    let hasCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    
    let imagePicker = UIImagePickerController()
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "Impact", size: 40)!,
        NSStrokeWidthAttributeName: -4
    ]
    
    var viewIsShifted = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        topTextField.contentVerticalAlignment = .Top
        topTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.contentVerticalAlignment = .Top
        bottomTextField.textAlignment = NSTextAlignment.Center
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "readjustConstraints", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        exportButton.enabled = false
        trashButton.enabled = false
        
        imagePicker.delegate = self
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
    }

    // ------------------------------------------------
    // ------------ Camera / Photo Library ------------
    // ------------------------------------------------
    
    @IBAction func tapCamera(sender: UIBarButtonItem) {
        let alertController = UIAlertController()
        let choosePhotoAction = UIAlertAction(title:"Photo Library", style:UIAlertActionStyle.Default) {
            action in self.dismissViewControllerAnimated(true, completion: nil)
            self.openCamera(false)
        }
        let takePhotoAction = UIAlertAction(title:"Take Photo", style:UIAlertActionStyle.Default) {
            action in self.dismissViewControllerAnimated(true, completion: nil)
            if (self.hasCamera) {
                self.openCamera(true)
            } else {
                self.alertNoCamera()
            }
        }
        let cancelAction = UIAlertAction(title:"Cancel", style:UIAlertActionStyle.Cancel) {
            action in self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(choosePhotoAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func openCamera(takeNewPhoto: Bool) {
        if (takeNewPhoto) {
            imagePicker.sourceType = .Camera
        } else {
            imagePicker.sourceType = .PhotoLibrary
        }
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
        dismissViewControllerAnimated(true, completion: didPickImage)
    }
    
    func didPickImage() {
        readjustConstraints()
        topTextField.hidden = false
        bottomTextField.hidden = false
        trashButton.enabled = true
        exportButton.enabled = true
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        readjustConstraints()
    }
    
    func readjustConstraints() {
        if let image = imageView.image {
            let imageRatio = image.size.width / image.size.height
            let viewRatio = imageView.frame.size.width / imageView.frame.size.height
            
            var y: CGFloat = 0
            var height: CGFloat = 0
            if (imageRatio >= viewRatio) {
                let scale = imageView.frame.size.width / image.size.width
                height = scale * image.size.height
                y = 0.5 * (imageView.frame.size.height - height)
            }
            
            topTextFieldConstraint.constant = y + 10
            bottomTextFieldConstraint.constant = -y - 10
        }
    }
    
    func alertNoCamera() {
        let alertController = UIAlertController()
        alertController.title = "No camera detected"
        let okAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.Default) {
            action in self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // ------------------------------------------------
    // ----------------- Text Fields ------------------
    // ------------------------------------------------
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        view.endEditing(true)
        readjustConstraints()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (!viewIsShifted) {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
            viewIsShifted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += getKeyboardHeight(notification)
        viewIsShifted = false
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    // ------------------------------------------------
    // ---------------- Export / Trash ----------------
    // ------------------------------------------------

    @IBAction func exportMeme(sender: UIBarButtonItem) {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imageView.image!, memedImage: generateMemedImage())
        
        self.presentViewController(UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil), animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        navbar.hidden = true
        toolbar.hidden = true
        let bgColor = view.backgroundColor
        view.backgroundColor = UIColor(white: 1, alpha: 0.0)
        
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, view.opaque, 0.0)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        navbar.hidden = false
        toolbar.hidden = false
        view.backgroundColor = bgColor
        
        return memedImage
    }
    
    @IBAction func trashMeme(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete Meme", message: "Are you sure you want to delete this meme?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (alert: UIAlertAction!) in
                self.imageView.image = nil
                self.topTextField.hidden = true
                self.topTextField.text = "TOP"
                self.bottomTextField.hidden = true
                self.bottomTextField.text = "BOTTOM"
                self.exportButton.enabled = false
                self.trashButton.enabled = false
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

