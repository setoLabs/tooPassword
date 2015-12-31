//
//  TPW1PasswordFileSupportTest.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 29.01.13.
//
//

#import "TPW1PasswordFileSupportTest.h"
#import "TPW1PasswordType.h"

@implementation TPW1PasswordFileSupportTest

- (void)testIdentitySupport {
	XCTAssertTrue([TPW1PasswordType isSupportedType:@"identities.Identity"], @"type identities.Identity not supported");
}

- (void)testWalletSupport {
	XCTAssertTrue([TPW1PasswordType isSupportedType:@"wallet.computer.Database"], @"type wallet.computer.Database not supported");
	XCTAssertTrue([TPW1PasswordType isSupportedType:@"wallet.onlineservices.FTP"], @"type wallet.onlineservices.FTP not supported");
	XCTAssertTrue([TPW1PasswordType isSupportedType:@"wallet.computer.License"], @"type wallet.computer.License not supported");
	XCTAssertTrue([TPW1PasswordType isSupportedType:@"wallet.financial.CreditCard"], @"type wallet.financial.CreditCard not supported");
}

- (void)testWebformsSupport {
	XCTAssertTrue([TPW1PasswordType isSupportedType:@"webforms.WebForm"], @"type webforms.WebForm not supported");
}

- (void)testSecureNotesSupport {
	XCTAssertTrue([TPW1PasswordType isSupportedType:@"securenotes.SecureNote"], @"type securenotes.SecureNote not supported");
}

@end
