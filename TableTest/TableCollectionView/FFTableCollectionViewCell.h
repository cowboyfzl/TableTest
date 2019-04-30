//
//  FFTableCollectionViewCell.h
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFTableCollectionModel.h"
#import "FFTableManager.h"

extern CGFloat const FFTableCollectionViewCellLineOffst;
extern NSInteger const FFTableCollectionViewWidth;

typedef NS_ENUM(NSInteger, ScreenType) {
    ScreenType320 = 320,
    ScreenType375 = 375,
    ScreenType414 = 414,
};
NS_ASSUME_NONNULL_BEGIN

@interface FFTableCollectionViewCell : UICollectionViewCell
@property (nonatomic, assign) FFMatrix currentMatrix;
@property (nonatomic, assign) FFMatrix maxMatrix;
@property (nonatomic, getter=isHeader) BOOL haveHeader;
@property (nonatomic, getter=isLeft) BOOL left;
- (void)showDataWithModel:(FFTableCollectionModel *)model borderColor:(UIColor *)borderColor edge:(UIEdgeInsets )edge size:(CGSize )size;
+ (UIFont *)getPhoneFont;
@end

NS_ASSUME_NONNULL_END
