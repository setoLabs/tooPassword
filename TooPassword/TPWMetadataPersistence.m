//
//  TPWMetadataPersistence.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 29.04.13.
//
//

#import "TPWMetadataPersistence.h"

NSString *const kTPWMetadataKeyFormat = @"Format";
NSString *const kTPWMetadataKeyProductVersion = @"ProductVersion";
NSString *const kTPWMetadataKeyImportDate = @"ImportDate";
NSString *const kTPWMetadataKeyModificationDate = @"ModificationDate";
NSString *const kTPWMetadataKeyPath = @"Path";
NSString *const kTPWMetadataKeySource = @"Source";
NSString *const kTPWMetadataKeyRevisionNumbers = @"RevisionNumbers";

NSString *const kTPWMetadataValueFormat = @"AgileKeychain";
NSString *const kTPWMetadataValueSourceDropbox = @"Dropbox";
NSString *const kTPWMetadataValueSourceiTunes = @"iTunes";
NSString *const kTPWMetadataValueSourceWebDAV = @"WebDAV";