//
//  ViewController.swift
//  MemeMe
//
//  Created by Luppino, Angelo on 2/28/16.
//  Copyright © 2016 Angelo Luppino. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var selectAPhotoLabel: UILabel!
    @IBOutlet weak var downArrowImage: UIImageView!
    @IBOutlet weak var stripesImage: UIImageView!
    
    
    let hasCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    
    let imagePicker = UIImagePickerController()
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "Impact", size: 40)!,
        NSStrokeWidthAttributeName: -4
    ]
    
    var memedImage: UIImage!
    
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
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func openCamera(takeNewPhoto: Bool) {
        if (takeNewPhoto) {
            imagePicker.sourceType = .Camera
        } else {
            imagePicker.sourceType = .PhotoLibrary
        }
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageView.image = image
        
        trashButton.enabled = true
        exportButton.enabled = true
        selectAPhotoLabel.hidden = true
        downArrowImage.hidden = true
        stripesImage.hidden = true
        
        dismissViewControllerAnimated(true, completion: didPickImage)
    }
    
    func didPickImage() {
        readjustConstraints()
        topTextField.hidden = false
        bottomTextField.hidden = false
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
        presentViewController(alertController, animated: true, completion: nil)
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
        if (bottomTextField.isFirstResponder()) {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
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
        memedImage = generateMemedImage()
        let avc = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        avc.completionWithItemsHandler = {(activityType, completed, returnedItems, activityError) in
            if (completed) {
                self.saveMeme()
                if (activityType == UIActivityTypeCopyToPasteboard) {
                    let alert = UIAlertController(title: "Success!", message: "Image copied", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else if (activityType == UIActivityTypeSaveToCameraRoll) {
                    let alert = UIAlertController(title: "Success!", message: "Image saved to camera roll", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        presentViewController(avc, animated: true, completion: nil)
    }
    
    func saveMeme() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imageView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        let topTextImage = textFieldToImage(topTextField)
        let bottomTextImage = textFieldToImage(bottomTextField)

        // Combine with original image
        UIGraphicsBeginImageContextWithOptions(imageView.image!.size, view.opaque, 0.0)
        imageView.image!.drawInRect(CGRect(x: 0, y: 0, width: imageView.image!.size.width, height: imageView.image!.size.height))
        let propHeight = (imageView.image!.size.width * topTextImage.size.height) / topTextImage.size.width
        topTextImage.drawInRect(CGRect(x: 0, y: 0, width: imageView.image!.size.width, height: propHeight))
        bottomTextImage.drawInRect(CGRect(x: 0, y: imageView.image!.size.height-propHeight, width: imageView.image!.size.width, height: propHeight))
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    func textFieldToImage(textField: UITextField) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(textField.bounds.size, false, 0.0)
        textField.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let textImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return textImage
    }
    
    @IBAction func trashMeme(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete Meme", message: "Are you sure you want to delete this meme?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (alert: UIAlertAction!) in
                self.imageView.image = nil
                self.topTextField.hidden = true
                self.topTextField.text = "TOP"
                self.bottomTextField.hidden = true
                self.bottomTextField.text = "BOTTOM"
                self.selectAPhotoLabel.hidden = false
                self.downArrowImage.hidden = false
                self.stripesImage.hidden = false
                self.exportButton.enabled = false
                self.trashButton.enabled = false
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

