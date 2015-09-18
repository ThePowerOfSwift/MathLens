//
//  LetterInfo.h
//  CameraMath
//
//  Created by Achintya Gopal on 4/6/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LetterInfo : NSObject

@property (nonatomic, copy) UIImage *imageOfChar;
@property (nonatomic) CGPoint locationOfChar;

-(instancetype)initWithImage:(UIImage *)image
                withLocation:(CGPoint)point;


@end
