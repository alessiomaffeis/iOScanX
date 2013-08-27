//
//  iSXAppsViewController.h
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iSXApp.h"


@interface iSXAppsViewController : NSViewController

@property (assign) IBOutlet NSCollectionView *appsCollectionView;
@property (retain) NSMutableArray *apps;

- (void)addApp:(iSXApp *)app;
- (BOOL)appExistsWithID:(NSString*)appID;
- (NSArray*)selectedApps;

@end
