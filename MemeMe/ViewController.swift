//
//  ViewController.swift
//  MemeMe
//
//  Created by Luppino, Angelo on 2/28/16.
//  Copyright © 2016 Angelo Luppino. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    let hasCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exportButton.enabled = false
        trashButton.enabled = false
    }


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
        let imagePicker = UIImagePickerController()
        if (takeNewPhoto) {
            imagePicker.sourceType = .Camera
        }
        self.presentViewController(imagePicker, animated: true, completion: nil)
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

}

