//
//  TPWWebDAVSyncChecker.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 06.12.13.
//
//

#import "TPWWebDAVSyncChecker.h"
#import "TPWWebDAVAgileKeychainImporter.h"
#import "TPWPooledAsyncHttpClient.h"
#import "TPWReachability.h"
#import "NSDate+RFCFormats.h"
#import "TPWFileUtil.h"
#import "NSString+TPWExtensions.h"
#import "TPWSettings.h"

@interface TPWWebDAVSyncChecker ()
@property (nonatomic, strong) TPWPooledAsyncHttpClient *httpClient;
@end

@implementation TPWWebDAVSyncChecker

- (id)init {
	if (self = [super init]) {
		self.httpClient = [[TPWPooledAsyncHttpClient alloc] init];
	}
	return self;
}

- (void)checkSyncPossibility:(TPWSyncCheckCallback)callback {
	NSString *username = [TPWSettings webDAVUser];
	NSString *password = [TPWSettings webDAVPass];
	
	if (password.length == 0 || ![TPWSettings webDAVShouldSavePass]) {
		callback(NO, NO);
		return;
	}
	
	self.httpClient.username = username;
	self.httpClient.password = password;
	
	NSString *keychainDataDefaultPath = [TPWFileUtil keychainDataDefaultPath:self.reader.path];
	NSString *keychainContentsPath = [keychainDataDefaultPath URLStringByAppendingPathComponent:kTPWContentsFileName];
	NSURL *url = [NSURL URLWithString:keychainContentsPath];
	
	if ([TPWReachability hostIsReachable:url.host]) {
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
		request.HTTPMethod = @"HEAD";
		[self.httpClient makeRequest:request downloadToPath:nil onRedirect:nil onCompletion:^(NSNumber *tag, TPWPooledAsyncHttpClientResponse *response, NSError *error) {
			if (error) {
				callback(NO, NO);
			} else {
				BOOL keychainAvailable = response.response.statusCode == 200;
				NSDate *keychainModificationDate = [NSDate dateFromRFC822:response.response.allHeaderFields[kTPWHttpLastModifiedHeaderFieldKey]];
				BOOL hasChanges = ![keychainModificationDate isEqualToDate:self.reader.modificationDate];
				callback(keychainAvailable, hasChanges);
			}
		} onProgress:nil];
	}
}

- (BOOL)canCheckSync:(NSString*)source {
	return [kTPWMetadataValueSourceWebDAV isEqualToString:source];
}

- (NSArray*)suitableImporters {
	NSString *username = [TPWSettings webDAVUser];
	NSString *password = [TPWSettings webDAVPass];
	TPWWebDAVAgileKeychainImporter *agileKeychainImporter = [[TPWWebDAVAgileKeychainImporter alloc] initWithUsername:username password:password];
	return @[agileKeychainImporter];
}

@end
