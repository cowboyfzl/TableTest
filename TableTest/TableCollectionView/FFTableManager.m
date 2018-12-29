//
//  TableCollectionView.m
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import "FFTableManager.h"
#import "FFTableCollectionViewCell.h"
#import "FFTableCollectionViewFlowLayout.h"

@interface FFTableManager () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, assign) UIEdgeInsets margin;
@property (nonatomic, assign) UIEdgeInsets cellTextMargin;
@property (nonatomic, weak) UIView *superV;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, strong) NSMutableArray *cellWidthsArr;
@property (nonatomic, copy) FFSelectBlock selectBlock;
@property (nonatomic, strong) NSMutableDictionary *cacheRowHeight;
@property (nonatomic, strong) UIColor *cellBorderColor;
@property (nonatomic, assign) FFMatrix maxMatrix;
@property (nonatomic, assign) BOOL cellAverageItem;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) CGFloat maxCellWidth;
@property (nonatomic, assign) CGFloat headerCellHeight;
@end
static NSInteger const DefaultCellWidth = 80;
static NSInteger const HeaderCollectionViewTag = 100;
@implementation FFTableManager

+ (instancetype)shareFFTableManagerWithFrame:(CGRect )frame {
    FFTableManager *manager = [self new];
    manager.mainScrollView.frame = frame;
    manager.cellAverageItem = false;
    manager.cellTextMargin = UIEdgeInsetsMake(5, 5, 5, 5);
    manager.margin = UIEdgeInsetsMake(5, 5, 5, 5);
    manager.cellBorderColor = [UIColor grayColor];
    manager.section = 1;
    manager.maxCellWidth = 0;
    return manager;
}

+ (instancetype)shareFFTableManagerWithFrame:(CGRect )frame sView:(UIView *)sView {
    FFTableManager *manager = [self shareFFTableManagerWithFrame:frame];
    manager.sView(sView);
    return manager;
}

- (FFTableManager *(^)(UIEdgeInsets edge))setTableCellTextMargin {
    return ^FFTableManager *(UIEdgeInsets edge) {
        self.cellTextMargin = edge;
        return self;
    };
}

- (FFTableManager *(^)(UIEdgeInsets edge))setTableMargin {
    return ^FFTableManager *(UIEdgeInsets edge) {
        self.margin = edge;
        return self;
    };
}

-(instancetype)didSelectWithBlock:(FFSelectBlock)block {
    _selectBlock = block;
    return self;
}

- (FFTableManager * _Nonnull (^)(UIView * _Nonnull))sView {
    return ^FFTableManager *(UIView *sView) {
        self.superV = sView;
        [self.superV addSubview:self.mainScrollView];
        return self;
    };
}

- (FFTableManager *(^)(BOOL averageItem))averageItem {
    return ^FFTableManager *(BOOL averageItem) {
        self.cellAverageItem = averageItem;
        return self;
    };
}

- (FFTableManager *(^)(UICollectionViewScrollDirection direction))direction {
    return ^FFTableManager *(UICollectionViewScrollDirection direction) {
//        self.flowLayout.scrollDirection = direction;
        return self;
    };
}

- (FFTableManager *(^)(UIColor *borderColor))borderColor {
    return ^FFTableManager *(UIColor *borderColor) {
        self.cellBorderColor = borderColor;
        return self;
    };
}

- (void)reloadData {
    
    if ([self.dataSource respondsToSelector:@selector(ffTableManagerNumberOfSection)]) {
        _section = [self.dataSource ffTableManagerNumberOfSection];
    }
    [self calulateMaxWidth];
    _headerCellHeight =[self calculateHeaderCellHeight];
    [self setHeaderViewContent];
    if (!_mainCollectionView) {
        [_superV addSubview:_mainScrollView];
        [_mainScrollView addSubview:self.mainCollectionView];
    } else {
        [_mainCollectionView reloadData];
    }
}

- (void)calulateMaxWidth {
    [self.cellWidthsArr removeAllObjects];
    CGFloat itemOffset = _margin.left + _margin.right;
    CGFloat width = _superV.bounds.size.width;
    for (NSInteger i = 0; i < _section; i++) {
        CGFloat itemWidth = 0;
        if (!_cellAverageItem) {
            if ([self.dataSource respondsToSelector:@selector(ffTableManagerItemWidthWithSection:)]) {
                itemWidth = [self.dataSource ffTableManagerItemWidthWithSection:i];
            } else {
                itemWidth = DefaultCellWidth;
            }
        } else {
           itemWidth = (width - itemOffset) / [self.dataSource ffTableManagerColumnSection:i];
        }
        
        [_cellWidthsArr addObject:@(itemWidth)];
        _maxCellWidth = itemWidth > _maxCellWidth ? itemWidth : _maxCellWidth;
    }
}

- (void)setHeaderViewContent {
    if ([self.delegate respondsToSelector:@selector(ffTableManagerSetHeaderView:)]) {
        self.headerView = [self.delegate ffTableManagerSetHeaderView:self];
        CGRect headerRect = _headerView.frame;
        _headerView.frame = CGRectMake(0, 0, headerRect.size.width, headerRect.size.height);
    } else {
        self.headerView = [self defaultHeaderView];
        /// 添加一个带表格的collectionView
    }
    [_mainScrollView addSubview:_headerView];
}

- (CGFloat)calculateRowMaxHeightWithSection:(NSInteger )section row:(NSInteger )row {
    /// 有几列
    NSInteger column = [self.dataSource ffTableManagerColumnSection:section];
    NSCAssert(column >= 0, @"不能输入负数");
    NSInteger maxHeight = 0;
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", section, row];
    if (_cacheRowHeight[key]) {
        maxHeight = [_cacheRowHeight[key] integerValue];
        return maxHeight;
    }

    for (NSInteger j = 0; j < column; j++) {
        FFMatrix matrix = MatrixMake(row - 1, j);
        FFTableCollectionModel *model = [self.dataSource ffTableManagerSetData:self matrix:matrix];
        CGFloat textWidth = [self calculateTextLabelWidthWithSection:section];
        CGFloat textHeight = [self tableManagerWithLabelTextRectWithSize:CGSizeMake(textWidth, MAXFLOAT) withFontSize:model.font withText:model.content].size.height + 1;
        maxHeight = textHeight > maxHeight ? textHeight : maxHeight;
    }
    
    maxHeight += _cellTextMargin.top + _cellTextMargin.bottom;
    [self.cacheRowHeight setValue:@(maxHeight) forKey:key];
    return maxHeight;
}

- (CGFloat)calculateHeaderCellHeight {
    NSInteger column = [self.dataSource ffTableManagerColumnSection:0];
    NSInteger maxHeight = 0;
    FFTableCollectionModel *model;
    for (NSInteger i = 0; i < column; i++) {
        if ([self.dataSource respondsToSelector:@selector(ffTableManagerHeaderViewSetData:index:)]) {
           model = [self.dataSource ffTableManagerHeaderViewSetData:self index:i];
        }
        CGFloat textWidth = [self calculateTextLabelWidthWithSection:0];
        CGFloat textHeight = [self tableManagerWithLabelTextRectWithSize:CGSizeMake(textWidth, MAXFLOAT) withFontSize:model.font withText:model.content].size.height + 1;
        maxHeight = textHeight > maxHeight ? textHeight : maxHeight;
    }
    
    maxHeight += _cellTextMargin.top + _cellTextMargin.bottom;
    return maxHeight;
}

- (CGFloat)calculateTextLabelWidthWithSection:(NSInteger )section {
    CGFloat textoffset = _cellTextMargin.left + _cellTextMargin.right;
    return [_cellWidthsArr[section]floatValue] - textoffset;
}

- (CGRect)tableManagerWithLabelTextRectWithSize:(CGSize )size withFontSize:(UIFont *)fontSize withText:(NSString *)text {
    CGRect frame = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName : fontSize} context:nil];
    return frame;
}

- (NSInteger )calulateAllCountWithSection:(NSInteger )section {
    /// 有几排
    NSInteger row = [self.dataSource ffTableManagerRowWithNumberSection:section];
    /// 有几列
    NSInteger column = [self.dataSource ffTableManagerColumnSection:section];
    NSCAssert(column >= 0 || row >= 0, @"不能输入负数");
    _maxMatrix = MatrixMake(row - 1, column - 1);
    return row * column;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (collectionView.tag == HeaderCollectionViewTag) {
        return 1;
    }
    return _section;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == HeaderCollectionViewTag && [self.delegate respondsToSelector:@selector(ffTableManagerHeaderViewSetData:index:)]) {
        return [self calulateAllCountWithSection:0];
    }
    
    return [self calulateAllCountWithSection:section];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString: UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
        if ([self.delegate respondsToSelector:@selector(ffTableManagerSetCollectionHeaderView:section:)]) {
            view = [self.delegate ffTableManagerSetCollectionHeaderView:self section:indexPath.section];
        }
         return view;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == HeaderCollectionViewTag) {
        return CGSizeMake([self calculateTextLabelWidthWithSection:0], _headerCellHeight);
    } else {
        NSInteger row = ceil(indexPath.row / [self.dataSource ffTableManagerColumnSection:indexPath.section]) + 1;
        return CGSizeMake([_cellWidthsArr[indexPath.section]floatValue], [self calculateRowMaxHeightWithSection:indexPath.section row:row]);
    }
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return _margin;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (collectionView.tag == HeaderCollectionViewTag) {
        
    } else {
        
    }
    FFTableCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FFTableCollectionViewCell class]) forIndexPath:indexPath];
    NSInteger sourceColumn = [self.dataSource ffTableManagerColumnSection:indexPath.section];
    NSInteger row = ceil(indexPath.row / sourceColumn);
    NSInteger column = indexPath.row % [self.dataSource ffTableManagerColumnSection:indexPath.section];
    FFMatrix matrix = MatrixMake(row, column);
    FFTableCollectionModel *model = [self.dataSource ffTableManagerSetData:self matrix:matrix];
    cell.currentMatrix = matrix;
    cell.maxMatrix = _maxMatrix;
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", indexPath.section, row + 1];
    [cell showDataWithModel:model borderColor:_cellBorderColor edge:_cellTextMargin size:CGSizeMake([_cellWidthsArr[indexPath.section]floatValue], [_cacheRowHeight[key] floatValue])];
    return cell;
}

- (UICollectionView *)defaultHeaderView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    
    CGFloat itemWidth = _maxCellWidth;
    NSInteger column = [self.dataSource ffTableManagerColumnSection:0];
    CGFloat width = column * itemWidth;
    width += _margin.left + _margin.right;
    width = MAX(_mainScrollView.bounds.size.width, width);
    UICollectionView *mainCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, _cellAverageItem ? _mainScrollView.bounds.size.width : MAX(_mainScrollView.bounds.size.width, width), _headerCellHeight) collectionViewLayout:layout];
    mainCollectionView.tag = HeaderCollectionViewTag;
    mainCollectionView.scrollEnabled = false;
    mainCollectionView.delegate = self;
    mainCollectionView.dataSource = self;
    mainCollectionView.backgroundColor = [UIColor whiteColor];
    [mainCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FFTableCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([FFTableCollectionViewCell class])];
    return mainCollectionView;
}

- (UICollectionView *)mainCollectionView {
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat itemWidth = _maxCellWidth;
        NSInteger column = [self.dataSource ffTableManagerColumnSection:0];
        CGFloat width = column * itemWidth;
        width += _margin.left + _margin.right;
        width = MAX(_mainScrollView.bounds.size.width, width);
        _mainScrollView.contentSize = CGSizeMake(width, 0);
        _mainCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, _headerView.bounds.size.height, _cellAverageItem ? _mainScrollView.bounds.size.width : MAX(_mainScrollView.bounds.size.width, width), _mainScrollView.bounds.size.height - _headerView.bounds.size.height) collectionViewLayout:layout];
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.backgroundColor = [UIColor whiteColor];
        [_mainCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FFTableCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([FFTableCollectionViewCell class])];
        [_mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
    }
    return _mainCollectionView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc]init];
    }
    return _headerView;
}

- (UIScrollView *)mainScrollView {
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc]init];
        _mainScrollView.delegate = self;
        _mainScrollView.showsVerticalScrollIndicator = false;
        _mainScrollView.showsHorizontalScrollIndicator = false;
    }
    return _mainScrollView;
}

- (NSMutableDictionary *)cacheRowHeight {
    if (!_cacheRowHeight) {
        _cacheRowHeight = [NSMutableDictionary dictionary];
    }
    return _cacheRowHeight;
}

- (NSMutableArray *)cellWidthsArr {
    if (!_cellWidthsArr) {
        _cellWidthsArr = [NSMutableArray array];
    }
    return _cellWidthsArr;
}

@end


