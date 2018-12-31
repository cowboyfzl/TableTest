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
NS_ASSUME_NONNULL_BEGIN

@interface FFCollectionHeaderView : UICollectionReusableView
@property (nonatomic, copy) void(^selectBlock)(FFMatrix matrix);
- (void)collectionHeaderViewWithTextWidth:(CGFloat )textWidht cellTextMargin:(UIEdgeInsets )cellTextMargin margin:(UIEdgeInsets )margin borderColor:(UIColor *)borderColor;

- (void )showDataWithModel:(NSMutableArray<FFTableCollectionModel *> *)models size:(CGSize )size isHover:(BOOL )isHover;
@end

NS_ASSUME_NONNULL_END
