//
//  PeopleViewController.mm
//  FaceRecognition
//
//  Created by Michael Peterson on 2012-11-16.
//
//

#import "PeopleViewController.h"
#import "CaptureImagesViewController.h"

@interface PeopleViewController ()

@end

@implementation PeopleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.faceRecognizer = [[CustomFaceRecognizer alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.people = [self.faceRecognizer getAllPeople];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.people count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    static NSString *CellIdentifier = @"PersonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *person = [self.people objectAtIndex:row];
    cell.textLabel.text = [person objectForKey:@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    self.selectedPerson = [self.people objectAtIndex:row];
    
    [self performSegueWithIdentifier:@"CaptureImages" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CaptureImagesViewController *destination = segue.destinationViewController;
    
    if (self.selectedPerson) {
        destination.personID = [self.selectedPerson objectForKey:@"id"];
        destination.personName = [self.selectedPerson objectForKey:@"name"];
    }
}

@end
