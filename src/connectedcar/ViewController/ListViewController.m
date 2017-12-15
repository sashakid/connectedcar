//
//  ListViewController.m
//  connectedcar
//
//  Created by Alexander Yakovlev on 4/29/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import "ListViewController.h"
#import "DatabaseManager.h"
#import "ListCell.h"
#import "MapViewController.h"
#import "UIViewController+Error.h"

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataSource;

@end

@implementation ListViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = @"Connected Car";
   
    [self updateDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isMemberOfClass:[MapViewController class]]) {
        MapViewController *controller = (MapViewController *)segue.destinationViewController;
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        controller.user = _dataSource[indexPath.row];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ListCell class])];
    cell.user = _dataSource[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Helpers 

- (void)updateDataSource {
    [[DatabaseManager sharedManager] getUsersWithCompletion:^(BOOL success, NSArray<User *> *users, NSError *error) {
        if (success) {
            _dataSource = users;
            [_tableView reloadData];
        } else {
            if ([error.localizedDescription containsString:@"html"]) {
                [self showRetryErrorMessage:error.localizedDescription retry:^{
                    //error from server, we need to repeat request
                    [self updateDataSource];
                } cancel:^{
                    //nothing to do
                }];
            } else {
                [self showErrorMessage:error.localizedDescription];
            }
        }
    }];
}

@end
