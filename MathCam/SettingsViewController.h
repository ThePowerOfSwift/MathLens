//
//  SettingsViewController.h
//  MathCam
//
//  Created by Achintya Gopal on 4/12/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic) int problemType;

- (IBAction)doneEditing:(id)sender;

@end
