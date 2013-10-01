//
//  iSXResultsViewController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 20/06/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXResultsViewController.h"

@interface iSXResultsViewController ()

@end

@implementation iSXResultsViewController {
    
    IBOutlet NSButton *_exportButton;
    IBOutlet NSOutlineView *_outlineView;
    NSMutableArray *_apps;
    NSMutableDictionary *_evaluations;
    NSUInteger _evalCount;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    
    return self;
}


- (void) updateResults:(NSMutableDictionary *)results {
    
    if (_apps != nil)
        [_apps release];
    if (_evaluations != nil)
        [_evaluations release];
    
    _apps = [[NSMutableArray alloc] init];
    _evaluations = [[NSMutableDictionary alloc] init];
    
    NSDictionary *evaluations;
    
    for (NSString *appID in results) {
        
        NSString *name = [[results objectForKey:appID] objectForKey:@"name"];
        evaluations = [[results objectForKey:appID] objectForKey:@"evaluations"];
        [_apps addObject:name];
        [_evaluations setObject:evaluations forKey:name];
    }
    
    if (evaluations != nil) {
        _evalCount = evaluations.count;
    }
    [_exportButton setEnabled:YES];
    [_outlineView reloadData];
}

- (IBAction)export:(id)sender {
    
    [_delegate exportResults];
}


//  NSOutlineViewDelegate methods:

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    
    if (![_apps containsObject:item])
    {
        return 18 * _evalCount;
    }
    
    return 17;
}


// NSOutlineViewDataSource methods:

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    
    if (item == nil) { //item is nil when the outline view wants to inquire for root level items
        return [_apps objectAtIndex:index];
    }
    else
    {
        return [[[[_evaluations objectForKey:item] description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{} \n"]] retain];
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([_apps containsObject:item])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    
    if (item == nil)
    {
        return [_apps count];
    }
    
    if ([_apps containsObject:item])
    {
        return 1;
    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return item;
}

@end
