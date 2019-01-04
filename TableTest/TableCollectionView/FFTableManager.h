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
typedef void(^FFSelectBlock)(UICollectionView *collectionView, FFMatrix matrix, NSInteger section, FFTableCollectionModel *model);
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

/**
 每条数据

 @param FFTableManager 当前类
 @param matrix item的位置
 @return 对应的模型
 */
- (FFTableCollectionModel *)ffTableManagerSetData:(FFTableManager *)FFTableManager matrix:(FFMatrix )matrix;

@optional
/**
 有几组
 
 @return 数量
 */
- (NSInteger)ffTableManagerNumberOfSection;


/**
 每组 每列cell的宽度

 @param column 多少列
 @param section 第几组
 @param margin collectiony边缘偏移量
 @return 宽度
 */
- (CGFloat )ffTableManagerItemWidthWithColumn:(NSInteger )column Section:(NSInteger )section margin:(UIEdgeInsets )margin;

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
- (Class )ffTableManagerRegistClassWithSection:(NSInteger )section;
- (void )ffTableManagerSetCollectionHeaderView:(UICollectionReusableView *)ffTableCollectionView section:(NSInteger )section;
- (CGFloat )ffTableManagerHeaderHeightWithSction:(NSInteger )section;
- (UIEdgeInsets )ffTableManagerWithsetMargin;
- (void)didSelectWithCollectionView:(UICollectionView *)collectionView section:(NSInteger )section matrix:(FFMatrix )matrix model:(FFTableCollectionModel *)model;
- (void)didSelectWithCollectionViewHeader:(UICollectionView *)collectionView section:(NSInteger )section matrix:(FFMatrix )matrix model:(FFTableCollectionModel *)model;
@end

@interface FFTableManager : NSObject
+ (instancetype )shareFFTableManagerWithFrame:(CGRect )frame;
+ (instancetype )shareFFTableManagerWithFrame:(CGRect )frame sView:(UIView *)sView;
@property (nonatomic, weak) id<FFTableManagerDataSource> dataSource;
@property (nonatomic, weak) id<FFTableManagerDelegate> delegate;
@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic, strong) UIScrollView *mainScrollView;
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
