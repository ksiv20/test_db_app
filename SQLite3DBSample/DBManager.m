//
//  DBManager.m
//  SQLite3DBSample
//
//  Created by Katherine Sivonxay on 7/31/15.
//  Copyright (c) 2015 Katherine Sivonxay. All rights reserved.
//

/*
 * Original database file will reside in the application's bundle (app package).
 * Goal is to make a copy of that file to the app's document directory and work
 * with that copy later on.
 * Note: Should never work directly with a file existing in the app bundle, 
 *       especially if app is going to modify it. Always make a copy of it to
 *       the documents directory.
 */

#import "DBManager.h"
#import <sqlite3.h>

// private class
@interface DBManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrResults;

- (void)copyDatabaseIntoDocumentsDirectory;

// query statement (ex: select) is text, and boolean for whether or not the statement is executable (ex: select wouldn't be)
// Note: query param is a const char (a C string) and not a NSString obj since SQLite functions only know how to handle
// C strings and not NSString
- (void)runQuery:(const char *)queryStatement isQueryExecutable:(BOOL)queryExecutable;

@end // of private class



@implementation DBManager



#pragma mark - Initialization


/*
 * Init method that will:
 * 1. specify the path to the documents directory of the app and store it to a property.
 * 2. store the database filename that is provided as an argument to another property
 * 3. copy the database file from the app bundle into the documents directory if necessary.
 */
- (instancetype)initWithDatabaseFilename:(NSString *)dbFilename{
    self = [super init];
    if (self) {
        // Set the documents directory path to the documentsDirectory property
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        
        // Keep the database filename
        self.databaseFilename = dbFilename;
        
        // Copy the database file from the app bundle into the documents directory if necessary
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}



#pragma mark - Private method implementation


/*
 * Checks whether or not the database file exists in the documents directory.
 * If not then it'll be copied there.
 */
- (void)copyDatabaseIntoDocumentsDirectory {
    // Check if the database file exists in the documents directory
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The database file does not exist in the documents directory, so copy it from the main bundle now
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        // Check if any error occurred during copying and displaying it
        if(error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}


/* 
 * (Core Functionality implementation.)
 *
 * Runs a given query by either executing it (updating data) or not execuiting
 * it (returning it. ex: SELECT)
 *
 * 1) Initializes objects needed
 *    Note: if any previous data exists in any of the arrays, they're cleared here before
 *          initializing the arrays again to make sure that nothing remains in memory.
 * 2) opens the database
 *
 *
 *
 */
- (void)runQuery:(const char *)queryStatement isQueryExecutable:(BOOL)queryExecutable {
    /////////////////////////    (1) Initialization     /////////////////////
    // Create a sqlite obj
    sqlite3 *sqlite3Database;
    
    // Set the database file path
    NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    // Initialize the results array. (clear any data that exists before doing so)
    if (self.arrResults != nil) {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
    
    // Initialize the column names array. (clear any data that exists before doing so)
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    
    /////////////////////////    (2) Open Database     /////////////////////
    // if no errors occur then the query will be converted into an executable
    // sqlite statement using the sqlite3_prepare_v2 function
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if (openDatabaseResult == SQLITE_OK) {

        // Declare a sqlite3_stmt obj that'll be stored as query after it's compiled into
        // a SQLite statement
        sqlite3_stmt *compiledStatement;
        
        // Load all data from database to memory
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, queryStatement, -1, &compiledStatement, NULL);
        if (prepareStatementResult == SQLITE_OK) {
        
            
            // If the query is nonexecutable:
            if (!queryExecutable) {
                // then data must be loaded from the database

                // Declare an array to keep the data for each fetched row
                NSMutableArray *arrDataRow;
                
                // Loop through the results and add them to the results array row by row
                while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    // Initialize the mutable array that will contain the data of a fetched row.
                    arrDataRow = [[NSMutableArray alloc] init];
                    
                    // Get the total number of columns
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    // Go through all columns and fetch each column data
                    for (int i=0; i<totalColumns; i++) {
                        // Convert the column data to text (characters)
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        
                        // If any content exists in the current column, then add them to the current row array
                        if (dbDataAsChars != NULL) {
                            [arrDataRow addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                        
                        // Keep the current column name
                        if (self.arrColumnNames.count != totalColumns) {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    
                    // Store each fetched data row in the results array, but first check if there is actually data
                    if (arrDataRow.count > 0) {
                        [self.arrResults addObject:arrDataRow];
                    }
                }
            } else { // query is executable (ex: insert, update, ..)
                
                // Execute the query:
                
//                int executeQueryResults = sqlite3_step(compiledStatement);
//                if (executeQueryResults == SQLITE_DONE) {
                if( (sqlite3_step(compiledStatement)) == SQLITE_DONE) {
                    // (query executed successfully)
                    // keep the affected rows
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    // keep the last inserted row ID
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                } else {
                    // (query did not execute successfully)
                    // display error msg in debugger
                    NSLog(@"Database Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
            
        } else { // prepareStatementResult != SQLITE_OK
            // database can't be opened.
            // display error msg in debugger
            NSLog(@"ERRRR!! %s", sqlite3_errmsg(sqlite3Database));
        }
        
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    
    // Close the database
    sqlite3_close(sqlite3Database);
}


#pragma mark - Public method implementation


/*
 * For a nonexecutable query. (Data will need to be loaded.)
 * param query: the query to be executed as a NSString obj
 *              ex: select * from age > 18
 * fetched result set is returned as a 2D array
 * 1st array represents the rows
 * each sub-array represents the columns of each row
 */
- (NSArray *)loadDataFromDB:(NSString *)query {
    // Run the query and indicate that it's not executable.
    // the query string is converted to a char* obj
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    // Return the loaded results
    // Note: would be bad idea to make this array public cuz then other apps would
    // have direct access to it
    return (NSArray *)self.arrResults;
}


/*
 * Executes a query.
 * (The affectedRows property can used to verify if any changes were made after
 * the execution.)
 */
- (void)executeQuery:(NSString *)query {
    // Run the query and indicate that it's executable
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}


@end