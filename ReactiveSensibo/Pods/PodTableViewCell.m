//
//  PodsTableViewCell.m
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import "PodTableViewCell.h"

@interface PodTableViewCell ()
@property (nonatomic, strong) UISwitch *switchView;
@end

@implementation PodTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self) {
        self.switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        self.accessoryView = self.switchView;
        
        @weakify(self);
        [[self.switchView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISwitch *switchControl) {
            @strongify(self);
            [self.pod turnOn:switchControl.on];
        }];
        
        [RACObserve([AFNetworkReachabilityManager sharedManager], networkReachabilityStatus) subscribeNext:^(NSNumber *value) {
            @strongify(self);
            
            self.switchView.enabled = value.boolValue;
            self.textLabel.textColor = value.boolValue ? [UIColor blackColor] : [UIColor grayColor];
            self.detailTextLabel.textColor = value.boolValue ? [UIColor blackColor] : [UIColor grayColor];
        }];
    }
    return self;
}

// first time use binding, if it's been used before, the existing bindings
// will continue to work
- (void)attach:(Pod *)pod {
    RACCommand *toggleCommand = [pod createToggleCommandIfNeeded];
    
    if (self.pod == nil) {
        RAC(self.textLabel, text) = RACObserve(self, pod.uid);
        RAC(self.detailTextLabel, text) = RACObserve(self, pod.location);
        
        @weakify(self);
        [RACObserve(self, pod.on) subscribeNext:^(NSNumber *value) {
            @strongify(self);
            self.switchView.on = value.boolValue;
        }];
        
        [toggleCommand.executing subscribeNext:^(NSNumber *value) {
            @strongify(self);
            
            if(value.boolValue) {
                UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                self.accessoryView = activityView;
                [activityView startAnimating];
            }
            else {
                self.accessoryView = self.switchView;
            }
        }];
    }
    
    self.pod = pod;
}
@end
