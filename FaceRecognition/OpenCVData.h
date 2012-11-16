//
//  OpenCVData.h
//  FaceRecognition
//
//  Created by Michael Peterson on 2012-11-16.
//
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>

@interface OpenCVData : NSObject

+ (NSData *)serializeCvMat:(cv::Mat&)cvMat;
+ (cv::Mat)dataToMat:(NSData *)data width:(NSNumber *)width height:(NSNumber *)height;
+ (CGRect)faceToCGRect:(cv::Rect)face;
+ (UIImage *)UIImageFromMat:(cv::Mat)image;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;

@end
