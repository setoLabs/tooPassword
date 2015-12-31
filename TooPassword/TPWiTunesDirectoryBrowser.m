//
//  TPWiTunesDirectoryBrowser.m
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import "NSString+TPWExtensions.h"
#import "TPWFileUtil.h"

#import "TPWiTunesDirectoryBrowser.h"
#import "TPWiTunesAgileKeychainImporter.h"
#import "TPWiTunesZipImporter.h"

@interface TPWiTunesDirectoryBrowser ()
@property (nonatomic, strong) NSString *basePath;
@end

@implementation TPWiTunesDirectoryBrowser

- (id)initWithWorkingDirectory:(NSString *)path basePath:(NSString*)basePath {
	if (self = [super initWithWorkingDirectory:path]) {
		self.basePath = basePath;
	}
	return self;
}

- (id)initWithWorkingDirectory:(NSString *)path {
	return [self initWithWorkingDirectory:path basePath:path];
}

- (TPWAbstractDirectoryBrowser *)browserForWorkingDirectory:(NSString *)path {
	return [[TPWiTunesDirectoryBrowser alloc] initWithWorkingDirectory:path basePath:self.basePath];
}

- (NSString *)relativeWorkingDirectoryForDisplay {
	NSString *relativePath = [self.path substringFromIndex:self.basePath.length];
	if (![relativePath hasPrefix:kTPWStringExtensionsPathSeperator]) {
		relativePath = [kTPWStringExtensionsPathSeperator stringByAppendingString:relativePath];
	}
	return relativePath;
}

- (BOOL)contentsOfDirectoryWillLoadImmediately {
	return YES;
}

- (void)contentsOfDirectory:(TPWContentsOfDirectoryCallback)callback {
	NSError *error = nil;
	NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error];

	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:directoryContents.count];
	
	for (NSString *filename in directoryContents) {
		NSString *filePath = [self.path stringByAppendingPathComponent:filename];
		BOOL isDirectory;
		[[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
		if (isDirectory || [self canImportFileAtPath:filePath]) {
			result[filePath] = filename;
		}
	}
	
	callback(result, error);
}

- (void)cancel {
	// Nothing to cancel.
}

- (NSArray *)suitableImporters {
	TPWiTunesAgileKeychainImporter *agileKeychainImporter = [[TPWiTunesAgileKeychainImporter alloc] init];
	TPWiTunesZipImporter *zipImporter = [[TPWiTunesZipImporter alloc] init];
	return @[agileKeychainImporter, zipImporter];
}

@end
