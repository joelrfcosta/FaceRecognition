//
//  CaptureImagesViewController.m
//  FaceRecognition
//
//  Created by Michael Peterson on 2012-11-16.
//
//

#import "CaptureImagesViewController.h"
#import "OpenCVData.h"

@interface CaptureImagesViewController ()

@end

@implementation CaptureImagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.faceDetector = [[FaceDetector alloc] init];
    self.faceRecognizer = [[CustomFaceRecognizer alloc] init];
    
    NSString *instructions = @"Make sure %@ is holding the phone. "
                                "When you are ready, press start.";
    self.instructionsLabel.text = [NSString stringWithFormat:instructions, self.personName];
    
    [self setupCamera];
}

- (void)setupCamera
{
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.previewImage];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
}

- (void)processImage:(cv::Mat&)image
{
    // Only process every 30th frame (every 1s)
    if (self.frameNum == 30) {
        [self parseFaces:[self.faceDetector facesFromImage:image] forImage:image];
        self.frameNum = 1;
    }
    else {
        self.frameNum++;
    }
}

- (void)parseFaces:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    if (faces.size() != 1) {
        [self noFaceToDisplay];
        return;
    }
    
    // We only care about the first face
    cv::Rect face = faces[0];
    
    // Learn it
//    [self.faceRecognizer learnFace:face ofPersonID:[self.personID intValue] fromImage:image];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self highlightFace:[OpenCVData faceToCGRect:face]];
    });
}

- (void)noFaceToDisplay
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.featureLayer.hidden = YES;
    });
}

- (void)highlightFace:(CGRect)faceRect
{
    if (self.featureLayer == nil) {
        self.featureLayer = [[CALayer alloc] init];
        self.featureLayer.borderColor = [[UIColor redColor] CGColor];
        self.featureLayer.borderWidth = 4.0;
        [self.previewImage.layer addSublayer:self.featureLayer];
    }
    
    self.featureLayer.hidden = NO;
    self.featureLayer.frame = faceRect;
}

- (IBAction)cameraButtonClicked:(id)sender
{
    [self.videoCamera start];
}

@end
