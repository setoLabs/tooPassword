//
//  TPWConstants.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 13.01.13.
//
//

// Directories.
extern NSString *const kTPWRootDirectory;
extern NSString *const kTPWKeychainDataDirectory;
extern NSString *const kTPWKeychainDataDefaultDirectory;
extern NSSearchPathDirectory const kTPWSearchPathForLocationOfDocumentsDirectory;
extern NSSearchPathDirectory const kTPWSearchPathForLocationOfPrivateDocumentsDirectory;
extern NSString *const kTPWInboxDirectory;
extern NSString *const kTPWPrivateDocumentsDirectory;
extern NSString *const kTPWPrivateKeychainDirectory;
extern NSString *const kTPWPrivateKeychainTempDirectory;
extern NSString *const kTPWPrivateZipTempDirectory;

// File Names.
extern NSString *const kTPWContentsFileName;
extern NSString *const kTPWEncryptionKeysFileName;
extern NSString *const kTPW1PasswordKeysFileName;
extern NSString *const kTPWPasswordHintFileName;
extern NSString *const kTPWPrivateKeychainInfoFileName;

// File Extensions.
extern NSString *const kTPWAgileKeychainFileExtension;
extern NSString *const kTPW1PasswordFileExtension;
extern NSString *const kTPWZipFileExtension;

// Notifications.
extern NSString *const kTPWNotificationDropboxLinkSuccessful;
extern NSString *const kTPWNotificationCheckSyncPossiblity;

// WebDAV
extern NSStringEncoding const kTPWHttpPercentEncodingCharset;
extern NSString *const kTPWHttpLastModifiedHeaderFieldKey;