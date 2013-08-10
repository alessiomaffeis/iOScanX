//
//  iSXImportViewController.h
//  iOScanX
//
//  Created by Alessio Maffeis on 08/08/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSString+IPValidation.h"

@protocol iSXImportViewDelegate

- (void)connectWithUsername:(NSString*)user andPassword:(NSString*)password toAddress:(NSString*)address;

@end


@interface iSXImportViewController : NSViewController

@property (assign) id <iSXImportViewDelegate> delegate;
@property (assign) NSInteger tabIndex;
@property (retain) NSMutableString *user;
@property (retain) NSMutableString *password;
@property (retain) NSMutableString *ipAddress;


- (IBAction)connect:(id)sender;

@end


