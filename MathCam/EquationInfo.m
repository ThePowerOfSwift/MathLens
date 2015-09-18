//
//  EquationInfo.m
//  MathCam
//
//  Created by Achintya Gopal on 4/7/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import "EquationInfo.h"

@implementation EquationInfo

-(instancetype)initWithLetter:(NSString *)word
                    withBegin: (CGPoint)start
                      withEnd: (CGPoint)finished{
    self = [super init];
    if(self){
        self.letter = word;
        self.beginPoint = start;
        self.endPoint = finished;
    }
    return self;
}

-(void)changeLetter:(NSString *)word{
    self.letter = word;
}

-(void)changePoints:(CGPoint)newBegin withEnd: (CGPoint)newEnd{
    self.beginPoint = newBegin;
    self.endPoint = newEnd;
}

@end
