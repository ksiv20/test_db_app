//
//  ViewController.h
//  SQLite3DBSample
//
//  Created by Katherine Sivonxay on 7/31/15.
//  Copyright (c) 2015 Katherine Sivonxay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditInfoViewController.h"

// Make this ViewController class both a delegate and datasource of the
// table view IBOutlet property
//@interface ViewController : UIViewController
@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EditInfoViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tblPeople;

- (IBAction)addNewRecord:(id)sender;


@end

