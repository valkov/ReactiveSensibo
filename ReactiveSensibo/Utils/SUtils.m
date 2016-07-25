//
//  SUtils.m
//  ReactiveSensibo
//
//  Created by valentinkovalski on 7/25/16.
//  Copyright © 2016 valentinkovalski. All rights reserved.
//

#import "SUtils.h"

@implementation SUtils

#pragma mark - UI Utils

+ (void)changeRootViewController:(UIViewController*)viewController withCompletion:(emptyBlock)completion {
    
    void (^changeRootBlock)(void) = ^ {
        if (![UIApplication sharedApplication].keyWindow.rootViewController) {
            [UIApplication sharedApplication].keyWindow.rootViewController = viewController;
            return;
        }
        
        UIView *snapShot = [[UIApplication sharedApplication].keyWindow snapshotViewAfterScreenUpdates:YES];
        
        [viewController.view addSubview:snapShot];
        
        [UIApplication sharedApplication].keyWindow.rootViewController = viewController;
        
        [UIView animateWithDuration:0.5 animations:^{
            snapShot.layer.opacity = 0;
            snapShot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
        } completion:^(BOOL finished) {
            [snapShot removeFromSuperview];
            if(completion)
                completion();
        }];
        
    };
    
    if([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController) {
        [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:^{
            changeRootBlock();
        }];
    }
    else {
        changeRootBlock();
    }
}

+ (void)showErrorAlertFromHTMLData:(NSData*)data {
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
    
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error occured", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [errorAlert setValue:attributedString forKey:@"attributedMessage"];
    [errorAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"") style:UIAlertActionStyleDefault handler:nil]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:errorAlert animated:YES completion:nil];
}

+ (void)showNoConnectionError {
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error occured", @"") message:NSLocalizedString(@"You appear to be offline", @"") preferredStyle:UIAlertControllerStyleAlert];
    [errorAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"") style:UIAlertActionStyleDefault handler:nil]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:errorAlert animated:YES completion:nil];
}

+ (void)showSuccess {
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Success", @"") message:NSLocalizedString(@"Operation complete", @"") preferredStyle:UIAlertControllerStyleAlert];
    [errorAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"") style:UIAlertActionStyleDefault handler:nil]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:errorAlert animated:YES completion:nil];
}

#pragma mark - Other
+ (NSArray *)indexSetToIndexPathArray:(NSIndexSet *)indexes section:(NSInteger)section {
    NSMutableArray *paths = [NSMutableArray arrayWithCapacity:indexes.count];
    NSUInteger index = [indexes firstIndex];
    while (index != NSNotFound) {
        [paths addObject:[NSIndexPath indexPathForRow:index inSection:section]];
        index = [indexes indexGreaterThanIndex:index];
    }
    return paths;
}

@end
