//
//  TJTableViewCell.m
//  TuJiaDemo
//
//  Created by xujunhao on 2017/6/2.
//  Copyright © 2017年 cocoadogs. All rights reserved.
//

#import "TJTableViewCell.h"

@interface TJTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation TJTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUp {
    _imgView.image = [UIImage imageNamed:@"nyc"];
}

@end
