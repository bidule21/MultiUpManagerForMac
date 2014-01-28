//
//  AppDelegate.m
//  MultiUp Manager
//
//  Created by Thomas Guider on 26/01/2014.
//  Copyright (c) 2014 Thomas Guider. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize password = _password;
@synthesize login = _login;
@synthesize filename = _filename;
@synthesize name = _name;
@synthesize hash = _hash;
@synthesize size = _size;
@synthesize type = _type;
@synthesize url = _url;
@synthesize status = _status;
@synthesize status2 = _status2;
@synthesize panel = _panel;
@synthesize progres = _progres;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    if ([pref stringForKey:@"login"] != nil) {
        [_login setStringValue:[pref stringForKey:@"login"]];
    }
    
    if ([pref stringForKey:@"login"] != nil) {
        [_password setStringValue:[pref stringForKey:@"password"]];
    }
    
    if (![_password.stringValue isEqualToString:@""] && ![_login.stringValue isEqualToString:@""]) {
        [self connexion:self];
    }
}

- (IBAction)openLink:(id)sender {
    if (![[_url stringValue] isEqualToString:@""]) {
        NSURL *url = [NSURL URLWithString:[_url stringValue]];
        if( ![[NSWorkspace sharedWorkspace] openURL:url] )
            NSLog(@"Failed to open url: %@",[url description]);
    }
}

- (IBAction)connexion:(id)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"username": [_login stringValue], @"password": [_password stringValue]};
    [manager POST:@"http://www.multiup.org/api/login" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* responseString = [NSString stringWithUTF8String:[responseObject bytes]];
        NSLog(@"Response: %@", responseString);
        
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        
        if ([[responseData objectForKey:@"error"] isEqualToString:@"success"]) {
            user = [responseData objectForKey:@"user"];
            [_status setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
            [_status2 setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
        } else {
            [_status setImage:[NSImage imageNamed:@"NSStatusUnavailable"]];
            [_status2 setImage:[NSImage imageNamed:@"NSStatusUnavailable"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [_status setImage:[NSImage imageNamed:@"NSStatusUnavailable"]];
        [_status2 setImage:[NSImage imageNamed:@"NSStatusUnavailable"]];
    }];
}

- (IBAction)sauvegarder:(id)sender {
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:[_login stringValue] forKey:@"login"];
    [pref setObject:[_password stringValue] forKey:@"password"];
    [pref synchronize];
}

- (IBAction)chooseFile:(id)sender {
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Multiple files not allowed
    [openDlg setAllowsMultipleSelection:NO];
    
    // Can't select a directory
    [openDlg setCanChooseDirectories:NO];
    
    if ([openDlg runModal] == NSOKButton)
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* urls = [openDlg URLs];
        // Here we take the first one
        urlFile = [[urls objectAtIndex:0]path];
        [_filename setStringValue:urlFile];
    }
}

- (IBAction)uploadFile:(id)sender {
    [_name setStringValue:@""];
    [_hash setStringValue:@""];
    [_size setStringValue:@""];
    [_type setStringValue:@""];
    [_url setStringValue:@""];
    [_panel makeKeyAndOrderFront:self];
    [_panel setAlphaValue:0.7];
    [_progres startAnimation:nil];
    [self getFastestServer];
}

- (void)getFastestServer {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://www.multiup.org/api/get-fastest-server" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* responseString = [NSString stringWithUTF8String:[responseObject bytes]];
        NSLog(@"Response: %@", responseString);
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if ([[responseData objectForKey:@"error"] isEqualToString:@"success"]) {
            fastestServer = [responseData objectForKey:@"server"];
            [self getListHosts];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)getListHosts {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://www.multiup.org/api/get-list-hosts" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* responseString = [NSString stringWithUTF8String:[responseObject bytes]];
        NSLog(@"Response: %@", responseString);
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if ([[responseData objectForKey:@"error"] isEqualToString:@"success"]) {
            hosts = [responseData objectForKey:@"hosts"];
            [self upload:fastestServer UserId:user Hosters:hosts];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)getListFilesForUser:(NSString *)username WithPassword:(NSString *)password {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"username": username, @"password": password};
    [manager POST:@"http://www.multiup.org/api/list-files" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* responseString = [NSString stringWithUTF8String:[responseObject bytes]];
        NSLog(@"Response: %@", responseString);
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if ([[responseData objectForKey:@"error"] isEqualToString:@"success"]) {
            files = [responseData objectForKey:@"files"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)checkLink:(NSString *)link {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"link": link};
    [manager POST:@"http://www.multiup.org/api/check-file" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* responseString = [NSString stringWithUTF8String:[responseObject bytes]];
        NSLog(@"Response: %@", responseString);
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if ([[responseData objectForKey:@"error"] isEqualToString:@"success"]) {
            checkLinkDico = responseData;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)upload:(NSString *)serverUrl UserId:(NSString *)userId Hosters:(NSDictionary *)hosters {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // ajout hosts boolean
    
    NSURL *filePath = [NSURL fileURLWithPath:urlFile];
    NSDictionary *parameters = @{@"user": userId};
    [manager POST:serverUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePath name:@"files" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* responseString = [NSString stringWithUTF8String:[responseObject bytes]];
        NSLog(@"Response: %@", responseString);
        if (![responseString isEqualToString:@"[]"] || responseString != nil) {
            NSArray *responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            upload = [responseData objectAtIndex:0];
            [_panel orderOut:self];
            [_name setStringValue:[upload objectForKey:@"name"]];
            [_hash setStringValue:[upload objectForKey:@"hash"]];
            [_size setStringValue:[upload objectForKey:@"size"]];
            [_type setStringValue:[upload objectForKey:@"type"]];
            [_url setStringValue:[upload objectForKey:@"url"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [_panel orderOut:self];
    }];
}

@end
