//
//  iSXModulesViewController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 20/06/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXModulesViewController.h"

@interface iSXModulesViewController ()

@end

@implementation iSXModulesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (IBAction)add:(id)sender {
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseFiles = YES;
    openDlg.canChooseDirectories = NO;
    openDlg.allowsMultipleSelection = NO;
    openDlg.allowedFileTypes = [NSArray arrayWithObject:@"isxm"];
    
    [openDlg beginSheetModalForWindow:[self.view window] completionHandler:^(NSInteger result) {
        
        if (result == NSOKButton) {
            
            NSArray* files = [openDlg URLs];
            NSLog(@"Module path: %@",[files objectAtIndex:0 ]);
        }
    }];
}

- (IBAction)delete:(id)sender {
}
@end
