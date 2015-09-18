//
//  CaptureSessionManager.m
//  AVCamera
//
//  Created by Achintya Gopal on 3/29/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

@implementation CaptureSessionManager

-(id)init{
    if((self = [super init])){
        [self setCaptureSession:[[AVCaptureSession alloc]init]];
    }
    return self;
}

-(void)addVideoPreviewLayer{
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc]initWithSession:[self captureSession]]];
    [[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
}

-(void)toggleFlashlight{
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device.torchMode == AVCaptureTorchModeOff)
    {
        [self.captureSession beginConfiguration];
        [device lockForConfiguration:nil];
        
        [device setTorchMode:AVCaptureTorchModeOn];
        
        [device unlockForConfiguration];
        [self.captureSession commitConfiguration];

    }
    else
    {        
        
        [self.captureSession beginConfiguration];
        [device lockForConfiguration:nil];
        
        [device setTorchMode:AVCaptureTorchModeOff];
        
        [device unlockForConfiguration];
        [self.captureSession commitConfiguration];

    }
   
}

/*-(void)addVideoInput{
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(videoDevice){
        NSError *error;
        AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if(!error){
            if([[self captureSession] canAddInput:videoIn]){
                [[self captureSession] addInput:videoIn];
            }
            else{
                NSLog(@"Couldn't add video input");
            }
        }
        else{
            NSLog(@"Couldn't create video input");
        }
    }
    else{
        NSLog(@"Couldn't create video capture device");
    }
}*/

-(void)addVideoInputFrontCamera:(BOOL)front{
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for(AVCaptureDevice *device in devices) {
        NSLog(@"Device name: %@",[device localizedName]);
        
        if([device hasMediaType:AVMediaTypeVideo]){
            if([device position] == AVCaptureDevicePositionBack){
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else{
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }

    NSError *error = nil;
    
    if(front){
        
        AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if(!error){
            if([[self captureSession] canAddInput:frontFacingCameraDeviceInput]){
                [[self captureSession] addInput:frontFacingCameraDeviceInput];
            }
            else{
                [self.captureSession removeInput:[self.captureSession.inputs objectAtIndex:0]];
                [[self captureSession] addInput:frontFacingCameraDeviceInput];
                NSLog(@"Couldn't add front facing video input");
            }
        }
    }
    else{
        AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if(!error){
            if([[self captureSession]canAddInput:backFacingCameraDeviceInput]){
                [[self captureSession] addInput:backFacingCameraDeviceInput];
            }
            else{
                [self.captureSession removeInput:[self.captureSession.inputs objectAtIndex:0]];
                [[self captureSession] addInput:backFacingCameraDeviceInput];
                NSLog(@"Couldn't add back facing video input");
            }
        }
    }
}

-(void) addStillImageOutput{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc]init]];
     NSDictionary *outputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
     [[self stillImageOutput] setOutputSettings:outputSettings];
     
     AVCaptureConnection *videoConnection = nil;
     for(AVCaptureConnection *connection in [[self stillImageOutput]connections]){
         for(AVCaptureInputPort *port in [connection inputPorts]){
             if([[port mediaType] isEqual:AVMediaTypeVideo]){
                 videoConnection = connection;
                 break;
             }
         }
         if(videoConnection) {
             break;
         }
     }
    
     [[self captureSession]addOutput:[self stillImageOutput]];
     
}

-(void) captureStillImage{
    AVCaptureConnection *videoConnection = nil;
    for(AVCaptureConnection *connection in [[self stillImageOutput]connections]){
        for(AVCaptureInputPort *port in [connection inputPorts]){
            if([[port mediaType] isEqual:AVMediaTypeVideo]){
                videoConnection = connection;
                break;
            }
        }
        if(videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", [self stillImageOutput]);
    [[self stillImageOutput]captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error){
        CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if(exifAttachments) {
            NSLog(@"attachments : %@", exifAttachments);
        }
        else{
            NSLog(@"no attachments");
        }
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *image2 = [[UIImage alloc]initWithData:imageData];
        
        
        [self setStillImage:image2];
        [[NSNotificationCenter defaultCenter]postNotificationName:kImageCapturedSuccessfully object:nil];
        
        
    }];
}

@end
