//
//  AppDelegate.h
//  MultiUp Manager
//
//  Created by Thomas Guider on 26/01/2014.
//  Copyright (c) 2014 Thomas Guider. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSString *user;
    NSString *urlFile;
    NSString *fastestServer;
    NSDictionary *hosts;
    NSDictionary *checkLinkDico;
    NSDictionary *upload;
    NSDictionary *files;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSSecureTextField *password;
@property (weak) IBOutlet NSTextField *login;
@property (weak) IBOutlet NSTextField *filename;
@property (weak) IBOutlet NSTextField *name;
@property (weak) IBOutlet NSTextField *hash;
@property (weak) IBOutlet NSTextField *size;
@property (weak) IBOutlet NSTextField *type;
@property (weak) IBOutlet NSTextField *url;
@property (weak) IBOutlet NSImageView *status;
@property (weak) IBOutlet NSImageView *status2;
@property (unsafe_unretained) IBOutlet NSPanel *panel;
@property (weak) IBOutlet NSProgressIndicator *progres;

- (IBAction)openLink:(id)sender;
- (IBAction)connexion:(id)sender;
- (IBAction)sauvegarder:(id)sender;
- (IBAction)chooseFile:(id)sender;
- (IBAction)uploadFile:(id)sender;

- (void)getFastestServer;
- (void)getListHosts;
- (void)getListFilesForUser:(NSString *)username WithPassword:(NSString *)password;
- (void)checkLink:(NSString *)link;
- (void)upload:(NSString *)serverUrl UserId:(NSString *)userId Hosters:(NSDictionary *)hosters;

@end
