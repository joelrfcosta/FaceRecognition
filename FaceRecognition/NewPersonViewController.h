//
//  NewPersonViewController.h
//  FaceRecognition
//
//  Created by Michael Peterson on 2012-11-16.
//
//

#import <UIKit/UIKit.h>

@interface NewPersonViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *nameField;

- (IBAction)savePerson:(id)sender;

@end
