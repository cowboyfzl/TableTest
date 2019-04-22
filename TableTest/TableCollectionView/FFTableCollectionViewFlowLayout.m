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
@property (nonatomic, assign) CGFloat headerOffset;
@end
@implementation FFTableCollectionViewFlowLayout
- (void)prepareLayout {
    [super prepareLayout];
    _row = 0;
    _allHeight = 0;
    _headerOffset = 0;
    [self.attrsArr removeAllObjects];
    NSMutableArray *headerArr = [NSMutableArray array];
    NSInteger section = [self.collectionView numberOfSections];
    for (NSInteger i = 0; i < section; i++) {
        NSInteger number = [self.collectionView numberOfItemsInSection:i];
        UICollectionViewLayoutAttributes *headerAttribut = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        _headerOffset += headerAttribut.frame.size.height;
        if (headerAttribut) {
            [headerArr addObject:headerAttribut];
        }
        
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
    if (_contentHeight) {
        return CGSizeMake(self.collectionView.bounds.size.width, _contentHeight);
    } else {
        return [super collectionViewContentSize];
    }
}

- (NSMutableArray *)attrsArr {
    if (!_attrsArr) {
        _attrsArr = [NSMutableArray array];
    }
    return _attrsArr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
   UICollectionViewLayoutAttributes *oldAttre = [super layoutAttributesForItemAtIndexPath:indexPath];
    NSInteger sourceColumn = 0;
    sourceColumn = [self.columns[oldAttre.indexPath.section] integerValue];
    
    NSInteger row = ceil(oldAttre.indexPath.row / sourceColumn);
    CGFloat width = oldAttre.frame.size.width;
    CGFloat height = oldAttre.frame.size.height;
    
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
    
    CGFloat sectionWidth = 0;
    if (_sectionWidths.count) {
        sectionWidth = [_sectionWidths[indexPath.section] floatValue];
    }
    
    CGFloat yPosition = _allHeight + _headerOffset + _edgeInsets.bottom * indexPath.section;
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
