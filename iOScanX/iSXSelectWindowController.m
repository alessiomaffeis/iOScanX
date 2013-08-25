//
//  iSXSelectWindowController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 24/08/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXSelectWindowController.h"

@implementation iSXSelectWindowController {
    
    IBOutlet NSWindow *_selectWindow;
    IBOutlet NSArrayController *_arrayController;
    IBOutlet NSTableView *_tableView;
    IBOutlet NSButton *_selectAll;
    NSArray *_paths;
}


- (IBAction)import:(id)sender {
    
    _selectedApps = [[NSMutableArray alloc]init];
    NSIndexSet *indexSet = [_arrayController selectionIndexes];
    NSUInteger index = [indexSet firstIndex];
    while (index != NSNotFound) {
        [_selectedApps addObject:[_arrayController.arrangedObjects objectAtIndex:index]];
        index = [indexSet indexGreaterThanIndex:index];
    }

    [NSApp stopModal];
}

- (IBAction)selectAll:(id)sender; {
    
    if (_selectAll.state == NSOnState)
    {
        [_tableView selectAll:sender];
    }
    else
    {
        [_tableView deselectAll:sender];
    }
}

- (void) show:(NSWindow*)window {
    
    if (_selectWindow == nil)
        [NSBundle loadNibNamed: @"iSXSelectWindow" owner: self];
    
    [NSApp beginSheet: _selectWindow
       modalForWindow: window
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    [NSApp runModalForWindow: _selectWindow];
    [NSApp endSheet: _selectWindow];
    [_selectWindow orderOut: self];
    
}

- (void)addApps:(NSArray*)paths {
    
    _paths = paths;
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    
    for(NSString *path in _paths)
    {
        if(path.length>61)
            [_arrayController addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys: [path stringByDeletingLastPathComponent], @"path", [path lastPathComponent], @"name", nil]];
    }
    [_arrayController setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
}

- (void)dealloc{
    
    [_selectedApps release];
    [super dealloc];
}


@end
