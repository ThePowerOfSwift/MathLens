//
//  SettingsViewController.m
//  MathCam
//
//  Created by Achintya Gopal on 4/12/15.
//  Copyright (c) 2015 Achintya Gopal. All rights reserved.
//

#import "SettingsViewController.h"
#import "PropertyTableCell.h"
#import "ViewController.h"

@interface SettingsViewController ()
{
    NSArray *tableData;
    NSArray *imageData;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tableData = [NSArray arrayWithObjects:@"General",@"Arithmetic",nil];//,@"Algebra",@"System of Equations",@"Matrix", @"Graph", @"Limit", @"Derivative", @"Numerical Integral",nil];
    
}

/*
 0 - General
 1 - Arithmetic
 2 - Algebra
 3 - System of Equations
 4 - Matrix
 5 - Graph
 6 - Limit
 7 - Numerical Derivative
 8 - Numerical Integral
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTable = @"SimpleTableItem";
    
    PropertyTableCell *cell = (PropertyTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTable];
    
    if(cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PropertyTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.label.text = [tableData objectAtIndex:indexPath.row];
    //cell.sideImageView.image = [imageData objectAtIndex:indexPath.row];
    
    if(indexPath.row == self.problemType){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [tableData count];
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    self.problemType = (int)indexPath.row;
    [tableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneEditing:(id)sender {
   
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MODELVIEW DISMISS"
                                                        object:[NSNumber numberWithInt: self.problemType]];
}

@end
