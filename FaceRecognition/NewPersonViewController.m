//
//  NewPersonViewController.m
//  FaceRecognition
//
//  Created by Michael Peterson on 2012-11-16.
//
//

#import "NewPersonViewController.h"

@interface NewPersonViewController ()

@end

@implementation NewPersonViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)savePerson:(id)sender
{
    NSLog(@"%@", self.nameField.text);
    // save it into db
}

@end
