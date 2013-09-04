//
//  iSXAppController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXAppController.h"
#import "NSFileManager+DirectoryLocations.h"

@implementation iSXAppController {
    
    IBOutlet NSToolbar *_toolbar;
    NSView *_currentView;
    iSXImportViewController *_importViewController;
    iSXAppsViewController *_appsViewController;
    iSXModulesViewController *_modulesViewController;
    iSXEvaluationsViewController *_evaluationsViewController;
    iSXResultsViewController *_resultsViewController;
    iSXProgressSheetController *_progressSheetController;
    NMSSHSession *_ssh, *_scp;
    NSTask *_relay;
    NSString *_user, *_address, *_password;
}

- (id) init {
    self = [super init];
    if (self) {
        _scanner = [[SXScanner alloc] init];
        _importViewController = [[iSXImportViewController alloc] initWithNibName:@"iSXImportViewController" bundle:nil];
        _appsViewController = [[iSXAppsViewController alloc] initWithNibName:@"iSXAppsViewController" bundle:nil];
        _modulesViewController = [[iSXModulesViewController alloc] initWithNibName:@"iSXModulesViewController" bundle:nil];
        _evaluationsViewController = [[iSXEvaluationsViewController alloc] initWithNibName:@"iSXEvaluationsViewController" bundle:nil];
        _resultsViewController = [[iSXResultsViewController alloc] initWithNibName:@"iSXResultsViewController" bundle:nil];
        _progressSheetController = [[iSXProgressSheetController alloc] init];
        _importViewController.delegate = self;
        _appsViewController.delegate = self;
        _modulesViewController.delegate = self;
        _evaluationsViewController.delegate = self;
    }
    return self;
}

- (void)initialize {
    
    [_toolbar setSelectedItemIdentifier:@"ImportView"];
    [self.mainView addSubview:[_importViewController view]];
    _currentView = [_importViewController view];
    [[_importViewController view] setFrame:[self.mainView bounds]];
}

- (void)loadApps {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *appsPath = [fm applicationSupportSubDirectory:@"Apps"];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:appsPath];
    NSString *appID;
    
    while (appID = [de nextObject]) {
        
        if(appID.length==36 && ![_appsViewController appExistsWithID:appID]) {
        
            iSXApp *app = [[[iSXApp alloc] init] autorelease];
            app.ID = appID;
            NSString *appFolder = [appsPath stringByAppendingPathComponent:appID];
            NSDirectoryEnumerator *ade = [fm enumeratorAtPath:appFolder];
            NSString *appFile;
            while (appFile = [ade nextObject]) {
                if ([[appFile pathExtension] isEqualToString:@"tar"]) {
                    app.name = [appFile stringByDeletingPathExtension];
                    app.path = [appFolder stringByAppendingPathComponent:appFile];
                    app.iconPath = [appFolder stringByAppendingPathComponent:@"iTunesArtwork"];
                    [_appsViewController performSelectorOnMainThread:@selector(addApp:) withObject:app waitUntilDone: NO];
                    break;
                }
            }
        }
    }
}

- (void)loadModules {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *modulesPath = [fm applicationSupportSubDirectory:@"Modules"];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:modulesPath];
    NSString *moduleID;
    
    while (moduleID = [de nextObject]) {
        
        if (![_modulesViewController moduleExistsWithID:moduleID]) {
            
            iSXModule *module = [[[iSXModule alloc] init] autorelease];
            module.ID = moduleID;
            NSString *moduleFolder = [modulesPath stringByAppendingPathComponent:moduleID];
            NSDirectoryEnumerator *ade = [fm enumeratorAtPath:moduleFolder];
            NSString *moduleFile;
            while (moduleFile = [ade nextObject]) {
                if ([[moduleFile pathExtension] isEqualToString:@"isxm"]) {
                    NSDictionary *moduleData = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/Contents/Resources/Module.plist", moduleFolder, moduleFile]];
                    module.name = [moduleData objectForKey:@"name"];
                    module.prefix = [moduleData objectForKey:@"prefix"];
                    module.metrics = [moduleData objectForKey:@"metrics"];
                    module.path = [moduleFolder stringByAppendingPathComponent:moduleFile];
                    [_modulesViewController performSelectorOnMainThread:@selector(addModule:) withObject:module waitUntilDone: NO];
                    break;
                }
            }
        }
    }
}

- (void)loadEvaluations {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *evalPlist = [[fm applicationSupportSubDirectory:@"Evaluations"] stringByAppendingPathComponent:@"Evaluations.plist"];
    if ([_evaluationsViewController count] == 0 && [fm fileExistsAtPath:evalPlist]) {
        NSArray *evals = [NSArray arrayWithContentsOfFile:evalPlist];
        for (NSDictionary *eval in evals) {
            iSXEvaluation *evaluation = [[[iSXEvaluation alloc] init] autorelease];
            evaluation.name = [eval objectForKey:@"name"];
            evaluation.expression = [eval objectForKey:@"expression"];
            [_evaluationsViewController performSelectorOnMainThread:@selector(addEvaluation:) withObject:evaluation waitUntilDone: NO];
        }
    }
}

- (void)importApps {
    
    _progressSheetController.isIndeterminate = YES;
    _progressSheetController.message = @"Connecting to the device";
    [_progressSheetController showSheet:[_mainView window]];

    NSString *host = nil;
    
    if (_address == nil)
    {
        if(_relay == nil)
        {
            host = @"127.0.0.1:2222";
            NSString *tcprelayPath = [[NSBundle mainBundle] pathForResource:@"tcprelay" ofType:@"py"];
            NSString *pythonPath = @"/usr/bin/python";
            NSArray *args = [NSArray arrayWithObjects:tcprelayPath, @"-t", @"22:2222", nil];
            _relay = [[NSTask alloc] init];
            [_relay setLaunchPath:pythonPath];
            [_relay setArguments:args];
            [_relay launch];
            [NSThread sleepForTimeInterval:2];
        }
    }
    else
    {
        host = [NSString stringWithFormat:@"%@:22", _address];
    }
    
    _ssh = [NMSSHSession connectToHost:host withUsername:_user];
    _scp = [NMSSHSession connectToHost:host withUsername:_user];
    
    
    if (_ssh.isConnected && _scp.isConnected)
    {
        [_ssh authenticateByPassword:_password];
        [_scp authenticateByPassword:_password];
        
        if (_ssh.isAuthorized && _scp.isAuthorized )
        {
            [_progressSheetController updateMessage:@"Loading applications"];
            
            BOOL copiedDlyb = [_scp.channel uploadFile:[[NSBundle mainBundle] pathForResource:@"dumpdecrypted" ofType:@"dylib"] to:@"/var/local/"];
            
            if (copiedDlyb)
            {
                NSError *error = nil;
                NSString *response = [_ssh.channel execute:@"find /var/mobile/Applications/ $PWD -maxdepth 2 | grep .app$" error:&error];
                
                if (response != nil)
                {
                    NSArray *items = [response componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                    
                    iSXSelectWindowController *selDialog = [[iSXSelectWindowController alloc]init];
                    
                    [selDialog addApps:items];
                    [selDialog show:[_mainView window]];
                    
                    if (selDialog.selectedApps && selDialog.selectedApps.count>0)
                    {
                        NSFileManager *fm = [NSFileManager defaultManager];
                        NSString *asPath = [fm applicationSupportDirectory];
                        
                        _progressSheetController.minValue = 0;
                        _progressSheetController.maxValue = selDialog.selectedApps.count*2;
                        _progressSheetController.value = 0;
                        [_progressSheetController updateIsIndeterminate:NO];
                        
                        int i = 1;
                        for (NSDictionary *app in selDialog.selectedApps)
                        {
                            NSString *appName = [app objectForKey:@"name"];
                            NSString *appPath = [app objectForKey:@"path"];
                            NSString *appID = [appPath lastPathComponent];
                            
                            if (appID.length==36)
                            {
                                [_progressSheetController updateMessage:[NSString stringWithFormat:@"Decrypting: %@", appName]];
                                
                                NSString *subPath = [NSString stringWithFormat:@"Apps/%@", appID];
                                NSString *dstPath = [asPath stringByAppendingPathComponent:subPath];
                                
                                if ([fm fileExistsAtPath:dstPath])
                                    [fm removeItemAtPath:dstPath error:nil];
                                
                                [fm createDirectoryAtPath:dstPath withIntermediateDirectories:YES attributes:nil error:nil];
                                
                                NSString *binaryName = [appName stringByDeletingPathExtension];
                                NSString *escAppName = [appName stringByReplacingOccurrencesOfString:@" "
                                                                                          withString:@"\\ "];
                                NSString *escBinName = [binaryName stringByReplacingOccurrencesOfString:@" "
                                                                                             withString:@"\\ "];
                                
                                NSString *decrypted = [_ssh.channel execute:[NSString stringWithFormat:@"DYLD_INSERT_LIBRARIES=/var/local/dumpdecrypted.dylib /var/mobile/Applications/%@/%@/%@", appID, escAppName, escBinName] error:&error];
                                
                                if (decrypted != nil)
                                {
                                    [_progressSheetController incrementValue];
                                    [_progressSheetController updateMessage:[NSString stringWithFormat:@"Copying: %@", appName]];
                                    
                                    NSString *artwork = [NSString stringWithFormat:@"/var/mobile/Applications/%@/iTunesArtwork", appID];
                                    NSString *meta = [NSString stringWithFormat:@"/var/mobile/Applications/%@/iTunesMetadata.plist", appID];
                                    NSString *bundle = [NSString stringWithFormat:@"/var/mobile/Applications/%@/%@", appID, appName];
                                    NSString *tar = [bundle stringByAppendingPathExtension:@"tar"];
                                    
                                    NSString *tarred = [_ssh.channel execute:[NSString stringWithFormat:@"tar -cf %@ --directory=/var/mobile/Applications/%@ %@", tar, appID, appName] error:&error];
                                    
                                    BOOL ok = YES;

                                    if (tarred != nil)
                                    {
                                        ok &= [_scp.channel downloadFile:artwork to:[dstPath stringByAppendingPathComponent:@"iTunesArtWork" ]];
                                        ok &= [_scp.channel downloadFile:meta to:[dstPath stringByAppendingPathComponent:@"iTunesMetadata.plist"]];
                                        ok &= [_scp.channel downloadFile:tar to:[dstPath stringByAppendingPathComponent:[tar lastPathComponent]]];
                                        [_ssh.channel execute:[NSString stringWithFormat:@"rm -rf %@", tar] error:&error];
                                    }
                                    else
                                    {
                                        ok = NO;
                                    }
                                    
                                    if (!ok)
                                    {
                                        [fm removeItemAtPath:dstPath error:nil];
                                        [[NSAlert alertWithMessageText:@"Import error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"It was not possible to import the application from the device."] runModal];
                                    }
                                }
                                else
                                {
                                    [fm removeItemAtPath:dstPath error:nil];
                                    [[NSAlert alertWithError:error] runModal];
                                }
                            }
                            [_progressSheetController incrementValue];
                            i++;
                        }
                    }
                    [selDialog release];
                }
                else
                {
                    [[NSAlert alertWithError:error] runModal];
                }
                
            }
            else
            {
                [[NSAlert alertWithMessageText:@"Connection closed" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"It was not possible to import the applications from the device."] runModal];
            }
            
        }
        else
        {
            [[NSAlert alertWithMessageText:@"Authentication failed" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please check your SSH User and Password and try again."] runModal];
        }
    }
    else
    {
        [[NSAlert alertWithMessageText:@"Connection failed" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"It was not possible to establish a connection with the device."] runModal];
    }
    
    [_scp disconnect];
    [_ssh disconnect];
    
    [_relay terminate];
    [_relay release];
    _relay = nil;
    [_progressSheetController closeSheet];

}

- (void)startScanning {
    
    NSArray *apps = [_appsViewController selectedApps];
    for (iSXApp *app in apps) {
        [_scanner addItem:app withId:app.ID];
    }
    
    NSLog(@"Number of items: %lu",_scanner.items.count);
    
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
    [self performSelectorInBackground:@selector(loadApps) withObject:nil];
}

- (IBAction)showModules:(id)sender {

    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_modulesViewController view]];
    _currentView = [_modulesViewController view];
    [[_modulesViewController view] setFrame:[self.mainView bounds]];
    [self performSelectorInBackground:@selector(loadModules) withObject:nil];
}

- (IBAction)showEvaluations:(id)sender {
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_evaluationsViewController view]];
    _currentView = [_evaluationsViewController view];
    [[_evaluationsViewController view] setFrame:[self.mainView bounds]];
    [self performSelectorInBackground:@selector(loadEvaluations) withObject:nil];

}

- (IBAction)showResults:(id)sender {
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_resultsViewController view]];
    _currentView = [_resultsViewController view];
    [[_resultsViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)toggleStart:(id)sender {
    
    [self performSelectorInBackground:@selector(startScanning) withObject:nil];

}

// iSXImportViewController delegate's methods:

- (void)connectWithUsername:(NSString*)user andPassword:(NSString*)password toAddress:(NSString*)address {
    
    _user = user;
    _password = password;
    _address = address;
    
    [self importApps];
}

// iSXAppsViewController delegate's methods:

- (void)deleteApp:(iSXApp*)app {
 
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *appsPath = [fm applicationSupportSubDirectory:@"Apps"];
    [fm removeItemAtPath:[appsPath stringByAppendingPathComponent:app.ID] error:nil];
}

// iSXModulesViewController delegate's methods:

- (BOOL)addModule:(NSString*)path {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *modulesPath = [fm applicationSupportSubDirectory:@"Modules"];
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingString:@"/Contents/Info.plist"]];
    if(info == nil)
        return NO;
    if(![[info objectForKey:@"NSPrincipalClass"] isEqualToString:@"iSXMAnalysisModule"])
        return NO;
    NSString *moduleID = [info objectForKey:@"CFBundleIdentifier"];
    NSString *moduleFolder = [modulesPath stringByAppendingPathComponent:moduleID];
    NSString *modulePath = [moduleFolder stringByAppendingPathComponent:[path lastPathComponent]];
    if ([fm fileExistsAtPath:moduleFolder])
        [fm removeItemAtPath:moduleFolder error:nil];
    [fm createDirectoryAtPath:moduleFolder withIntermediateDirectories:YES attributes:nil error:nil];
    [fm copyItemAtPath:path toPath:modulePath error:nil];
    [self performSelectorInBackground:@selector(loadModules) withObject:nil];

    return YES;
}

- (void)deleteModule:(iSXModule*)module {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *modulesPath = [fm applicationSupportSubDirectory:@"Modules"];
    [fm removeItemAtPath:[modulesPath stringByAppendingPathComponent:module.ID] error:nil];
}

// iSXEvaluationsViewController delegate's methods:

- (void)saveEvaluations:(NSArray*)evaluations {
    
    NSString *evalPath = [[NSFileManager defaultManager] applicationSupportSubDirectory:@"Evaluations"];
    [evaluations writeToFile:[evalPath stringByAppendingPathComponent:@"Evaluations.plist"] atomically:YES];
    
}


// NSToolbar delegate's methods:

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar;
{    
    return [NSArray arrayWithObjects:@"ImportView",
            @"AppsView",
            @"ModulesView",
            @"EvaluationsView",
            @"ResultsView", nil];
}


- (void) dealloc {
    
    [_progressSheetController release];
    [_importViewController release];
    [_appsViewController release];
    [_modulesViewController release];
    [_evaluationsViewController release];
    [_resultsViewController release];
    [_scanner release];
    [super dealloc];
}

@end
