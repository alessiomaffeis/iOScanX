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
    NSMutableDictionary *_moduleInstances;
    NSMutableDictionary *_results;
    BOOL _loadingApps, _loadingModules, _loadingEvaluations, _loadingResults;
}

- (id) init {
    self = [super init];
    if (self) {
        _moduleInstances = [[NSMutableDictionary alloc] init];
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
        _resultsViewController.delegate = self;
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
            NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[appFolder stringByAppendingPathComponent:@"Info.plist"]];
            NSDirectoryEnumerator *ade = [fm enumeratorAtPath:appFolder];
            NSString *appFile;
            while (appFile = [ade nextObject]) {
                if ([[appFile pathExtension] isEqualToString:@"tar"]) {
                    app.name = [info objectForKey:@"CFBundleDisplayName"];
                    if (app.name == nil) {
                        app.name = [info objectForKey:@"CFBundleName"];
                    }
                    app.bundleName = [appFile stringByDeletingPathExtension];
                    app.executableName = [info objectForKey:@"CFBundleExecutable"];
                    app.path = [appFolder stringByAppendingPathComponent:appFile];
                    NSString *appIcon = [appFolder stringByAppendingPathComponent:@"iTunesArtwork"];
                    app.iconPath = [fm fileExistsAtPath:appIcon] ? appIcon : [[NSBundle mainBundle] pathForResource:@"noIcon" ofType:@"png"];
                    [_appsViewController performSelectorOnMainThread:@selector(addApp:) withObject:app waitUntilDone: YES];
                    break;
                }
            }
        }
    }
    _loadingApps = NO;
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
                    module.prefix = [[moduleData objectForKey:@"prefix"] stringByAppendingString:@"_"];
                    module.metrics = [moduleData objectForKey:@"metrics"];
                    module.path = [moduleFolder stringByAppendingPathComponent:moduleFile];
                    
                    if ([_moduleInstances objectForKey:module.ID] == nil) {
                        
                        NSBundle *bundle = [NSBundle bundleWithPath:module.path];
                        Class moduleClass = [bundle principalClass];
                        if([moduleClass conformsToProtocol:@protocol(SXModule)])
                        {
                            id instance = [[[moduleClass alloc] init] autorelease];
                            [_moduleInstances setObject:instance forKey:module.ID];
                        }
                    }
                    
                    [_modulesViewController performSelectorOnMainThread:@selector(addModule:) withObject:module waitUntilDone: NO];
                    break;
                }
            }
        }
    }
    _loadingModules = NO;
}

- (void)loadEvaluations {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *evalPlist = [[fm applicationSupportSubDirectory:@"Evaluations"] stringByAppendingPathComponent:@"Evaluations.plist"];
    if ([_evaluationsViewController count] == 0 && [fm fileExistsAtPath:evalPlist]) {
        NSArray *evals = [NSArray arrayWithContentsOfFile:evalPlist];
        for (NSDictionary *eval in evals) {
            iSXEvaluation *evaluation = [[[iSXEvaluation alloc] init] autorelease];
            evaluation.ID = [(NSNumber*)[eval objectForKey:@"ID"] unsignedLongValue];
            evaluation.name = [eval objectForKey:@"name"];
            evaluation.expression = [eval objectForKey:@"expression"];
            [_evaluationsViewController performSelectorOnMainThread:@selector(addEvaluation:) withObject:evaluation waitUntilDone: NO];
        }
    }
    _loadingEvaluations = NO;
}

- (void) loadResults {
    
    [_resultsViewController removeAllResults];
    
    for(NSString *appID in _results)
    {
        iSXResult *result = [[[iSXResult alloc] init] autorelease];
        NSDictionary *details = [_results objectForKey:appID];
        result.name = [details objectForKey:@"name"];
        result.evaluations = [details objectForKey:@"evaluations"];
        [_resultsViewController performSelectorOnMainThread:@selector(addResult:) withObject:result waitUntilDone:NO];
    }
    _loadingResults = NO;
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
                        _progressSheetController.maxValue = selDialog.selectedApps.count*3;
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
                                
                                NSString *escAppName = [appName stringByReplacingOccurrencesOfString:@"'"
                                                                                          withString:@"'\\''"];
                                
                                NSString *info = [NSString stringWithFormat:@"/var/mobile/Applications/%@/%@/Info.plist", appID, escAppName];
                                NSString *infoDst = [dstPath stringByAppendingPathComponent:@"Info.plist"];
                                [_scp.channel downloadFile:info to:infoDst];
                                NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:infoDst];
                                
                                NSString *binaryName = [infoPlist objectForKey:@"CFBundleExecutable"];
                                
                                NSString *escBinName = [binaryName stringByReplacingOccurrencesOfString:@"'"
                                                                                             withString:@"'\\''"];
                                                                
                                NSString *decrypted = [_ssh.channel execute:[NSString stringWithFormat:@"cd '/var/mobile/Applications/%@/%@' && DYLD_INSERT_LIBRARIES=/var/local/dumpdecrypted.dylib '/var/mobile/Applications/%@/%@/%@'",appID, escAppName, appID, escAppName, escBinName] error:&error];
                                
                                if (decrypted != nil)
                                {
                                    [_progressSheetController incrementValue];
                                    [_progressSheetController updateMessage:[NSString stringWithFormat:@"Copying: %@", appName]];
                                    
                                    NSString *artwork = [NSString stringWithFormat:@"/var/mobile/Applications/%@/iTunesArtwork", appID];
                                    NSString *meta = [NSString stringWithFormat:@"/var/mobile/Applications/%@/iTunesMetadata.plist", appID];
                                    NSString *bundle = [NSString stringWithFormat:@"/var/mobile/Applications/%@/%@", appID, escAppName];
                                    
                                    NSString *escTar = [bundle stringByAppendingPathExtension:@"tar"];
                                    NSString *tar = [NSString stringWithFormat:@"/var/mobile/Applications/%@/%@.tar", appID, appName];
                                    
                                    [_ssh.channel execute:[NSString stringWithFormat:@"mv '/var/mobile/Applications/%@/%@/%@' '/var/mobile/Applications/%@/%@'",appID, escAppName, escBinName, appID, escBinName] error:&error];
                                    
                                    NSString *tarred = [_ssh.channel execute:[NSString stringWithFormat:@"tar -cf '%@' '--directory=/var/mobile/Applications/%@' '%@'", escTar, appID, escAppName] error:&error];
                                    
                                    [_ssh.channel execute:[NSString stringWithFormat:@"mv '/var/mobile/Applications/%@/%@' '/var/mobile/Applications/%@/%@/%@'",appID, escBinName, appID, escAppName, escBinName] error:&error];
                                    
                                    [_progressSheetController incrementValue];

                                    BOOL ok = YES;
                                    if (tarred != nil)
                                    {
                                        [_scp.channel downloadFile:artwork to:[dstPath stringByAppendingPathComponent:@"iTunesArtWork" ]];
                                        [_scp.channel downloadFile:meta to:[dstPath stringByAppendingPathComponent:@"iTunesMetadata.plist"]];
                                        ok = [_scp.channel downloadFile:tar to:[dstPath stringByAppendingPathComponent:[tar lastPathComponent]]];
                                        [_ssh.channel execute:[NSString stringWithFormat:@"rm -rf '%@'", escTar] error:&error];
                                    }
                                    else
                                    {
                                        ok = NO;
                                    }
                                    
                                    if (!ok)
                                    {
                                        [fm removeItemAtPath:dstPath error:nil];
                                        [[NSAlert alertWithMessageText:@"Import error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"It was not possible to import %@ from the device.", appName] runModal];
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

- (BOOL)startScanning {
    
    NSArray *apps = [_appsViewController selectedApps];
    if (apps.count == 0)
        return NO;
    
    NSArray *modules = [_modulesViewController selectedModules];
    if(modules.count == 0)
        return NO;
    
    NSUInteger evalsCount = [_evaluationsViewController count];
    if (evalsCount == 0)
        return NO;
    
    if (_scanner != nil)
        [_scanner release];
    
    _scanner = [[SXScanner alloc] init];
    _scanner.delegate = self;
    
    for (iSXApp *app in apps) {
        
        [_scanner addItem:app withId:app.ID];
    }
    
    NSLog(@"Number of apps: %lu",_scanner.items.count);
    
    for (iSXModule *module in modules) {
        
        [_scanner addModule:[_moduleInstances objectForKey:module.ID] withId:module.ID];
    }
    
    NSLog(@"Number of modules: %lu",_scanner.modules.count);
    
    
    _progressSheetController.minValue = 0;
    _progressSheetController.maxValue = apps.count*modules.count;
    _progressSheetController.value = 0;
    _progressSheetController.message = @"Scanning applications";
    _progressSheetController.isIndeterminate = NO;
    [_progressSheetController showSheet:[_mainView window]];

    
    [_scanner performSelectorInBackground:@selector(startScanning) withObject:nil];
    
    return YES;
}

- (BOOL)startEvaluating {
    
    NSArray *evals = [_evaluationsViewController evaluations];
    
    if (evals.count == 0)
        return NO;
    
    for (iSXEvaluation *eval in evals) {
        SXEvaluation *evaluation = [[SXEvaluation alloc] initWithName:eval.name andExpression:eval.expression];
        [_scanner addEvaluation:[evaluation autorelease] withId:[NSString stringWithFormat:@"%lu_%@", eval.ID, eval.name]];
    }
    
    _progressSheetController.minValue = 0;
    _progressSheetController.maxValue = _scanner.items.count*evals.count;
    _progressSheetController.value = 0;
    _progressSheetController.message = @"Computing evaluations";
    _progressSheetController.isIndeterminate = NO;
    [_progressSheetController showSheet:[_mainView window]];
    
    [_scanner performSelectorInBackground:@selector(startEvaluating) withObject:nil];
    
    return YES;
}

// UI related methods:

- (IBAction)showImport:(id)sender {
    
    if(_currentView == [_importViewController view])
        return;
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_importViewController view]];
    _currentView = [_importViewController view];
    [[_importViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showApps:(id)sender {
    
    if(_currentView == [_appsViewController view])
        return;
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_appsViewController view]];
    _currentView = [_appsViewController view];
    [[_appsViewController view] setFrame:[self.mainView bounds]];
    if (!_loadingApps) {
        _loadingApps = YES;
        [self performSelectorInBackground:@selector(loadApps) withObject:nil];
    }
}

- (IBAction)showModules:(id)sender {
    
    if(_currentView == [_modulesViewController view])
        return;

    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_modulesViewController view]];
    _currentView = [_modulesViewController view];
    [[_modulesViewController view] setFrame:[self.mainView bounds]];
    if (!_loadingModules) {
        _loadingModules = YES;
        [self performSelectorInBackground:@selector(loadModules) withObject:nil];
    }
}

- (IBAction)showEvaluations:(id)sender {
    
    if(_currentView == [_evaluationsViewController view])
        return;
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_evaluationsViewController view]];
    _currentView = [_evaluationsViewController view];
    [[_evaluationsViewController view] setFrame:[self.mainView bounds]];
    if (!_loadingEvaluations) {
        _loadingEvaluations = YES;
        [self performSelectorInBackground:@selector(loadEvaluations) withObject:nil];
    }

}

- (IBAction)showResults:(id)sender {
    
    if(_currentView == [_resultsViewController view])
        return;
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_resultsViewController view]];
    _currentView = [_resultsViewController view];
    [[_resultsViewController view] setFrame:[self.mainView bounds]];
    if (!_loadingResults) {
        _loadingResults = YES;
        [self performSelectorInBackground:@selector(loadResults) withObject:nil];
    }

}

- (IBAction)toggleStart:(id)sender {
    
    if(![self startScanning]) {
        
        [[NSAlert alertWithMessageText:@"Scan failed" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"It was not possible to start the scan. Please check your Applications, Modules and Evaluations."] runModal];
    }
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
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [fm removeItemAtPath:[appsPath stringByAppendingPathComponent:app.ID] error:nil];
    });
}

// iSXModulesViewController delegate's methods:

- (BOOL)addModules:(NSArray*)URLs {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *modulesPath = [fm applicationSupportSubDirectory:@"Modules"];
    
    for(NSURL *URL in URLs)
    {
        NSString *path = [URL path];
        NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingString:@"/Contents/Info.plist"]];
        
        if(info == nil)
            return NO;
        
        if([[info objectForKey:@"NSPrincipalClass"] isEqualToString:@"iSXMAnalysisModule"])
            return NO;
        
        NSString *moduleID = [info objectForKey:@"CFBundleIdentifier"];
        if([_moduleInstances objectForKey:moduleID] != nil)
            return NO;
        
        NSString *moduleFolder = [modulesPath stringByAppendingPathComponent:moduleID];
        NSString *modulePath = [moduleFolder stringByAppendingPathComponent:[path lastPathComponent]];
        if ([fm fileExistsAtPath:moduleFolder])
            [fm removeItemAtPath:moduleFolder error:nil];
        [fm createDirectoryAtPath:moduleFolder withIntermediateDirectories:YES attributes:nil error:nil];
        [fm copyItemAtPath:path toPath:modulePath error:nil];
        
        NSBundle *bundle = [NSBundle bundleWithPath:modulePath];
        Class moduleClass = [bundle principalClass];
        if([moduleClass conformsToProtocol:@protocol(SXModule)])
        {
            id instance = [[[moduleClass alloc] init] autorelease];
            [_moduleInstances setObject:instance forKey:moduleID];
        }
        else
        {
            [fm removeItemAtPath:moduleFolder error:nil];
            return NO;
        }
    }
    
    if (_currentView != [_modulesViewController view])
    {
        [self showModules:nil];
    }
    else
    {
        [self performSelectorInBackground:@selector(loadModules) withObject:nil];
    }
    
    _toolbar.selectedItemIdentifier = @"ModulesView";
    
    return YES;
}

- (void)deleteModule:(iSXModule*)module {
    
    [_moduleInstances removeObjectForKey:module.ID];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *modulesPath = [fm applicationSupportSubDirectory:@"Modules"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [fm removeItemAtPath:[modulesPath stringByAppendingPathComponent:module.ID] error:nil];
    });
}

// iSXEvaluationsViewController delegate's methods:

- (void)saveEvaluations:(NSArray*)evaluations {
    
    NSString *evalPath = [[NSFileManager defaultManager] applicationSupportSubDirectory:@"Evaluations"];
    [evaluations writeToFile:[evalPath stringByAppendingPathComponent:@"Evaluations.plist"] atomically:YES];
    
}

// iSXResultsViewController delegate's methods:

- (void)exportResults {
    
    NSSavePanel*    panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"results.xml"];
    [panel beginSheetModalForWindow:[_mainView window] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton)
        {
            NSURL* theFile = [panel URL];
            [_results writeToURL:theFile atomically:YES];
        }
    }];
    }

// SXScanner delegate's methods:

- (void) scanHasFinished {
    
    [self startEvaluating];
}

- (void) evaluationHasFinished {
    
    _progressSheetController.isIndeterminate = YES;
    [_progressSheetController updateMessage:@"Generating results"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *appsPath = [fm applicationSupportSubDirectory:@"Apps"];
    
    if (_results != nil)
        [_results release];
    _results = [[NSMutableDictionary alloc] init];
    
    for (NSString *appID in _scanner.computedEvaluations) {
        NSDictionary *meta = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/iTunesMetadata.plist", appsPath, appID]];
        
        NSString *name = [meta objectForKey:@"bundleDisplayName"] != nil ? [meta objectForKey:@"bundleDisplayName"] : [(iSXApp*)[_scanner.items objectForKey:appID] name];
        NSString *developer = [meta objectForKey:@"artistName"] != nil ? [meta objectForKey:@"artistName"] : @"Undefined";
        NSString *category = [meta objectForKey:@"genre"] != nil ? [meta objectForKey:@"genre"] : @"Undefined";
        NSString *version = [meta objectForKey:@"bundleShortVersionString"];
        if (version == nil)
            version = [meta objectForKey:@"bundleVersion"] != nil ? [meta objectForKey:@"bundleVersion"] : @"Undefined";
        
        NSDictionary *details = [NSDictionary dictionaryWithObjectsAndKeys:
                                 name, @"name",
                                 version, @"version",
                                 developer, @"developer",
                                 category, @"category",
                                 [_scanner.computedEvaluations objectForKey:appID], @"evaluations",
                                 nil];
        [_results setObject:details forKey:appID];
                
        [meta release];
    }
    
    _toolbar.selectedItemIdentifier = @"ResultsView";
    [_scanner release];
    _scanner = nil;
    [_progressSheetController closeSheet];
    [self performSelectorOnMainThread:@selector(showResults:) withObject:nil waitUntilDone:NO];

}

- (void) remainingScansDidChange {
    
    [_progressSheetController updateValue:_progressSheetController.maxValue-_scanner.remainingScans];
}

- (void) remainingEvaluationsDidChange {
    
    [_progressSheetController updateValue:_progressSheetController.maxValue-_scanner.remainingEvaluations];
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
    [_moduleInstances release];
    [super dealloc];
}

@end
