//
//  FFTableCollectionModel.m
//  TableTest
//
//  Created by blm on 2018/12/26.
//  Copyright © 2018 FFXiao. All rights reserved.
//

#import "FFTableCollectionModel.h"

@implementation FFTableCollectionModel
+ (instancetype)tableCollectionModelWithContent:(NSString *)content textColor:(UIColor *)textColor font:(UIFont *)font bgColor:(UIColor *)bgColor type:(NSString *)type code:(NSString *)code select:(BOOL )select {
    return [[FFTableCollectionModel alloc]initWithContent:content textColor:textColor font:font bgColor:bgColor type:type code:code select:select];
}

- (instancetype)initWithContent:(NSString *)content textColor:(UIColor *)textColor font:(UIFont *)font bgColor:(UIColor *)bgColor type:(NSString *)type code:(NSString *)code select:(BOOL )select
{
    self = [super init];
    if (self) {
        self.content = content;
        self.textColor = textColor;
        self.font = font;
        self.bgColor = bgColor;
        self.type = type;
        self.select = select;
        self.code = code;
    }
    return self;
}
@end
