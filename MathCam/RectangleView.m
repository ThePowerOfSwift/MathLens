//
//  RectangleView.m
//  MathCam
//
//  Created by Achintya Gopal on 4/5/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import "Rectangle.h"
#import "RectangleView.h"

@interface RectangleView()



@end

@implementation RectangleView

-(instancetype)initWithFrame:(CGRect)r{
    self = [super initWithFrame:r];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.inProgress = [[NSMutableDictionary alloc]init];
        self.multipleTouchEnabled = YES;
        self.finished =[[NSMutableArray alloc]init];
        
        UITapGestureRecognizer *tapGR;
        tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        tapGR.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGR];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    for(Rectangle *rect in self.finished){
        [self strokeLine:rect];
    }
    
    for(NSValue *key in self.inProgress){
        [self strokeLine:self.inProgress[key]];
    }
    
}

- (void)strokeLine:(Rectangle *)rectangle
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(rectangle.begin.x, rectangle.begin.y)];
    [path addLineToPoint:CGPointMake(rectangle.end.x, rectangle.begin.y)];
    [path addLineToPoint:CGPointMake(rectangle.end.x, rectangle.end.y)];
    [path addLineToPoint:CGPointMake(rectangle.begin.x,rectangle.end.y)];
    [path closePath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineWidth = 4.0f;
    [[UIColor redColor] setStroke];
    const CGFloat a[] = {7.0,7.0};
    [path setLineDash:a count:2 phase:0.0];
    [path stroke];
}


- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    for (UITouch *t in touches) {
        CGPoint location = [t locationInView:self];
        
        Rectangle *line = [[Rectangle alloc] init];
        line.begin = location;
        line.end = location;
        
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        self.inProgress[key] = line;
    }
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Rectangle *line = self.inProgress[key];
        CGPoint location = [t locationInView:self];
        if(location.y >= self.frame.size.height){
            line.end = CGPointMake([t locationInView:self].x, self.frame.size.height);
        }
        else{
            line.end = [t locationInView:self];
 
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Rectangle *line = self.inProgress[key];
        self.finished[0] = line;
        [self.inProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        [self.inProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}


-(void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
            // handling code
            NSLog(@"%@", NSStringFromSelector(_cmd));
            [self.finished removeAllObjects];
    }
    
    [self setNeedsDisplay];
}

@end
