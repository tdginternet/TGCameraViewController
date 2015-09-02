//
//  TGInitialViewController.swift
//  TGCameraSwift
//
//  Created by Lucas Farah on 8/26/15.
//  Copyright © 2015 Lucas Farah. All rights reserved.
//

import UIKit

class TGInitialViewController: UIViewController,TGCameraDelegate {

  @IBOutlet weak var photoView: UIImageView!
  
    override func viewDidLoad() {
        super.viewDidLoad()

      // save image at album
//      TGCamera.setOption(kTGCameraOptionSaveImageToAlbum, value: NSNumber(bool: true))
      
      // hidden toggle button
      //TGCamera.setOption(kTGCameraOptionHiddenToggleButton, value: NSNumber(bool: true))
      //TGCameraColor.setTintColor(UIColor.greenColor())
      
      // hidden album button
//      TGCamera.setOption(kTGCameraOptionHiddenAlbumButton, value: NSNumber(bool: true))
      
      // hide filter button
      //TGCamera.setOption(kTGCameraOptionHiddenFilterButton, value: NSNumber(bool: true))
      
      self.photoView.clipsToBounds = true

      let clearButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "clearTapped")
      
      self.navigationItem.rightBarButtonItem = clearButton;
    }
  
  //MARK: TGCameraDelegate optional
  func cameraWillTakePhoto()
  {

  }
  func cameraDidSavePhotoAtPath(assetURL: NSURL!)
  {
    
  }
  func cameraDidSavePhotoWithError(error: NSError!)
  {
    
  }
  
  //MARK: TGCameraDelegate required
  func cameraDidCancel()
  {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func cameraDidTakePhoto(image: UIImage!)
  {
    self.photoView.image = image;
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func cameraDidSelectAlbumPhoto(image: UIImage!)
  {
    self.photoView.image = image;
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  //MARK: Actions
  @IBAction func takePhotoTapped(sender: AnyObject)
  {
    let navigationController = TGCameraNavigationController.newWithCameraDelegate(self)
    self.presentViewController(navigationController, animated: true, completion: nil)
  }

  //MARK: Private Methods
  func clearTapped()
  {
    self.photoView.image = nil
  }

}
