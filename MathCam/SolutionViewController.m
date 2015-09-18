//
//  SolutionViewController.m
//  MathCam
//
//  Created by Achintya Gopal on 4/14/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import "SolutionViewController.h"
#import <Foundation/Foundation.h>

@interface SolutionViewController ()

@end

@implementation SolutionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(self.problemType != 0){
        self.problemType = [self decideProblemType:self.problem];
    }
    
    NSMutableString *problem2 = [NSMutableString stringWithString:self.problem];
    int period = 0;
    
    //convert all exponent to **
    [problem2 replaceOccurrencesOfString:@"^" withString:@"**" options:NSCaseInsensitiveSearch range:NSMakeRange(0, problem2.length)];
    //convert all numbers to doubles
    for(int i = 0; i< problem2.length; i++){
        if([problem2 characterAtIndex:i] == '.'){
            period = 1;
        }
        else if([problem2 characterAtIndex:i] == '('){
            if(i != 0){
                if([problem2 characterAtIndex:i-1] >= '0' ||[problem2 characterAtIndex:i-1] <= '9' ||[problem2 characterAtIndex:i-1] == ')' ){
                    [problem2 insertString:@"*" atIndex:i];
                }
            }
        }
        else if(!([problem2 characterAtIndex:i] >= '0') && !([problem2 characterAtIndex:i] <= '9')){
            period = 0;
        }
        else{
            if(i != problem2.length -1) {
                if(!([problem2 characterAtIndex:i+1] >= '0') && !([problem2 characterAtIndex:i+1] <= '9') && [problem2 characterAtIndex:i+1] != '.'){
                    if(period == 0){
                        [problem2 insertString:@".0" atIndex:i];
                    }
                }
            }
        }
    }
   
    if(self.problemType == 0){
        //print unable to recognize problem type
    }
    else if(self.problemType == 1){
        float a = [self arithmeticCalculation:problem2];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Result" message:problem2 delegate:self cancelButtonTitle:@"COOL" otherButtonTitles: nil];
        [alert show];
    }
    
}

/*
 0 - General
 1 - Arithmetic (3x4)
 2 - Algebra (else)
 3 - System of Equations (multiple equals signs)
 4 - Matrix ({}{})
 5 - Graph
 6 - Limit (lim)
 7 - Derivative (d/dx)
 8 - Numerical Integral (\u222b)
 */

-(int)decideProblemType: (NSString *)problem{
    bool arithmeticX = true;
    NSString *integral = @"\u222b";
    char integral2 = [integral characterAtIndex:0];
    for(int i = 0; i<problem.length; i++){
        if([problem characterAtIndex:i] == 'x'){
            if([problem characterAtIndex:0] == integral2){
                arithmeticX = false;
                break;
            }
            if(i == 0 || i == problem.length - 1){
                arithmeticX = true;
                break;
            }
            if([problem characterAtIndex:i+1] >= '0' && [problem characterAtIndex:i+1] <= '9'){
                arithmeticX = false;
            }
            if([problem characterAtIndex:i+1] >= 'a' && [problem characterAtIndex:i+1] <= 'z' && [problem characterAtIndex:i+1] != 'x'){
                arithmeticX = false;
                break;
            }
            if([problem characterAtIndex:i+1] == '+' ||[problem characterAtIndex:i+1] == '-' || [problem characterAtIndex:i+1] == '/' || [problem characterAtIndex:i+1] == ')' ||[problem characterAtIndex:i+1] == '}'){
                arithmeticX = false;
                break;
            }
        }
        if([problem characterAtIndex:i+1] == '*'){
            arithmeticX = false;
            break;
        }
    }
    
    if(arithmeticX){
        problem = [problem stringByReplacingOccurrencesOfString:@"x" withString:@"*"];
        return 1;
    }
    
    if([problem containsString:@"lim"]){
        return 6;
    }
    if([problem containsString:integral]){
        return 8;
    }
    if([problem containsString:@"(d)/(dx)"]){
        return 7;
    }
    if([problem containsString:@"*"]){
        return 1;
    }
    
    int equals = 0;
    int commas = 0;
    int spaces = 0;
    
    for(int i = 0; i<problem.length; i++){
        
        if([problem characterAtIndex:i] == ','){
            commas++;
        }
        else if([problem characterAtIndex:i] == '='){
            equals++;
        }
        else if([problem characterAtIndex:i] == ' '){
            spaces++;
        }
    }
    
    if(equals > 1){
        return 3;
    }
    if(spaces != 0){
        return 4;
    }
    if(commas != 0){
        return 4;
    }
    if([problem characterAtIndex:problem.length - 1] == '=' || equals == 0){
        return 1;
    }
    return 0;
}

-(float)arithmeticCalculation: (NSMutableString *)problem{
    
    [problem replaceOccurrencesOfString:@"=" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, problem.length)];
    NSPredicate *pred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = 0",problem]];
    float a = [pred evaluateWithObject:nil];
    NSLog(@"%f",a);
    return a;
}

-(void)algebraCalculation: (NSString *)problem{
    //distribute parenthesis
    
    
    //distribute fractions if no x in numerator
    
    //find equal sign, split across
}

-(void)graphFunction: (NSMutableString *)problem{
 
    NSMutableString *problem2 = problem;
    [problem2 replaceOccurrencesOfString:@"f(x)" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, problem2.length)];
    [problem2 replaceOccurrencesOfString:@"=" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, problem2.length)];
    [problem2 replaceOccurrencesOfString:@"y" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, problem2.length)];
    
    NSMutableArray *values = [[NSMutableArray alloc]init];
    float maxValue = 1;
    float minValue = -1;
    for(float i = -10; i<= 10; i=i+0.02){
        NSExpression *expr = [NSExpression expressionWithFormat:problem2];
        NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:i],@"x", nil];
        float a = [[expr expressionValueWithObject:object context:nil]floatValue];
        if(a > 1000 || a<-1000){
            [values addObject:@"NONE"];
            continue;
        }
        if(a > maxValue){
            maxValue = a;
        }
        if(a < minValue){
            minValue = a;
        }
        [values addObject:[NSNumber numberWithFloat:a]];
    }
    
}

-(void)integralProblem: (NSMutableString *)problem{
    NSString *integral = @"\u222b";
    if([problem characterAtIndex:0] == [integral characterAtIndex:0]){
        [problem deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    int initial = 0;
    int final = 0;
    for(int i = 0; i<1; i++){
        int a = 0;
        while([problem characterAtIndex:0] != '}'){
            if([problem characterAtIndex:0] == '{'){
                
            }
            else{
                a = a * 10 + [[NSString stringWithFormat:@"%c",[problem characterAtIndex:0]]intValue];
            }
            [problem deleteCharactersInRange:NSMakeRange(0, 1)];
        }
        if(i == 0){
            final = a;
        }
        else{
            initial = a;
        }
    }
    
    int solution = 0;
    int increment = (final - initial)/1000;
    for(float i = initial; i< final; i=i+increment){
        NSExpression *expr = [NSExpression expressionWithFormat:problem ];
        NSDictionary *object1 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:i],@"x", nil];
        NSDictionary *object2 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:i+increment],@"x", nil];
        float a = [[expr expressionValueWithObject:object1 context:nil]floatValue];
        float b = [[expr expressionValueWithObject:object2 context:nil]floatValue];
        
        if(a > 1000 || a<-1000){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Integral To Large" message:@"f(x) gets to large" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            break;
        }
        solution += (a+b)*increment/2;
    }
    
}

-(void)createMatrix: (NSMutableString *)problem{
    //search for location of equal, becomes AX=B
    NSMutableArray *container = [[NSMutableArray alloc]init];
    NSUInteger numberOfMatrices = [problem replaceOccurrencesOfString:@"}}" withString:@"}}" options:NSCaseInsensitiveSearch range:NSMakeRange(0, problem.length)];
    NSUInteger numberOfEquals = [problem replaceOccurrencesOfString:@"=" withString:@"=" options:NSCaseInsensitiveSearch range:NSMakeRange(0, problem.length)];
    int level = 0;
    NSMutableArray *mainArray = [[NSMutableArray alloc]init];
    NSMutableArray *row = [[NSMutableArray alloc]init];
    NSMutableArray *operations = [[NSMutableArray alloc]init];
    float a = 0;
    int *decimal = 0;
    bool exponent = false;
    //add exponent handling
    for(int i = 0; i<problem.length; i++){
        if([problem characterAtIndex:i] == '{'){
            if(level == 0){
                if(operations.count == container.count){
                    [operations addObject:@"*"];
                }
            }
            level++;
        }
        else if([problem characterAtIndex:i] == '}'){
            level--;
            if(level == 0){
                [container addObject:mainArray];
                [mainArray removeAllObjects];
                decimal = 0;
            }
            else if(level == 1){
                [mainArray addObject:row];
                [row removeAllObjects];
                decimal = 0;
            }
        }
        else if(level == 0){
            if(i == problem.length - 1 && !exponent){
                break;
            }
            if(exponent){
                //exponent
            }
            if([problem characterAtIndex:i] == '^'){
                //exponent
            }
            [operations addObject:[NSString stringWithFormat:@"%c",[problem characterAtIndex:i]]];
        }
        else if([problem characterAtIndex:i] == ' '){
            [row addObject:[NSNumber numberWithFloat:a]];
            decimal = 0;
        }
        else if([problem characterAtIndex:i] >= '0' && [problem characterAtIndex:i] <= '9')
        {
            int addition = [problem characterAtIndex:i]-'0';
            if(decimal != 0){
                a = a + addition/(10**decimal);
                decimal++;
            }
            else{
                a = a*10 + addition;
            }
        }
        else if([problem characterAtIndex:i] == '.'){
            decimal++;
        }
        else{
            if(i == problem.length - 1){
                break;
            }
            [operations addObject:[NSString stringWithFormat:@"%c",[problem characterAtIndex:i]]];
        }
    }
    
    if(container.count != numberOfMatrices) {
        //error in reading
    }
    if(container.count != operations.count + 1){
        //error
    }
    if(numberOfEquals == 1){
        if(container.count == 3){
            //solve linear equations
        }
        else if(container.count == 2){
            //compare
        }
    }
    else if(numberOfEquals > 1){
        //error
    }
    
    if(container.count == 0){
        //alert no found matrices
        return;
    }
    else if(container.count == 1){
        //rref
    }
    else if(container.count == 2){
        //operate
        if([[operations objectAtIndex:0]  isEqual: @"+"]){
            //add
        }
        else if([[operations objectAtIndex:0]  isEqual: @"-"]){
            //subtract
        }
        else if([[operations objectAtIndex:0]  isEqual: @"*"]){
            //multiply
        }
        else if([[operations objectAtIndex:0]  isEqual: @"."]){
            //dot product
        }
        else if([[operations objectAtIndex:0]  isEqual: @"x"]){
            //cross product
        }



    }
    else if(container.count == 3){
        //order of operations
    }
    
    
}

-(void)addMatrix: (NSArray *)array1 toMatrix: (NSArray *)array2{
    if(array1.count != array2.count){
        //can't add
        return;
    }
    for(int i = 0; i<array1.count; i++){
        if([[array1 objectAtIndex:i]count] != [[array2 objectAtIndex:i]count]){
            //can't add
            return;
        }
    }
    
    
}

-(void)multiplyMatrix: (NSArray *)array1 toMatrix: (NSArray *)array2{}

-(void)dotProduct: (NSArray *)array1 toMatrix: (NSArray *)array2{}

-(void)crossProduct: (NSArray *)array1 toMatrix: (NSArray *)array2{}

-(void)inverseMatrix: (NSArray *)array1{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
