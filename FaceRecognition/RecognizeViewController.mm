//
//  RecognizeViewController.mm
//  FaceRecognition
//
//  Created by Michael Peterson on 2012-11-16.
//
//

#import "RecognizeViewController.h"

@interface RecognizeViewController ()

@end

@implementation RecognizeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.faceDetector = [[FaceDetector alloc] init];
    self.faceRecognizer = [[CustomFaceRecognizer alloc] init];
    
    [self.faceRecognizer trainModel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
