//
//  ChatTableViewCell.m
//  Demo
//
//  Created by IEMacBook01 on 22/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

#import "ChatTableViewCell.h"

@implementation ChatLabel

-(CGSize)intrinsicContentSize
{
    CGSize sizeThatFits = [super intrinsicContentSize];
    sizeThatFits.width += 10;
    sizeThatFits.height += 10;
    return sizeThatFits;
}


@end

@implementation ChatTableViewCell

@end
