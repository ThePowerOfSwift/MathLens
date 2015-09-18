//
//  ViewController.m
//  MathCam
//
//  Created by Achintya Gopal on 3/30/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import "ViewController.h"
#import "Rectangle.h"
#import "RectangleView.h"
#import "CaptureSessionManager.h"
#import "LetterInfo.h"
#import "EquationInfo.h"
#import "ImageProcessor.h"
#import "SettingsViewController.h"
#import "SolutionViewController.h"

#import "G8RecognitionOperation.h"
#import "UIImage+G8Filters.h"
#import "G8Tesseract.h"
#import "G8Constants.h"
#import "G8TesseractParameters.h"

#include "opencv2/opencv.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/features2d.hpp"
#include "opencv2/core/types.hpp"

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //add camera view
    [self setCaptureManager:[[CaptureSessionManager alloc]init]];
    [[self captureManager] addStillImageOutput];
    [[self captureManager] addVideoPreviewLayer];
    CGRect layerRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44);
    [[[self captureManager]previewLayer]setBounds:layerRect];
    [[[self captureManager]previewLayer]setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    [[[self view] layer]addSublayer:[[self captureManager]previewLayer]];
    
    self.imageView = [[UIImageView alloc]init];
    [self.imageView setBounds:layerRect];
    [self.imageView setCenter:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    [self.view addSubview:self.imageView]; //index 1
    
    self.rectangleView = [[RectangleView alloc]initWithFrame:CGRectZero];
    [self.rectangleView setBounds:layerRect];
    [self.rectangleView setCenter:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    //[self.view addSubview:self.rectangleView];
    
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 120, 30)];
    [self setScanningLabel:tempLabel];
    [[self scanningLabel] setBackgroundColor:[UIColor clearColor]];
    [[self scanningLabel] setFont:[UIFont fontWithName:@"Courier" size:18.0]];
    [[self scanningLabel] setTextColor:[UIColor redColor]];
    [[self scanningLabel] setText: @"Scanning..."];
    [[self scanningLabel]setHidden:YES];
    [[self view] addSubview:[self scanningLabel]]; //index 2
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveImageToPhotoAlbum) name:kImageCapturedSuccessfully object:nil];
    
    //toolbar with three buttons
    UIToolbar *toolbar = [[UIToolbar alloc]init];
    toolbar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width,44);
    NSMutableArray *items = [[NSMutableArray alloc]init];
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fake = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil] ;
    [items addObject:[[UIBarButtonItem alloc]initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(getPhoto:)]];
    [items addObject:fake];
    [items addObject:flexSpace];
    [items addObject:fake];
    self.cameraButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scanButtonPressed:)];
    [items addObject:self.cameraButton];
    [items addObject:fake];
    [items addObject:flexSpace];
    [items addObject:fake];
    [items addObject:[[UIBarButtonItem alloc]initWithTitle:@"Calculate" style:UIBarButtonItemStylePlain target:self action:@selector(calculate:)]];
    [toolbar setItems:items animated:NO];
    [self.view addSubview:toolbar]; //index 9
    toolbar.layer.borderWidth = 2;
    toolbar.layer.borderColor = [[UIColor blueColor]CGColor];
    toolbar.translucent = false;
    
    //redo toolbar with 3 buttons
    
    //add info button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"?" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    //width and height should be same value
    button.frame = CGRectMake(self.view.frame.size.width - 60, 20, 50, 50);
    //Clip/Clear the other pieces whichever outside the rounded corner
    button.clipsToBounds = YES;
    //half of the width
    button.layer.cornerRadius = 50/2.0f;
    button.layer.borderColor=[UIColor blueColor].CGColor;
    button.layer.borderWidth=2.0f;

    [self.view addSubview:button]; //index 6
    
    //add settings
    //UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"\u2699" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)];
    UIImage *flash = [[UIImage imageNamed:@"flashlight.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIButton *flashLight = [UIButton buttonWithType:UIButtonTypeCustom];
    //[flashLight setTitle:@"Flash" forState:UIControlStateNormal];
    [flashLight setImage:flash forState:UIControlStateNormal];
    //[flashLight setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [flashLight addTarget:self action:@selector(flashLight) forControlEvents:UIControlEventTouchUpInside];
    //width and height should be same value
    flashLight.frame = CGRectMake(10, 20, 70, 50);
    //Clip/Clear the other pieces whichever outside the rounded corner
    flashLight.clipsToBounds = YES;
    //half of the width
    flashLight.layer.cornerRadius = 50/2.0f;
    flashLight.layer.borderColor=[UIColor blueColor].CGColor;
    flashLight.layer.borderWidth=2.0f;
    [self.view addSubview:flashLight]; //index 4
    
    UIButton *switchCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchCamera setTitle:@"Camera" forState:UIControlStateNormal];
    [switchCamera setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [switchCamera addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    //width and height should be same value
    switchCamera.frame = CGRectMake(self.view.frame.size.width/2 - 35, 20, 70, 50);
    //Clip/Clear the other pieces whichever outside the rounded corner
    switchCamera.clipsToBounds = YES;
    //half of the width
    switchCamera.layer.cornerRadius = 50/2.0f;
    switchCamera.layer.borderColor=[UIColor blueColor].CGColor;
    switchCamera.layer.borderWidth=2.0f;
    [self.view addSubview:switchCamera]; //index 5
    
    //check if camera exists
    if(![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
        [[self captureManager] addVideoInputFrontCamera:YES];
        switchCamera.enabled = false;
        switchCamera.layer.borderColor = [UIColor grayColor].CGColor;
        [switchCamera setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else{
        [[self captureManager] addVideoInputFrontCamera:NO];
    }
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        self.cameraButton.enabled = FALSE;
    }
    
    [[[self captureManager]captureSession]startRunning];
    
    UIRotationGestureRecognizer *rotGR = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotateImage:)];
    //rotGR.numberOfTouches = 2;
    self.image = NULL;
    //[self.view addGestureRecognizer:rotGR];
    
    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchImage:)];
    //[self.view addGestureRecognizer:pinchGR];
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveImage:)];
    panGR.minimumNumberOfTouches = 2;
    //[self.view addGestureRecognizer:panGR];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yourNotificationHandler:)
                                                 name:@"MODELVIEW DISMISS" object:nil];
    
    self.problemType = 0;
}

-(void)yourNotificationHandler:(NSNotification *)notice{
    self.problemType = [[notice object]intValue];
}

-(void)switchCamera{
    AVCaptureInput* currentCameraInput = [[[self captureManager]captureSession].inputs objectAtIndex:0];
    if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack){
        //[[[self captureManager]captureSession]stopRunning];
        [[self captureManager]addVideoInputFrontCamera:YES];
        //[[[self captureManager]captureSession]startRunning];
    }
    else{
        //[[[self captureManager]captureSession]stopRunning];
        [[self captureManager]addVideoInputFrontCamera:NO];
       // [[[self captureManager]captureSession]startRunning];
    }
    
}

-(void)flashLight{
    [[self captureManager]toggleFlashlight];
    
}

-(void)moveImage:(UIPanGestureRecognizer *)uigr{
    if (uigr.state == UIGestureRecognizerStateEnded)
    {
        CGPoint newCenter = CGPointMake(
                                        self.imageView.center.x + self.imageView.transform.tx,
                                        self.imageView.center.y + self.imageView.transform.ty);
        self.imageView.center = newCenter;
        
        CGAffineTransform theTransform = self.imageView.transform;
        theTransform.tx = 0.0f;
        theTransform.ty = 0.0f;
        self.imageView.transform = theTransform;
        
        return;
    }
    
    CGPoint translation = [uigr translationInView:self.imageView.superview];
    CGAffineTransform theTransform = self.imageView.transform;
    theTransform.tx = translation.x;
    theTransform.ty = translation.y;
    self.imageView.transform = theTransform;
}

-(void)rotateImage:(UIRotationGestureRecognizer *)recognize{
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, recognize.rotation);
    recognize.rotation = 0;
}

-(void)pinchImage: (UIPinchGestureRecognizer *)recognize{
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, recognize.scale, recognize.scale);
    recognize.scale = 1;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void)getPhoto:(UIBarButtonItem *)button{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker
                       animated:YES
                     completion:NULL];
    
    CGRect layerRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44);
    RectangleView *rect = [[RectangleView alloc]initWithFrame:CGRectZero];
    [rect setBounds:layerRect];
    [rect setCenter:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    [self.view addSubview:rect];//index 3
    
}

-(void)calculate:(UIBarButtonItem *)button{
    
    CGImageRef cgref = [self.image CGImage];
    CIImage *cim = [self.image CIImage];
    if(cim == nil && cgref == NULL){
        //if no image
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"No image chosen"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
    else{
        Rectangle *rectangle = NULL;
        for(UIView *v in [self.view subviews]){
            if([v isKindOfClass:[RectangleView class]]){
                for(Rectangle *s in [(RectangleView *)v finished]){
                    rectangle = s;
                }
            }
        }
    
        UIImage *croppedImage;
        if(rectangle == NULL){
            croppedImage = self.image;
        }
        else{
            CGRect rect = CGRectMake(rectangle.begin.x , rectangle.begin.y, (rectangle.end.x - rectangle.begin.x),(rectangle.end.y - rectangle.begin.y));
            UIGraphicsBeginImageContext(self.view.frame.size);
            CGContextRef c = UIGraphicsGetCurrentContext();
            [self.imageView.layer renderInContext:c];
            croppedImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            CGImageRef imageRef = CGImageCreateWithImageInRect([croppedImage CGImage], rect);
            croppedImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        
        ImageProcessor *imageProcessing = [[ImageProcessor alloc]initWithImage:croppedImage];
        NSString *stringResult = [imageProcessing makeImageBlackAndWhite];
        NSLog(@"%@", stringResult);
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Solution" message:stringResult delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        
        //code to add after step by step solutions added
        
        SolutionViewController *solutionView;
        solutionView.problem = stringResult;
        solutionView.problemType = self.problemType;
        solutionView = [[SolutionViewController alloc]init];
         
    }
}

-(void)showInfo:(UIBarButtonItem *)button{
    SettingsViewController *settings = [[SettingsViewController alloc]init];
    settings.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    settings.problemType = self.problemType;
    [self presentViewController:settings animated:YES completion:nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    self.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    CGRect layerRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44);
    RectangleView *rect = [[RectangleView alloc]initWithFrame:CGRectZero];
    [rect setBounds:layerRect];
    [rect setCenter:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    [self.view addSubview:rect]; //index 3
    
}

-(void)scanButtonPressed:(UIBarButtonItem *)button{
    
    //CGImageRef cgref = [self.image CGImage];
    //CIImage *cim = [self.image CIImage];
    NSLog(@"camera button pressed");
    if((self.image == NULL)){
        //if no image
        //add still image to imageview
        //NSLog(@"Take picture");
        
        [[self scanningLabel]setHidden:NO];
        [[self captureManager]captureStillImage];

        self.imageView.image = [[self captureManager]stillImage];
        self.image = self.imageView.image;
        self.rectangleView.userInteractionEnabled = true;
        [self.view addSubview:self.rectangleView]; //index 3
        
    }
    else{
        //if image exists
        //NSLog(@"Give camera");
        NSLog(@"Remove image");
        for(UIView *v in [self.view subviews]){
            if([v isKindOfClass:[RectangleView class]]){
                [v removeFromSuperview];
            }
        }
        self.imageView.image = NULL;
        self.image = NULL;
        [self.view sendSubviewToBack:self.rectangleView];
    }
}

-(void)hideLabel: (UILabel *)label{
    [label setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveImageToPhotoAlbum
{
    NSLog(@"save image");
    self.imageView.image = [[self captureManager]stillImage];
    self.image = self.imageView.image;
    for(UIView *v in [self.view subviews]){
        if([v isKindOfClass:[CaptureSessionManager class]]){
            [v removeFromSuperview];
        }
    }
    
    CGRect layerRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44);
    RectangleView *rect = [[RectangleView alloc]initWithFrame:CGRectZero];
    [rect setBounds:layerRect];
    [rect setCenter:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    [self.view addSubview:rect]; //index 3
    [[self scanningLabel] setHidden:YES];

}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be scanned" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        [[self scanningLabel] setHidden:YES];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
