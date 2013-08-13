//
//  iSXImportViewController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 08/08/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXImportViewController.h"

@interface iSXImportViewController ()

@end

@implementation iSXImportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tabIndex = 0;
        _user = [[NSMutableString alloc] initWithString:@"root"];
        _password = [[NSMutableString alloc] initWithString:@"alpine"];
        _ipAddress = [[NSMutableString alloc] init];
    }
    
    return self;
}

- (IBAction)connect:(id)sender;
{    
    if (_tabIndex == 1) {
        
        if ([_ipAddress isValidIPAddress]) {
            [_delegate connectWithUsername:_user andPassword:_password toAddress:_ipAddress];
        }
        else {
            // Invalid IP 
        }
    }
    else
    {
        // [_delegate connectWithUsername:_user andPassword:_password toAddress:nil];
    }
    
    // TODO: sanitize user + password
}

- (void)dealloc {
    
    [_user release];
    [_password release];
    [_ipAddress release];
    
    [super dealloc];
}

@end
