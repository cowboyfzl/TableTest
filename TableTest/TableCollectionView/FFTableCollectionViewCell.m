//
//  FFTableCollectionViewCell.m
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import "FFTableCollectionViewCell.h"
typedef NS_ENUM(NSInteger, ScreenType) {
    ScreenType320 = 320,
    ScreenType375 = 375,
    ScreenType414 = 414,
};
@interface FFTableCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *LabelOffsets;
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@end
static NSInteger const FFBorderWidth = 1;
@implementation FFTableCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _haveHeader = false;
    [self.contentView.layer addSublayer:self.borderLayer];
    // Initialization code
}

- (void)showDataWithModel:(FFTableCollectionModel *)model borderColor:(UIColor *)borderColor edge:(UIEdgeInsets )edge size:(CGSize )size {
    _contentLabel.textColor = model.textColor ?: [UIColor blackColor];
    _contentLabel.font = model.font?: [FFTableCollectionViewCell getPhoneFont];
    _contentLabel.text = model.content;
    self.contentView.backgroundColor = model.bgColor?: [UIColor whiteColor];
    _borderLayer.strokeColor = borderColor.CGColor ?: [UIColor lightGrayColor].CGColor;
    [self setFrameWithSize:size];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)setFrameWithSize:(CGSize )size {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (self.ishaveHeader) {
        if (_currentMatrix.row == 0 && _currentMatrix.column == 0) {
            [path moveToPoint:CGPointMake(0, size.height)];
            [path addLineToPoint:CGPointMake(0, 0)];
            
            [path moveToPoint:CGPointMake(size.width, 0)];
            [path addLineToPoint:CGPointMake(size.width, size.height)];
        }
        
        if (_currentMatrix.row == 0 && _currentMatrix.column > 0) {
            [path moveToPoint:CGPointMake(size.width, 0)];
            [path addLineToPoint:CGPointMake(size.width, size.height)];
        }
        
        if (_currentMatrix.row > 0) {
            [self drawPath:path size:size];
        }
        
    } else {
        [self drawPath:path size:size];
    }
    
    _borderLayer.path = path.CGPath;
}

- (void )drawPath:(UIBezierPath *)path size:(CGSize )size {
    if (_currentMatrix.column == 0) {
        [path moveToPoint:CGPointMake(0, size.height)];
        [path addLineToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(size.width, 0)];
        [path addLineToPoint:CGPointMake(size.width, size.height)];
    }
    
    if (_currentMatrix.column > 0) {
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(size.width, 0)];
        [path addLineToPoint:CGPointMake(size.width, size.height)];
    }
    
    if (_currentMatrix.row == _maxMatrix.row ) {
        [path addLineToPoint:CGPointMake(0,size.height)];
    }
}

+ (UIFont *)getPhoneFont {
    UIFont *font;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    ScreenType type = screenWidth;
    switch (type) {
        case ScreenType320:
            font = [UIFont systemFontOfSize:12];
            break;
            
        case ScreenType375:
            font = [UIFont systemFontOfSize:14];
            break;
            
        case ScreenType414:
            font = [UIFont systemFontOfSize:15];
            break;
    }
    return font;
}

- (CAShapeLayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
        _borderLayer.borderWidth = FFBorderWidth;
    }
    return _borderLayer;
}
@end
