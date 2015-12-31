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

@interface NSData (Base64)

- (NSString*) base64Representation;
+ (NSData*) dataWithBase64Representation:(NSString*)base64String;

@end