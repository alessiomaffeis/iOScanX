//
//  iSXAppController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXAppController.h"

@implementation iSXAppController

@synthesize mainViewController = _mainViewController;

- (void)awakeFromNib {
    
}

- (IBAction)showApps:(id)sender {
    
    self.mainViewController = [[iSXAppsViewController alloc] initWithNibName:@"iSXAppsViewController" bundle:nil];
    
    [self.mainView addSubview:[self.mainViewController view]];
    
    [[self.mainViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showModules:(id)sender {
}

- (IBAction)showEvaluations:(id)sender {
}

- (IBAction)showResults:(id)sender {
}

- (IBAction)toggleStart:(id)sender {
}
@end
