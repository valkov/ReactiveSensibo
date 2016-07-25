//
//  RLMArray+LongestCommonSubsequence.h
//  reactiveRealm
//
//  Created by valentinkovalski on 11/11/15.
//  Copyright © 2015 valentinkovalski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/RLMArray.h>

@interface RLMArray (LongestCommonSubsequence)

- (NSIndexSet*)indexesOfCommonElementsWithArray:(NSArray*)array;
- (NSIndexSet*)indexesOfCommonElementsWithArray:(NSArray*)array addedIndexes:(NSIndexSet**)addedIndexes removedIndexes:(NSIndexSet**)removedIndexes;
@end