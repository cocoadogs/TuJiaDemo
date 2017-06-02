//
//  ViewController.m
//  TuJiaDemo
//
//  Created by xujunhao on 2017/6/2.
//  Copyright © 2017年 cocoadogs. All rights reserved.
//

#import "ViewController.h"
#import "TJTableViewCell.h"
#import "TJTableViewHeader.h"
#import <Masonry.h>

// 导航栏高度
#define kNavBarH 64.0f
// 头部图片的高度
#define kHeardH  180.0f

#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width

#ifdef DEBUG
#define DLog(FORMAT, ...) fprintf(stderr,"%s\n\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define DLog(...)
#endif

@interface ViewController ()<UITableViewDataSource, UITabBarDelegate, UIScrollViewDelegate>

@property(nonatomic, strong) UIView *navigationView;       // 导航栏
@property(nonatomic, strong) UIView *centerTextView;       // title文字
@property (nonatomic, assign) CGFloat lastOffsetY;        // 记录上一次位置
@property (nonatomic, strong) UIImageView *scaleImageView; // 顶部图片
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TJTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([TJTableViewCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TJTableViewHeader class]) bundle:nil] forHeaderFooterViewReuseIdentifier:NSStringFromClass([TJTableViewHeader class])];
    self.tableView.rowHeight = 120.0f;
    self.lastOffsetY = -kHeardH;
    
    [self.view addSubview:self.scaleImageView];
    // 设置展示图片的约束
    [_scaleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(kHeardH);
    }];
    
    [self.view addSubview:self.navigationView];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    // 直接添加到控制器的View上面,注意添加顺序,在添加导航栏之后,否则会被遮盖住
    [self configNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 隐藏系统导航栏
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TJTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TJTableViewCell class]) forIndexPath:indexPath];
    // Configure the cell...
    [cell setUp];
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TJTableViewHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([TJTableViewHeader class])];
    return header;
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 计算当前偏移位置
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat delta = offsetY - _lastOffsetY;
    CGFloat height = kHeardH - delta;
    if (height < kNavBarH) {
        height = kNavBarH;
    }
    
    CGFloat margin = kHeardH-kNavBarH+10;//10是header中Label的top
    
    if (delta>margin && delta<margin+39) {
        CGPoint center = self.centerTextView.center;
        CGFloat centerY = 64 - (delta-margin) + 10;
        centerY = (centerY > 42)?centerY:42;// 42=32+10
        center.y = centerY;
        self.centerTextView.center = center;
        self.centerTextView.alpha = (centerY < 42)?1.0:delta / kHeardH;
    }
    
    if (delta>margin+39) {
        CGPoint center = self.centerTextView.center;
        center.y = 42;
        self.centerTextView.center = center;
        self.centerTextView.alpha = 1.0;
    }
    if (delta<=margin) {
        self.centerTextView.alpha = 0;
    }
    if (delta<= 0) {
        CGPoint center = self.centerTextView.center;
        center.y = 64;
        self.centerTextView.center = center;
        self.centerTextView.alpha = 0.0;
    }
    [_scaleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    CGFloat alpha = delta / (kHeardH - kNavBarH);
    if (alpha >= 1.0) {
        alpha = 1.0;
    }
    self.navigationView.alpha = alpha;
}

#pragma mark - UIContent Init Methods

- (void)configNavigationBar {
    //左边返回按钮
    UIButton *backBtn = [[UIButton alloc]init];
    backBtn.frame = CGRectMake(0, 20, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
    ;
    
    //右边分享按钮
    UIButton *shartBtn = [[UIButton alloc]init];
    shartBtn.frame = CGRectMake(SCREENWIDTH-44, 20, 44, 44);
    [shartBtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    
    [self.view addSubview:backBtn];
    [self.view addSubview:shartBtn];
}

- (UIView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[UIView alloc]init];
        _navigationView.frame = CGRectMake(0, 0, SCREENWIDTH, kNavBarH);
        _navigationView.backgroundColor = [UIColor clearColor];
        _navigationView.alpha = 0.0;
        
        //添加子控件
        [self setNavigationSubView];
    }
    return _navigationView;
}

// 注意:毛玻璃效果API是iOS8的,适配iOS8以下的请用其他方法
-(void)setNavigationSubView{
    
    // 毛玻璃背景
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:_navigationView.bounds];
    bgImgView.image = [UIImage imageNamed:@"666"];
    [_navigationView addSubview:bgImgView];
    
    /**  毛玻璃特效类型
     *   UIBlurEffectStyleExtraLight,
     *   UIBlurEffectStyleLight,
     *   UIBlurEffectStyleDark
     */
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    //  毛玻璃视图
    UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    //添加到要有毛玻璃特效的控件中
    effectView.frame = bgImgView.bounds;
    [bgImgView addSubview:effectView];
    //设置模糊透明度
    effectView.alpha = 0.9f;
    
    //中间文本框
    UIView *centerTextView = [[UIView alloc]init];
    self.centerTextView = centerTextView;
    CGFloat centerTextViewX = 0;
    CGFloat centerTextViewY = 64;
    CGFloat centerTextViewW = 0;
    CGFloat centerTextViewH = 0;
    
    //文字大小
    NSString *title = @"Pg.lostk开启后摇滚的新图景";
    NSString *desc  = @"摇滚清心坊8套";
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGSize descSize = [desc sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}];
    centerTextViewW = titleSize.width > descSize.width ? titleSize.width : descSize.width;
    centerTextViewH = titleSize.height + descSize.height +10;
    centerTextViewX = (SCREENWIDTH - centerTextViewW) / 2;
    centerTextView.frame = CGRectMake(centerTextViewX, centerTextViewY, centerTextViewW, centerTextViewH);
    
    //文字label
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.frame = CGRectMake(0,5, centerTextViewW, titleSize.height);
    
    UILabel *descLabel = [[UILabel alloc]init];
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.text = desc;
    descLabel.font = [UIFont systemFontOfSize:11];
    descLabel.textColor = [UIColor whiteColor];
    descLabel.frame = CGRectMake(0, titleSize.height + 5, centerTextViewW, descSize.height);
    
    [centerTextView addSubview:titleLabel];
    [centerTextView addSubview:descLabel];
    [_navigationView addSubview:centerTextView];
}


#pragma mark - Lazy Load Methods

- (UIImageView *)scaleImageView {
    if (!_scaleImageView) {
        _scaleImageView = [[UIImageView alloc] init];
        _scaleImageView.contentMode = UIViewContentModeScaleAspectFill;
        _scaleImageView.clipsToBounds = YES;
        _scaleImageView.image = [UIImage imageNamed:@"nyc"];
    }
    return _scaleImageView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.contentInset = UIEdgeInsetsMake(kHeardH, 0, 0, 0);
        _tableView.delegate = (id)self;
        _tableView.dataSource = (id)self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}


@end
