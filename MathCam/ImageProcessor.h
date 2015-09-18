//
//  ImageProcessor.h
//  MathCam
//
//  Created by Achintya Gopal on 4/11/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageProcessor : NSObject

@property (nonatomic) UIImage *cropped;

-(instancetype)initWithImage: (UIImage *)croppedImage;

-(NSString *)makeImageBlackAndWhite;

@end
