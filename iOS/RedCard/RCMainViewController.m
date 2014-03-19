//
//  RCMainViewController.m
//  RedCard
//
//  Created by Ronnie Liew on 12/3/14.
//  Copyright (c) 2014 Monokromik. All rights reserved.
//


#import <AFNetworking.h>
#import "RCMainViewController.h"
#import "RCLoginViewController.h"
#import "RCFacebookManager.h"
#import "RCConstants.h"
#import "RCTableViewCell.h"

@interface RCMainViewController () <UITableViewDataSource>

@property (nonatomic, strong) RCFacebookManager *fbManager;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (nonatomic ,strong) NSArray *personsInRoom;
@end

@implementation RCMainViewController

/////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
/////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fbManager = [[RCFacebookManager alloc] init];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.clipsToBounds = YES;
    self.refreshButton.enabled = NO;
    
    self.tableView.dataSource = self;
    
    
    if (self.fbManager.userLoggedIn) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            self.refreshButton.enabled = NO;
            [self getRoomUpdate];
            [self getUserData];
        });
        
    }
    else{
        RCLoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RCLoginViewController"];
        loginViewController.fbManager = self.fbManager;
        [self presentViewController:loginViewController animated:YES completion:nil];
        
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [super viewWillAppear:animated];
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.personsInRoom.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCTableViewCell *cell = (RCTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RCMainControllerCell" forIndexPath:indexPath];
    NSDictionary *person = self.personsInRoom[indexPath.row];
    
    cell.person = person;
    return cell;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)getUserData {
    // Trying out using dispatch_semaphore to do wait for both calls to complete and collate the data
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSMutableDictionary* parameters = [NSMutableDictionary dictionary];

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    dispatch_async(queue, ^{
        [self.fbManager GET:@"me" parameters:nil
                    success:^(id responseObject){
                        [parameters addEntriesFromDictionary:responseObject];
                        dispatch_semaphore_signal(sema);
                    }
                    failure:^(NSError *error){
                        dispatch_semaphore_signal(sema);
                    }];
    });

    dispatch_async(queue, ^{
        NSString *widthAndHeight =[@(RCFBProfileImageWidth * 2) stringValue];
        [self.fbManager GET:@"me/picture/"
                 parameters:@{@"redirect":@"false", @"width":widthAndHeight, @"height":widthAndHeight}
                    success:^(id responseObject){
                        [parameters addEntriesFromDictionary:responseObject[@"data"]];
                        dispatch_semaphore_signal(sema);

                        dispatch_async(queue, ^{
                            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:parameters[@"url"]]];
                            
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                self.profileImageView.image = [UIImage imageWithData:imageData];
                            });
                        });
                    }
                    failure:^(NSError *error){
                        dispatch_semaphore_signal(sema);
                    }];
    });

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}



- (void)getRoomUpdate {
    [[AFHTTPRequestOperationManager manager] GET:@"http://redcard.herokuapp.com/getpersons" parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject){
                                             NSLog(@"refreshing: %@", responseObject);
                                             self.personsInRoom = responseObject[@"result"];
                                             self.refreshButton.enabled = YES;
                                             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                                         }
                                         failure:nil
     ];
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)pingButtonTapped:(id)sender {
    [[AFHTTPRequestOperationManager manager] GET:[NSString stringWithFormat:@"http://redcard.herokuapp.com/focusperson/%@", self.fbManager.userID]
                                      parameters:nil
                                         success:nil
                                         failure:nil];
}


- (IBAction)refreshButtonTapped:(id)sender {
    self.refreshButton.enabled = NO;
    [self getRoomUpdate];
}




/////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flipside View
/////////////////////////////////////////////////////////////////////////////////////////////////
- (void)flipsideViewControllerDidFinish:(RCFlipsideViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

@end
