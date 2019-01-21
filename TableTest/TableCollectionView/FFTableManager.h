//
//  TableCollectionView.h
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFTableCollectionModel.h"
#import "FFTableCollectionViewFlowLayout.h"
NS_ASSUME_NONNULL_BEGIN
@class FFTableManager;

/**
 矩阵，代表当前是第几排第几列
 */
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
typedef void(^FFSelectBlock)(UICollectionView *collectionView, FFMatrix matrix, NSInteger section);
@protocol FFTableManagerDataSource <NSObject>

@required

/**
 有多少排
 @param section 第几组
 @return 排数
 */
- (NSInteger)ffTableManager:(FFTableManager *)FFTableManager rowWithNumberSection:(NSInteger)section;

/**
 有几列
 @param section 第几组
 @return 列数
 */
- (NSInteger)ffTableManager:(FFTableManager *)FFTableManager columnSection:(NSInteger)section;

/**
 每条数据内容

 @param FFTableManager 当前类
 @param matrix item的位置
 @return 对应的模型
 */
- (FFTableCollectionModel *)ffTableManagerSetData:(FFTableManager *)FFTableManager section:(NSInteger )section matrix:(FFMatrix )matrix;

@optional
/**
 有几组
 
 @return 数量
 */
- (NSInteger)ffTableManagerNumberOfSection:(FFTableManager *)FFTableManager;

/**
 每组 每行cell的宽度
 注意margin这个参数会影响你计算宽度的最终结果，你应该跟进margin.left 和 margin.right的总偏移量来计算每行cell的宽度
 
 例如 Column == 6
 CGFloat w = self.view.bounds.size.width - margin.left - margin.right;
 CGFloat cellWidth = w / Column;
 switch (column) {
 case 0:
 return cellWidth * 2;
 break;
 
 default:
 {
 CGFloat width = (w - cellWidth * 2) / (Column  - 1);
 return width;
 }
 break;
 }
 
 @param column 第几列
 @param section 第几组
 @param margin collectiony边缘偏移量
 @return 宽度
 */
- (CGFloat )ffTableManager:(FFTableManager *)FFTableManager itemWidthWithColumn:(NSInteger )column Section:(NSInteger )section margin:(UIEdgeInsets )margin;

/**
 根据权重系数设置每组 每行cell宽度
 此代理会优先于直接设置宽度代理，如果传入的数组数据数量与当前列总数不一致，之后会根据averageItem设置cell宽度
 
 例如目前总共有6列数据返回@[@1.5,@1.5,@1,@1,@1,@1]
 
 @param section 第几组
 @return 权重系数
 */
- (NSArray *)ffTableManager:(FFTableManager *)FFTableManager itemWidtWeightCoefficienthWithSection:(NSInteger )section;

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

/**
 自定义头
 此方法只需要在其他地方创建相对应的类或者XIB 赋值嘛请看下面
 @param section 对应的组
 @return 类名
 */
- (Class )ffTableManager:(FFTableManager *)FFTableManager registClassWithSection:(NSInteger )section;

/**
 配合上面用的给自定义头赋值

 @param ffTableCollectionView 自定义的UICollectionReusableView 记着强转成传入的类型
 @param section 分组
 */
- (void )ffTableManager:(FFTableManager *)FFTableManager setCollectionHeaderView:(UICollectionReusableView *)ffTableCollectionView section:(NSInteger )section;

/**
 头的高度
 配合上面的方法可以设置自定义表头的高度（直接设置每组头的数据不用自定义高度，不然很丑……排版也会错误）
 @param section 分组
 @return 高度
 */
- (CGFloat )ffTableManager:(FFTableManager *)FFTableManager headerHeightWithSction:(NSInteger )section;

/**
 设置表的边距

 @return 边距参数
 */
- (UIEdgeInsets )ffTableManager:(FFTableManager *)FFTableManagerWithsetMargin;

/**
 点击回调

 @param collectionView 当前的表格对象
 @param section 第几组
 @param matrix 矩阵
 */
- (void)ffTableManager:(FFTableManager *)FFTableManager didSelectWithCollectionView:(UICollectionView *)collectionView section:(NSInteger )section matrix:(FFMatrix )matrix;

/**
 点击头的回调

 @param collectionView 当前的头表格对象
 @param section 第几组
 @param matrix 矩阵
 */
- (void)ffTableManager:(FFTableManager *)FFTableManager didSelectWithCollectionViewHeader:(UICollectionView *)collectionView section:(NSInteger )section matrix:(FFMatrix )matrix;
@end

@interface FFTableManager : NSObject

/**
 初始化方法

 @param frame 传入的尺寸位置
 @return 实例
 */
+ (instancetype )shareFFTableManagerWithFrame:(CGRect )frame;

/**
 初始化方法

 @param frame 对象
 @param sView 父视图
 @return 实例
 */
+ (instancetype )shareFFTableManagerWithFrame:(CGRect )frame sView:(UIView *)sView;

/// 数据代理
@property (nonatomic, weak) id<FFTableManagerDataSource> dataSource;
/// 其他代理
@property (nonatomic, weak) id<FFTableManagerDelegate> delegate;
/// 表格对象
@property (nonatomic, strong) UICollectionView *mainCollectionView;
/// 左右滚动对象
@property (nonatomic, strong) UIScrollView *mainScrollView;

/**
 是否显示全部
 默认为 false
 如果设置成true当前视图的高度为所有列表高度加上头视图的总合
 */
- (FFTableManager *(^)(BOOL showAll))isShowAll;

/**
 是否让header悬停
 */
- (FFTableManager *(^)(BOOL showAll))isHoverHeader;

/**
 默认grayColor
 列表所有边框颜色
 */
- (FFTableManager *(^)(UIColor *borderColor))borderColor;

/**
 默认为 false
 是否按照collectionView的宽度平分每个单元的宽度,如果设置为true就算设置了宽度也会失效
 */
- (FFTableManager *(^)(BOOL averageItem))averageItem;

/**
 父视图
 默认为空，在选择+ (instancetype )shareFFTableManagerWithFrame:(CGRect )frame的时候才有必要使用这个函数
 */
- (FFTableManager *(^)(UIView *sView))sView;

/**
 默认为 (5, 5, 5, 5)
 设置表格相对CollectionView的边距
 */
- (FFTableManager *(^)(UIEdgeInsets edge))setTableMargin;

/**
 默认为 (5, 5, 5, 5)
 设置表格每个cell 文本框相对边缘的的边距
 */
- (FFTableManager *(^)(UIEdgeInsets edge))setTableCellTextMargin;

/**
 默认为 CollectionViewCellPositionLeft 居左
 设置可左右滑动表格在多组数据不同列的情况下布局方式
 */
- (FFTableManager *(^)(CollectionViewCellPosition position))collectionViewCellPosition;
/**
 点击cell回调

 @param block FFSelectBlock对象包含UICollectionView *collectionView, FFMatrix matrix, NSInteger section
 @return 实例
 */
- (instancetype)didSelectWithBlock:(FFSelectBlock)block;

/**
 点击Header回调
 
 @param block FFSelectBlock对象包含UICollectionView *collectionView, FFMatrix matrix, NSInteger section
 @return 实例
 */
- (instancetype)didSelectHeaderWithBlock:(FFSelectBlock)block;

/**
 获取整个列表的高度

 @return 高度
 */
- (CGFloat )getTableHeight;

/**
 重载数据
 */
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
