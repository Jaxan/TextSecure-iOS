//
//  TextSecureiOS_Tests.m
//  TextSecureiOS Tests
//
//  Created by Alban Diquet on 11/24/13.
//  Copyright (c) 2013 Open Whisper Systems. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EncryptedDatabase.h"



static NSString *dbPw = @"1234test";


@interface EncryptedDatabase_Tests : XCTestCase

@end

@implementation EncryptedDatabase_Tests

- (void)setUp
{
    [super setUp];
    // Remove any existing DB
    [EncryptedDatabase databaseErase];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testDatabaseErase
{
    [EncryptedDatabase databaseCreateWithPassword:dbPw error:nil];
    [EncryptedDatabase databaseErase];
    XCTAssertThrows([EncryptedDatabase databaseUnlockWithPassword:dbPw error:nil], @"database was unlocked after being erased");
}


- (void)testDatabaseCreate
{
    NSError *error = nil;
    EncryptedDatabase *encDb = [EncryptedDatabase databaseCreateWithPassword:dbPw error:&error];
    XCTAssertNil(error, @"database creation returned an error");
    XCTAssertNotNil(encDb, @"database creation failed");
}


- (void)testDatabaseCreateAndOverwrite
{
    NSError *error = nil;
    [EncryptedDatabase databaseCreateWithPassword:dbPw error:nil];
    EncryptedDatabase *encDb = [EncryptedDatabase databaseCreateWithPassword:dbPw error:&error];
    // TODO: Look at the actual error code
    XCTAssertNil(encDb, @"database overwrite did not fail");
    XCTAssertNotNil(error, @"database overwrite did not return an error");
}


- (void)testDatabaseLock
{
    [EncryptedDatabase databaseCreateWithPassword:dbPw error:nil];
    [EncryptedDatabase databaseLock];
    XCTAssertThrows([EncryptedDatabase database], @"database was still available after getting locked");
    }


- (void)testDatabaseUnlock
{
    NSError *error = nil;
    EncryptedDatabase *encDb = [EncryptedDatabase databaseCreateWithPassword:dbPw error:nil];
    [EncryptedDatabase databaseLock];
    
    // Wrong password
    encDb = [EncryptedDatabase databaseUnlockWithPassword:@"wrongpw" error:&error];
    XCTAssertNil(encDb, @"wrong password unlocked the database");
    // TODO: Look at the actual error code
    XCTAssertNotNil(error, @"wrong password did not return an error");
    
    // Good password
    error = nil;
    encDb = [EncryptedDatabase databaseUnlockWithPassword:dbPw error:&error];
    XCTAssertNotNil(encDb, @"valid password did not unlock the database");
    XCTAssertNil(error, @"valid password returned an error");
}


@end
