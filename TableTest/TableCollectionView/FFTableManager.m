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
#import "UICollectionViewFlowLayout+Add.h"
#import "FFCollectionHeaderView.h"
@interface FFTableManager () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) UIEdgeInsets margin;
@property (nonatomic, assign) UIEdgeInsets cellTextMargin;
@property (nonatomic, weak) UIView *superV;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, assign) NSInteger column;
@property (nonatomic, strong) NSMutableArray <NSMutableArray <NSNumber *> *> *cellWidthsArr;
@property (nonatomic, copy) FFSelectBlock selectBlock;
@property (nonatomic, copy) FFSelectBlock selectHeaderBlock;
@property (nonatomic, strong) NSMutableDictionary *cacheRowHeight;
@property (nonatomic, strong) UIColor *cellBorderColor;
@property (nonatomic, strong) NSMutableArray *maxMatrixs;
@property (nonatomic, assign) BOOL cellAverageItem;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, strong) NSMutableArray *headerCellSizes;
@property (nonatomic, assign) BOOL showAllHeight;
@end
static NSInteger const DefaultCellWidth = 80;
@implementation FFTableManager

+ (instancetype)shareFFTableManagerWithFrame:(CGRect )frame {
    FFTableManager *manager = [self new];
    CGRect rect = frame;
    rect.origin.y -= 1;
    rect.size.height -= 1;
    manager.mainScrollView.frame = rect;
    manager.cellAverageItem = false;
    manager.cellTextMargin = UIEdgeInsetsMake(5, 5, 5, 5);
    manager.margin = UIEdgeInsetsMake(5, 5, 5, 5);
    manager.cellBorderColor = [UIColor grayColor];
    manager.section = 1;
    manager.showAllHeight = false;
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

- (FFTableManager *(^)(BOOL showAll))isShowAll {
    return ^FFTableManager *(BOOL showAll) {
        self.showAllHeight = showAll;
        return self;
    };
}

- (instancetype)didSelectHeaderWithBlock:(FFSelectBlock)block {
    _selectHeaderBlock = block;
    return self;
}

- (void)reloadData {
    if ([self.dataSource respondsToSelector:@selector(ffTableManagerNumberOfSection)]) {
        _section = [self.dataSource ffTableManagerNumberOfSection];
    }
    [self.maxMatrixs removeAllObjects];
    [self calulateMaxWidthAndHeaderHeight];
    if (!_mainCollectionView) {
        [_superV addSubview:_mainScrollView];
        [_mainScrollView addSubview:self.mainCollectionView];
    } else {
        [_mainCollectionView reloadData];
    }
    
    self.mainCollectionView.frame = CGRectMake(self.mainCollectionView.frame.origin.x, self.mainCollectionView.frame.origin.y, [self calulateCollectionViewWidth], CGRectGetHeight(_mainCollectionView.bounds));
    
    if (_showAllHeight) {
        [self calulateAllHeight];
    }
}

- (CGFloat)getTableHeight {
    return [self calulateAllHeight];
}

- (CGFloat)calulateCollectionViewWidth {
    CGFloat itemWidth = 0;
    for (NSInteger i = 0; i < _section; i++ ) {
        CGFloat sectionWidth = 0;
        for (NSNumber *width in _cellWidthsArr[i]) {
            sectionWidth += [width floatValue];
        }
        
        if ([self.delegate respondsToSelector:@selector(ffTableManagerRegistClassWithSection:)] && [self.delegate respondsToSelector:@selector(ffTableManagerSetCollectionHeaderView:section:)]) {
            Class class = [self.delegate ffTableManagerRegistClassWithSection:i];
            NSString *nibPath = [[NSBundle mainBundle]pathForResource:NSStringFromClass(class) ofType:@"nib"];
            if (nibPath.length) {
                [_mainCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass(class) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(class)];
            } else {
                [_mainCollectionView registerClass:class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(class)];
            }
        }
        
        itemWidth = sectionWidth > itemWidth ? sectionWidth : itemWidth;
    }
    
    itemWidth += _margin.left + _margin.right;
    _mainScrollView.contentSize = CGSizeMake(itemWidth, 0);
    return itemWidth;
}

- (CGFloat )calulateAllHeight {
    CGFloat maxHeight = 0;
    for (NSInteger i = 0; i < _section; i++) {
        CGFloat headerHeight = [_headerCellSizes[i][0]CGSizeValue].height;
        NSInteger row = [self.dataSource ffTableManagerRowWithNumberSection:i];
        for (NSInteger j = 0; j < row; j++) {
            CGFloat rowHeight = [self calculateRowMaxHeightWithSection:i row:j + 1];
            maxHeight += rowHeight;
        }
        
        maxHeight += headerHeight + _margin.top + _margin.bottom;
    }
    
    if (_showAllHeight) {
        CGRect scrollRect = _mainScrollView.frame;
        scrollRect.size.height = maxHeight;
        _mainScrollView.frame = scrollRect;
        _mainCollectionView.frame = _mainScrollView.bounds;
    }
    
    return maxHeight;
}

- (void)calulateMaxWidthAndHeaderHeight {
    [_superV layoutIfNeeded];
    [self.cellWidthsArr removeAllObjects];
    [self.headerCellSizes removeAllObjects];
    CGFloat itemOffset = _margin.left + _margin.right;
    CGFloat width = _superV.bounds.size.width;
    for (NSInteger i = 0; i < _section; i++) {
        NSMutableArray *itemWidths = [NSMutableArray array];
        NSInteger column = [self.dataSource ffTableManagerColumnSection:i];
        for (NSInteger j = 0 ; j < column; j++) {
            if (!_cellAverageItem) {
                if ([self.dataSource respondsToSelector:@selector(ffTableManagerItemWidthWithColumn:Section:margin:)]) {
                    CGFloat itemWidth = [self.dataSource ffTableManagerItemWidthWithColumn:j Section:i margin:_margin];
                    [itemWidths addObject:@(itemWidth)];
                } else {
                    [itemWidths addObject:@(DefaultCellWidth)];
                }
            } else {
                CGFloat itemWidth = (width - itemOffset) / [self.dataSource ffTableManagerColumnSection:i];
                [itemWidths addObject:@(itemWidth)];
            }
        }
        [_cellWidthsArr addObject:itemWidths];
        [self calculateHeaderCellHeightWithSection:i textWidths:itemWidths];
    }
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
        CGFloat textWidth = [self calculateTextLabelWidthWithColumn:j Section:section];
        CGFloat textHeight = [self tableManagerWithLabelTextRectWithSize:CGSizeMake(textWidth, MAXFLOAT) withFontSize:model.font withText:model.content].size.height + 1;
        maxHeight = textHeight > maxHeight ? textHeight : maxHeight;
    }
    
    maxHeight += _cellTextMargin.top + _cellTextMargin.bottom;
    [self.cacheRowHeight setValue:@(maxHeight) forKey:key];
    return maxHeight;
}

- (CGFloat)calculateTextLabelWidthWithColumn:(NSInteger )column Section:(NSInteger )section {
    CGFloat textoffset = _cellTextMargin.left + _cellTextMargin.right;
    return [_cellWidthsArr[section][column]floatValue] - textoffset;
}

- (CGRect)tableManagerWithLabelTextRectWithSize:(CGSize )size withFontSize:(UIFont *)fontSize withText:(NSString *)text {
    CGRect frame = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName : fontSize} context:nil];
    return frame;
}

- (NSInteger)calulateAllCountWithSection:(NSInteger )section {
    /// 有几排
    NSInteger row = [self.dataSource ffTableManagerRowWithNumberSection:section];
    /// 有几列
    NSInteger column = [self.dataSource ffTableManagerColumnSection:section];
    NSCAssert(column >= 0 || row >= 0, @"不能输入负数");
    FFMatrix matrix = MatrixMake(row - 1, column - 1);
    NSValue *value = [NSValue valueWithBytes:&matrix objCType:@encode(FFMatrix)];
    [self.maxMatrixs addObject:value];
    return row * column;
}

- (void)calculateHeaderCellHeightWithSection:(NSInteger )section textWidths:(NSMutableArray *)textWidths {
    CGFloat textoffset = _cellTextMargin.left + _cellTextMargin.right;
    NSMutableArray *datas;
    if ([self.dataSource respondsToSelector:@selector(ffTableManagerHeaderViewSetData:section:)]) {
        datas = [self.dataSource ffTableManagerHeaderViewSetData:self section:section];
    }
    
    CGFloat maxHeight = 0;
    if (datas.count && datas.count == textWidths.count) {
        NSInteger index = 0;
        NSMutableArray *headerSizes = [NSMutableArray array];
        for (FFTableCollectionModel *model in datas) {
            CGFloat width = [textWidths[index]floatValue];
            CGFloat textHeight = [self tableManagerWithLabelTextRectWithSize:CGSizeMake(width- textoffset, MAXFLOAT) withFontSize:model.font withText:model.content].size.height + 1;
            textHeight += _cellTextMargin.top + _cellTextMargin.bottom;
            maxHeight = textHeight > maxHeight ? textHeight : maxHeight;
            index += 1;
        }
        
        for (NSNumber *width in textWidths) {
            CGSize size = CGSizeMake([width floatValue], maxHeight);
            [headerSizes addObject:@(size)];
        }
        
        [self.headerCellSizes addObject:headerSizes];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _section;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self calulateAllCountWithSection:section];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    if ([self.delegate respondsToSelector:@selector(ffTableManagerHeaderHeightWithSction:)]) {
        CGFloat height = [self.delegate ffTableManagerHeaderHeightWithSction:section];
        return CGSizeMake(collectionView.bounds.size.width, height);
    }
    
    if (_headerCellSizes.count) {
        CGSize size = [_headerCellSizes[section][0]CGSizeValue];
        size.height += _margin.top;
        size.width = collectionView.bounds.size.width;
        return size;
    } else {
        return CGSizeZero;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString: UICollectionElementKindSectionHeader]) {
        
        if ([self.delegate respondsToSelector:@selector(ffTableManagerSetCollectionHeaderView:section:)] && [self.delegate respondsToSelector:@selector(ffTableManagerRegistClassWithSection:)]) {
            Class class = [self.delegate ffTableManagerRegistClassWithSection:indexPath.section];
            UICollectionReusableView *headerViwe = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(class) forIndexPath:indexPath];
            [self.delegate ffTableManagerSetCollectionHeaderView:headerViwe section:indexPath.section];
            return headerViwe;
        }
        
        FFCollectionHeaderView *headerViwe = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FFCollectionHeaderView class]) forIndexPath:indexPath];
        NSMutableArray *datas;
        if ([self.dataSource respondsToSelector:@selector(ffTableManagerHeaderViewSetData:section:)]) {
            datas = [self.dataSource ffTableManagerHeaderViewSetData:self section:indexPath.section];
        }
        CGFloat headerWidth = [_cellWidthsArr[indexPath.section][indexPath.row]floatValue];
        [headerViwe collectionHeaderViewWithTextWidth: headerWidth cellTextMargin:_cellTextMargin margin:_margin borderColor:_cellBorderColor];
        if (datas.count && datas.count == _cellWidthsArr[indexPath.section].count) {
            [headerViwe showDataWithModel:datas sizes:_headerCellSizes[indexPath.section] isHover:true];
        }
        
        __weak typeof (self)weakSelf = self;
        headerViwe.selectBlock = ^(FFMatrix matrix) {
            if ([weakSelf.delegate respondsToSelector:@selector(didSelectWithCollectionViewHeader:section:matrix:)]) {
                [weakSelf.delegate didSelectWithCollectionViewHeader:collectionView section:indexPath.section matrix:matrix];
            }
            weakSelf.selectHeaderBlock(collectionView, matrix, indexPath.section);
        };
        return headerViwe;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = ceil(indexPath.row / [self.dataSource ffTableManagerColumnSection:indexPath.section]) + 1;
    NSInteger column = indexPath.row % [self.dataSource ffTableManagerColumnSection:indexPath.section];
    return CGSizeMake([_cellWidthsArr[indexPath.section][column]floatValue], [self calculateRowMaxHeightWithSection:indexPath.section row:row]);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(ffTableManagerHeaderViewSetData:section:)]) {
        return UIEdgeInsetsMake(0, _margin.left, _margin.bottom, _margin.right);
    } else {
        return _margin;
    }
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FFTableCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FFTableCollectionViewCell class]) forIndexPath:indexPath];
    NSInteger sourceColumn = [self.dataSource ffTableManagerColumnSection:indexPath.section];
    NSInteger row = ceil(indexPath.row / sourceColumn);
    NSInteger column = indexPath.row % [self.dataSource ffTableManagerColumnSection:indexPath.section];
    FFMatrix matrix = MatrixMake(row, column);
    FFTableCollectionModel *model = [self.dataSource ffTableManagerSetData:self matrix:matrix];
    cell.currentMatrix = matrix;
    FFMatrix maxMatrix;
    [_maxMatrixs[indexPath.section]getValue:&maxMatrix];
    cell.maxMatrix = maxMatrix;
    cell.haveHeader = [self.dataSource respondsToSelector:@selector(ffTableManagerHeaderViewSetData:section:)];
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", indexPath.section, row + 1];
    [cell showDataWithModel:model borderColor:_cellBorderColor edge:_cellTextMargin size:CGSizeMake([_cellWidthsArr[indexPath.section][column]floatValue], [_cacheRowHeight[key] floatValue])];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger sourceColumn = [self.dataSource ffTableManagerColumnSection:indexPath.section];
    NSInteger row = ceil(indexPath.row / sourceColumn);
    NSInteger column = indexPath.row % [self.dataSource ffTableManagerColumnSection:indexPath.section];
    FFMatrix matrix = MatrixMake(row, column);
    
    if ([self.delegate respondsToSelector:@selector(didSelectWithCollectionView:section:matrix:)]) {
        [self.delegate didSelectWithCollectionView:collectionView section:indexPath.section matrix:matrix];
    }
    
    if (self.selectBlock) {
        self.selectBlock(collectionView, matrix, indexPath.section);
    }
}

- (UICollectionView *)mainCollectionView {
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.sectionHeadersPinToVisibleBoundsAll = !self.showAllHeight;
        _mainCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, _cellAverageItem ? _mainScrollView.bounds.size.width : _mainScrollView.bounds.size.width, _mainScrollView.bounds.size.height) collectionViewLayout:layout];
        _mainCollectionView.showsVerticalScrollIndicator = false;
        _mainCollectionView.showsHorizontalScrollIndicator = false;
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.backgroundColor = [UIColor whiteColor];
        [_mainCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FFTableCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([FFTableCollectionViewCell class])];
        [_mainCollectionView registerClass:[FFCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FFCollectionHeaderView class])];
        _mainCollectionView.scrollEnabled = !self.showAllHeight;
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
        _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _mainScrollView.delegate = self;
        _mainScrollView.backgroundColor = [UIColor whiteColor];
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

- (NSMutableArray *)headerCellSizes {
    if (!_headerCellSizes) {
        _headerCellSizes = [NSMutableArray array];
    }
    return _headerCellSizes;
}

- (NSMutableArray *)maxMatrixs {
    if (!_maxMatrixs) {
        _maxMatrixs = [NSMutableArray array];
    }
    return _maxMatrixs;
}

@end


