//
//  PodsTableViewCell.h
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import "PodsModel.h"

@interface PodTableViewCell : UITableViewCell

@property (nonatomic, strong) Pod *pod;

- (void)attach:(Pod *)pod;
@end
