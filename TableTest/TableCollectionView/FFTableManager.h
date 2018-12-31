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
typedef void(^FFSelectBlock)(FFMatrix matrix, NSInteger section);
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

/**
 设置每组头的数据（和子数据数量一致）

 @param FFTableManager 管理类
 @param section 组
 @return 数据
 */
- (NSMutableArray <FFTableCollectionModel *>*)ffTableManagerHeaderViewSetData:(FFTableManager *)FFTableManager section:(NSInteger )section;
@end

@protocol FFTableManagerDelegate <NSObject>

@optional
- (UICollectionReusableView *)ffTableManagerSetCollectionHeaderView:(FFTableManager *)ffTableCollectionView section:(NSInteger )section;
- (CGFloat )ffTableManagerWithItemWidth;
- (UIEdgeInsets )ffTableManagerWithsetMargin;
- (void)didSelectWithSection:(NSInteger )section matrix:(FFMatrix )matrix;
- (void)didSelectWithHeaderSection:(NSInteger )section matrix:(FFMatrix )matrix;
@end

@interface FFTableManager : NSObject
+ (instancetype )shareFFTableManagerWithFrame:(CGRect )frame;
+ (instancetype )shareFFTableManagerWithFrame:(CGRect )frame sView:(UIView *)sView;
@property (nonatomic, weak) id<FFTableManagerDataSource> dataSource;
@property (nonatomic, weak) id<FFTableManagerDelegate> delegate;

- (FFTableManager *(^)(BOOL showAll))isShowAll;
- (FFTableManager *(^)(UIColor *borderColor))borderColor;
- (FFTableManager *(^)(BOOL averageItem))averageItem;
- (FFTableManager *(^)(UIView *sView))sView;
- (FFTableManager *(^)(UIEdgeInsets edge))setTableMargin;
- (FFTableManager *(^)(UIEdgeInsets edge))setTableCellTextMargin;
- (instancetype)didSelectWithBlock:(FFSelectBlock)block;
- (instancetype)didSelectHeaderWithBlock:(FFSelectBlock)block;
- (CGFloat )getTableHeight;
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
