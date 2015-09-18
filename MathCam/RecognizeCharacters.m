//
//  RecognizeCharacters.m
//  MathCam
//
//  Created by Achintya Gopal on 4/11/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import "RecognizeCharacters.h"
#import "G8RecognitionOperation.h"
#import "EquationInfo.h"
#import "LetterInfo.h"

#import "UIImage+G8Filters.h"
#import "G8Tesseract.h"
#import "G8Constants.h"
#import "G8TesseractParameters.h"

@implementation RecognizeCharacters

-(instancetype)initWithImage: (UIImage *)editedImage
           withOriginalImage: (UIImage *)original
                   withArray: (NSMutableDictionary *)blackPoints
                    withSize: (int)columns{
    
    self = [super init];
    if(self){
        self.originalImage = original;
        self.editedImage = editedImage;
        self.blackPoints = blackPoints;
        self.columns = columns;
    }
    return self;
}

-(NSString *)interpretBlackAndWhiteImage{
    UIImage *croppedImage = self.originalImage;
    NSMutableDictionary *blackValues = self.blackPoints;
    NSMutableArray *_images = [[NSMutableArray alloc] init];
    [self createImages:blackValues withArray:_images withColumns:self.columns withImage:self.editedImage];
    
    NSString *output = @"";
    NSMutableArray *result = [[NSMutableArray alloc]initWithCapacity:[_images count]];
    
    for(int i = 0; i<[_images count];i++){
        G8Tesseract *helper2 = [[G8Tesseract alloc]initWithLanguage:@"eng+ita+equ"];
        
        CGRect cropRect = CGRectMake([_images[i] locationOfChar].x, [_images[i] locationOfChar].y, [_images[i] imageOfChar].size.width, [_images[i] imageOfChar].size.height);
        CGImageRef imageRef = CGImageCreateWithImageInRect([croppedImage CGImage], cropRect);
        
        
        UIImage *image3 = [UIImage imageWithCGImage:imageRef];
        CGPoint beginPoint = [_images[i] locationOfChar];
        [helper2 setImage:image3];
        
        helper2.pageSegmentationMode = G8PageSegmentationModeSingleChar;
        EquationInfo *info = [[EquationInfo alloc]initWithLetter:[helper2 recognizedText] withBegin:beginPoint withEnd:CGPointMake(beginPoint.x + image3.size.width, beginPoint.y +image3.size.height)];
        [result addObject:info];
        output = [output stringByAppendingString:[helper2 recognizedText]];
    }

    for(int i = 0; i< [result count]; i++){
        NSString *trimmedString = [[result[i] letter]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [result[i] changeLetter:trimmedString];
        int xSize =[result[i] endPoint].x - [result[i] beginPoint].x;
        int ySize =[result[i] endPoint].y - [result[i] beginPoint].y;
        int ratio = xSize/ySize;
        CGPoint endPointI = [result[i] endPoint];
        CGPoint beginPointI = [result[i] beginPoint];
        if((ratio >= 2 && ySize <= 30) || [[result[i] letter]  isEqual: @""]){
            [result[i] changeLetter:@"-"];
            [result[i] changePoints:CGPointMake(
                                                beginPointI.x - 5 , beginPointI.y) withEnd:CGPointMake(endPointI.x + 5, endPointI.y)];
        }
        if(xSize <= 30 && ySize<= 30){
            [result[i] changeLetter:@"."];
        }
        if([[result[i] letter]  isEqual: @"I"]) {
            [result[i] changeLetter:@"x"];
        }
    }
    
    NSArray *sortedy1;
    sortedy1 = [result sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
        CGPoint beginOne = [(EquationInfo *)a beginPoint];
        CGPoint beginTwo = [(EquationInfo *)b beginPoint];
        
        double comparisonOne = beginOne.x *croppedImage.size.height + beginOne.y;
        double comparisonTwo = beginTwo.x *croppedImage.size.height + beginTwo.y;
        if(comparisonOne > comparisonTwo) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if(comparisonOne < comparisonTwo) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    NSMutableArray *sortedy = [[NSMutableArray alloc]init];
    sortedy = [sortedy1 mutableCopy];
    
    for(int i = 0; i< [sortedy count]; i++){
        NSLog(@"%@", [sortedy[i] letter]);
    }
    
    NSString *stringResult = @"";
    if([sortedy count] == 0){
        stringResult = @"";
    }
    else
        stringResult = [self interpretArray:sortedy];
    
    return stringResult;
}

-(NSString *)interpretArray: (NSMutableArray *)result{
    //NSLog(@"1");
    NSString *a = @"";
    
    //interpret integral
    NSString *integral = @"\u222b";
    if([result[0] letter] == integral){
        a =[a stringByAppendingString:integral];
        a = [a stringByAppendingString:@"{"];
        a = [a stringByAppendingString:[self interpretRow:result[1] fromArray:result]];
        a = [a stringByAppendingString:@"}{"];
        a = [a stringByAppendingString:[self interpretRow:result[2] fromArray:result]];
        a = [a stringByAppendingString:@"}"];
        [result removeObject:result[0]];
        [result removeObject:result[1]];
        [result removeObject:result[2]];
    }
    
    //find lim
    int letterI = 0;
    int letterM = 0;
    int j = 0;
    int k = 0;
    EquationInfo *letI= NULL;
    EquationInfo *letM= NULL;
    
    for(int i = 0; i < [result count]; i++){
        if([[result[i] letter] isEqual: @"l"]){
            if(!letterI){
                letI = result[i];
                j = i;
            }
            letterI = i;
        }
        else if([[result[i] letter] isEqual: @"m"]){
            if(!letterM){
                letM = result[i];
            }
            if(!letterI){
                letterM = 0;
            }else{
                letterM = i;
                k = i;
            }
        }
    }
    
    if(letterI != 0 && letterM != 0){
        if(letI.endPoint.y
           < letM.beginPoint.y && letI.endPoint.x >= letM.beginPoint.x - 3*(letM.endPoint.x - letM.beginPoint.x)){
            // j < k
            
        }
    }
    
    //split above, below, middle
    NSMutableArray *above = [[NSMutableArray alloc]init];
    NSMutableArray *below = [[NSMutableArray alloc]init];
    NSMutableArray *middle = [[NSMutableArray alloc]init];
    
    for(int i = 1; i< [result count]; i++){
        if([result[i] beginPoint].x>= [result[0] beginPoint].x-3 && [result[i] endPoint].x <= [result[0] endPoint].x+3){
            if([result[i] beginPoint].y < [result[0] beginPoint].y){
                NSLog(@"above");
                [above addObject:result[i]];
                [result removeObjectAtIndex:i];
            }
            else if([result[i] endPoint].y > [result[0] endPoint].y){
                NSLog(@"below");
                
                [below addObject:result[i]];
                [result removeObject:result[i]];
            }
            else{
                NSLog(@"middle");
                
                [middle addObject:result[i]];
                [result removeObject:result[i]];
            }
            i--;
        }
    }

    if([above count] == 0 && [below count] == 0 && [middle count] == 0){
        a = [a stringByAppendingString:[result[0] letter]];
    }
    else if([middle count] != 0){
        NSString *b = @"2";
        NSLog(@"middle 1");
        if([middle[0] beginPoint].x > [result[0] beginPoint].x-5 && [middle[0] beginPoint].x > [result[0] beginPoint].x+5){
            NSLog(@"middle 2");
            NSMutableArray *midTemp = [[NSMutableArray alloc]init];
            [midTemp addObject:middle[0]];
            
            b = [self interpretArray:midTemp];
        }
        NSLog(@"middle 3");
        
        a = [a stringByAppendingString:@"("];
        a = [a stringByAppendingString:[self interpretArray:middle]];
        a = [a stringByAppendingString:@")^(1/"];
        a = [a stringByAppendingString:b];
        a = [a stringByAppendingString:@")"];
    }
    else if([[result[0] letter] isEqual: @"-"]){
        if([above count] == 1 && [below count] == 0){
            if([[above[0] letter] isEqual: @"-"]){
                a = [a stringByAppendingString:@"="];
            }
            if([[above[0] letter] isEqual:@"<"] || [[above[0] letter] isEqual:@"("]){
                a = [a stringByAppendingString:@"<="];
            }
            if([[above[0] letter] isEqual:@">"] || [[above[0] letter] isEqual:@")"]){
                a = [a stringByAppendingString:@">="];
            }
        }
        else if([below count] == 1 && [above count] == 0){
            if([[below[0] letter]  isEqual: @"-"]){
                a = [a stringByAppendingString:@"="];
            }
        }
        else if([above count] != 0 && [below count] != 0){
            if([[above[0] letter]  isEqual: @"."] && [[below[0] letter]  isEqual: @"."]){
                a = [a stringByAppendingString:@"/"];
            }
            else{
                NSLog(@"fraction");
                a = [a stringByAppendingString:@"("];
                a = [a stringByAppendingString:[self    interpretArray:above]];
                a = [a stringByAppendingString:@")"];
                a = [a stringByAppendingString:@"/"];
                a = [a stringByAppendingString:@"("];
                a = [a stringByAppendingString:[self    interpretArray:below]];
                a = [a stringByAppendingString:@")"];
            }
        }
    }
    else if([above count] ==1 && [[result[0] letter]isEqual:@"."]){
        if([[above[0] letter] isEqual: @"."]){
            a = [a stringByAppendingString:@"/"];
        }
    }
    else if([below count] == 1 && [[result[0] letter]  isEqual: @"."]){
        if([[below[0] letter]  isEqual: @"."]){
            a = [a stringByAppendingString:@"/"];
        }
    }
    else if([[result[0] letter]isEqual:@"."]){
        
    }
    else{
        for(int i = 0; i< [above count]; i++){
            a = [a stringByAppendingString:@"{"];
            a = [a stringByAppendingString:[self interpretRow: above[i] fromArray: result]];
            a = [a stringByAppendingString:@"}"];
            
        }
        for(int i = 0; i< [below count]; i++){
            a = [a stringByAppendingString:@"{"];
            a = [a stringByAppendingString:[self interpretRow: below[i] fromArray: result]];
            a = [a stringByAppendingString:@"}"];
            
        }
    }

    if([result count] != 1){
        EquationInfo *next = result[1];
        double length = [result[0] endPoint].y -[result[0] beginPoint].y;
        if(next.beginPoint.x - [result[0] endPoint].x >= [result[0] endPoint].x - [result[0] beginPoint].x){
            a = [a stringByAppendingString:@" "];
        }
        else if(next.beginPoint.y > [result[0] beginPoint].y - 2*length){
            NSLog(@"superscript");
            if(next.endPoint.y < [result[0] endPoint].y - length*3/4){
                if([[result[0] letter]  isEqual: @"("] || [[result[0] letter]  isEqual: @"["]){
                    NSLog(@"matrix");
                    
                    a = [a stringByAppendingString:@"{"];
                }
                else if(![next.letter isEqual:@"."] && ![next.letter isEqual:@"-"] && 3*length/4 > (next.beginPoint.y - next.endPoint.y)){
                    NSLog(@"exponent");
                    
                    a = [a stringByAppendingString:@"^("];
                    a = [a stringByAppendingString:[self interpretRow:next fromArray:result]];
                    a = [a stringByAppendingString:@")"];
                }
                else{
                    NSLog(@"else");
                    
                }
            }
            else if(next.endPoint.y < [result[0] endPoint].y - length/4+5){
                if([next.letter  isEqual: @"."]){
                    if([[result[0] letter] isEqual:@"}"]){
                        
                    }
                    else{
                        [result[1] changeLetter:@"*"];
                    }
                }
            }
            else if(![[result[0] letter] isEqual:@"."] && ![[result[0] letter] isEqual:@"-"] && next.beginPoint.y < [result[0] endPoint].y && next.endPoint.y > [result[0] endPoint].y){
                
            }
        }
        else{
            //a = [a stringByAppendingString:@"{"];
        }
        [result removeObject:result[0]];
        a = [a stringByAppendingString:[self interpretArray:result]];
    }
    return a;
}

-(NSString *) interpretRow:(EquationInfo *)info fromArray: (NSMutableArray *)result{
    
    NSString *a = @"";
    NSMutableArray *middle = [[NSMutableArray alloc]init];
    NSMutableArray *right = [[NSMutableArray alloc]init];
    
    NSLog(@"%lu", (unsigned long)[result count]);
    for(int i = 0; i< [result count]; i++){
        //NSLog(@"%d",i);
        if([result[i] beginPoint].y>= [info beginPoint].y-10 && [result[i] endPoint].y <= [info endPoint].y+10){
            if([result[i] endPoint].x > [info endPoint].x){
                [right addObject:result[i]];
                [result removeObject:result[i]];
            }
            else{
                [middle addObject:result[i]];
                [result removeObject:result[i]];
            }
            i--;
        }
        if([result[i] beginPoint].y < [info beginPoint].y-10 && [result[i] endPoint].y > [info endPoint].y + 10){
            break;
        }
    }
    a = [info letter];
    if([middle count] != 0){
        NSString *b = @"2";
        if([middle[0] beginPoint].x > [info beginPoint].x-5 && [middle[0] beginPoint].x > [info beginPoint].x+5){
            b = [self interpretArray:middle[0]];
            [middle removeObjectAtIndex:0];
        }
        
        a = @"(";
        a = [a stringByAppendingString:[self interpretArray:middle]];
        a = [a stringByAppendingString:@")^(1/"];
        a = [a stringByAppendingString:b];
        a = [a stringByAppendingString:@")"];
    }
    
    if([right count] != 0) {
        EquationInfo *next = result[0];
        double length = [info beginPoint].y -[info endPoint].y;
        if(next.beginPoint.x - [result[0] endPoint].x >= [result[0] endPoint].x - [result[0] beginPoint].x){
            a = [a stringByAppendingString:@" "];
        }
        else if(next.beginPoint.y > [info beginPoint].y - length){
            if(next.endPoint.y < [info endPoint].y - length*3/4){
                if(![next.letter isEqual:@"."] && ![next.letter isEqual:@"-"] ){
                    a = [a stringByAppendingString:@"^("];
                    a = [a stringByAppendingString:[self interpretRow:next fromArray:result]];
                    a = [a stringByAppendingString:@")"];                }
            }
        }
        a = [a stringByAppendingString:[self interpretArray:right]];
    }
    
    return a;
}

-(void)createImages:(NSMutableDictionary *)values withArray: (NSMutableArray *)images withColumns: (int)cols withImage: (UIImage *)editedImage{
    if(values != nil){
        NSArray *array = [values allKeys];
        if([array count] != 0){
            NSString *a = [values objectForKey:array[0]];
            long long b = [a longLongValue];
            
            NSMutableArray *keys = [[NSMutableArray alloc]init];
            [keys addObject:[NSNumber numberWithInteger:[a intValue]]];
            
            [self addLetterFrom:values fromIndex:b toArray:keys withColumns:cols];
            NSLog(@"%d",(int)[keys count]);
            
            // NSArray *sortedArray = [keys sortedArrayUsingSelector:@selector(compare:)];
            NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                long long a = [obj1 longLongValue];
                long long b = [obj2 longLongValue];
                if(a < b){
                    return NSOrderedAscending;
                }
                if(a == b){
                    return NSOrderedSame;
                }
                return NSOrderedDescending;
            }];
            
            long long maxY;
            long long minY;
            minY = [sortedArray.firstObject longLongValue]/cols;
            maxY = [sortedArray.lastObject longLongValue]/cols;
            long long maxX = 0;
            long long minX = 0;
            if(keys != nil){
                minX = [keys[0] intValue]%cols;
                maxX = [keys[0] intValue]%cols;
            }
            for(int i = 1; i<keys.count;i++){
                keys[i] = [NSNumber numberWithInt:[keys[i] intValue]%cols];
                if([keys[i] intValue]<minX){
                    minX = [keys[i] intValue];
                }
                if([keys[i] intValue]>maxX){
                    maxX = [keys[i] intValue];
                }
            }
            minX -=1;
            maxX += 1;
            minY -= 1;
            maxY += 1;
            if(minX < 0){
                minX = 0;
            }if(minY < 0){
                minY = 0;
            }
            if((maxX-minX)*(maxY-minY) < 35){
                
                
            }
            else{
                if(maxX-minX > 0 && minY-maxY < 0){
                    CGRect rect = CGRectMake(minX, minY, maxX-minX, maxY-minY);
                    CGImageRef imageRef = CGImageCreateWithImageInRect([editedImage CGImage], rect);
                    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    LetterInfo *character = [[LetterInfo alloc]initWithImage:croppedImage withLocation:CGPointMake(minX, minY)];
                    [images addObject:character];
                    
                }
                if([images count] < 200){
                    [self createImages:values withArray:images withColumns:cols withImage:editedImage];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Too much noise" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }
                
            }
        }
    }
    return;
}

-(void)addLetterFrom:(NSMutableDictionary *)values fromIndex:(long long)index toArray: (NSMutableArray *)keys withColumns: (int)cols{
    //NSLog(@"found black");
    /* NSLog(@"%lu",index);
     if([values objectForKey:[NSString stringWithFormat:@"%ld",index-1]] != nil){
     [values removeObjectForKey:[NSString stringWithFormat:@"%lu",index - 1]];
     [keys addObject:[NSNumber numberWithInteger:index - 1]];
     [self addLetterFrom:values fromIndex:index-1 toArray:keys withColumns:cols];
     }
     if([values objectForKey:[NSString stringWithFormat:@"%lu",index + 1]] != nil){
     [values removeObjectForKey:[NSString stringWithFormat:@"%lu",index + 1]];
     [keys addObject:[NSNumber numberWithInteger:index + 1]];
     [self addLetterFrom:values fromIndex:index + 1 toArray:keys withColumns:cols];
     }
     if([values objectForKey:[NSString stringWithFormat:@"%lu",index - cols]] != nil){
     [values removeObjectForKey:[NSString stringWithFormat:@"%lu",index - cols]];
     [keys addObject:[NSNumber numberWithInteger:index - cols]];
     [self addLetterFrom:values fromIndex:index - cols toArray:keys withColumns:cols];
     }
     if([values objectForKey:[NSString stringWithFormat:@"%lu",index + cols]] != nil){
     [values removeObjectForKey:[NSString stringWithFormat:@"%lu",index + cols]];
     [keys addObject:[NSNumber numberWithInteger:index + cols]];
     [self addLetterFrom:values fromIndex:index + cols toArray:keys withColumns:cols];
     }
     if([values objectForKey:[NSString stringWithFormat:@"%lu",index - cols -1]] != nil){
     [values removeObjectForKey:[NSString stringWithFormat:@"%lu",index - cols - 1]];
     [keys addObject:[NSNumber numberWithInteger:index - cols - 1]];
     [self addLetterFrom:values fromIndex:index - cols -1 toArray:keys withColumns:cols];
     }
     if([values objectForKey:[NSString stringWithFormat:@"%lu",index - cols + 1]] != nil){
     [values removeObjectForKey:[NSString stringWithFormat:@"%lu",index -cols + 1]];
     [keys addObject:[NSNumber numberWithInteger:index - cols +1]];
     [self addLetterFrom:values fromIndex:index - cols + 1 toArray:keys withColumns:cols];
     }
     if([values objectForKey:[NSString stringWithFormat:@"%lu",index + cols -1]] != nil){
     [values removeObjectForKey:[NSString stringWithFormat:@"%lu",index + cols - 1]];
     [keys addObject:[NSNumber numberWithInteger:index  + cols - 1]];
     [self addLetterFrom:values fromIndex:index + cols - 1 toArray:keys withColumns:cols];
     }
     if([values objectForKey:[NSString stringWithFormat:@"%lu",index + cols + 1]] != nil){
     [values removeObjectForKey:[NSString stringWithFormat:@"%lu",index +cols + 1]];
     [keys addObject:[NSNumber numberWithInteger:index +cols + 1]];
     [self addLetterFrom:values fromIndex:index + cols + 1 toArray:keys withColumns:cols];
     }*/
    
    //bool done = false;
    int position = 0;
    [keys insertObject:[NSString stringWithFormat:@"%lld",index] atIndex:position];
    while(position >= 0){
        index = [[keys objectAtIndex:position]longLongValue];
        long long a = index - 1;
        long long b = index + 1;
        long long c = index - cols;
        long long d = index + cols;
        long long f = index - cols - 1;
        long long g = index - cols + 1;
        long long h = index + cols - 1;
        long long j = index + cols + 1;
        if([values objectForKey:[NSString stringWithFormat:@"%lld",a]] != nil){
            [values removeObjectForKey:[NSString stringWithFormat:@"%lld",a]];
            [keys insertObject:[NSString stringWithFormat:@"%lld",a] atIndex:position];
            position++;
            continue;
        }
        else if([values objectForKey:[NSString stringWithFormat:@"%lld",b]] != nil){
            [values removeObjectForKey:[NSString stringWithFormat:@"%lld",b]];
            [keys insertObject:[NSString stringWithFormat:@"%lld",b] atIndex:position];
            position++;
            continue;
        }
        else if([values objectForKey:[NSString stringWithFormat:@"%lld",c]] != nil){
            [values removeObjectForKey:[NSString stringWithFormat:@"%lld",c]];
            [keys insertObject:[NSString stringWithFormat:@"%lld",c] atIndex:position];
            position++;
            continue;
        }
        else if([values objectForKey:[NSString stringWithFormat:@"%lld",d]] != nil){
            [values removeObjectForKey:[NSString stringWithFormat:@"%lld",d]];
            [keys insertObject:[NSString stringWithFormat:@"%lld",d] atIndex:position];
            position++;
            continue;
        }
        else if([values objectForKey:[NSString stringWithFormat:@"%lld",f]] != nil){
            [values removeObjectForKey:[NSString stringWithFormat:@"%lld",f]];
            [keys insertObject:[NSString stringWithFormat:@"%lld",f] atIndex:position];
            position++;
            continue;
        }
        else if([values objectForKey:[NSString stringWithFormat:@"%lld",g]] != nil){
            [values removeObjectForKey:[NSString stringWithFormat:@"%lld",g]];
            [keys insertObject:[NSString stringWithFormat:@"%lld",g] atIndex:position];
            position++;
            continue;
        }
        else if([values objectForKey:[NSString stringWithFormat:@"%lld",h]] != nil){
            [values removeObjectForKey:[NSString stringWithFormat:@"%lld",h]];
            [keys insertObject:[NSString stringWithFormat:@"%lld",h] atIndex:position];
            position++;
            continue;
        }
        else if([values objectForKey:[NSString stringWithFormat:@"%lld",j]] != nil){
            [values removeObjectForKey:[NSString stringWithFormat:@"%lld",j]];
            [keys insertObject:[NSString stringWithFormat:@"%lld",j] atIndex:position];
            position++;
            continue;
        }
        else{
            position--;
        }
    }
    
    return;
}

@end
