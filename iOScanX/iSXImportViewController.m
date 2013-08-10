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
    NSString *address = nil;
    
    if (_tabIndex == 1) {
        
        if ([_ipAddress isValidIPAddress]) {
            address = _ipAddress;
        }
        else
        {
            // Invalid IP Address
        }
    }
    
    // TODO: sanitize user + password too.
    
    [_delegate connectWithUsername:_user andPassword:_password toAddress:address];
}

- (void)dealloc {
    
    [_user release];
    [_password release];
    [_ipAddress release];
    
    [super dealloc];
}

@end
