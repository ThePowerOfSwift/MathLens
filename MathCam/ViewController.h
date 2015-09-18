//
//  ViewController.h
//  MathCam
//
//  Created by Achintya Gopal on 3/30/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"
#import "RectangleView.h"

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (retain) CaptureSessionManager *captureManager;
@property (nonatomic, retain) UILabel *scanningLabel;
@property (nonatomic) UIBarButtonItem *cameraButton;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) RectangleView *rectangleView;
@property (nonatomic)UIImage *image;
@property (nonatomic) int problemType;

@end

