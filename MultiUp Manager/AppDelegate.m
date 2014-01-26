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
@synthesize md5 = _md5;
@synthesize sha = _sha;
@synthesize url = _url;

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
            
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:NSLocalizedString(@"Success", nil)];
            [alert setInformativeText:NSLocalizedString(@"Connexion réussi.", nil)];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert runModal];
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:NSLocalizedString(@"Error", nil)];
            [alert setInformativeText:NSLocalizedString([responseData objectForKey:@"error"], nil)];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert runModal];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:NSLocalizedString(@"Error", nil)];
        [alert setInformativeText:NSLocalizedString(@"Impossible de se connecter avec ses identifiants.", nil)];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert runModal];
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
    
    if ( [openDlg runModal] == NSOKButton )
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
    [_md5 setStringValue:@""];
    [_sha setStringValue:@""];
    [_url setStringValue:@""];
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
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:NSLocalizedString(@"Error", nil)];
            [alert setInformativeText:NSLocalizedString([responseData objectForKey:@"error"], nil)];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert runModal];
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
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:NSLocalizedString(@"Error", nil)];
            [alert setInformativeText:NSLocalizedString([responseData objectForKey:@"error"], nil)];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert runModal];
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
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:NSLocalizedString(@"Error", nil)];
            [alert setInformativeText:NSLocalizedString([responseData objectForKey:@"error"], nil)];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert runModal];
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
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:NSLocalizedString(@"Error", nil)];
            [alert setInformativeText:NSLocalizedString([responseData objectForKey:@"error"], nil)];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert runModal];
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
            
            [_name setStringValue:[upload objectForKey:@"name"]];
            [_hash setStringValue:[upload objectForKey:@"hash"]];
            [_size setStringValue:[upload objectForKey:@"size"]];
            [_type setStringValue:[upload objectForKey:@"type"]];
            [_md5 setStringValue:[upload objectForKey:@"md5"]];
            [_sha setStringValue:[upload objectForKey:@"sha"]];
            [_url setStringValue:[upload objectForKey:@"url"]];
        } else {
            NSLog(@"Erreur upload");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
