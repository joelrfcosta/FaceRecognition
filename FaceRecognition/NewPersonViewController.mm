//
//  NewPersonViewController.mm
//  FaceRecognition
//
//  Created by Michael Peterson on 2012-11-16.
//
//

#import "NewPersonViewController.h"
#import "CustomFaceRecognizer.h"

@interface NewPersonViewController ()

@end

@implementation NewPersonViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)savePerson:(id)sender
{
    CustomFaceRecognizer *faceRecognizer = [[CustomFaceRecognizer alloc] init];
    [faceRecognizer newPersonWithName:self.nameField.text];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
