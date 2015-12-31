//
//  TPWWebDAVPropfinder.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 01.12.13.
//
//

#import "TPWWebDAVPropfindResponseParser.h"

NSString *const kTPWWebDAVPropfindResponseParserDAVNamespace = @"DAV:";

@interface TPWWebDAVPropfindResponseParser () <NSXMLParserDelegate>
@property (nonatomic, assign) NSStringEncoding encoding;
@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSMutableArray *responses;
@property (nonatomic, copy) TPWWebDAVPropfindResponseParserCallback callback;
@end

@implementation TPWWebDAVPropfindResponseParser

- (instancetype)initWithXMLData:(NSData*)xmlData encoding:(NSStringEncoding)encoding {
	if (self = [super init]) {
		self.parser = [[NSXMLParser alloc] initWithData:xmlData];
		self.parser.shouldProcessNamespaces = YES;
		self.parser.delegate = self;
		self.encoding = encoding;
	}
	return self;
}

- (void)parseResponses:(TPWWebDAVPropfindResponseParserCallback)callback {
	NSParameterAssert(callback);
	self.callback = callback;
	[self.parser parse];
}

- (void)cancelParsing {
	[self.parser abortParsing];
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	self.responses = [NSMutableArray array];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([kTPWWebDAVPropfindResponseParserDAVNamespace isEqualToString:namespaceURI] && [elementName isEqualToString:@"response"]) {
		TPWWebDAVResponse *response = [[TPWWebDAVResponse alloc] initWithParserRootDelegate:self];
		parser.delegate = response;
		[self.responses addObject:response];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	DLog(@"finished parsing: %@", self.responses);
	self.callback(self.responses, nil);
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	self.callback(nil, parseError);
}

@end
