//
//  FFTableCollectionModel.h
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FFTableCollectionModel : NSObject
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIFont *font;
+ (instancetype)tableCollectionModelWithContent:(NSString *)content textColor:(UIColor *)textColor font:(UIFont *)font bgColor:(UIColor *)bgColor;
@end

NS_ASSUME_NONNULL_END
