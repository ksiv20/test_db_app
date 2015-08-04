//
//  EditInfoViewController.m
//  SQLite3DBSample
//
//  Created by Katherine Sivonxay on 8/3/15.
//  Copyright (c) 2015 Katherine Sivonxay. All rights reserved.
//

#import "EditInfoViewController.h"
#import "DBManager.h"

// private class
@interface EditInfoViewController ()

@property (nonatomic, strong) DBManager *dbManager;
- (void)loadInfoToEdit;

@end
// end private class



@implementation EditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Make self the delegate of the textfields
    // (So that can dismiss the keyboard when the done btn is pressed)
    self.txtFirstname.delegate = self;
    self.txtLastname.delegate = self;
    self.txtAge.delegate = self;

    // Set the navigation bar tint color so that the back btn is the same as the
    // save btn
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    
    // Initialize the dbManager object with the name of the database
    // (Upon initialization, the database class will check if the sampledb.sql
    // file exists or not in the documents directory, and will copy it
    // there if not found
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"sampledb.sql"];
    
    // Check if necessary to load specific record for editing
    if (self.recordIDToEdit != -1) {
        // Load the record w/the specific ID from the database
        [self loadInfoToEdit];
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - UITextFieldDelegate method implementation

/*
 * Dismiss the keyboard when the done btn is pressed)
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - IBAction method implementation

/*
 *
 *
 */
- (IBAction)saveInfo:(id)sender {
    // Prepare the query string
    NSString *query;// = [NSString stringWithFormat:@"INSERT INTO peopleInfo values(null, '%@', '%@', %d)", self.txtFirstname.text, self.txtLastname.text, [self.txtAge.text intValue]];
    if (self.recordIDToEdit == -1) {
        query = [NSString stringWithFormat:@"INSERT INTO peopleInfo values(null, '%@', '%@', %d)", self.txtFirstname.text, self.txtLastname.text, [self.txtAge.text intValue]];
    } else {
        query = [NSString stringWithFormat:@"UPDATE peopelInfo set firstname='%@', lastname='%@', age=%d where peopleInfoID=%d", self.txtFirstname.text,
                                                                                                                                 self.txtLastname.text,
                                                                                                                                 self.txtAge.text.intValue,
                                                                                                                                 self.recordIDToEdit];
    }
    
    // Execute the query
    [self.dbManager executeQuery:query];
    
    // If the query was successfully executed then pop the view controller
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was successfully executed. Affected rows = %d", self.dbManager.affectedRows);
        
        // Inform the delegate that the editing was finished (so that data will be "refreshed" in table view)
        [self.delegate editingInfoWasFinished];
        
        // pop the view controller to return back to the previous view controller scene
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSLog(@"Could not execute the query.");
    }
}


#pragma mark - Private method implementation
- (void)loadInfoToEdit {
    // Create the query to select all columns of the specified row
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM peopleInfo where peopleInfoID=%d", self.recordIDToEdit];

    // Load the relevant dat
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Set the loaded data to the textfields
    self.txtFirstname.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"firstname"]];
    self.txtLastname.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"lastname"]];
    self.txtAge.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"age"]];
}


@end
