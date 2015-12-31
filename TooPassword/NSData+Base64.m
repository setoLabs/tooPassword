// Copyright 2012, Sebastian Stenzel, sebastianstenzel.de
// All rights reserved.
//
// This software is derived from the Base64Coder by Christian d'Heureuse in terms of the Apache License.
// Copyright 2003-2010 Christian d'Heureuse, Inventec Informatik AG, Zurich, Switzerland
// www.source-code.biz, www.inventec.ch/chdh
//
// This code can be used, copied or modified for any purpose according to the
// simplified BSD Licence (http://opensource.org/licenses/bsd-license.php) as
// long as you retain this copyright notice and reproduce it in binary form.

#import "NSData+Base64.h"

static unsigned char encodingTable[64] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};
static unsigned char decodingTable[128];

@implementation NSData (Base64)

#pragma mark static initialization

+ (void) initialize {
	[super initialize];
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		for(int i=0;i<128;i++) decodingTable[i] = -1;
		for(int i=0;i<64;i++) decodingTable[encodingTable[i]] = i;
	});
}


#pragma mark -
#pragma mark encoding

- (NSString*) base64Representation {
	NSUInteger length = [self length];
	NSUInteger oDataLen = (length*4+2)/3;	// output length without padding
	NSUInteger oLen = ((length+2)/3)*4;		// output length including padding
	const unsigned char* input = [self bytes];
	char output[oLen+1]; //+1 for null terminator
	int ip = 0;
	int op = 0;
	while (ip < length) {
		int i0 = input[ip++];
		int i1 = ip < length ? input[ip++] : 0;
		int i2 = ip < length ? input[ip++] : 0;
		int o0 = i0 >> 2;
		int o1 = ((i0 &   3) << 4) | (i1 >> 4);
		int o2 = ((i1 & 0xf) << 2) | (i2 >> 6);
		int o3 = i2 & 0x3F;
		output[op++] = encodingTable[o0];
		output[op++] = encodingTable[o1];
		output[op] = op < oDataLen ? encodingTable[o2] : '='; op++;
		output[op] = op < oDataLen ? encodingTable[o3] : '='; op++;
	}
	output[op++] = '\0'; //c string terminator
	return [NSString stringWithCString:output encoding:NSASCIIStringEncoding];
}

#pragma mark -
#pragma mark decoding

+ (NSData*) dataWithBase64Representation:(NSString*)base64String {
	NSString *cleanedString = base64String;
	cleanedString = [cleanedString stringByReplacingOccurrencesOfString:@"\\u0000" withString:@""];	// wtf!
	cleanedString = [cleanedString stringByReplacingOccurrencesOfString:@"-" withString:@"+"];	// 62nd char rfc4648 chapter 5
	cleanedString = [cleanedString stringByReplacingOccurrencesOfString:@"_" withString:@"/"];	// 63rd char rfc4648 chapter 5
	cleanedString = [cleanedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];	//removing line breaks from base64 blocks
	NSData *inputData = [cleanedString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];	//valid base64 strings only contain ascii chars
	
	NSUInteger iLen = [inputData length];
	const unsigned char* input = [inputData bytes];
	while (iLen > 0 && input[iLen-1] == '\0') iLen--;	//remove null characters at the end of the input string

	if (iLen%4 != 0) @throw [NSException exceptionWithName:@"invalid base64 data"
													reason:@"length of base64 encoded string not a multiple of 4."
												  userInfo:nil];
	
	while (iLen > 0 && input[iLen-1] == '=') iLen--;	//remove padding
	
	NSUInteger oLen = (iLen*3) / 4;
	
	char output[oLen];
	int ip = 0;
	int op = 0;
	while (ip < iLen) {
		int i0 = input[ip++];
		int i1 = input[ip++];
		int i2 = ip < iLen ? input[ip++] : 'A';
		int i3 = ip < iLen ? input[ip++] : 'A';
		if (i0 > 127 || i1 > 127 || i2 > 127 || i3 > 127)
			@throw [NSException exceptionWithName:@"invalid base64 data"
										   reason:@"illegal character in base64 encoded data."
										 userInfo:nil];
		int b0 = decodingTable[i0];
		int b1 = decodingTable[i1];
		int b2 = decodingTable[i2];
		int b3 = decodingTable[i3];
		if (b0 < 0 || b1 < 0 || b2 < 0 || b3 < 0)
			@throw [NSException exceptionWithName:@"invalid base64 data"
										   reason:@"illegal character in base64 encoded data."
										 userInfo:nil];
		int o0 = (b0<<2) | (b1>>4);
		int o1 = ((b1 & 0xf)<<4) | (b2>>2);
		int o2 = ((b2 & 3)<<6) | b3;
		output[op++] = o0;
		if (op<oLen) output[op++] = o1;
		if (op<oLen) output[op++] = o2;
	}
	return [NSData dataWithBytes:output length:oLen];
}

@end