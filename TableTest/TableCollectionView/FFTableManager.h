//
//  TableCollectionView.h
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFTableCollectionModel.h"
NS_ASSUME_NONNULL_BEGIN
@class FFTableManager;
typedef void(^FFSelectBlock)(NSInteger row, NSInteger index);

struct FFMatrix {
    NSInteger row;
    NSInteger column ;
};
typedef struct CG_BOXABLE FFMatrix FFMatrix;

CG_INLINE FFMatrix
MatrixMake(NSInteger row, CGFloat column)
{
    FFMatrix matrix;
    matrix.row = row;
    matrix.column = column;
    return matrix;
}

@protocol FFTableManagerDataSource <NSObject>

@required

/**
 有多少排
 @param section 第几组
 @return 排数
 */
- (NSInteger)ffTableManagerRowWithNumberSection:(NSInteger)section;

/**
 有几列
 @param section 第几组
 @return 列数
 */
- (NSInteger)ffTableManagerColumnSection:(NSInteger)section;

- (FFTableCollectionModel *)ffTableManagerSetData:(FFTableManager *)FFTableManager matrix:(FFMatrix )matrix;

@optional
/**
 有几组
 
 @return 数量
 */
- (NSInteger)ffTableManagerNumberOfSection;

/**
 每组的cell的宽度

 @return cell的宽度
 */
- (CGFloat )ffTableManagerItemWidthWithSection:(NSInteger )section;

- (FFTableCollectionModel *)ffTableManagerHeaderViewSetData:(FFTableManager *)FFTableManager index:(NSInteger )index;
@end

@protocol FFTableManagerDelegate <NSObject>

@optional
- (UIView *)ffTableManagerSetHeaderView:(FFTableManager *)FFTableManager;
- (UICollectionReusableView *)ffTableManagerSetCollectionHeaderView:(FFTableManager *)ffTableCollectionView section:(NSInteger )section;
- (CGFloat )ffTableManagerWithItemWidth;
- (UIEdgeInsets )ffTableManagerWithsetMargin;
@end

@interface FFTableManager : NSObject
+ (instancetype )shareFFTableManagerWithFrame:(CGRect )frame;
+ (instancetype )shareFFTableManagerWithFrame:(CGRect )frame sView:(UIView *)sView;
@property (nonatomic, weak) id<FFTableManagerDataSource> dataSource;
@property (nonatomic, weak) id<FFTableManagerDelegate> delegate;

- (FFTableManager *(^)(BOOL showHeader))isShowHeader;
- (FFTableManager *(^)(UIColor *borderColor))borderColor;
- (FFTableManager *(^)(BOOL averageItem))averageItem;
- (FFTableManager *(^)(UIView *sView))sView;
- (FFTableManager *(^)(UIEdgeInsets edge))setTableMargin;
- (FFTableManager *(^)(UIEdgeInsets edge))setTableCellTextMargin;
- (instancetype)didSelectWithBlock:(FFSelectBlock)block;
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
