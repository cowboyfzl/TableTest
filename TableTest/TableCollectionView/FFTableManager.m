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
#import "FixedTableViewTableViewCell.h"
#import "FFColectionView.h"
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
@property (nonatomic, assign) BOOL hoverHeader;
@property (nonatomic, assign) CGFloat beforCollectionWidth;
@property (nonatomic, assign) BOOL isFixedFirstcolumn;
@property (nonatomic, assign) CollectionViewCellPosition position;
@property (nonatomic, strong) FFColectionView *fixedCollectionView;
@property (nonatomic, assign) CGFloat fixedTableViewWidth;
@property (nonatomic, assign) BOOL isRotate;
@property (nonatomic, assign) CGFloat beforContentOffset;
@property (nonatomic, assign) CGFloat cellHeight;
@end
static NSInteger const DefaultCellWidth = 80;
@implementation FFTableManager

+ (instancetype)shareFFTableManagerWithFrame:(CGRect )frame {
    FFTableManager *manager = [self new];
    manager.beforCollectionWidth = 0;
    manager.cellAverageItem = false;
    manager.cellTextMargin = UIEdgeInsetsMake(5, 5, 5, 5);
    manager.margin = UIEdgeInsetsMake(5, 5, 5, 5);
    manager.cellBorderColor = [UIColor grayColor];
    manager.section = 1;
    manager.showAllHeight = false;
    manager.isFixedFirstcolumn = false;
    manager.hoverHeader = true;
    return manager;
}

+ (instancetype)shareFFTableManagerWithFrame:(CGRect )frame sView:(UIView *)sView {
    FFTableManager *manager = [self shareFFTableManagerWithFrame:frame];
    manager.sView(sView);
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    //    [self.superV removeObserver:self forKeyPath:@"frame"];
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
        if (self.isFixedFirstcolumn) {
            [self fixedCollectionView];
        }
        //        [self.superV addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
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

- (FFTableManager *(^)(BOOL showAll))isHoverHeader {
    return ^FFTableManager *(BOOL isHoverHeader) {
        self.hoverHeader = isHoverHeader;
        return self;
    };
}

- (FFTableManager * _Nonnull (^)(BOOL fixedFirstcolumn))setFixedFirstcolumn {
    return ^FFTableManager *(BOOL setFixedFirstcolumn) {
        self.isFixedFirstcolumn = setFixedFirstcolumn;
        return self;
    };
}

- (instancetype)didSelectHeaderWithBlock:(FFSelectBlock)block {
    _selectHeaderBlock = block;
    return self;
}

- (FFTableManager *(^)(CollectionViewCellPosition position))collectionViewCellPosition {
    return ^FFTableManager *(CollectionViewCellPosition position) {
        self.position = position;
        return self;
    };
}

- (FFTableManager * _Nonnull (^)(CGFloat))fixedCellHeight {
    return ^FFTableManager *(CGFloat height) {
        self.cellHeight = height;
        return self;
    };
}

- (void)orientChange:(NSNotification *)noti {
    self.isRotate = true;
}

- (void)reloadData {
    [_superV layoutIfNeeded];
    if ([self.dataSource respondsToSelector:@selector(ffTableManagerNumberOfSection:)]) {
        _section = [self.dataSource ffTableManagerNumberOfSection:self];
    }
    
    if ([self.dataSource respondsToSelector:@selector(ffTableManager:rowWithNumberSection:)] && ![self.dataSource ffTableManager:self rowWithNumberSection:0]) {
        return;
    }
    
    [self.maxMatrixs removeAllObjects];
    [self calulateMaxWidthAndHeaderHeight];
    CGRect fixTableRect = CGRectZero;
    CGRect mainScrollViewRect = _superV.bounds;
    [self calulateAllHeight];
    if (self.isFixedFirstcolumn && _section == 1) {
        fixTableRect = CGRectMake(_margin.left, 0, _fixedTableViewWidth, CGRectGetHeight(_superV.frame));
        if (!CGRectEqualToRect(fixTableRect, self.fixedCollectionView.frame)) {
            self.fixedCollectionView.frame = fixTableRect;
        }
        
        mainScrollViewRect = CGRectMake(fixTableRect.size.width + _margin.left, 0, mainScrollViewRect.size.width - fixTableRect.size.width - _margin.left, mainScrollViewRect.size.height);
        [_fixedCollectionView reloadData];
    } else {
        if (_fixedCollectionView) {
            [_fixedCollectionView removeFromSuperview];
            _fixedCollectionView = nil;
        }
    }
    
    if (!_mainCollectionView.superview) {
        [_superV addSubview:_mainScrollView];
        [_mainScrollView addSubview:self.mainCollectionView];
    }
    
    if (!CGRectEqualToRect(mainScrollViewRect, self.mainScrollView.frame)) {
        self.mainScrollView.frame = mainScrollViewRect;
        self.mainCollectionView.frame = CGRectMake(self.mainCollectionView.frame.origin.x, self.mainCollectionView.frame.origin.y, [self calulateCollectionViewWidth], CGRectGetHeight(_mainScrollView.bounds));
    }
    
    [_mainCollectionView reloadData];
    
    
    if (_isRotate) {
        _fixedCollectionView.contentOffset = CGPointZero;
        _mainCollectionView.contentOffset = CGPointZero;
        _isRotate = false;
    }
}

- (CGFloat)getTableHeight {
    return [self calulateAllHeight];
}

- (CGFloat)calulateCollectionViewWidth {
    CGFloat itemWidth = 0;
    for (NSInteger i = 0; i < _section; i++ ) {
        CGFloat sectionWidth = 0;
        if (_cellWidthsArr.count) {
            for (NSNumber *width in _cellWidthsArr[i]) {
                sectionWidth += [width floatValue];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(ffTableManager:registClassWithSection:)]) {
            Class class = [self.delegate ffTableManager:self registClassWithSection:i];
            NSString *nibPath = [[NSBundle mainBundle]pathForResource:NSStringFromClass(class) ofType:@"nib"];
            if (nibPath.length) {
                [_mainCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass(class) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(class)];
            } else {
                [_mainCollectionView registerClass:class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(class)];
            }
        }
        
        itemWidth = sectionWidth > itemWidth ? sectionWidth : itemWidth;
    }
    
    if (itemWidth) {
        itemWidth += _margin.left + _margin.right;
        NSInteger offset = _isFixedFirstcolumn;
        _mainScrollView.contentSize = CGSizeMake(itemWidth + offset, 0);
    } else {
        itemWidth = _mainScrollView.bounds.size.width;
    }
    
    return itemWidth;
}

- (CGFloat )calulateAllHeight {
    CGFloat maxHeight = 0;
    for (NSInteger i = 0; i < _section; i++) {
        CGFloat headerHeight = 0;
        if ([self.delegate respondsToSelector:@selector(ffTableManager:headerHeightWithSction:)]) {
            headerHeight = [self.delegate ffTableManager:self headerHeightWithSction:i];
        } else {
            if (_headerCellSizes.count) {
                headerHeight = [_headerCellSizes[i][0]CGSizeValue].height;
            }
        }
        
        NSInteger row = [self.dataSource ffTableManager:self rowWithNumberSection:i];
        for (NSInteger j = 0; j < row; j++) {
            CGFloat rowHeight = [self calculateRowMaxHeightWithSection:i row:j + 1];
            maxHeight += rowHeight;
        }
        
        CGFloat bottomMargin = [self.delegate respondsToSelector:@selector(ffTableManager:registClassWithSection:)] ? 0 : _margin.bottom;
        maxHeight += headerHeight + _margin.top + bottomMargin;
    }
    
    if (_showAllHeight) {
        CGRect scrollRect = _mainScrollView.frame;
        scrollRect.size.height = maxHeight;
        _mainScrollView.frame = scrollRect;
        _mainCollectionView.frame = CGRectMake(_mainCollectionView.frame.origin.x, _mainCollectionView.frame.origin.y, _mainCollectionView.frame.size.width, maxHeight);
    }
    
    return maxHeight;
}

- (void)calulateMaxWidthAndHeaderHeight {
    [_superV layoutIfNeeded];
    [self.cellWidthsArr removeAllObjects];
    [self.headerCellSizes removeAllObjects];
    [self.cacheRowHeight removeAllObjects];
    CGFloat itemOffset = _margin.left + _margin.right;
    CGFloat width = _superV.bounds.size.width;
    for (NSInteger i = 0; i < _section; i++) {
        NSMutableArray *weightCoefficienths = [self checkWidtWeightCoefficientWithSection:i];
        if (weightCoefficienths) {
            [_cellWidthsArr addObject:weightCoefficienths];
            [self calculateHeaderCellHeightWithSection:i textWidths:weightCoefficienths];
            continue;
        }
        NSMutableArray *itemWidths = [NSMutableArray array];
        NSInteger column = [self.dataSource ffTableManager:self columnSection:i];
        if (column == 0) {
            continue;
        }
        
        for (NSInteger j = 0 ; j < column; j++) {
            if (!_cellAverageItem) {
                if ([self.dataSource respondsToSelector:@selector(ffTableManager:itemWidthWithColumn:Section:margin:)]) {
                    CGFloat itemWidth = [self.dataSource ffTableManager:self itemWidthWithColumn:j Section:i margin:_margin];
                    [itemWidths addObject:@(itemWidth)];
                } else {
                    [itemWidths addObject:@(DefaultCellWidth)];
                }
            } else {
                CGFloat itemWidth = (width - itemOffset) / [self.dataSource ffTableManager:self columnSection:i];
                [itemWidths addObject:@(itemWidth)];
            }
        }
        
        if (itemWidths.count && self.isFixedFirstcolumn && i == 0) {
            _fixedTableViewWidth = [itemWidths[0]floatValue];
            [itemWidths removeObjectAtIndex:0];
        }
        
        [_cellWidthsArr addObject:itemWidths];
        [self calculateHeaderCellHeightWithSection:i textWidths:itemWidths];
    }
}

- (NSMutableArray *)checkWidtWeightCoefficientWithSection:(NSInteger )section {
    if ([self.dataSource respondsToSelector:@selector(ffTableManager:itemWidtWeightCoefficienthWithSection:)]) {
        NSArray *weightCoefficientArr = [self.dataSource ffTableManager:self itemWidtWeightCoefficienthWithSection:section];
        NSInteger column = [self.dataSource ffTableManager:self columnSection:section];
        if (column != weightCoefficientArr.count) {
            return nil;
        }
        
        CGFloat allWeightCoefficient = 0;
        for (NSNumber *weightCoefficient in weightCoefficientArr) {
            allWeightCoefficient += [weightCoefficient floatValue];
        }
        
        CGFloat collectionWidth = _superV.bounds.size.width;
        collectionWidth -= (_margin.left + _margin.right);
        CGFloat finalWidth = collectionWidth / allWeightCoefficient;
        NSMutableArray *itemWidths = [NSMutableArray array];
        for (NSNumber *weightCoefficient in weightCoefficientArr) {
            CGFloat width = finalWidth * [weightCoefficient floatValue];
            [itemWidths addObject:@(width)];
        }
        
        return itemWidths;
    }
    return nil;
}

- (CGFloat)calculateRowMaxHeightWithSection:(NSInteger )section row:(NSInteger )row {
    /// 有几列
    NSInteger column = [self.dataSource ffTableManager:self columnSection:section];
    if (self.isFixedFirstcolumn && _section == 1) {
        column -= 1;
    }
    
    NSCAssert(column >= 0, @"不能输入负数");
    CGFloat maxHeight = 0;
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)section, (long)row];
    if (_cacheRowHeight[key]) {
        maxHeight = [_cacheRowHeight[key] floatValue];
        return maxHeight;
    }
    
    if (self.cellHeight > 0) {
        maxHeight = self.cellHeight;
    } else {
        if (self.isFixedFirstcolumn && _section == 1) {
            CGFloat textWidth = self.fixedTableViewWidth + _cellTextMargin.left + _cellTextMargin.right;
            FFMatrix currentMatrix = MatrixMake(row - 1, 0);
            FFTableCollectionModel *model = [self.dataSource ffTableManagerSetData:self section:section matrix:currentMatrix];
            CGFloat textHeight = [self tableManagerWithLabelTextRectWithSize:CGSizeMake(textWidth, MAXFLOAT) withFontSize:model.font withText:model.content].size.height + 1;
            maxHeight = textHeight;
        }
        
        for (NSInteger j = 0; j < column; j++) {
            FFMatrix currentMatrix = MatrixMake(row - 1, j);
            __weak FFTableCollectionModel *model;
            if (self.isFixedFirstcolumn && _section == 1) {
                FFMatrix matrix = MatrixMake(row - 1, j + 1);
                model = [self.dataSource ffTableManagerSetData:self section:section matrix:matrix];
            } else {
                model = [self.dataSource ffTableManagerSetData:self section:section matrix:currentMatrix];
            }
            
            CGFloat textWidth = [self calculateTextLabelWidthWithColumn:j Section:section];
            CGFloat textHeight = [self tableManagerWithLabelTextRectWithSize:CGSizeMake(textWidth, MAXFLOAT) withFontSize:model.font withText:model.content].size.height + 1;
            maxHeight = textHeight > maxHeight ? textHeight : maxHeight;
        }
        
        maxHeight += _cellTextMargin.top + _cellTextMargin.bottom;
    }
    
    [self.cacheRowHeight setValue:@(maxHeight) forKey:key];
    return maxHeight;
}

- (CGFloat)calculateTextLabelWidthWithColumn:(NSInteger )column Section:(NSInteger )section {
    CGFloat textoffset = _cellTextMargin.left + _cellTextMargin.right;
    return [_cellWidthsArr[section][column]floatValue] - textoffset;
}

- (CGRect)tableManagerWithLabelTextRectWithSize:(CGSize )size withFontSize:(UIFont *)fontSize withText:(NSString *)text {
    CGRect frame = CGRectZero;
    if (text.length) {
        frame = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName : fontSize} context:nil];
    }
    
    return frame;
}

- (NSInteger)calulateAllCountWithSection:(NSInteger )section {
    /// 有几排
    NSInteger row = [self.dataSource ffTableManager:self rowWithNumberSection:section];
    /// 有几列
    NSInteger column = [self.dataSource ffTableManager:self columnSection:section];
    if (self.isFixedFirstcolumn) {
        column -= 1;
    }
    
    NSCAssert(column >= 0 || row >= 0, @"不能输入负数");
    FFMatrix matrix = MatrixMake(row - 1, column - 1);
    NSValue *value = [NSValue valueWithBytes:&matrix objCType:@encode(FFMatrix)];
    [self.maxMatrixs addObject:value];
    return row * column;
}

- (void)calculateHeaderCellHeightWithSection:(NSInteger )section textWidths:(NSMutableArray *)textWidths {
    CGFloat textoffset = _cellTextMargin.left + _cellTextMargin.right;
    __weak NSMutableArray *datas;
    if ([self.dataSource respondsToSelector:@selector(ffTableManagerHeaderViewSetData:section:)]) {
        datas = [self.dataSource ffTableManagerHeaderViewSetData:self section:section];
    }
    
    if (datas.count) {
        CGFloat maxHeight = 0;
        if (datas.count && datas.count == textWidths.count) {
            NSInteger index = 0;
            NSMutableArray *headerSizes = [NSMutableArray array];
            for (FFTableCollectionModel *model in datas) {
                CGFloat width = [textWidths[index]floatValue];
                CGFloat textHeight = [self tableManagerWithLabelTextRectWithSize:CGSizeMake(width - textoffset, MAXFLOAT) withFontSize:model.font withText:model.content].size.height + 1;
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
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _section;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:_mainCollectionView]) {
        return [self calulateAllCountWithSection:section];
    } else {
        return [self.dataSource ffTableManager:self rowWithNumberSection:section];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if ([collectionView isEqual:_mainCollectionView]) {
        if ([self.delegate respondsToSelector:@selector(ffTableManager:headerHeightWithSction:)]) {
            CGFloat height = [self.delegate ffTableManager:self headerHeightWithSction:section];
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
    } else {
        CGFloat height = 0;
        if ([self.delegate respondsToSelector:@selector(ffTableManager:headerHeightWithSction:)]) {
            height = [self.delegate ffTableManager:self headerHeightWithSction:section];
        }
        
        return CGSizeMake(_fixedTableViewWidth, height);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString: UICollectionElementKindSectionHeader] && [collectionView isEqual:_mainCollectionView]) {
        if ([self.delegate respondsToSelector:@selector(ffTableManager:setCollectionHeaderView:section:)] && [self.delegate respondsToSelector:@selector(ffTableManager:registClassWithSection:)]) {
            Class class = [self.delegate ffTableManager:self registClassWithSection:indexPath.section];
            UICollectionReusableView *headerViwe = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(class) forIndexPath:indexPath];
            [self.delegate ffTableManager:self setCollectionHeaderView:headerViwe section:indexPath.section];
            return headerViwe;
        }
        
        FFCollectionHeaderView *headerViwe = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FFCollectionHeaderView class]) forIndexPath:indexPath];
        __weak NSMutableArray *datas;
        if ([self.dataSource respondsToSelector:@selector(ffTableManagerHeaderViewSetData:section:)]) {
            datas = [self.dataSource ffTableManagerHeaderViewSetData:self section:indexPath.section];
        }
        
        [headerViwe collectionHeaderViewWithCellTextMargin:_cellTextMargin margin:_margin borderColor:_cellBorderColor collectionViewCellPosition:_position];
        if (datas.count && datas.count == _cellWidthsArr[indexPath.section].count) {
            [headerViwe showDataWithModel:datas sizes:_headerCellSizes[indexPath.section] isHover:true];
        }
        
        __weak typeof (self)weakSelf = self;
        __weak typeof (collectionView)weakCollection = collectionView;
        headerViwe.selectBlock = ^(FFMatrix matrix) {
            if ([weakSelf.delegate respondsToSelector:@selector(ffTableManager:didSelectWithCollectionViewHeader:section:matrix:)]) {
                [weakSelf.delegate ffTableManager:weakSelf didSelectWithCollectionViewHeader:weakCollection section:indexPath.section matrix:matrix];
            }
            
            if (weakSelf.selectHeaderBlock) {
                weakSelf.selectHeaderBlock(weakCollection, matrix, indexPath.section);
            }
        };
        
        return headerViwe;
    } else {
        FFCollectionHeaderView *headerViwe = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FFCollectionHeaderView class]) forIndexPath:indexPath];
        headerViwe.left = _isFixedFirstcolumn;
        FFTableCollectionModel *model;
        if ([self.dataSource respondsToSelector:@selector(ffTableManagerFixHeaderViewSetData:)]) {
            model = [self.dataSource ffTableManagerFixHeaderViewSetData:self];
        }
        
        CGFloat height = 0;
        if ([self.delegate respondsToSelector:@selector(ffTableManager:headerHeightWithSction:)]) {
            height = [self.delegate ffTableManager:self headerHeightWithSction:_section];
        }
        
        [headerViwe collectionHeaderViewWithCellTextMargin:_cellTextMargin margin:_margin borderColor:_cellBorderColor collectionViewCellPosition:_position];
        [headerViwe showDataWithModel:[@[model] mutableCopy] sizes:@[@(CGSizeMake(_fixedTableViewWidth, height))] isHover:true];
        return headerViwe;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:_mainCollectionView]) {
        NSInteger column = [self.dataSource ffTableManager:self columnSection:indexPath.section];
        if (self.isFixedFirstcolumn && _section == 1) {
            column -= 1;
        }
        
        NSInteger row = ceil(indexPath.row / column) + 1;
        NSInteger currnetColumn = indexPath.row % column;
        CGFloat height = [self calculateRowMaxHeightWithSection:indexPath.section row:row];
        return CGSizeMake([_cellWidthsArr[indexPath.section][currnetColumn]floatValue], height);
    } else {
        NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)0, (long)indexPath.row + 1];
        CGFloat height = [_cacheRowHeight[key] floatValue];
        return CGSizeMake(_fixedTableViewWidth, height);
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat marginLeft = _margin.left;
    if (self.isFixedFirstcolumn) {
        marginLeft = 0;
    }
    
    if ([self.dataSource respondsToSelector:@selector(ffTableManagerHeaderViewSetData:section:)]) {
        return UIEdgeInsetsMake(0, marginLeft, _margin.bottom, _margin.right);
    } else {
        return UIEdgeInsetsMake(_margin.top, marginLeft, _margin.bottom, _margin.right);
    }
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([collectionView isEqual:_mainCollectionView]) {
        FFTableCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FFTableCollectionViewCell class]) forIndexPath:indexPath];
        cell.fixedHeight = _cellHeight > 0;
        NSInteger sourceColumn = [self.dataSource ffTableManager:self columnSection:indexPath.section];
        if (self.isFixedFirstcolumn && _section == 1) {
            sourceColumn -= 1;
        }
        
        if (sourceColumn == 0) {
            sourceColumn = 1;
        }
        
        NSInteger row = ceil(indexPath.row / sourceColumn);
        NSInteger column = indexPath.row % sourceColumn;
        FFMatrix matrix = MatrixMake(row, column);
        __weak FFTableCollectionModel *model;
        
        if (self.isFixedFirstcolumn && _section == 1) {
            FFMatrix fiexMatrix = MatrixMake(matrix.row, matrix.column + 1);
            model = [self.dataSource ffTableManagerSetData:self section:indexPath.section matrix:fiexMatrix];
        } else {
            model = [self.dataSource ffTableManagerSetData:self section:indexPath.section matrix:matrix];
        }
        
        cell.currentMatrix = matrix;
        FFMatrix maxMatrix = MatrixMake(0, 0);
        if (_maxMatrixs.count > 0) {
            [_maxMatrixs[indexPath.section]getValue:&maxMatrix];
        }
        
        cell.maxMatrix = maxMatrix;
        cell.haveHeader = [self.dataSource respondsToSelector:@selector(ffTableManagerHeaderViewSetData:section:)];
        NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)row + 1];
        [cell showDataWithModel:model borderColor:_cellBorderColor edge:_cellTextMargin size:CGSizeMake([_cellWidthsArr[indexPath.section][column]floatValue], [_cacheRowHeight[key] floatValue])];
        return cell;
    } else {
        FFTableCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FFTableCollectionViewCell class]) forIndexPath:indexPath];
        cell.fixedHeight = _cellHeight > 0;
        cell.left = _isFixedFirstcolumn;
        FFMatrix fiexMatrix = MatrixMake(indexPath.row, 0);
        cell.currentMatrix = fiexMatrix;
        cell.haveHeader = [self.dataSource respondsToSelector:@selector(ffTableManagerHeaderViewSetData:section:)];
        cell.maxMatrix = MatrixMake([self.dataSource ffTableManager:self rowWithNumberSection:indexPath.section] - 1, 0);
        FFTableCollectionModel *model = [self.dataSource ffTableManagerSetData:self section:indexPath.section matrix:fiexMatrix];
        
        NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)0, (long)indexPath.row + 1];
        CGFloat height = [_cacheRowHeight[key] floatValue];
        [cell showDataWithModel:model borderColor:_cellBorderColor edge:_margin size:CGSizeMake(collectionView.bounds.size.width, height)];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:_mainCollectionView]) {
        NSInteger sourceColumn = [self.dataSource ffTableManager:self columnSection:indexPath.section];
        if (self.isFixedFirstcolumn && _section == 1) {
            sourceColumn -= 1;
        }
        
        NSInteger row = ceil(indexPath.row / sourceColumn);
        NSInteger column = indexPath.row % sourceColumn;
        if (self.isFixedFirstcolumn && _section == 1) {
            column += 1;
        }
        
        FFMatrix matrix = MatrixMake(row, column);
        if ([self.delegate respondsToSelector:@selector(ffTableManager:didSelectWithCollectionView:section:matrix:)]) {
            [self.delegate ffTableManager:self didSelectWithCollectionView:collectionView section:indexPath.section matrix:matrix];
        }
        
        if (self.selectBlock) {
            __weak typeof (collectionView)weakCollectionView = collectionView;
            self.selectBlock(weakCollectionView, matrix, indexPath.section);
        }
        
        
    } else {
        FFMatrix matrix = MatrixMake(indexPath.row, 0);
        if ([self.delegate respondsToSelector:@selector(ffTableManager:didSelectWithCollectionView:section:matrix:)]) {
            [self.delegate ffTableManager:self didSelectWithCollectionView:nil section:indexPath.section matrix:matrix];
        }
        
        if (self.selectBlock) {
            self.selectBlock(nil, matrix, indexPath.section);
        }
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger row = [self.dataSource ffTableManager:self rowWithNumberSection:section];
    return row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)0, (long)indexPath.row + 1];
    CGFloat height = [_cacheRowHeight[key] floatValue];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FixedTableViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FixedTableViewTableViewCell class])];
    FFMatrix fiexMatrix = MatrixMake(indexPath.row, 0);
    FFTableCollectionModel *model = [self.dataSource ffTableManagerSetData:self section:indexPath.section matrix:fiexMatrix];
    NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)0, (long)indexPath.row + 1];
    CGFloat height = [_cacheRowHeight[key] floatValue];
    NSInteger row = [self.dataSource ffTableManager:self rowWithNumberSection:indexPath.section];
    [cell showDataWithModel:model borderColor:_cellBorderColor edge:_margin size:CGSizeMake(tableView.bounds.size.width, height) currentRow:indexPath.row maxRow:row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if ([self.delegate respondsToSelector:@selector(ffTableManager:headerHeightWithSction:)]) {
        height = [self.delegate ffTableManager:self headerHeightWithSction:section];
    }
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, height)];
    UILabel *contentLabel = [[UILabel alloc]init];
    contentLabel.numberOfLines = 0;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.center = CGPointMake(headerView.bounds.size.width / 2, headerView.bounds.size.height / 2);
    FFTableCollectionModel *model;
    if ([self.dataSource respondsToSelector:@selector(ffTableManagerFixHeaderViewSetData:)]) {
        model = [self.dataSource ffTableManagerFixHeaderViewSetData:self];
    }
    
    headerView.backgroundColor = model.bgColor ?: [UIColor whiteColor];
    CGFloat textHeight = [self tableManagerWithLabelTextRectWithSize:CGSizeMake(tableView.bounds.size.width, MAXFLOAT) withFontSize:model.font withText:model.content].size.height + 1;
    contentLabel.bounds = CGRectMake(0, 0, headerView.bounds.size.width - _cellTextMargin.left - _cellTextMargin.right, textHeight);
    contentLabel.textColor = model.textColor ?: [UIColor blackColor];
    contentLabel.font = model.font ?: [FFTableCollectionViewCell getPhoneFont];
    contentLabel.text = model.content;
    [headerView addSubview:contentLabel];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.borderWidth = FFTableCollectionViewWidth;
    shapeLayer.strokeColor = _cellBorderColor.CGColor ?: [UIColor lightGrayColor].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(FFTableCollectionViewCellLineOffst, headerView.bounds.size.height - FFTableCollectionViewCellLineOffst * 2)];
    [path addLineToPoint:CGPointMake(FFTableCollectionViewCellLineOffst, FFTableCollectionViewCellLineOffst)];
    [path addLineToPoint:CGPointMake(headerView.bounds.size.width - FFTableCollectionViewCellLineOffst * 2, FFTableCollectionViewCellLineOffst)];
    [path addLineToPoint:CGPointMake(headerView.bounds.size.width - FFTableCollectionViewCellLineOffst * 2, headerView.bounds.size.height - FFTableCollectionViewCellLineOffst * 2)];
    shapeLayer.path = path.CGPath;
    [headerView.layer addSublayer:shapeLayer];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if ([self.delegate respondsToSelector:@selector(ffTableManager:headerHeightWithSction:)]) {
        height = [self.delegate ffTableManager:self headerHeightWithSction:section];
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FFMatrix matrix = MatrixMake(indexPath.row, 0);
    if ([self.delegate respondsToSelector:@selector(ffTableManager:didSelectWithCollectionView:section:matrix:)]) {
        [self.delegate ffTableManager:self didSelectWithCollectionView:nil section:indexPath.section matrix:matrix];
    }
    
    if (self.selectBlock) {
        self.selectBlock(nil, matrix, indexPath.section);
    }
}

- (UIViewController *)getCurrentVC {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC {
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    
    return currentVC;
}

- (UICollectionViewFlowLayout *)getFlowlayout {
    FFTableCollectionViewFlowLayout *layout = [[FFTableCollectionViewFlowLayout alloc]init];
    layout.collectionViewCellPosition = _position;
    if (_cellAverageItem) {
        layout.contentHeight = 0;
    } else {
        layout.contentHeight = [self getTableHeight];
    }
    
    NSMutableArray *columns = [NSMutableArray array];
    NSMutableArray *sectionWidths = [NSMutableArray array];
    for (NSInteger i = 0; i < _section; i++) {
        NSInteger column = [self.dataSource ffTableManager:self columnSection:i];
        if (self.isFixedFirstcolumn && i == 0) {
            column -= 1;
        }
        if (!column) {
            continue;
        }
        
        [columns addObject:@(column)];
        NSArray *widths = _cellWidthsArr[i];
        CGFloat sectionWidth = 0;
        for (NSNumber *width in widths) {
            sectionWidth += [width floatValue];
        }
        
        [sectionWidths addObject:@(sectionWidth)];
    }
    
    layout.sectionWidths = sectionWidths;
    layout.columns = columns;
    layout.edgeInsets = self.margin;
    layout.sectionHeadersPinToVisibleBoundsAll = _hoverHeader;
    layout.isCustomHeader = [self.delegate respondsToSelector:@selector(ffTableManager:registClassWithSection:)];
    return layout;
}

- (UICollectionView *)mainCollectionView {
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.sectionHeadersPinToVisibleBoundsAll = !self.showAllHeight;
        _mainCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, _mainScrollView.bounds.size.width, _mainScrollView.bounds.size.height) collectionViewLayout:layout];
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

- (FFColectionView *)fixedCollectionView {
    if (!_fixedCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.sectionHeadersPinToVisibleBoundsAll = !self.showAllHeight;
        _fixedCollectionView = [[FFColectionView alloc]initWithFrame:CGRectMake(0, 0, _fixedCollectionView.bounds.size.width, _fixedCollectionView.bounds.size.height) collectionViewLayout:layout];
        _fixedCollectionView.showsVerticalScrollIndicator = false;
        _fixedCollectionView.showsHorizontalScrollIndicator = false;
        _fixedCollectionView.delegate = self;
        _fixedCollectionView.dataSource = self;
        _fixedCollectionView.backgroundColor = [UIColor whiteColor];
        [_fixedCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FFTableCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([FFTableCollectionViewCell class])];
        [_fixedCollectionView registerClass:[FFCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FFCollectionHeaderView class])];
        _fixedCollectionView.scrollEnabled = !self.showAllHeight;
        [self.superV addSubview:_fixedCollectionView];
    }
    return _fixedCollectionView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc]init];
    }
    return _headerView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_mainCollectionView] && self.isFixedFirstcolumn) {
        _fixedCollectionView.userInteractionEnabled = false;
        [_fixedCollectionView setContentOffset:_fixedCollectionView.contentOffset animated:NO];
    }
    
    if ([scrollView isEqual:_fixedCollectionView] && self.isFixedFirstcolumn) {
        _mainCollectionView.userInteractionEnabled = false;
        [_mainCollectionView setContentOffset:_mainCollectionView.contentOffset animated:NO];
    }
    
    _beforContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.dragging || scrollView.decelerating) {
        CGFloat value = 0;
        value = scrollView.contentOffset.y - _beforContentOffset;
        if ([scrollView isEqual:_mainCollectionView] && self.isFixedFirstcolumn) {
            _fixedCollectionView.contentOffset = _mainCollectionView.contentOffset;
        }
        
        if ([scrollView isEqual:_fixedCollectionView] && self.isFixedFirstcolumn) {
            _mainCollectionView.contentOffset = _fixedCollectionView.contentOffset;
        }
        
        _beforContentOffset = scrollView.contentOffset.y;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([scrollView isEqual:_mainCollectionView] && self.isFixedFirstcolumn) {
        _fixedCollectionView.userInteractionEnabled = true;
    }
    
    if ([scrollView isEqual:_fixedCollectionView] && self.isFixedFirstcolumn) {
        _mainCollectionView.userInteractionEnabled = true;
    }
}

- (FFMainScrollView *)mainScrollView {
    if (!_mainScrollView) {
        _mainScrollView = [[FFMainScrollView alloc]initWithFrame:CGRectZero];
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

- (float)roundFloat:(float)price{
    return (floorf(price * 100 + 0.5)) / 100;
}

@end


