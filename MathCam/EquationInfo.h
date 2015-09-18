//
//  EquationInfo.h
//  MathCam
//
//  Created by Achintya Gopal on 4/7/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EquationInfo : NSObject

@property (nonatomic, retain) NSString *letter;
@property (nonatomic) CGPoint beginPoint;
@property (nonatomic) CGPoint endPoint;

-(instancetype)initWithLetter:(NSString *)word
                    withBegin: (CGPoint)start
                      withEnd: (CGPoint)finished;

-(void)changeLetter:(NSString *)word;
-(void)changePoints:(CGPoint)newBegin withEnd: (CGPoint)newEnd;

@end
