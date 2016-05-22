//
//  ChatTableViewCell.h
//  Demo
//
//  Created by IEMacBook01 on 22/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatLabel : UILabel

@end

@interface ChatTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet ChatLabel *chatLabel;

@end
