//
//  iSXAppController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXAppController.h"
#import "NSFileManager+DirectoryLocations.h"
#import "ZipFile.h"
#import "FileInZipInfo.h"

@implementation iSXAppController {
    
    IBOutlet NSToolbar *_toolbar;
    NSView *_currentView;
    iSXImportViewController *_importViewController;
    iSXAppsViewController *_appsViewController;
    iSXModulesViewController *_modulesViewController;
    iSXEvaluationsViewController *_evaluationsViewController;
    iSXResultsViewController *_resultsViewController;
}

- (id) init {
    [super init];
    if (self) {
        _scanner = [[SXScanner alloc] init];
        _importViewController = [[iSXImportViewController alloc] initWithNibName:@"iSXImportViewController" bundle:nil];
        _appsViewController = [[iSXAppsViewController alloc] initWithNibName:@"iSXAppsViewController" bundle:nil];
        _modulesViewController = [[iSXModulesViewController alloc] initWithNibName:@"iSXModulesViewController" bundle:nil];
        _evaluationsViewController = [[iSXEvaluationsViewController alloc] initWithNibName:@"iSXEvaluationsViewController" bundle:nil];
        _resultsViewController = [[iSXResultsViewController alloc] initWithNibName:@"iSXResultsViewController" bundle:nil];
    }
    return self;
}

- (void)initialize {
    
    [_toolbar setSelectedItemIdentifier:@"ImportView"];
    [self.mainView addSubview:[_importViewController view]];
    _currentView = [_importViewController view];
    [[_importViewController view] setFrame:[self.mainView bounds]];
    //[self performSelectorInBackground:@selector(loadApps) withObject:nil];
}

- (void)loadApps {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *srcPath = [fm iTunesMobileAppsDirectory];
    NSString *asPath = [fm applicationSupportDirectory];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:srcPath];
    NSString *ipa;
    int bufSize = 65536;
    while (ipa = [de nextObject]) {
        
        if ([[ipa pathExtension] isEqualToString:@"ipa"]) {
            
            NSString *subPath = [NSString stringWithFormat:@"Apps/%@", ipa];
            NSString *dstPath = [asPath stringByAppendingPathComponent:subPath];
            
            if (![fm fileExistsAtPath:dstPath]) {
            
                [fm createDirectoryAtPath:dstPath withIntermediateDirectories:NO attributes:nil error:nil];
                
                ZipFile *zip= [[ZipFile alloc] initWithFileName:[srcPath stringByAppendingPathComponent:ipa] mode:ZipFileModeUnzip];
                
                NSMutableData *buffer= [[NSMutableData alloc] initWithLength:bufSize];
                
                // Loop on file list
                NSArray *zipContentList= [zip listFileInZipInfos];
                for (FileInZipInfo *fileInZipInfo in zipContentList) {
                    
                    // Check if it's a directory
                    if ([fileInZipInfo.name hasSuffix:@"/"]) {
                        NSString *dirPath= [dstPath stringByAppendingPathComponent:fileInZipInfo.name];
                        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:NULL];
                        continue;
                    }
                    
                    // Create file
                    NSString *filePath= [dstPath stringByAppendingPathComponent:fileInZipInfo.name];
                    [[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:nil];
                    NSFileHandle *file= [NSFileHandle fileHandleForWritingAtPath:filePath];
                    
                    // Seek file in zip
                    [zip locateFileInZip:fileInZipInfo.name];
                    ZipReadStream *readStream= [zip readCurrentFileInZip];
                    
                    // Reset buffer
                    [buffer setLength:bufSize];
                    
                    // Loop on read stream
                    int totalBytesRead= 0;
                    do {
                        int bytesRead= [readStream readDataWithBuffer:buffer];
                        if (bytesRead > 0) {
                            
                            // Write data
                            [buffer setLength:bytesRead];
                            [file writeData:buffer];
                            
                            totalBytesRead += bytesRead;
                            
                        } else
                            break;
                        
                    } while (YES);
                    
                    // Close file
                    [file closeFile];
                    [readStream finishedReading];
                }
                
                // Close zip and release buffer
                [buffer release];
                [zip close];
                [zip release];
            }
                       
            iSXApp *app = [[iSXApp alloc] init];
            app.name = ipa;
            app.iconPath = [dstPath stringByAppendingPathComponent:@"iTunesArtwork"];
            [_appsViewController performSelectorOnMainThread:@selector(addApp:) withObject:app waitUntilDone: NO];
        }
    }

    
    
}

// UI related methods:

- (IBAction)showImport:(id)sender {
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_importViewController view]];
    _currentView = [_importViewController view];
    [[_importViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showApps:(id)sender {
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_appsViewController view]];
    _currentView = [_appsViewController view];
    [[_appsViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showModules:(id)sender {

    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_modulesViewController view]];
    _currentView = [_modulesViewController view];
    [[_modulesViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showEvaluations:(id)sender {
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_evaluationsViewController view]];
    _currentView = [_evaluationsViewController view];
    [[_evaluationsViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showResults:(id)sender {
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_resultsViewController view]];
    _currentView = [_resultsViewController view];
    [[_resultsViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)toggleStart:(id)sender {
    
    iSXApp *test = [[iSXApp alloc] init];
    [_appsViewController addApp:test];
}


// NSToolbar delegates methods:

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar;
{    
    return [NSArray arrayWithObjects:@"ImportView",
            @"AppsView",
            @"ModulesView",
            @"EvaluationsView",
            @"ResultsView", nil];
}

//

- (void) dealloc {
    
    [_appsViewController release];
    [_modulesViewController release];
    [_evaluationsViewController release];
    [_resultsViewController release];
    [_scanner release];
    [super dealloc];
}

@end
