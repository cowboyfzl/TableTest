//
//  FFCollectionHeaderView.h
//  TableTest
//
//  Created by fafa on 2018/12/31.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFTableCollectionModel.h"
#import "FFTableManager.h"
#import "FFTableCollectionViewFlowLayout.h"
NS_ASSUME_NONNULL_BEGIN

@interface FFCollectionHeaderView : UICollectionReusableView
@property (nonatomic, copy) void(^selectBlock)(FFMatrix matrix);
@property (nonatomic, getter=isLeft) BOOL left;
- (void)collectionHeaderViewWithCellTextMargin:(UIEdgeInsets )cellTextMargin margin:(UIEdgeInsets )margin borderColor:(UIColor *)borderColor collectionViewCellPosition:(CollectionViewCellPosition)collectionViewCellPosition;

- (void )showDataWithModel:(NSMutableArray<FFTableCollectionModel *> *)models sizes:(NSArray *)sizes isHover:(BOOL )isHover;
@end

NS_ASSUME_NONNULL_END
