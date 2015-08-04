// TUT: http://www.appcoda.com/sqlite-database-ios-app-tutorial/
//
//  DBManager.h
//  SQLite3DBSample
//
//  Created by Katherine Sivonxay on 7/31/15.
//  Copyright (c) 2015 Katherine Sivonxay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

// (returnType)instanceMethodName:(param1Type)param1Name;
- (instancetype)initWithDatabaseFilename:(NSString *)dbFilename;

- (NSArray *)loadDataFromDB:(NSString *)query;
- (void)executeQuery:(NSString *)query;

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;// rows affected after query executed
@property (nonatomic) long long lastInsertedRowID;// rows inserted after query executed

@end
