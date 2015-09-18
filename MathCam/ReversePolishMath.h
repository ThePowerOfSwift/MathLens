//
//  ReversePolishMath.h
//  MathCam
//
//  Created by Achintya Gopal on 4/29/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef __MathCam__PolishMath__
#define __MathCam__PolishMath__
#include <string>

using std::string;

@interface ReversePolishMath : NSObject

@property(nonatomic, copy) NSString *problem;

-(string)add:(string)a toString: (string)b;
-(string)subtract:(string)a fromString: (string)b;
-(string)multiply:(string)a byString: (string)b;
-(string)divide:(string)a byString: (string)b;
-(string)exponentiate:(string)a toString: (string)b;
-(string)solve: (string)problem;
-(BOOL)compare:(string)a toString: (string)b;
-(string)simplifyString: (string)a;

bool is_digits(const std::string &str);
bool isInteger(const std::string &str);

#endif

@end
