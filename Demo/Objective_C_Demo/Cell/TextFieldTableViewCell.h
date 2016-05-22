//
//  TextFieldTableViewCell.h
//  Demo
//
//  Created by IEMacBook01 on 22/05/16.
//  Copyright © 2016 Iftekhar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelSubtitle;

@property (strong, nonatomic) IBOutlet UITextField *textField;

@end
