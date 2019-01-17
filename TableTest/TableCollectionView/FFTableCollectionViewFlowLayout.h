//
//  FFTableCollectionViewFlowLayout.h
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CollectionViewCellPosition) {
    CollectionViewCellPositionLeft = 0,
    CollectionViewCellPositionCenter,
    CollectionViewCellPositionRight,
};
@interface FFTableCollectionViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) CollectionViewCellPosition collectionViewCellPosition;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, strong) NSMutableArray *columns;
@property (nonatomic, strong) NSMutableArray *headerHeights;
@end

NS_ASSUME_NONNULL_END
