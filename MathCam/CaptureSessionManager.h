//
//  CaptureSessionManager.h
//  AVCamera
//
//  Created by Achintya Gopal on 3/29/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

@interface CaptureSessionManager : NSObject{
    
}

@property(retain) AVCaptureVideoPreviewLayer *previewLayer;
@property(retain) AVCaptureSession *captureSession;

-(void)addVideoPreviewLayer;
-(void)addVideoInputFrontCamera: (BOOL)front;

@property (retain)AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) UIImage *stillImage;

-(void)toggleFlashlight;
-(void) addStillImageOutput;
-(void) captureStillImage;


@end
