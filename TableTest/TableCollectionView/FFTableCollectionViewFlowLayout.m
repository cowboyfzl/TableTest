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
    
    NSInteger section = [self.collectionView numberOfSections];
    for (NSInteger i = 0; i < section; i++) {
        NSInteger row = [self.collectionView numberOfItemsInSection:i];
        UICollectionViewLayoutAttributes *headerAttribut = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:1 inSection:i]];
        CGFloat y = 0;
        if (i != 0) {
            UICollectionViewLayoutAttributes *lastAttributes = self.attrsArr.lastObject;
            y = CGRectGetMaxY(lastAttributes.frame);
        }
        
        headerAttribut.frame = CGRectMake(0, y, self.collectionView.bounds.size.width, [_headerHeights[i] floatValue]);
        [self.attrsArr addObject:headerAttribut];
        for (NSInteger j = 0; j < row; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            @autoreleasepool {
                UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                [self.attrsArr addObject:attributes];
            }
        }
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.attrsArr filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return CGRectIntersectsRect(rect, [evaluatedObject frame]);
    }]];
}

- (NSMutableArray *)attrsArr {
    if (!_attrsArr) {
        _attrsArr = [NSMutableArray array];
    }
    return _attrsArr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
   UICollectionViewLayoutAttributes *oldAttre = [super layoutAttributesForItemAtIndexPath:indexPath];
    if ([oldAttre.representedElementKind isEqualToString:UICollectionElementKindSectionHeader] ) {
        NSLog(@"哈哈哈");
    }
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
    
    if (oldAttre.indexPath.row % sourceColumn == 0) {
        _allWidth = 0;
    }
    
    switch (self.collectionViewCellPosition) {
        case CollectionViewCellPositionLeft:
            for (NSInteger i = 0; i < oldAttre.indexPath.section + 1; i++) {
                headerOffset += [_headerHeights[i] floatValue];
            }
            
            
            oldAttre.frame = CGRectMake(_allWidth + self.edgeInsets.left, _allHeight + headerOffset, width, height);
            break;
            
        case CollectionViewCellPositionCenter:
            
            break;
            
        case CollectionViewCellPositionRight:
            
            break;
    }
    _allWidth += width;
    return oldAttre;
}
                                                                                                                              
@end
