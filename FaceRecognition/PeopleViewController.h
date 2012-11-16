//
//  PeopleViewController.h
//  FaceRecognition
//
//  Created by Michael Peterson on 2012-11-16.
//
//

#import <UIKit/UIKit.h>
#import "CustomFaceRecognizer.h"

@interface PeopleViewController : UITableViewController

@property (nonatomic, strong) CustomFaceRecognizer *faceRecognizer;
@property (nonatomic, strong) NSArray *people;
@property (nonatomic, strong) NSDictionary *selectedPerson;

@end
