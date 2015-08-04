//
//  EditInfoViewController.h
//  SQLite3DBSample
//
//  Created by Katherine Sivonxay on 8/3/15.
//  Copyright (c) 2015 Katherine Sivonxay. All rights reserved.
//

#import <UIKit/UIKit.h>

// protocol to be adopted to the ViewController class
@protocol EditInfoViewControllerDelegate
// delegate method here to be used for notifying when a new record
// has been added.
- (void)editingInfoWasFinished;

@end

//@interface EditInfoViewController : UIViewController
// class is the delegate of the textfields so that keyboard
// can be dismissed when done btn is pressed
@interface EditInfoViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtFirstname;
@property (weak, nonatomic) IBOutlet UITextField *txtLastname;
@property (weak, nonatomic) IBOutlet UITextField *txtAge;

@property (nonatomic, strong) id<EditInfoViewControllerDelegate> delegate;

@property (nonatomic) int recordIDToEdit;

- (IBAction)saveInfo:(id)sender;

@end
