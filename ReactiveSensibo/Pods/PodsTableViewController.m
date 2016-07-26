//
//  PodsTableViewController.m
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import "PodsTableViewController.h"
#import "SUtils.h"
#import "NetworkingManager.h"
#import "LoginViewController.h"
#import "PodTableViewCell.h"

@interface PodsTableViewController ()
@end

static NSString *cellIdentifier = @"PodsTableViewCellID";

@implementation PodsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [[NSUserDefaults standardUserDefaults] objectForKey:kUsername];
    
    [self.tableView registerClass:[PodTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout", @"") style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    
    self.refreshControl = [UIRefreshControl new];
    
    self.refreshControl.rac_command = self.podsModel.refreshCommand;
    
    //pull to refresh
    @weakify(self);
    [self.refreshControl.rac_command.executionSignals subscribeNext:^(RACSignal *signal) {
        @strongify(self);
        [signal subscribeCompleted:^{
            [self.refreshControl endRefreshing];
        }];
    }];

    [self bindTableView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height * 2) animated:YES];
    [self.refreshControl beginRefreshing];
    
    [self.refreshControl.rac_command execute:nil];
}

#pragma mark - UITableiView model binding
- (void)bindTableView {
    
    RACSignal *podsChangedSignal = [self.podsModel rac_valuesAndChangesForKeyPath:@"pods" options:0 observer:self];
    
    @weakify(self);
    [podsChangedSignal subscribeNext:^(RACTuple *info) { // tuple is value, change dictionary
        @strongify(self);
        
        NSDictionary *change = info.second;
        NSKeyValueChange kind = [change[NSKeyValueChangeKindKey] intValue];
        NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
        
        if (indexes) {
            NSArray *paths = [SUtils indexSetToIndexPathArray:indexes section:0];
            if (kind == NSKeyValueChangeInsertion) {
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView endUpdates];
                DLog(@"insertRowsAtIndexPaths %@", paths);
            }
            else if (kind == NSKeyValueChangeRemoval) {
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                DLog(@"deleteRowsAtIndexPaths %@", paths);
            }
            else {
                [self.tableView reloadData];
            }
        }
        else {
            [self.tableView reloadData];
        }
    }];
}


#pragma mark - Navigation bar control handlers

- (void)logout {
    [[NetworkingManager sharedManager] logout];
    
    LoginViewController *loginController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewControllerID"];
    loginController.viewModel = [LoginModel new];
    [SUtils changeRootViewController:loginController withCompletion:nil];
    DLog(@"logged out");
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.podsModel.pods.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Pod *pod = self.podsModel.pods[indexPath.row];
    [cell attach:pod];
    
    return cell;
}

@end
