//
//  FFTableCollectionViewFlowLayout.m
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import "FFTableCollectionViewFlowLayout.h"
@interface FFTableCollectionViewFlowLayout ()
@property(nonatomic,strong)NSMutableArray * attrsArr;
@property(nonatomic,strong)UICollectionViewLayoutAttributes *beforAttre;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) CGFloat allHeight;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat allWidth;
@end
@implementation FFTableCollectionViewFlowLayout
- (void)prepareLayout {
    [super prepareLayout];
    _row = 0;
    _allHeight = 0;
    [self.attrsArr removeAllObjects];
    NSMutableArray *headerArr = [NSMutableArray array];
    NSInteger section = [self.collectionView numberOfSections];
    for (NSInteger i = 0; i < section; i++) {
        NSInteger number = [self.collectionView numberOfItemsInSection:i];
        UICollectionViewLayoutAttributes *headerAttribut = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForRow:1 inSection:i]];
        CGFloat y = 0;
        if (i != 0) {
            UICollectionViewLayoutAttributes *lastAttributes = self.attrsArr.lastObject;
            y = CGRectGetMaxY(lastAttributes.frame) + (i ? _edgeInsets.top : 0);
        }
        [headerArr addObject:headerAttribut];
        headerAttribut.frame = CGRectMake(0, y, self.collectionView.bounds.size.width, [_headerHeights[i] floatValue] + (_isCustomHeader ? 0 : _edgeInsets.top));
        for (NSInteger j = 0; j < number; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (attributes) {
                [self.attrsArr addObject:attributes];
            }
        }
    }
    [_attrsArr addObjectsFromArray:headerArr];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *arr = [self.attrsArr filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return CGRectIntersectsRect(rect, [evaluatedObject frame]);
    }]];
    return arr;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.bounds.size.width, _contentHeight);
}

- (NSMutableArray *)attrsArr {
    if (!_attrsArr) {
        _attrsArr = [NSMutableArray array];
    }
    return _attrsArr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
   UICollectionViewLayoutAttributes *oldAttre = [[super layoutAttributesForItemAtIndexPath:indexPath]copy];
    NSInteger sourceColumn = [self.columns[oldAttre.indexPath.section] integerValue];
    NSInteger row = ceil(oldAttre.indexPath.row / sourceColumn);
    CGFloat width = oldAttre.frame.size.width;
    CGFloat height = oldAttre.frame.size.height;
    CGFloat headerOffset = 0;
    
    if (oldAttre.indexPath.row == 0) {
        _beforAttre = oldAttre;
    }
    
    if (_row != row) {
        _row = row;
        _allHeight += _beforAttre.frame.size.height;
        _beforAttre = oldAttre;
    }
    
    NSInteger number = [self.collectionView numberOfItemsInSection:oldAttre.indexPath.section] / sourceColumn;
    if (number == 1 && oldAttre.indexPath.section > 0) {
        _allHeight = oldAttre.frame.size.height;
    }

    if (oldAttre.indexPath.row % sourceColumn == 0) {
        _allWidth = 0;
    }
    
    for (NSInteger i = 0; i < oldAttre.indexPath.section + 1; i++) {
        headerOffset += [_headerHeights[i] floatValue];
    }
    
    CGFloat edgeinsetTop = _isCustomHeader ? 0 :_edgeInsets.top;
    NSInteger section = _isCustomHeader ? indexPath.section : indexPath.section + 1;
    CGFloat sectionWidth = [_sectionWidths[indexPath.section] floatValue];
    CGFloat yPosition = _allHeight + headerOffset + (oldAttre.indexPath.section ? ((_edgeInsets.bottom * section) + edgeinsetTop) : edgeinsetTop);
    switch (self.collectionViewCellPosition) {
        case CollectionViewCellPositionLeft:
            oldAttre.frame = CGRectMake(_allWidth + _edgeInsets.left, yPosition, width, height);
            break;
            
        case CollectionViewCellPositionCenter:
        {
            CGFloat offset = (self.collectionView.bounds.size.width - sectionWidth) / 2;
            oldAttre.frame = CGRectMake(offset + _allWidth, yPosition, width, height);
        }
            
            break;
            
        case CollectionViewCellPositionRight:
        {
            CGFloat offset = self.collectionView.bounds.size.width - sectionWidth;
            oldAttre.frame = CGRectMake(offset + _allWidth -_edgeInsets.left , yPosition, width, height);
        }
            break;
    }
    _allWidth += width;
    return oldAttre;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *oldAttre = [[super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath]copy];
    return oldAttre;
}
                                                                                                                              
@end
