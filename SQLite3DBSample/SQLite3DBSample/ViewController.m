//
//  ViewController.m
//  SQLite3DBSample
//
//  Created by Katherine Sivonxay on 7/31/15.
//  Copyright (c) 2015 Katherine Sivonxay. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"

// private class
@interface ViewController ()

// For displaying data in the table view
@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *arrPeopleInfo;

@property (nonatomic) int recordIDToEdit;

- (void)loadData;

@end // end private class

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Make self the delegate and datasource of the table view
    self.tblPeople.delegate = self;
    self.tblPeople.dataSource = self;
    
    // Initialize the dbManager object with the name of the database
    // (Upon initialization, the database class will check if the sampledb.sql
    // file exists or not in the documents directory, and will copy it
    // there if not found
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"sampledb.sql"];
    
    // Load the data into the table view
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EditInfoViewController *editInfoViewController = [segue destinationViewController];
    editInfoViewController.delegate = self;
    
    editInfoViewController.recordIDToEdit = self.recordIDToEdit;
}


#pragma mark - IBAction method implementation

/*
 * When the button to addsa new record to the database is pressed, will
 * navigate to the next view controller class (EditInfoViewController)
 */
- (IBAction)addNewRecord:(id)sender {
    // Before performing the segue, set the -1 value to the recordIDToEdit so that
    // can indicate when we want to add a new record and not to edit an existing one.
    self.recordIDToEdit = -1;
    
    // Perform the segue
    [self performSegueWithIdentifier:@"idSegueEditInfo" sender:self];
}


- (void)loadData {
    // Form the query to obtain data from database
    NSString *query = @"SELECT * FROM peopleInfo";
    
    // Get the results by clearing the array if necessary so that old info isn't
    // retained as results/view are refreshed
    if (self.arrPeopleInfo != nil) {
        self.arrPeopleInfo = nil;
    }
    // Upon initialization, loadDataFromDB method of the dbManager obj is called
    self.arrPeopleInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Reload the table view once data is fetched and returned to display it
    [self.tblPeople reloadData];
}


#pragma mark - Table Implementation Methods

/*
 * Sets table view to have only one section
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


/*
 * Sets the total number of rows displayed in the table view to the number of 
 * items to be displayed (the number of objects in the array of data fetched
 * from the database).
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrPeopleInfo.count;
}


/* 
 * Set each row's height to 60.0 points.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}


/*
 * Displays a row's data using the tableView:cellForRowAtIndexPath: method.
 * 1.) Dequeues the prototype cell created in the Storyboard Interface Builder.
 * 2.) Makes use of the arrColumnNames array of the dbManager property by defining
 *     the index of each column (field) in the sub-array for the current index of the arrPeopleInfo array.
 * 3.) Gets the actual data and assigns it to the textLabel and detailTextLabel
 *     labels of the cell. 
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Dequeue the cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord" forIndexPath:indexPath];
    
    NSInteger indexOfFirstname = [self.dbManager.arrColumnNames indexOfObject:@"firstname"];
    NSInteger indexOfLastname = [self.dbManager.arrColumnNames indexOfObject:@"lastname"];
    NSInteger indexOfAge = [self.dbManager.arrColumnNames indexOfObject:@"age"];
    
    // Set the loaded data to the appropriate cell labels
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfFirstname],
                                                               [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfLastname]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Age: %@", [[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfAge]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    // Delete the selected record:
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        // Find the record ID of the selected cell
        // Note: objectAtIndex:0 is the peopleInfoID integer primary key
        int recordIDToDelete = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
        // Prepare the query:
        NSString *query = [NSString stringWithFormat:@"DELETE FROM peopleInfo where peopleInfoID=%d", recordIDToDelete];
        
        // Execute the query
        [self.dbManager executeQuery:query];
        
        // Reload the table view
        [self loadData];
    }
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Get the record ID of the selected name and set it to the recordIDToEdit property
    self.recordIDToEdit = [[[self.arrPeopleInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    
    // Perform the segue
    [self performSegueWithIdentifier:@"idSegueEditInfo" sender:self];
}


#pragma mark - EditInfoViewControllerDelegate method implementation

/*
 * Reloads the data in the table view when any records are updated (added/edited)
 */
- (void)editingInfoWasFinished{
    // Reload the data
    [self loadData];
}


@end
