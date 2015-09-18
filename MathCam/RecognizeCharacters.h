//
//  RecognizeCharacters.h
//  MathCam
//
//  Created by Achintya Gopal on 4/11/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RecognizeCharacters : NSObject

@property(nonatomic)UIImage *editedImage;
@property(nonatomic)UIImage *originalImage;
@property(nonatomic)NSMutableDictionary *blackPoints;
@property(nonatomic)int columns;

-(instancetype)initWithImage: (UIImage *)editedImage
           withOriginalImage: (UIImage *)original
                   withArray: (NSMutableDictionary *)blackPoints
                    withSize: (int)columns;
-(NSString *)interpretBlackAndWhiteImage;

@end
