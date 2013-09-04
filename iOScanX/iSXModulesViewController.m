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

@implementation iSXModulesViewController {
    
    IBOutlet NSArrayController *_modulesArrayController;
    IBOutlet NSButton *_selectAll;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _modules = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BOOL)moduleExistsWithID:(NSString*)moduleID {
    
    for (iSXModule *module in _modulesArrayController.arrangedObjects) {
        if ([module.ID isEqualToString:moduleID]) {
            return YES;
        }
    }
    return NO;
}


- (NSArray*)selectedModules {
    
    NSMutableArray *sel = [NSMutableArray array];
    for (iSXModule *module in _modulesArrayController.arrangedObjects) {
        if (module.selected) {
            [sel addObject:module];
        }
    }
    return [NSArray arrayWithArray:sel];
}

- (void)addModule:(iSXModule *)module {
    
    [_modulesArrayController addObject:module];
}


- (IBAction)add:(id)sender {
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseFiles = YES;
    openDlg.canChooseDirectories = NO;
    openDlg.allowsMultipleSelection = YES;
    openDlg.allowedFileTypes = [NSArray arrayWithObject:@"isxm"];
    
    [openDlg beginSheetModalForWindow:[self.view window] completionHandler:^(NSInteger result) {
        
        if (result == NSOKButton) {
            
            for(NSURL *module in [openDlg URLs])
            {
                [_delegate addModule:[module path]];
            }
        }
    }];
}

- (IBAction)delete:(id)sender {
    
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Are you sure you want to delete the selected modules?"];
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
        for (iSXModule *module in _modulesArrayController.selectedObjects) {
            [_delegate deleteModule:module];
            [toDelete addObject:module];
        }
        [_modulesArrayController removeObjects:toDelete];
    }
}

- (void)dealloc {
    
    [_modules release];
    [super dealloc];
}

- (IBAction)selectAll:(id)sender {
    
    for (iSXModule *module in _modulesArrayController.arrangedObjects) {
        module.selected = _selectAll.state;
    }
}

// NSTableView's delegate methods:

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    iSXModule *module = [_modulesArrayController.arrangedObjects objectAtIndex:row];
    
    return 4 + module.metrics.count*14;
}

//

@end
