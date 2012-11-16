//
//  CustomFaceRecognizer.mm
//  FaceRecognition
//
//  Created by Michael Peterson on 2012-11-16.
//
//

#import "CustomFaceRecognizer.h"
#import "OpenCVData.h"

@implementation CustomFaceRecognizer

- (id)init
{
    self = [super init];
    if (self) {
        [self loadDatabase];
        _model = cv::createLBPHFaceRecognizer();
    }
    
    return self;
}

- (void)loadDatabase
{
    if (sqlite3_open([[self dbPath] UTF8String], &_db) != SQLITE_OK) {
        NSLog(@"Cannot open the database.");
    }
    
    [self createTablesIfNeeded];
}

- (NSString *)dbPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"training-data.sql"];
}

- (int)newPersonWithName:(NSString *)name
{
    const char *newPersonSQL = "INSERT INTO people (name) VALUES (?)";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, newPersonSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_step(statement);
    }
    
    sqlite3_finalize(statement);
    
    return sqlite3_last_insert_rowid(_db);
}

- (NSMutableArray *)getAllPeople
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    const char *findPeopleSQL = "SELECT id, name FROM people ORDER BY name";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, findPeopleSQL, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSNumber *personID = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
            NSString *personName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            
            [results addObject:@{@"id": personID, @"name": personName}];
        }
    }
    
    sqlite3_finalize(statement);
    
    return results;
}

- (BOOL)trainModel
{
    std::vector<cv::Mat> images;
    std::vector<int> labels;
    
    const char* selectSQL = "SELECT person_id, image FROM images";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, selectSQL, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int personID = sqlite3_column_int(statement, 0);
            
            // First pull out the image into NSData
            int imageSize = sqlite3_column_bytes(statement, 1);
            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(statement, 1) length:imageSize];
            
            // Then convert NSData to a cv::Mat
            cv::Mat faceData = [OpenCVData dataToMat:imageData
                                               width:[NSNumber numberWithInt:100]
                                              height:[NSNumber numberWithInt:100]];
            
            // Put this image into the model
            images.push_back(faceData);
            labels.push_back(personID);
        }
    }
    
    sqlite3_finalize(statement);
    
    if (images.size() > 0 && labels.size() > 0) {
        _model->train(images, labels);
        return YES;
    }
    else {
        return NO;
    }
}

- (void)forgetAllFacesForPersonID:(int)personID
{
    // DELETE FROM
}

- (void)learnFace:(cv::Rect)face ofPersonID:(int)personID fromImage:(cv::Mat&)image
{
    cv::Mat faceData = [self pullStandardizedFace:face fromImage:image];
    NSData *serialized = [OpenCVData serializeCvMat:faceData];
    
    const char* insertSQL = "INSERT INTO images (person_id, image) VALUES (?, ?)";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, insertSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, personID);
        sqlite3_bind_blob(statement, 2, serialized.bytes, serialized.length, SQLITE_TRANSIENT);
        sqlite3_step(statement);
    }
    
    sqlite3_finalize(statement);
}

- (cv::Mat)pullStandardizedFace:(cv::Rect)face fromImage:(cv::Mat&)image
{
    // Pull the grayscale face ROI out of the captured image
    cv::Mat onlyTheFace;
    cv::cvtColor(image(face), onlyTheFace, CV_RGB2GRAY);
    
    // Standardize the face to 100x100 pixels
    cv::resize(onlyTheFace, onlyTheFace, cv::Size(100, 100), 0, 0);
    
    return onlyTheFace;
}

- (NSDictionary *)recognizeFace:(cv::Rect)face inImage:(cv::Mat&)image
{
    int predictedLabel = -1;
    double confidence = 0.0;
    _model->predict([self pullStandardizedFace:face fromImage:image], predictedLabel, confidence);
    
    return @{
        @"label": [NSNumber numberWithInt:predictedLabel],
        @"confidence": [NSNumber numberWithDouble:confidence]
    };
}

- (void)createTablesIfNeeded
{
    // People table
    const char *peopleSQL = "CREATE TABLE IF NOT EXISTS people ("
                            "'id' integer NOT NULL PRIMARY KEY AUTOINCREMENT, "
                            "'name' text NOT NULL)";
    
    if (sqlite3_exec(_db, peopleSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"The people table could not be created.");
    }
    
    // Images table
    const char *imagesSQL = "CREATE TABLE IF NOT EXISTS images ("
                            "'id' integer NOT NULL PRIMARY KEY AUTOINCREMENT, "
                            "'person_id' integer NOT NULL, "
                            "'image' blob NOT NULL)";
    
    if (sqlite3_exec(_db, imagesSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"The images table could not be created.");
    }
}

@end
