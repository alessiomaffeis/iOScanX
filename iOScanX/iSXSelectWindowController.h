//
//  iSXSelectWindowController.h
//  iOScanX
//
//  Created by Alessio Maffeis on 24/08/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iSXSelectWindowController : NSObject

@property (readonly) NSMutableArray *selectedApps;

- (IBAction)import:(id)sender;
- (IBAction)selectAll:(id)sender;
- (void) show:(NSWindow*)window;
- (void)addApps:(NSArray*)apps;

@end
