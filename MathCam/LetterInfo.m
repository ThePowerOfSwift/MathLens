//
//  LetterInfo.m
//  CameraMath
//
//  Created by Achintya Gopal on 4/6/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import "LetterInfo.h"

@implementation LetterInfo

-(instancetype)initWithImage:(UIImage *)image
                withLocation:(CGPoint)point{
    self = [super init];
    
    if(self){
        self.imageOfChar = image;
        self.locationOfChar = point;
    }
    return self;
}

@end
