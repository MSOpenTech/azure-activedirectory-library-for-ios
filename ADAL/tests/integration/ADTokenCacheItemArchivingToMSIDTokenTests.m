// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <XCTest/XCTest.h>
#import "XCTestCase+TestHelperMethods.h"
#import "MSIDTokenCacheItem.h"
#import "MSIDKeyedArchiverSerializer.h"
#import "ADTokenCacheItem.h"
#import "ADUserInformation.h"

@interface ADTokenCacheItemArchivingToMSIDTokenTests : ADTestCase

@end

@implementation ADTokenCacheItemArchivingToMSIDTokenTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - ADTokenCacheItem -> MSIDTokenCacheItem

- (void)testDeserialize_whenAccessTokenIsValidRefreshTokenNil_shouldReturnAccessToken
{
    MSIDKeyedArchiverSerializer *serializer = [MSIDKeyedArchiverSerializer new];
    NSDate *date = [NSDate new];
    NSDictionary *additionalServerInfo = @{@"key1": @"value1"};
    NSData *sessionKey = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    ADTokenCacheItem *item = [ADTokenCacheItem new];
    item.resource = TEST_RESOURCE;
    item.authority = TEST_AUTHORITY;
    item.clientId = TEST_CLIENT_ID;
    item.accessToken = TEST_ACCESS_TOKEN;
    item.expiresOn = date;
    item.userInformation = [self adCreateUserInformation:TEST_USER_ID];
    [item setValue:additionalServerInfo forKey:@"additionalServer"];
    [item setValue:sessionKey forKey:@"sessionKey"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:item];
    
    MSIDTokenCacheItem *tokenCacheItem = [serializer deserializeTokenCacheItem:data];
    
    XCTAssertTrue([tokenCacheItem isKindOfClass:MSIDTokenCacheItem.class]);
    XCTAssertNotNil(tokenCacheItem);
    XCTAssertEqualObjects(tokenCacheItem.clientId, TEST_CLIENT_ID);
    XCTAssertEqual(tokenCacheItem.tokenType, MSIDTokenTypeAccessToken);
    XCTAssertEqualObjects(tokenCacheItem.accessToken, TEST_ACCESS_TOKEN);
    XCTAssertNil(tokenCacheItem.refreshToken);
    XCTAssertEqualObjects(tokenCacheItem.idToken, item.userInformation.rawIdToken);
    XCTAssertEqualObjects(tokenCacheItem.target, TEST_RESOURCE);
    XCTAssertEqualObjects(tokenCacheItem.expiresOn, date);
    XCTAssertNil(tokenCacheItem.cachedAt);
    XCTAssertNil(tokenCacheItem.familyId);
    XCTAssertEqualObjects(tokenCacheItem.authority.absoluteString, TEST_AUTHORITY);
    XCTAssertNil(tokenCacheItem.uniqueUserId);
    XCTAssertNil(tokenCacheItem.username);
    XCTAssertNil(tokenCacheItem.clientInfo);
    XCTAssertEqualObjects(tokenCacheItem.additionalInfo, additionalServerInfo);
}

- (void)testDeserialize_whenAccessTokenIsNilRefreshTokenIsValid_shouldReturnRefreshToken
{
    MSIDKeyedArchiverSerializer *serializer = [MSIDKeyedArchiverSerializer new];
    NSDate *date = [NSDate new];
    NSDictionary *additionalServerInfo = @{@"key1": @"value1"};
    NSData *sessionKey = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    ADTokenCacheItem *item = [ADTokenCacheItem new];
    item.resource = TEST_RESOURCE;
    item.authority = TEST_AUTHORITY;
    item.clientId = TEST_CLIENT_ID;
    item.accessToken = nil;
    item.refreshToken = TEST_REFRESH_TOKEN;
    item.expiresOn = date;
    item.userInformation = [self adCreateUserInformation:TEST_USER_ID];
    [item setValue:additionalServerInfo forKey:@"additionalServer"];
    [item setValue:sessionKey forKey:@"sessionKey"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:item];
    
    MSIDTokenCacheItem *tokenCacheItem = [serializer deserializeTokenCacheItem:data];
    
    XCTAssertTrue([tokenCacheItem isKindOfClass:MSIDTokenCacheItem.class]);
    XCTAssertNotNil(tokenCacheItem);
    XCTAssertEqualObjects(tokenCacheItem.clientId, TEST_CLIENT_ID);
    XCTAssertEqual(tokenCacheItem.tokenType, MSIDTokenTypeRefreshToken);
    XCTAssertNil(tokenCacheItem.accessToken);
    XCTAssertEqualObjects(tokenCacheItem.refreshToken, TEST_REFRESH_TOKEN);
    XCTAssertEqualObjects(tokenCacheItem.idToken, item.userInformation.rawIdToken);
    XCTAssertEqualObjects(tokenCacheItem.target, TEST_RESOURCE);
    XCTAssertEqualObjects(tokenCacheItem.expiresOn, date);
    XCTAssertNil(tokenCacheItem.cachedAt);
    XCTAssertNil(tokenCacheItem.familyId);
    XCTAssertEqualObjects(tokenCacheItem.authority.absoluteString, TEST_AUTHORITY);
    XCTAssertNil(tokenCacheItem.uniqueUserId);
    XCTAssertNil(tokenCacheItem.username);
    XCTAssertNil(tokenCacheItem.clientInfo);
    XCTAssertEqualObjects(tokenCacheItem.additionalInfo, additionalServerInfo);
}

- (void)testDeserialize_whenAccessTokenIsValidRefreshTokenIsValid_shouldReturnLegacySingleResourceToken
{
    MSIDKeyedArchiverSerializer *serializer = [MSIDKeyedArchiverSerializer new];
    NSDate *date = [NSDate new];
    NSDictionary *additionalServerInfo = @{@"key1": @"value1"};
    NSData *sessionKey = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    ADTokenCacheItem *item = [ADTokenCacheItem new];
    item.resource = TEST_RESOURCE;
    item.authority = TEST_AUTHORITY;
    item.clientId = TEST_CLIENT_ID;
    item.accessToken = TEST_ACCESS_TOKEN;
    item.refreshToken = TEST_REFRESH_TOKEN;
    item.expiresOn = date;
    item.userInformation = [self adCreateUserInformation:TEST_USER_ID];
    [item setValue:additionalServerInfo forKey:@"additionalServer"];
    [item setValue:sessionKey forKey:@"sessionKey"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:item];
    
    MSIDTokenCacheItem *tokenCacheItem = [serializer deserializeTokenCacheItem:data];
    
    XCTAssertTrue([tokenCacheItem isKindOfClass:MSIDTokenCacheItem.class]);
    XCTAssertNotNil(tokenCacheItem);
    XCTAssertEqualObjects(tokenCacheItem.clientId, TEST_CLIENT_ID);
    XCTAssertEqual(tokenCacheItem.tokenType, MSIDTokenTypeLegacySingleResourceToken);
    XCTAssertEqualObjects(tokenCacheItem.accessToken, TEST_ACCESS_TOKEN);
    XCTAssertEqualObjects(tokenCacheItem.refreshToken, TEST_REFRESH_TOKEN);
    XCTAssertEqualObjects(tokenCacheItem.idToken, item.userInformation.rawIdToken);
    XCTAssertEqualObjects(tokenCacheItem.target, TEST_RESOURCE);
    XCTAssertEqualObjects(tokenCacheItem.expiresOn, date);
    XCTAssertNil(tokenCacheItem.cachedAt);
    XCTAssertNil(tokenCacheItem.familyId);
    XCTAssertEqualObjects(tokenCacheItem.authority.absoluteString, TEST_AUTHORITY);
    XCTAssertNil(tokenCacheItem.uniqueUserId);
    XCTAssertNil(tokenCacheItem.username);
    XCTAssertNil(tokenCacheItem.clientInfo);
    XCTAssertEqualObjects(tokenCacheItem.additionalInfo, additionalServerInfo);
}

#pragma mark - MSIDTokenCacheItem -> ADTokenCacheItem

- (void)testSerialize_whenAccessMSIDToken_shouldUnarchiveAsAccessADTokenCacheItem
{
    MSIDTokenCacheItem *tokenCacheItem = [self adCreateAccessMSIDTokenCacheItem];
    MSIDKeyedArchiverSerializer *serializer = [MSIDKeyedArchiverSerializer new];
    NSData *data = [serializer serializeTokenCacheItem:tokenCacheItem];
    
    ADTokenCacheItem *adToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertNotNil(adToken);
    XCTAssertTrue([adToken isKindOfClass:ADTokenCacheItem.class]);
    XCTAssertEqualObjects(adToken.resource, TEST_RESOURCE);
    XCTAssertEqualObjects(adToken.authority, TEST_AUTHORITY);
    XCTAssertEqualObjects(adToken.clientId, TEST_CLIENT_ID);
    XCTAssertEqualObjects(adToken.accessToken, TEST_ACCESS_TOKEN_TYPE);
    XCTAssertEqualObjects(adToken.accessTokenType, @"Bearer");
    XCTAssertNil(adToken.refreshToken);
    XCTAssertEqualObjects(adToken.expiresOn, [NSDate dateWithTimeIntervalSince1970:1500000000]);
    XCTAssertEqualObjects(adToken.userInformation, [self adCreateUserInformation:TEST_USER_ID]);
    XCTAssertNil(adToken.familyId);
}

- (void)testSerialize_whenRefreshMSIDToken_shouldUnarchiveAsRefreshADTokenCacheItem
{
    MSIDTokenCacheItem *tokenCacheItem = [self adCreateRefreshMSIDTokenCacheItem];
    MSIDKeyedArchiverSerializer *serializer = [MSIDKeyedArchiverSerializer new];
    NSData *data = [serializer serializeTokenCacheItem:tokenCacheItem];
    
    ADTokenCacheItem *adToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertNotNil(adToken);
    XCTAssertTrue([adToken isKindOfClass:ADTokenCacheItem.class]);
    XCTAssertNil(adToken.resource);
    XCTAssertEqualObjects(adToken.authority, TEST_AUTHORITY);
    XCTAssertEqualObjects(adToken.clientId, TEST_CLIENT_ID);
    XCTAssertEqualObjects(adToken.refreshToken, TEST_REFRESH_TOKEN);
    XCTAssertEqualObjects(adToken.accessTokenType, @"Bearer");
    XCTAssertNil(adToken.accessToken);
    XCTAssertEqualObjects(adToken.expiresOn, [NSDate dateWithTimeIntervalSince1970:1500000000]);
    XCTAssertEqualObjects(adToken.userInformation, [self adCreateUserInformation:TEST_USER_ID]);
    XCTAssertEqualObjects(adToken.familyId, @"familyId value");
}

- (void)testSerialize_whenLegacySingleResourceMSIDToken_shouldUnarchiveAsSingleResourceADTokenCacheItem
{
    MSIDTokenCacheItem *tokenCacheItem = [self adCreateLegacySingleResourceMSIDTokenCacheItem];
    MSIDKeyedArchiverSerializer *serializer = [MSIDKeyedArchiverSerializer new];
    NSData *data = [serializer serializeTokenCacheItem:tokenCacheItem];
    
    ADTokenCacheItem *adToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertNotNil(adToken);
    XCTAssertTrue([adToken isKindOfClass:ADTokenCacheItem.class]);
    XCTAssertEqualObjects(adToken.resource, TEST_RESOURCE);
    XCTAssertEqualObjects(adToken.authority, TEST_AUTHORITY);
    XCTAssertEqualObjects(adToken.clientId, TEST_CLIENT_ID);
    XCTAssertEqualObjects(adToken.refreshToken, TEST_REFRESH_TOKEN);
    XCTAssertEqualObjects(adToken.accessTokenType, @"Bearer");
    XCTAssertEqualObjects(adToken.accessToken, TEST_ACCESS_TOKEN);
    XCTAssertEqualObjects(adToken.expiresOn, [NSDate dateWithTimeIntervalSince1970:1500000000]);
    XCTAssertEqualObjects(adToken.userInformation, [self adCreateUserInformation:TEST_USER_ID]);
    XCTAssertEqualObjects(adToken.familyId, @"familyId value");
}

@end
