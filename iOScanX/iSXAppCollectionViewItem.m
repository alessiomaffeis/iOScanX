//
//  iSXAppCollectionViewItem.m
//  iOScanX
//
//  Created by Alessio Maffeis on 03/09/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXAppCollectionViewItem.h"
#import "iSXAppView.h"

@interface iSXAppCollectionViewItem ()

@end

@implementation iSXAppCollectionViewItem

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setSelected:(BOOL)sel
{
    [super setSelected:sel];
    [(iSXAppView*)[self view] setSelected:sel];
    [(iSXAppView*)[self view] setNeedsDisplay:YES];
}

@end
