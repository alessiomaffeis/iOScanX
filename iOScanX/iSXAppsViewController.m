//
//  iSXAppsViewController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXAppsViewController.h"

@interface iSXAppsViewController ()

@end

@implementation iSXAppsViewController {
    
    IBOutlet NSArrayController *_appsArrayController;
    IBOutlet NSButton *_selectAll;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _apps = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)awakeFromNib {
    
    [_appsArrayController setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease]]];
}

- (BOOL)appExistsWithID:(NSString*)appID {
    
    for (iSXApp *app in _appsArrayController.arrangedObjects) {
        if ([app.ID isEqualToString:appID]) {
            return YES;
        }
    }
    return NO;
}

- (void)addApp:(iSXApp *)app {
    
    [_appsArrayController addObject:app];
}

- (NSArray*)selectedApps {
    
    NSMutableArray *sel = [NSMutableArray array];
    for (iSXApp *app in _appsArrayController.arrangedObjects) {
        if (app.selected) {
            [sel addObject:app];
        }
    }
    return [NSArray arrayWithArray:sel];
}

- (IBAction)selectAll:(id)sender {
    
    for (iSXApp *app in _appsArrayController.arrangedObjects) {
        app.selected = _selectAll.state;
    }
}

- (IBAction)delete:(id)sender {
    
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Are you sure you want to delete the selected applications?"];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert beginSheetModalForWindow:[self.view window]
                      modalDelegate:self
                     didEndSelector:@selector(deleteAlertDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}

- (void) deleteAlertDidEnd:(NSAlert *)a returnCode:(NSInteger)rc contextInfo:(void *)ci {
   
    if (rc == NSAlertFirstButtonReturn) {
        NSMutableArray *toDelete = [NSMutableArray array];
        for (iSXApp *app in _appsArrayController.selectedObjects) {
            [_delegate deleteApp:app];
            [toDelete addObject:app];
        }
        [_appsArrayController removeObjects:toDelete];
    }
}

- (void)dealloc {
    
    [_apps release];
    [super dealloc];
}

@end
