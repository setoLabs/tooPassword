//
//  TPWWebDAVResponse.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 28.11.13.
//
//

#import "TPWWebDAVResponse.h"
#import "NSDate+RFCFormats.h"

typedef NS_ENUM(NSUInteger, TPWWebDAVResponseTags) {
	RESPONSE,
	RESPONSE_HREF,
	RESPONSE_GETLASTMODIFIED,
	RESPONSE_RESOURCETYPE,
	RESPONSE_RESOURCETYPE_COLLECTION,
	RESPONSE_STATUS,
	
	UNKNOWN
};

NSString *const kTPWWebDAVResponseDAVNamespace = @"DAV:";

@interface TPWWebDAVResponse ()
@property (nonatomic, strong) NSString *href;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSDate *lastModified;
@property (nonatomic, assign, getter = isCollection) BOOL collection;

@property (nonatomic, weak) id<NSXMLParserDelegate> rootDelegate;

@property (nonatomic, strong) NSMutableString *xmlCharacterBuffer;
@property (nonatomic, assign) BOOL insideOfResourceType;
@end

@implementation TPWWebDAVResponse

- (instancetype)initWithParserRootDelegate:(id<NSXMLParserDelegate>)rootDelegate {
	if (self = [super init]) {
		self.rootDelegate = rootDelegate;
	}
	return self;
}

#pragma mark - tags

- (TPWWebDAVResponseTags)tagWithName:(NSString*)name {
	if ([@"response" compare:name options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		return RESPONSE;
	} else if ([@"href" compare:name options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		return RESPONSE_HREF;
	} else if ([@"getlastmodified" compare:name options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		return RESPONSE_GETLASTMODIFIED;
	} else if ([@"resourcetype" compare:name options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		return RESPONSE_RESOURCETYPE;
	} else if ([@"collection" compare:name options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		return RESPONSE_RESOURCETYPE_COLLECTION;
	} else if ([@"status" compare:name options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		return RESPONSE_STATUS;
	} else {
		return UNKNOWN;
	}
}

#pragma mark - parsing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if (![kTPWWebDAVResponseDAVNamespace isEqualToString:namespaceURI]) {
		return;
	}
	
	switch ([self tagWithName:elementName]) {
		case RESPONSE_HREF:
			self.xmlCharacterBuffer = [NSMutableString string];
			break;
		case RESPONSE_GETLASTMODIFIED:
			self.xmlCharacterBuffer = [NSMutableString string];
			break;
		case RESPONSE_RESOURCETYPE:
			self.insideOfResourceType = YES;
			break;
		case RESPONSE_RESOURCETYPE_COLLECTION:
			self.collection = self.insideOfResourceType;
			break;
		case RESPONSE_STATUS:
			self.xmlCharacterBuffer = [NSMutableString string];
			break;
		default:
			break;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.xmlCharacterBuffer appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (![kTPWWebDAVResponseDAVNamespace isEqualToString:namespaceURI]) {
		return;
	}
	
	switch ([self tagWithName:elementName]) {
		case RESPONSE:
			parser.delegate = self.rootDelegate;
			break;
		case RESPONSE_HREF:
			self.href = [NSString stringWithString:self.xmlCharacterBuffer];
			break;
		case RESPONSE_GETLASTMODIFIED:
			self.lastModified = [NSDate dateFromRFC822:self.xmlCharacterBuffer];
			break;
		case RESPONSE_RESOURCETYPE:
			self.insideOfResourceType = NO;
			break;
		case RESPONSE_STATUS:
			self.status = [NSString stringWithString:self.xmlCharacterBuffer];
			break;
		default:
			break;
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	[self.rootDelegate parser:parser parseErrorOccurred:parseError];
}

@end
