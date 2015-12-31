//
//  TPWConstants.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 13.01.13.
//
//

#import "TPWConstants.h"

// Directories.
NSString *const kTPWRootDirectory = @"/";
NSString *const kTPWKeychainDataDirectory = @"data";
NSString *const kTPWKeychainDataDefaultDirectory = @"default";
NSSearchPathDirectory const kTPWSearchPathForLocationOfDocumentsDirectory = NSDocumentDirectory;
NSSearchPathDirectory const kTPWSearchPathForLocationOfPrivateDocumentsDirectory = NSLibraryDirectory;
NSString *const kTPWInboxDirectory = @"Inbox";
NSString *const kTPWPrivateDocumentsDirectory = @"Private Documents";
NSString *const kTPWPrivateKeychainDirectory = @"keychain";
NSString *const kTPWPrivateKeychainTempDirectory = @"keychain-temp";
NSString *const kTPWPrivateZipTempDirectory = @"zip-temp";

// Agile Keychain File Names.
NSString *const kTPWContentsFileName = @"contents.js";
NSString *const kTPWEncryptionKeysFileName = @"encryptionKeys.js";
NSString *const kTPW1PasswordKeysFileName = @"1password.keys";
NSString *const kTPWPasswordHintFileName = @".password.hint";
NSString *const kTPWPrivateKeychainInfoFileName = @"keychain-Info.plist";

// File Extensions.
NSString *const kTPWAgileKeychainFileExtension = @"agilekeychain";
NSString *const kTPW1PasswordFileExtension = @"1password";
NSString *const kTPWZipFileExtension = @"zip";

// Notifications.
NSString *const kTPWNotificationDropboxLinkSuccessful = @"TPWDropboxLinkSuccessfulNotification";
NSString *const kTPWNotificationCheckSyncPossiblity = @"TPWNotificationCheckSyncPossiblity";

// WebDAV
NSStringEncoding const kTPWHttpPercentEncodingCharset = NSUTF8StringEncoding; //see rfc3986, chapter 3.2.2
NSString *const kTPWHttpLastModifiedHeaderFieldKey = @"Last-Modified";