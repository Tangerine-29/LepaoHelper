#import <UIKit/UIKit.h>
#import <objc/message.h>

#pragma mark - Forward Declarations

@interface LPRuningEntryModel : NSObject
@property(nonatomic) _Bool is_check_device;
@property(nonatomic) _Bool is_check_geedevice;
@property(nonatomic) _Bool is_check_geetest;
@property(nonatomic) _Bool is_check_deepkonw;
@property(nonatomic) _Bool is_check_face;
@property(nonatomic) _Bool gyroscope_type;
@property(nonatomic) _Bool robot_module;
@end

@interface LPRunningMotionManager : NSObject
@property(nonatomic) long long cheatCount_step;
@property(nonatomic) long long cheatCount_speed;
@property(nonatomic) long long cheatCount_drift;
@property(nonatomic) long long cyclingOrAutomotiveCount;
@end

@interface LPRunningViewController : UIViewController
@property(nonatomic) _Bool isRecording;
@property(nonatomic) long long checkCirclePoint;
@end

@interface AMapLocationManager : NSObject
@property(nonatomic) _Bool detectRiskOfFakeLocation;
@end

@interface AMapGeoFenceManager : NSObject
@property(nonatomic) _Bool detectRiskOfFakeLocation;
@end

@interface LPCOnTotalDistance : NSObject
@property(nonatomic) double totalDistance;
@end

@interface BLYDevice : NSObject
@property(nonatomic) unsigned long long jailbrokenStatus;
@end

@interface JADOSInfo : NSObject
@property(nonatomic) int jailbreak;
@end

@interface FlyVerifyCDevice : NSObject
@end

#pragma mark - Global State

static BOOL gBypassDevice    = YES;
static BOOL gBypassGyroscope = YES;
static BOOL gBypassGeetest   = YES;
static BOOL gBypassDeepknow  = YES;
static BOOL gBypassFace      = YES;
static BOOL gBypassMotion    = YES;
static BOOL gBypassFakeLoc   = YES;
static BOOL gBypassRobot     = YES;
static BOOL gBypassJailbreak = YES;
static BOOL gBypassProxy     = YES;

static NSMutableArray *gNetLog = nil;
static const NSInteger kNetLogMax = 30;

static long long gCheckRadius = 999999;
static double gTargetPace = 0;
static double gTargetDist = 0;
static BOOL gPaceLocked = NO;
static BOOL gDistLocked = NO;
static __weak UIViewController *gRunVC = nil;
static BOOL gUseChinese = YES;
static NSString *const kLangKey = @"com.lp.helper.lang";

#pragma mark - Localization

static NSString *L(NSString *zh, NSString *en) {
    return gUseChinese ? zh : en;
}

#pragma mark - Theme Colors

static UIColor *kBgColor(void)       { return [UIColor colorWithRed:0.10 green:0.10 blue:0.12 alpha:1.0]; }
static UIColor *kCardColor(void)     { return [UIColor colorWithRed:0.15 green:0.15 blue:0.18 alpha:1.0]; }
static UIColor *kAccentColor(void)   { return [UIColor colorWithRed:0.0 green:0.82 blue:0.55 alpha:1.0]; }
static UIColor *kTextColor(void)     { return [UIColor colorWithWhite:0.92 alpha:1.0]; }
static UIColor *kDimTextColor(void)  { return [UIColor colorWithWhite:0.55 alpha:1.0]; }

#pragma mark - Sheet Helper Forward

@interface LPSheetHelper : NSObject
+ (instancetype)shared;
- (void)toggleSheet;
- (void)handlePan:(UIPanGestureRecognizer *)pan;
- (void)dismissSheet;
@end

#pragma mark - Bottom Sheet

@interface LPBottomSheet : UIView <UITextFieldDelegate>
@property(nonatomic, strong) UIView *dimView;
@property(nonatomic, strong) UIView *sheetView;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UILabel *statusLabel;
@property(nonatomic, strong) UISlider *radiusSlider;
@property(nonatomic, strong) UILabel *radiusValueLabel;
@property(nonatomic, strong) UITextField *paceField;
@property(nonatomic, strong) UITextField *distField;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *langBtn;
@property(nonatomic, strong) NSTimer *statusTimer;
@property(nonatomic, strong) NSMutableArray<UISwitch *> *toggleSwitches;
@property(nonatomic, strong) NSMutableArray<UILabel *> *sectionHeaders;
@property(nonatomic, strong) NSMutableArray<UILabel *> *rowLabels;
@property(nonatomic, strong) NSMutableArray<UIView *> *cpCards;
@property(nonatomic, strong) NSMutableArray<UILabel *> *cpNameLabels;
@property(nonatomic, strong) NSMutableArray<UILabel *> *cpStatusLabels;
@property(nonatomic, strong) NSMutableArray<UIImageView *> *cpIcons;
@property(nonatomic, strong) UIButton *paceBtn;
@property(nonatomic, strong) UIButton *distBtn;
@property(nonatomic, strong) UILabel *diagLabel;
@property(nonatomic, strong) UILabel *netLabel;
@end

static void netLog(NSString *msg) {
    if (!gNetLog) gNetLog = [NSMutableArray new];
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateFormat = @"HH:mm:ss";
    NSString *line = [NSString stringWithFormat:@"[%@] %@", [f stringFromDate:[NSDate date]], msg];
    @synchronized(gNetLog) {
        [gNetLog addObject:line];
        while ((NSInteger)gNetLog.count > kNetLogMax) [gNetLog removeObjectAtIndex:0];
    }
}

static UIButton *gFloatingBall = nil;
static LPBottomSheet *gSheet = nil;
static BOOL gSheetVisible = NO;

@implementation LPBottomSheet

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    _toggleSwitches = [NSMutableArray new];
    _sectionHeaders = [NSMutableArray new];
    _rowLabels = [NSMutableArray new];
    CGFloat sw = frame.size.width;
    CGFloat sh = frame.size.height;
    CGFloat sheetH = sh * 0.75;

    _dimView = [[UIView alloc] initWithFrame:frame];
    _dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.55];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:[LPSheetHelper shared] action:@selector(dismissSheet)];
    [_dimView addGestureRecognizer:tap];
    [self addSubview:_dimView];

    _sheetView = [[UIView alloc] initWithFrame:CGRectMake(0, sh - sheetH, sw, sheetH)];
    _sheetView.backgroundColor = kBgColor();
    _sheetView.layer.cornerRadius = 20;
    _sheetView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    _sheetView.clipsToBounds = YES;
    [self addSubview:_sheetView];

    CGFloat pad = 20;
    CGFloat cw = sw - pad * 2;
    CGFloat y = 0;

    UIView *handle = [[UIView alloc] initWithFrame:CGRectMake((sw - 40) / 2, 8, 40, 4)];
    handle.backgroundColor = [UIColor colorWithWhite:0.35 alpha:1.0];
    handle.layer.cornerRadius = 2;
    [_sheetView addSubview:handle];
    y = 22;

    // Language toggle (top-left)
    _langBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _langBtn.frame = CGRectMake(pad, y, 36, 24);
    [_langBtn setTitle:@"EN" forState:UIControlStateNormal];
    [_langBtn setTitleColor:kAccentColor() forState:UIControlStateNormal];
    _langBtn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    _langBtn.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    _langBtn.layer.cornerRadius = 6;
    [_langBtn addTarget:self action:@selector(toggleLang) forControlEvents:UIControlEventTouchUpInside];
    [_sheetView addSubview:_langBtn];

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(pad + 44, y - 2, cw - 44, 28)];
    _titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBlack];
    _titleLabel.textColor = kTextColor();
    [_sheetView addSubview:_titleLabel];
    y += 36;

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, sw, sheetH - y)];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.alwaysBounceVertical = YES;
    [_sheetView addSubview:_scrollView];

    CGFloat cy = 4;

    // ═══ Status ═══
    cy = [self addSectionAt:cy icon:@"chart.bar.fill" zhTitle:@"运行状态" enTitle:@"RUNNING STATUS" width:sw];
    UIView *statusCard = [self makeCardAt:CGRectMake(pad, cy, cw, 44)];
    [_scrollView addSubview:statusCard];
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 4, cw - 24, 36)];
    _statusLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightMedium];
    _statusLabel.textColor = kAccentColor();
    _statusLabel.numberOfLines = 2;
    [statusCard addSubview:_statusLabel];
    cy += 54;

    // ═══ Data Controls ═══
    cy = [self addSectionAt:cy icon:@"slider.horizontal.3" zhTitle:@"数据控制" enTitle:@"DATA CONTROLS" width:sw];

    // Pace
    UIView *paceCard = [self makeCardAt:CGRectMake(pad, cy, cw, 44)];
    [_scrollView addSubview:paceCard];
    [self addIconToCard:paceCard icon:@"figure.run"];
    UILabel *paceL = [self addLabelToCard:paceCard zhText:@"配速" enText:@"Pace"];
    [_rowLabels addObject:paceL];
    _paceField = [self makeFieldInCard:paceCard x:cw - 140 placeholder:@"min/km"];
    _paceBtn = [self makeCardBtn:paceCard x:cw - 62 zhTitle:@"锁定" enTitle:@"Lock" color:kAccentColor()];
    [_paceBtn addTarget:self action:@selector(applyPace) forControlEvents:UIControlEventTouchUpInside];
    cy += 52;

    // Distance
    UIView *distCard = [self makeCardAt:CGRectMake(pad, cy, cw, 44)];
    [_scrollView addSubview:distCard];
    [self addIconToCard:distCard icon:@"ruler"];
    UILabel *distL = [self addLabelToCard:distCard zhText:@"公里" enText:@"Distance"];
    [_rowLabels addObject:distL];
    _distField = [self makeFieldInCard:distCard x:cw - 140 placeholder:@"km"];
    _distBtn = [self makeCardBtn:distCard x:cw - 62 zhTitle:@"锁定" enTitle:@"Lock" color:kAccentColor()];
    [_distBtn addTarget:self action:@selector(applyDist) forControlEvents:UIControlEventTouchUpInside];
    cy += 52;

    // Reset button
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    resetBtn.frame = CGRectMake(pad, cy, cw, 36);
    [resetBtn setTitle:L(@"↺ 恢复原始数据", @"↺ Reset to Original") forState:UIControlStateNormal];
    [resetBtn setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    resetBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    resetBtn.backgroundColor = [UIColor colorWithRed:0.25 green:0.08 blue:0.08 alpha:1.0];
    resetBtn.layer.cornerRadius = 10;
    resetBtn.layer.borderColor = [UIColor colorWithRed:0.5 green:0.15 blue:0.15 alpha:0.6].CGColor;
    resetBtn.layer.borderWidth = 0.5;
    resetBtn.tag = 999;
    resetBtn.accessibilityLabel = @"↺ 恢复原始数据";
    resetBtn.accessibilityHint = @"↺ Reset to Original";
    [resetBtn addTarget:self action:@selector(resetData) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:resetBtn];
    cy += 44;

    // Radius
    UIView *radCard = [self makeCardAt:CGRectMake(pad, cy, cw, 74)];
    [_scrollView addSubview:radCard];
    [self addIconToCard:radCard icon:@"location.circle"];
    UILabel *radL = [self addLabelToCard:radCard zhText:@"打卡范围" enText:@"Check-in Range"];
    [_rowLabels addObject:radL];
    _radiusValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(cw - 70, 10, 58, 20)];
    _radiusValueLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightBold];
    _radiusValueLabel.textColor = kAccentColor();
    _radiusValueLabel.textAlignment = NSTextAlignmentRight;
    [radCard addSubview:_radiusValueLabel];
    _radiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(12, 38, cw - 24, 28)];
    _radiusSlider.minimumValue = 50;
    _radiusSlider.maximumValue = 1000;
    _radiusSlider.value = 1000;
    _radiusSlider.minimumTrackTintColor = kAccentColor();
    _radiusSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.25 alpha:1.0];
    [_radiusSlider addTarget:self action:@selector(radiusChanged:) forControlEvents:UIControlEventValueChanged];
    [radCard addSubview:_radiusSlider];
    cy += 84;

    // Checkpoint preview (2x2 grid)
    cy = [self addSectionAt:cy icon:@"mappin.circle.fill" zhTitle:@"打卡点状态" enTitle:@"CHECKPOINT STATUS" width:sw];
    _cpCards = [NSMutableArray new];
    _cpNameLabels = [NSMutableArray new];
    _cpStatusLabels = [NSMutableArray new];
    _cpIcons = [NSMutableArray new];
    CGFloat cardW = (cw - 8) / 2;
    CGFloat cardH = 52;
    for (int i = 0; i < 4; i++) {
        CGFloat cx = pad + (i % 2) * (cardW + 8);
        CGFloat ry = cy + (i / 2) * (cardH + 8);
        UIView *card = [self makeCardAt:CGRectMake(cx, ry, cardW, cardH)];
        [_scrollView addSubview:card];
        [_cpCards addObject:card];

        UIImageView *ico = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 14, 14)];
        ico.image = [UIImage systemImageNamed:@"mappin.circle"];
        ico.tintColor = kDimTextColor();
        ico.contentMode = UIViewContentModeScaleAspectFit;
        [card addSubview:ico];
        [_cpIcons addObject:ico];

        UILabel *nameL = [[UILabel alloc] initWithFrame:CGRectMake(30, 6, cardW - 40, 18)];
        nameL.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        nameL.textColor = kTextColor();
        nameL.text = [NSString stringWithFormat:@"#%d", i + 1];
        [card addSubview:nameL];
        [_cpNameLabels addObject:nameL];

        UILabel *stL = [[UILabel alloc] initWithFrame:CGRectMake(30, 26, cardW - 40, 18)];
        stL.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
        stL.textColor = kDimTextColor();
        stL.text = L(@"待分配", @"Pending");
        [card addSubview:stL];
        [_cpStatusLabels addObject:stL];
    }
    cy += (cardH + 8) * 2 + 4;

    // ═══ Security ═══
    cy = [self addSectionAt:cy icon:@"shield.fill" zhTitle:@"安全绕过" enTitle:@"SECURITY BYPASS" width:sw];

    NSArray *toggleItems = @[
        @[@"checkmark.shield.fill", @"设备检测",     @"Device Detection",     @"0"],
        @[@"gyroscope",             @"陀螺仪检测",   @"Gyroscope Check",      @"1"],
        @[@"lock.shield.fill",      @"GeeTest 验证", @"GeeTest Verification", @"2"],
        @[@"brain.head.profile",    @"行为分析",     @"Behavior Analysis",    @"3"],
        @[@"faceid",                @"人脸识别",     @"Face Recognition",     @"4"],
        @[@"figure.walk",           @"运动传感器",   @"Motion Sensor",        @"5"],
        @[@"location.slash.fill",   @"虚拟定位检测", @"Fake Location Detect", @"6"],
        @[@"cpu",                   @"Robot 模块",   @"Robot Module",         @"7"],
        @[@"lock.open.fill",         @"越狱检测",     @"Jailbreak Detection",  @"8"],
        @[@"network",                @"代理/VPN 检测", @"Proxy/VPN Detection",  @"9"],
    ];

    for (NSArray *item in toggleItems) {
        cy = [self addToggleAt:cy icon:item[0] zhText:item[1] enText:item[2] tag:[item[3] intValue] width:sw];
    }

    // ═══ Diagnostics (Terminal Style) ═══
    cy += 12;
    cy = [self addSectionAt:cy icon:@"terminal" zhTitle:@"安全诊断" enTitle:@"SECURITY DIAGNOSTICS" width:sw];
    UIView *diagCard = [[UIView alloc] initWithFrame:CGRectMake(pad, cy, cw, 220)];
    diagCard.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.06 alpha:1.0];
    diagCard.layer.cornerRadius = 10;
    diagCard.layer.borderColor = [UIColor colorWithRed:0.0 green:0.6 blue:0.3 alpha:0.4].CGColor;
    diagCard.layer.borderWidth = 0.5;
    [_scrollView addSubview:diagCard];

    UILabel *termTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, cw - 20, 14)];
    termTitle.text = @"lepao-helper ~ /security/scan";
    termTitle.font = [UIFont monospacedSystemFontOfSize:9 weight:UIFontWeightMedium];
    termTitle.textColor = [UIColor colorWithRed:0.3 green:0.7 blue:0.3 alpha:0.6];
    [diagCard addSubview:termTitle];

    _diagLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 22, cw - 20, 192)];
    _diagLabel.font = [UIFont monospacedSystemFontOfSize:10 weight:UIFontWeightRegular];
    _diagLabel.textColor = [UIColor colorWithRed:0.2 green:0.9 blue:0.4 alpha:1.0];
    _diagLabel.numberOfLines = 0;
    [diagCard addSubview:_diagLabel];
    cy += 230;

    // ═══ Network Activity Log (Terminal Style) ═══
    cy += 12;
    cy = [self addSectionAt:cy icon:@"antenna.radiowaves.left.and.right" zhTitle:@"网络活动" enTitle:@"NETWORK ACTIVITY" width:sw];
    UIView *netCard = [[UIView alloc] initWithFrame:CGRectMake(pad, cy, cw, 180)];
    netCard.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.06 alpha:1.0];
    netCard.layer.cornerRadius = 10;
    netCard.layer.borderColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.8 alpha:0.4].CGColor;
    netCard.layer.borderWidth = 0.5;
    [_scrollView addSubview:netCard];

    UILabel *netTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, cw - 20, 14)];
    netTitle.text = @"lepao-helper ~ /network/monitor";
    netTitle.font = [UIFont monospacedSystemFontOfSize:9 weight:UIFontWeightMedium];
    netTitle.textColor = [UIColor colorWithRed:0.3 green:0.6 blue:0.9 alpha:0.6];
    [netCard addSubview:netTitle];

    _netLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 22, cw - 20, 152)];
    _netLabel.font = [UIFont monospacedSystemFontOfSize:9.5 weight:UIFontWeightRegular];
    _netLabel.textColor = [UIColor colorWithRed:0.4 green:0.75 blue:1.0 alpha:1.0];
    _netLabel.numberOfLines = 0;
    _netLabel.text = @"$ tail -f /var/log/network\nWaiting...";
    [netCard addSubview:_netLabel];
    cy += 190;

    cy += 50;
    _scrollView.contentSize = CGSizeMake(sw, cy);

    _statusTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(refreshStatus) userInfo:nil repeats:YES];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kLangKey])
        gUseChinese = [[NSUserDefaults standardUserDefaults] boolForKey:kLangKey];
    [self updateLanguage];
    return self;
}

#pragma mark - Card Builders

- (UIView *)makeCardAt:(CGRect)f {
    UIView *v = [[UIView alloc] initWithFrame:f];
    v.backgroundColor = kCardColor();
    v.layer.cornerRadius = 12;
    return v;
}

- (void)addIconToCard:(UIView *)card icon:(NSString *)name {
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 18, 18)];
    iv.image = [UIImage systemImageNamed:name];
    iv.tintColor = kAccentColor();
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [card addSubview:iv];
}

- (UILabel *)addLabelToCard:(UIView *)card zhText:(NSString *)zh enText:(NSString *)en {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(38, 0, 120, 44)];
    l.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    l.textColor = kTextColor();
    l.accessibilityLabel = zh;
    l.accessibilityHint = en;
    l.text = gUseChinese ? zh : en;
    [card addSubview:l];
    return l;
}

- (UITextField *)makeFieldInCard:(UIView *)card x:(CGFloat)x placeholder:(NSString *)p {
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(x, 6, 70, 32)];
    tf.placeholder = p;
    tf.font = [UIFont monospacedDigitSystemFontOfSize:14 weight:UIFontWeightMedium];
    tf.textColor = kTextColor();
    tf.backgroundColor = [UIColor colorWithWhite:0.22 alpha:1.0];
    tf.layer.cornerRadius = 8;
    tf.textAlignment = NSTextAlignmentCenter;
    tf.keyboardType = UIKeyboardTypeDecimalPad;
    tf.delegate = self;
    tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:p attributes:@{NSForegroundColorAttributeName: kDimTextColor()}];
    [card addSubview:tf];
    return tf;
}

- (UIButton *)makeCardBtn:(UIView *)card x:(CGFloat)x zhTitle:(NSString *)zh enTitle:(NSString *)en color:(UIColor *)c {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = CGRectMake(x, 7, 52, 30);
    [b setTitleColor:kBgColor() forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    b.backgroundColor = c;
    b.layer.cornerRadius = 8;
    b.accessibilityLabel = zh;
    b.accessibilityHint = en;
    [b setTitle:gUseChinese ? zh : en forState:UIControlStateNormal];
    [card addSubview:b];
    return b;
}

- (CGFloat)addSectionAt:(CGFloat)y icon:(NSString *)iconName zhTitle:(NSString *)zh enTitle:(NSString *)en width:(CGFloat)w {
    CGFloat pad = 20;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(pad, y + 4, 16, 16)];
    iv.image = [UIImage systemImageNamed:iconName];
    iv.tintColor = kAccentColor();
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:iv];

    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(pad + 22, y, w - pad * 2 - 22, 24)];
    l.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    l.textColor = kDimTextColor();
    l.accessibilityLabel = zh;
    l.accessibilityHint = en;
    l.text = gUseChinese ? zh : en;
    [_scrollView addSubview:l];
    [_sectionHeaders addObject:l];
    return y + 28;
}

- (CGFloat)addToggleAt:(CGFloat)y icon:(NSString *)iconName zhText:(NSString *)zh enText:(NSString *)en tag:(int)tag width:(CGFloat)w {
    CGFloat pad = 20;
    CGFloat cw = w - pad * 2;

    UIView *row = [self makeCardAt:CGRectMake(pad, y, cw, 44)];
    [_scrollView addSubview:row];

    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 18, 18)];
    iv.image = [UIImage systemImageNamed:iconName];
    iv.tintColor = kAccentColor();
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [row addSubview:iv];

    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(38, 0, cw - 105, 44)];
    l.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    l.textColor = kTextColor();
    l.accessibilityLabel = zh;
    l.accessibilityHint = en;
    l.text = gUseChinese ? zh : en;
    [row addSubview:l];
    [_rowLabels addObject:l];

    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(cw - 63, 7, 0, 0)];
    sw.on = YES;
    sw.tag = tag;
    sw.onTintColor = kAccentColor();
    sw.thumbTintColor = kTextColor();
    [sw addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
    [row addSubview:sw];
    [_toggleSwitches addObject:sw];

    return y + 50;
}

#pragma mark - Language Toggle

- (void)toggleLang {
    gUseChinese = !gUseChinese;
    [[NSUserDefaults standardUserDefaults] setBool:gUseChinese forKey:kLangKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateLanguage];
}

- (void)updateLanguage {
    [_langBtn setTitle:(gUseChinese ? @"EN" : @"ZH") forState:UIControlStateNormal];
    _titleLabel.text = L(@"乐跑助手", @"Lepao Helper");
    for (UILabel *l in _sectionHeaders) {
        l.text = gUseChinese ? l.accessibilityLabel : l.accessibilityHint;
    }
    for (UILabel *l in _rowLabels) {
        l.text = gUseChinese ? l.accessibilityLabel : l.accessibilityHint;
    }
    [_paceBtn setTitle:L(@"锁定", @"Lock") forState:UIControlStateNormal];
    [_distBtn setTitle:L(@"锁定", @"Lock") forState:UIControlStateNormal];
    UIButton *resetBtn = (UIButton *)[_scrollView viewWithTag:999];
    if (resetBtn) [resetBtn setTitle:L(@"↺ 恢复原始数据", @"↺ Reset to Original") forState:UIControlStateNormal];
    _radiusValueLabel.text = (gCheckRadius >= 999999) ? L(@"全局", @"Global") : [NSString stringWithFormat:@"%lldm", gCheckRadius];
    [self refreshStatus];
}

#pragma mark - Actions

- (void)radiusChanged:(UISlider *)s {
    long long val = (long long)s.value;
    if (s.value >= 990) {
        val = 999999;
        _radiusValueLabel.text = L(@"全局", @"Global");
    } else {
        _radiusValueLabel.text = [NSString stringWithFormat:@"%lldm", val];
    }
    gCheckRadius = val;
    if (gRunVC) [(NSObject *)gRunVC setValue:@(val) forKey:@"checkCirclePoint"];
}

- (void)flashBtn:(UIButton *)b {
    UIColor *orig = b.backgroundColor;
    b.backgroundColor = [UIColor whiteColor];
    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [gen impactOccurred];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{ b.backgroundColor = orig; }];
    });
}

- (void)resetData {
    gPaceLocked = NO;
    gDistLocked = NO;
    gTargetPace = 0;
    gTargetDist = 0;
    _paceField.text = @"";
    _distField.text = @"";

    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    [gen impactOccurred];

    UIButton *btn = (UIButton *)[_scrollView viewWithTag:999];
    if (btn) {
        UIColor *orig = btn.backgroundColor;
        btn.backgroundColor = [UIColor systemRedColor];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{ btn.backgroundColor = orig; }];
        });
    }

    [self refreshStatus];
}

- (void)applyPace {
    double pace = [_paceField.text doubleValue];
    if (pace < 1 || pace > 30) return;
    gTargetPace = pace;
    gPaceLocked = YES;
    [_paceField resignFirstResponder];
    [self flashBtn:_paceBtn];
}

- (void)applyDist {
    double dist = [_distField.text doubleValue];
    if (dist < 0.01 || dist > 100) return;
    gTargetDist = dist;
    gDistLocked = YES;
    [_distField resignFirstResponder];
    [self flashBtn:_distBtn];
}


- (void)toggleChanged:(UISwitch *)sw {
    if (!sw.isOn) {
        NSString *msg = L(
            @"关闭此绕过将重新启用应用的反作弊检测，可能导致跑步被标记或终止。确定要关闭吗？",
            @"Disabling this bypass will re-enable the app's anti-cheat detection. Your run may be flagged or terminated. Are you sure?"
        );
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:L(@"风险警告", @"Warning")
            message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:L(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *a) {
            [sw setOn:YES animated:YES];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:L(@"关闭", @"Disable") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
            [self applyToggle:sw.tag value:NO];
        }]];
        if (gRunVC) [gRunVC presentViewController:alert animated:YES completion:nil];
        else [sw setOn:YES animated:YES];
    } else {
        [self applyToggle:sw.tag value:YES];
    }
}

- (void)applyToggle:(NSInteger)tag value:(BOOL)on {
    switch (tag) {
        case 0: gBypassDevice    = on; break;
        case 1: gBypassGyroscope = on; break;
        case 2: gBypassGeetest   = on; break;
        case 3: gBypassDeepknow  = on; break;
        case 4: gBypassFace      = on; break;
        case 5: gBypassMotion    = on; break;
        case 6: gBypassFakeLoc   = on; break;
        case 7: gBypassRobot     = on; break;
        case 8: gBypassJailbreak = on; break;
        case 9: gBypassProxy     = on; break;
    }
}

- (void)updateCheckpoints:(NSArray *)success {
    @try {
        NSInteger ok = success ? [success count] : 0;
        NSArray *online = [(NSObject *)gRunVC valueForKey:@"onlineDataSource"];
        for (int i = 0; i < 4; i++) {
            BOOL signed_ = (i < ok);
            BOOL assigned = (online && i < (NSInteger)[online count]);
            NSString *name = @"";
            if (assigned) {
                id pt = [online objectAtIndex:i];
                name = [(NSObject *)pt valueForKey:@"address"];
                if (!name) name = [NSString stringWithFormat:@"#%d", i + 1];
                if (name.length > 8) name = [[name substringToIndex:8] stringByAppendingString:@".."];
            } else {
                name = [NSString stringWithFormat:@"#%d", i + 1];
            }
            _cpNameLabels[i].text = name;
            if (signed_) {
                _cpStatusLabels[i].text = L(@"已签到", @"Signed");
                _cpStatusLabels[i].textColor = kAccentColor();
                _cpIcons[i].tintColor = kAccentColor();
                _cpIcons[i].image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
                _cpCards[i].layer.borderColor = kAccentColor().CGColor;
                _cpCards[i].layer.borderWidth = 1.0;
            } else if (assigned) {
                _cpStatusLabels[i].text = L(@"待签到", @"Waiting");
                _cpStatusLabels[i].textColor = [UIColor systemOrangeColor];
                _cpIcons[i].tintColor = [UIColor systemOrangeColor];
                _cpIcons[i].image = [UIImage systemImageNamed:@"mappin.circle"];
                _cpCards[i].layer.borderColor = [UIColor systemOrangeColor].CGColor;
                _cpCards[i].layer.borderWidth = 0.5;
            } else {
                _cpStatusLabels[i].text = L(@"待分配", @"Pending");
                _cpStatusLabels[i].textColor = kDimTextColor();
                _cpIcons[i].tintColor = kDimTextColor();
                _cpIcons[i].image = [UIImage systemImageNamed:@"circle.dashed"];
                _cpCards[i].layer.borderWidth = 0;
            }
        }
    } @catch (NSException *e) {}
}

- (NSString *)s:(NSString *)name ok:(BOOL)ok {
    return [NSString stringWithFormat:@"> %@ %@", name, ok ? @"\u2500\u2500 PASS" : @"\u2500\u2500 FAIL !"];
}

- (void)refreshDiagnostics {
    NSMutableString *r = [NSMutableString new];
    [r appendString:@"$ scan --all\n"];
    @try {
        // Jailbreak
        Class blyClass = NSClassFromString(@"BLYDevice");
        if (blyClass && [blyClass respondsToSelector:@selector(isJailBreak)]) {
            BOOL jb = ((BOOL(*)(id,SEL))objc_msgSend)(blyClass, @selector(isJailBreak));
            [r appendFormat:@"%@\n", [self s:@"jailbreak.bly " ok:!jb]];
        }
        Class jadClass = NSClassFromString(@"JADOSInfo");
        if (jadClass && [jadClass respondsToSelector:@selector(jailbreak)]) {
            int jb = ((int(*)(id,SEL))objc_msgSend)(jadClass, @selector(jailbreak));
            [r appendFormat:@"%@\n", [self s:@"jailbreak.jad " ok:(jb==0)]];
        }
        Class flyClass = NSClassFromString(@"FlyVerifyCDevice");
        if (flyClass) {
            if ([flyClass respondsToSelector:@selector(hasJailBroken)])
                [r appendFormat:@"%@\n", [self s:@"jailbreak.fly " ok:!((BOOL(*)(id,SEL))objc_msgSend)(flyClass, @selector(hasJailBroken))]];
            if ([flyClass respondsToSelector:@selector(hasProxy)])
                [r appendFormat:@"%@\n", [self s:@"proxy.detect  " ok:!((BOOL(*)(id,SEL))objc_msgSend)(flyClass, @selector(hasProxy))]];
            if ([flyClass respondsToSelector:@selector(isSimulator)])
                [r appendFormat:@"%@\n", [self s:@"simulator.chk " ok:!((BOOL(*)(id,SEL))objc_msgSend)(flyClass, @selector(isSimulator))]];
        }
        // Entry model
        if (gRunVC) {
            id entry = [(NSObject *)gRunVC valueForKey:@"runEntryModel"];
            if (entry) {
                BOOL dev = [[(NSObject *)entry valueForKey:@"is_check_device"] boolValue];
                BOOL gee = [[(NSObject *)entry valueForKey:@"is_check_geetest"] boolValue];
                BOOL deep = [[(NSObject *)entry valueForKey:@"is_check_deepkonw"] boolValue];
                BOOL face = [[(NSObject *)entry valueForKey:@"is_check_face"] boolValue];
                BOOL gyro = [[(NSObject *)entry valueForKey:@"gyroscope_type"] boolValue];
                BOOL robot = [[(NSObject *)entry valueForKey:@"robot_module"] boolValue];
                [r appendFormat:@"%@\n", [self s:@"device.check  " ok:!dev]];
                [r appendFormat:@"%@\n", [self s:@"geetest.verif " ok:!gee]];
                [r appendFormat:@"%@\n", [self s:@"deepknow.scan " ok:!deep]];
                [r appendFormat:@"%@\n", [self s:@"face.recog    " ok:!face]];
                [r appendFormat:@"%@\n", [self s:@"gyroscope.chk " ok:!gyro]];
                [r appendFormat:@"%@\n", [self s:@"robot.module  " ok:!robot]];
            }
            // Motion + drift
            id motion = [(NSObject *)gRunVC valueForKey:@"motionManager"];
            if (motion) {
                long long cs = [[(NSObject *)motion valueForKey:@"cheatCount_step"] longLongValue];
                long long cv = [[(NSObject *)motion valueForKey:@"cheatCount_speed"] longLongValue];
                long long cd = [[(NSObject *)motion valueForKey:@"cheatCount_drift"] longLongValue];
                BOOL nStep = [[(NSObject *)motion valueForKey:@"postNoti_step"] boolValue];
                BOOL nSpd = [[(NSObject *)motion valueForKey:@"postNoti_speed"] boolValue];
                BOOL nDrift = [[(NSObject *)motion valueForKey:@"postNoti_drift"] boolValue];
                [r appendFormat:@"%@\n", [self s:@"cheat.counter " ok:(cs+cv+cd)==0]];
                [r appendFormat:@"%@\n", [self s:@"path.drift    " ok:!nDrift]];
                [r appendFormat:@"%@\n", [self s:@"motion.alert  " ok:(!nStep && !nSpd)]];
            }
        }
        int pass = 0, total = 0;
        NSArray *lines = [r componentsSeparatedByString:@"\n"];
        for (NSString *l in lines) { if ([l containsString:@"PASS"]) pass++; if ([l containsString:@">"]) total++; }
        [r appendFormat:@"\n$ result: %d/%d passed", pass, total];
    } @catch (NSException *e) {
        [r appendFormat:@"\n$ error: %@", e.reason];
    }
    _diagLabel.text = r;
}

- (void)refreshStatus {
    if (!gRunVC) { _statusLabel.text = L(@"等待跑步数据...", @"Waiting for data..."); return; }
    @try {
        id calc = [(NSObject *)gRunVC valueForKey:@"caculateTotalDisTance"];
        double timer = [[(NSObject *)gRunVC valueForKey:@"timer"] doubleValue];
        double dist = calc ? [[(NSObject *)calc valueForKey:@"totalDistance"] doubleValue] : 0;
        NSArray *success = [(NSObject *)gRunVC valueForKey:@"sucessPointDataSource"];
        NSInteger ok = success ? [success count] : 0;
        double pace = dist > 0 ? timer / dist / 60.0 : 0;
        long long radius = [[(NSObject *)gRunVC valueForKey:@"checkCirclePoint"] longLongValue];
        NSString *rStr = radius >= 999999 ? L(@"全局", @"Global") : [NSString stringWithFormat:@"%lldm", radius];
        NSString *mode = @"";
        if (gPaceLocked && gDistLocked) mode = @"[PD] ";
        else if (gPaceLocked) mode = @"[P] ";
        else if (gDistLocked) mode = @"[D] ";
        [self updateCheckpoints:success];
        if (gUseChinese) {
            _statusLabel.text = [NSString stringWithFormat:@"%@%.2f km  |  %d:%02d  |  %.1f'/km\n签到 %ld/4  |  范围: %@",
                mode, dist, (int)(timer/60), (int)timer%60, pace, (long)ok, rStr];
        } else {
            _statusLabel.text = [NSString stringWithFormat:@"%@%.2f km  |  %d:%02d  |  %.1f'/km\nCheckpoints %ld/4  |  Radius: %@",
                mode, dist, (int)(timer/60), (int)timer%60, pace, (long)ok, rStr];
        }
    } @catch (NSException *e) {}
    [self refreshDiagnostics];
    [self refreshNetLog];
}

- (void)refreshNetLog {
    @synchronized(gNetLog) {
        if (!gNetLog || gNetLog.count == 0) {
            _netLabel.text = @"$ tail -f /var/log/network\nWaiting...";
            return;
        }
        NSInteger start = gNetLog.count > 12 ? gNetLog.count - 12 : 0;
        NSMutableString *s = [NSMutableString new];
        for (NSInteger i = start; i < (NSInteger)gNetLog.count; i++) {
            [s appendFormat:@"%@\n", gNetLog[i]];
        }
        _netLabel.text = s;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)tf { [tf resignFirstResponder]; return YES; }
- (void)dealloc { [_statusTimer invalidate]; }

@end

#pragma mark - Sheet Helper + Floating Ball

@implementation LPSheetHelper
+ (instancetype)shared {
    static LPSheetHelper *h = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ h = [[LPSheetHelper alloc] init]; });
    return h;
}
- (void)toggleSheet { gSheetVisible ? [self dismissSheet] : [self showSheet]; }
- (void)showSheet {
    if (!gRunVC || gSheetVisible) return;
    gSheetVisible = YES;
    CGRect sb = [UIScreen mainScreen].bounds;
    if (!gSheet) gSheet = [[LPBottomSheet alloc] initWithFrame:sb];
    gSheet.alpha = 0;
    gSheet.sheetView.transform = CGAffineTransformMakeTranslation(0, sb.size.height * 0.75);
    [gRunVC.view addSubview:gSheet];
    [gRunVC.view bringSubviewToFront:gFloatingBall];
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.88 initialSpringVelocity:0 options:0 animations:^{
        gSheet.alpha = 1;
        gSheet.sheetView.transform = CGAffineTransformIdentity;
    } completion:nil];
}
- (void)dismissSheet {
    if (!gSheetVisible) return;
    [UIView animateWithDuration:0.25 animations:^{
        gSheet.alpha = 0;
        gSheet.sheetView.transform = CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.height * 0.75);
    } completion:^(BOOL f) { [gSheet removeFromSuperview]; gSheetVisible = NO; }];
}
- (void)handlePan:(UIPanGestureRecognizer *)pan {
    UIView *v = pan.view;
    CGPoint t = [pan translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [pan setTranslation:CGPointZero inView:v.superview];
}
@end

static void setupFloatingBall(UIViewController *vc) {
    if (gFloatingBall && gFloatingBall.superview) { [vc.view bringSubviewToFront:gFloatingBall]; return; }
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    gFloatingBall = [UIButton buttonWithType:UIButtonTypeCustom];
    gFloatingBall.frame = CGRectMake(sw - 56, 100, 44, 44);
    gFloatingBall.backgroundColor = kAccentColor();
    gFloatingBall.layer.cornerRadius = 22;
    gFloatingBall.layer.shadowColor = kAccentColor().CGColor;
    gFloatingBall.layer.shadowOffset = CGSizeMake(0, 0);
    gFloatingBall.layer.shadowRadius = 10;
    gFloatingBall.layer.shadowOpacity = 0.5;
    UIImageView *bi = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"network.badge.shield.half.filled"]];
    bi.tintColor = kBgColor();
    bi.contentMode = UIViewContentModeScaleAspectFit;
    bi.frame = CGRectMake(11, 11, 22, 22);
    [gFloatingBall addSubview:bi];
    [gFloatingBall addTarget:[LPSheetHelper shared] action:@selector(toggleSheet) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[LPSheetHelper shared] action:@selector(handlePan:)];
    [gFloatingBall addGestureRecognizer:pan];
    [vc.view addSubview:gFloatingBall];
}

#pragma mark - Anti-Cheat Hooks

%hook LPRuningEntryModel
- (void)setIs_check_geedevice:(_Bool)v { %orig(gBypassDevice ? NO : v); }
- (void)setIs_check_device:(_Bool)v    { %orig(gBypassDevice ? NO : v); }
- (void)setGyroscope_type:(_Bool)v     { %orig(gBypassGyroscope ? NO : v); }
- (void)setIs_check_geetest:(_Bool)v   { %orig(gBypassGeetest ? NO : v); }
- (void)setIs_check_deepkonw:(_Bool)v  { %orig(gBypassDeepknow ? NO : v); }
- (void)setIs_check_face:(_Bool)v      { %orig(gBypassFace ? NO : v); }
- (void)setRobot_module:(_Bool)v       { %orig(gBypassRobot ? NO : v); }
%end

%hook LPRunningMotionManager
- (void)setCheatCount_step:(long long)v  { %orig(gBypassMotion ? 0 : v); }
- (void)setCheatCount_speed:(long long)v { %orig(gBypassMotion ? 0 : v); }
- (void)setCheatCount_drift:(long long)v { %orig(gBypassMotion ? 0 : v); }
- (void)setCyclingOrAutomotiveCount:(long long)v { %orig(gBypassMotion ? 0 : v); }
- (void)setPostNoti_step:(_Bool)v   { %orig(gBypassMotion ? NO : v); }
- (void)setPostNoti_speed:(_Bool)v  { %orig(gBypassMotion ? NO : v); }
- (void)setPostNoti_drift:(_Bool)v  { %orig(gBypassMotion ? NO : v); }
- (void)setRemoveMileage_dirft:(double)v { %orig(gBypassMotion ? 0 : v); }
- (void)verifyLocationWithUpLocationWithCurrentLocation:(id)a1 withTotalRunTime:(long long)a2 { if (!gBypassMotion) %orig; }
- (_Bool)verifySegmentedMileageOfAnyDrift:(id)a1 withPlan:(long long)a2 { return gBypassMotion ? NO : %orig; }
- (id)getRunCheckResSource { return %orig; }
%end

%hook LPRunningViewModel
- (void)requestRunGetGeeInfo:(id)a1 withStartTime:(id)a2 withResultBlock:(id)a3 {
    netLog(@"REQ   requestGeeInfo (passthrough)");
    %orig;
}
- (void)checkIn_deepKnownIFNeeded:(id)a1 withResultBlock:(id)a2 {
    netLog(@"REQ   deepKnown (passthrough)");
    %orig;
}
- (void)requestUploadSetRunLocationRecordWithParams:(id)params withResultBlock:(id)block {
    @try {
        NSString *dist = [(NSDictionary *)params objectForKey:@"totalDistance"];
        netLog([NSString stringWithFormat:@"UP    locRecord dist=%@", dist ?: @"?"]);
    } @catch(NSException *e) { netLog(@"UP    locRecord"); }
    %orig;
}
- (void)checkCapture_zoneISokWithStartTime:(id)a1 withDistance:(id)a2 withEntryModel:(id)a3 withPointIds:(id)a4 withResultBlock:(id)a5 {
    netLog([NSString stringWithFormat:@"REQ   zoneCheck dist=%@", a2 ?: @"?"]);
    %orig;
}
%end

%hook AMapLocationManager
- (void)setDetectRiskOfFakeLocation:(_Bool)v { %orig(gBypassFakeLoc ? NO : v); }
- (_Bool)detectRiskOfFakeLocation { return gBypassFakeLoc ? NO : %orig; }
%end

%hook AMapGeoFenceManager
- (void)setDetectRiskOfFakeLocation:(_Bool)v { %orig(gBypassFakeLoc ? NO : v); }
- (_Bool)detectRiskOfFakeLocation { return gBypassFakeLoc ? NO : %orig; }
%end

#pragma mark - Jailbreak Detection Hooks

%hook BLYDevice
+ (_Bool)isJailBreak { return gBypassJailbreak ? NO : %orig; }
- (_Bool)isJailbroken { return gBypassJailbreak ? NO : %orig; }
- (unsigned long long)jailbrokenStatus { return gBypassJailbreak ? 0 : %orig; }
- (void)setJailbrokenStatus:(unsigned long long)v { %orig(gBypassJailbreak ? 0 : v); }
%end

%hook JADOSInfo
+ (int)jailbreak { return gBypassJailbreak ? 0 : %orig; }
- (int)jailbreak { return gBypassJailbreak ? 0 : %orig; }
- (void)setJailbreak:(int)v { %orig(gBypassJailbreak ? 0 : v); }
%end

%hook FlyVerifyCDevice
+ (_Bool)hasJailBroken { return gBypassJailbreak ? NO : %orig; }
+ (_Bool)hasJailBroken:(_Bool)a1 { return gBypassJailbreak ? NO : %orig; }
+ (_Bool)isSimulator { return gBypassJailbreak ? NO : %orig; }
+ (_Bool)hasProxy { return gBypassProxy ? NO : %orig; }
+ (_Bool)hasProxy:(_Bool)a1 { return gBypassProxy ? NO : %orig; }
%end

%hook UIDevice
- (_Bool)isJailbroken { return gBypassJailbreak ? NO : %orig; }
%end

#pragma mark - Data Hooks

%hook LPCOnTotalDistance
- (double)totalDistance {
    if (gDistLocked && gTargetDist > 0) return gTargetDist;
    if (gPaceLocked && gTargetPace > 0 && gRunVC) {
        double timer = [[(NSObject *)gRunVC valueForKey:@"timer"] doubleValue];
        return timer / (gTargetPace * 60.0);
    }
    return %orig;
}
%end

#pragma mark - Running VC Hooks

%hook LPRunningViewController
- (void)throughMotionManagerResultToStopRunning:(id)a1 { if (!gBypassMotion) %orig; }
- (void)checkIsgeetest { netLog(@"REQ   checkGeetest (passthrough)"); %orig; }
- (void)checkIn_deepKnownIFNeeded { netLog(@"REQ   checkDeepKnow (passthrough)"); %orig; }
- (void)checkDeepKonwOnly { netLog(@"REQ   deepKnowOnly (passthrough)"); %orig; }
- (void)postChestTestIsValid:(id)a1 { netLog(@"REQ   chestTest (passthrough)"); %orig; }

- (void)saveDataInEveryTime { netLog(@"SAVE  saveDataInEveryTime"); %orig; }
- (void)jieShuLepaopost { netLog(@"POST  jieShuLepaopost (end-run)"); %orig; }
- (void)userUpLoadDataToService:(id)a1 { netLog(@"UP    userUpLoadDataToService"); %orig; }
- (void)uploadPointTypeOne { netLog(@"UP    uploadPointTypeOne"); %orig; }
- (void)upLoadManegerFile { netLog(@"UP    upLoadManegerFile"); %orig; }
- (void)uploadAppLogFile { netLog(@"UP    uploadAppLogFile"); %orig; }
- (void)uploadGyroscope_typeData:(id)a1 andWith:(id)a2 {
    netLog(@"UP    uploadGyroscope (passthrough)");
    %orig;
}
- (void)uploadgyroscopeData:(id)a1 andWith:(id)a2 {
    netLog(@"UP    uploadgyroscope (passthrough)");
    %orig;
}

- (void)setCheckCirclePoint:(long long)v { %orig(gCheckRadius); }

- (long long)timer {
    long long real = %orig;
    if (gDistLocked && gTargetDist > 0 && gPaceLocked && gTargetPace > 0)
        return (long long)(gTargetDist * gTargetPace * 60.0);
    return real;
}

- (void)viewDidLoad {
    %orig;
    gRunVC = self;
    [(NSObject *)self setValue:@(gCheckRadius) forKey:@"checkCirclePoint"];
}

- (void)viewDidAppear:(_Bool)animated {
    %orig;
    gRunVC = self;
    setupFloatingBall(self);
}

- (void)viewDidDisappear:(_Bool)animated {
    %orig;
    if (gFloatingBall) { [gFloatingBall removeFromSuperview]; gFloatingBall = nil; }
    if (gSheet) { [gSheet removeFromSuperview]; gSheet = nil; }
    gRunVC = nil;
    gSheetVisible = NO;
}
%end

#pragma mark - Account Switcher

static NSString *const kSavedAccountsKey = @"lp_helper_accounts";

static NSArray<NSString *> *kLoginKeys(void) {
    return @[@"uid", @"myaccess_token", @"myrefresh_token", @"refresh_expire",
             @"sanloginInfo", @"LPhx_uid", @"myLoginType", @"LoginTypeV320",
             @"userIsAdmin", @"userIsStu", @"userName", @"islogin4"];
}

static NSDictionary *lpCurrentCredentials(void) {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *cred = [NSMutableDictionary new];
    for (NSString *key in kLoginKeys()) {
        id val = [d objectForKey:key];
        if (!val) continue;
        if ([val isKindOfClass:[NSString class]] || [val isKindOfClass:[NSNumber class]]) {
            cred[key] = val;
        } else if ([val isKindOfClass:[NSDictionary class]] || [val isKindOfClass:[NSArray class]]) {
            NSData *j = [NSJSONSerialization dataWithJSONObject:val options:0 error:nil];
            if (j) cred[key] = [[NSString alloc] initWithData:j encoding:NSUTF8StringEncoding];
        } else {
            cred[key] = [val description];
        }
    }
    return cred;
}

static NSMutableArray *lpLoadAccounts(void) {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedAccountsKey];
    if (data && [data isKindOfClass:[NSData class]]) {
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([arr isKindOfClass:[NSArray class]]) return [arr mutableCopy];
    }
    return [NSMutableArray new];
}

static void lpSaveAccounts(NSArray *accounts) {
    NSData *data = [NSJSONSerialization dataWithJSONObject:accounts options:0 error:nil];
    if (data) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kSavedAccountsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

static void lpSaveCurrentAccount(NSString *label) {
    NSDictionary *cred = lpCurrentCredentials();
    NSString *uid = cred[@"uid"] ? [cred[@"uid"] description] : @"unknown";
    if (!label) label = cred[@"userName"] ?: @"unknown";

    NSMutableArray *accounts = lpLoadAccounts();
    for (NSUInteger i = 0; i < accounts.count; i++) {
        if ([[accounts[i][@"uid"] description] isEqualToString:uid]) {
            NSMutableDictionary *updated = [accounts[i] mutableCopy];
            updated[@"label"] = label;
            updated[@"cred"] = cred;
            accounts[i] = updated;
            lpSaveAccounts(accounts);
            return;
        }
    }
    [accounts addObject:@{@"label": label, @"uid": uid, @"cred": cred}];
    lpSaveAccounts(accounts);
}

static void lpSwitchToAccount(NSDictionary *account) {
    NSDictionary *cred = account[@"cred"];
    if (!cred) return;
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    for (NSString *key in kLoginKeys()) {
        id val = cred[key];
        if (val) [d setObject:val forKey:key];
        else [d removeObjectForKey:key];
    }
    [d synchronize];
}

// ═══ Account Sheet Panel ═══

@interface LPAccountSheet : UIView
@property(nonatomic, strong) UIView *dimView;
@property(nonatomic, strong) UIView *sheetView;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *currentLabel;
@end

static LPAccountSheet *gAccSheet = nil;
static BOOL gAccSheetVisible = NO;

static UIViewController *lpTopVC(void) {
    UIViewController *topVC = nil;
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            for (UIWindow *w in scene.windows) {
                if (w.isKeyWindow) { topVC = w.rootViewController; break; }
            }
            if (topVC) break;
        }
    }
    while (topVC.presentedViewController) topVC = topVC.presentedViewController;
    return topVC;
}

@implementation LPAccountSheet

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    CGFloat sw = frame.size.width;
    CGFloat sh = frame.size.height;
    CGFloat sheetH = sh * 0.72;

    _dimView = [[UIView alloc] initWithFrame:frame];
    _dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.55];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [_dimView addGestureRecognizer:tap];
    [self addSubview:_dimView];

    _sheetView = [[UIView alloc] initWithFrame:CGRectMake(0, sh - sheetH, sw, sheetH)];
    _sheetView.backgroundColor = kBgColor();
    _sheetView.layer.cornerRadius = 20;
    _sheetView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    _sheetView.clipsToBounds = YES;
    [self addSubview:_sheetView];

    UIView *handle = [[UIView alloc] initWithFrame:CGRectMake((sw - 40) / 2, 8, 40, 4)];
    handle.backgroundColor = [UIColor colorWithWhite:0.35 alpha:1.0];
    handle.layer.cornerRadius = 2;
    [_sheetView addSubview:handle];

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, sw - 40, 28)];
    _titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBlack];
    _titleLabel.textColor = kTextColor();
    _titleLabel.text = L(@"账号管理", @"Account Manager");
    [_sheetView addSubview:_titleLabel];

    _currentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, sw - 40, 18)];
    _currentLabel.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightMedium];
    _currentLabel.textColor = kDimTextColor();
    [_sheetView addSubview:_currentLabel];

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 74, sw, sheetH - 74)];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.alwaysBounceVertical = YES;
    [_sheetView addSubview:_scrollView];

    [self rebuildContent];
    return self;
}

- (void)rebuildContent {
    for (UIView *v in _scrollView.subviews) [v removeFromSuperview];

    CGFloat sw = self.frame.size.width;
    CGFloat pad = 20;
    CGFloat cw = sw - pad * 2;
    CGFloat cy = 4;

    NSString *currentUid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"] description] ?: @"?";
    NSString *currentName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] ?: @"?";
    _currentLabel.text = [NSString stringWithFormat:L(@"当前: %@ (uid:%@)", @"Current: %@ (uid:%@)"), currentName, currentUid];

    // ═══ Section: Saved Accounts ═══
    cy = [self addSectionAt:cy icon:@"person.2.fill" title:L(@"已保存账号", @"SAVED ACCOUNTS") width:sw];

    NSMutableArray *accounts = lpLoadAccounts();

    if (accounts.count == 0) {
        UIView *emptyCard = [self makeCardAt:CGRectMake(pad, cy, cw, 52)];
        [_scrollView addSubview:emptyCard];
        UILabel *emptyL = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, cw - 24, 52)];
        emptyL.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        emptyL.textColor = kDimTextColor();
        emptyL.textAlignment = NSTextAlignmentCenter;
        emptyL.text = L(@"暂无保存的账号", @"No saved accounts");
        [emptyCard addSubview:emptyL];
        cy += 60;
    } else {
        for (NSUInteger i = 0; i < accounts.count; i++) {
            NSDictionary *acc = accounts[i];
            NSString *uid = [acc[@"uid"] description] ?: @"?";
            NSString *label = acc[@"label"] ?: @"?";
            BOOL isCurrent = [uid isEqualToString:currentUid];

            UIView *card = [self makeCardAt:CGRectMake(pad, cy, cw, 96)];
            [_scrollView addSubview:card];

            // Status dot
            UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(14, 16, 10, 10)];
            dot.layer.cornerRadius = 5;
            dot.backgroundColor = isCurrent ? kAccentColor() : kDimTextColor();
            [card addSubview:dot];

            // Label
            UILabel *nameL = [[UILabel alloc] initWithFrame:CGRectMake(32, 6, cw - 44, 22)];
            nameL.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
            nameL.textColor = isCurrent ? kAccentColor() : kTextColor();
            nameL.text = isCurrent ? [NSString stringWithFormat:@"%@ ← %@", label, L(@"当前", @"Current")] : label;
            [card addSubview:nameL];

            // UID
            UILabel *uidL = [[UILabel alloc] initWithFrame:CGRectMake(32, 28, cw - 44, 18)];
            uidL.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightRegular];
            uidL.textColor = kDimTextColor();
            uidL.text = [NSString stringWithFormat:@"uid: %@", uid];
            [card addSubview:uidL];

            // Token preview
            NSString *token = acc[@"cred"][@"myaccess_token"] ?: @"--";
            if (token.length > 12) token = [NSString stringWithFormat:@"%@...%@", [token substringToIndex:6], [token substringFromIndex:token.length - 4]];
            UILabel *tokL = [[UILabel alloc] initWithFrame:CGRectMake(32, 44, cw - 44, 16)];
            tokL.font = [UIFont monospacedDigitSystemFontOfSize:10 weight:UIFontWeightRegular];
            tokL.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
            tokL.text = [NSString stringWithFormat:@"token: %@", token];
            [card addSubview:tokL];

            // Button row
            CGFloat bx = 12;
            CGFloat bw = (cw - 12 * 2 - 8 * 3) / 4;
            CGFloat by = 64;

            if (!isCurrent) {
                UIButton *swBtn = [self makeActionBtn:CGRectMake(bx, by, bw, 26) title:L(@"切换", @"Switch") color:kAccentColor() tag:(1000 + i)];
                [swBtn addTarget:self action:@selector(switchAccount:) forControlEvents:UIControlEventTouchUpInside];
                [card addSubview:swBtn];
            } else {
                UIButton *swBtn = [self makeActionBtn:CGRectMake(bx, by, bw, 26) title:L(@"当前", @"Active") color:[UIColor colorWithWhite:0.3 alpha:1.0] tag:(1000 + i)];
                swBtn.enabled = NO;
                [card addSubview:swBtn];
            }
            bx += bw + 8;

            UIButton *renameBtn = [self makeActionBtn:CGRectMake(bx, by, bw, 26) title:L(@"改名", @"Rename") color:[UIColor colorWithRed:0.2 green:0.5 blue:0.9 alpha:1.0] tag:(2000 + i)];
            [renameBtn addTarget:self action:@selector(renameAccount:) forControlEvents:UIControlEventTouchUpInside];
            [card addSubview:renameBtn];
            bx += bw + 8;

            UIButton *viewBtn = [self makeActionBtn:CGRectMake(bx, by, bw, 26) title:L(@"查看", @"Data") color:[UIColor colorWithRed:0.6 green:0.5 blue:0.9 alpha:1.0] tag:(3000 + i)];
            [viewBtn addTarget:self action:@selector(viewAccount:) forControlEvents:UIControlEventTouchUpInside];
            [card addSubview:viewBtn];
            bx += bw + 8;

            UIButton *delBtn = [self makeActionBtn:CGRectMake(bx, by, bw, 26) title:L(@"删除", @"Delete") color:[UIColor colorWithRed:0.85 green:0.2 blue:0.2 alpha:1.0] tag:(4000 + i)];
            [delBtn addTarget:self action:@selector(deleteAccount:) forControlEvents:UIControlEventTouchUpInside];
            [card addSubview:delBtn];

            cy += 104;
        }
    }

    // ═══ Section: Actions ═══
    cy += 8;
    cy = [self addSectionAt:cy icon:@"square.and.arrow.down.fill" title:L(@"操作", @"ACTIONS") width:sw];

    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.frame = CGRectMake(pad, cy, cw, 44);
    [saveBtn setTitle:L(@"+ 保存当前账号", @"+ Save Current Account") forState:UIControlStateNormal];
    [saveBtn setTitleColor:kBgColor() forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    saveBtn.backgroundColor = kAccentColor();
    saveBtn.layer.cornerRadius = 12;
    [saveBtn addTarget:self action:@selector(saveCurrentAction) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:saveBtn];
    cy += 52;

    UIButton *importBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    importBtn.frame = CGRectMake(pad, cy, cw, 44);
    [importBtn setTitle:L(@"↓ 导入账号数据", @"↓ Import Account Data") forState:UIControlStateNormal];
    [importBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    importBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    importBtn.backgroundColor = [UIColor colorWithRed:0.2 green:0.5 blue:0.9 alpha:1.0];
    importBtn.layer.cornerRadius = 12;
    [importBtn addTarget:self action:@selector(importAccountAction) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:importBtn];
    cy += 52;

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(pad, cy, cw, 36);
    [closeBtn setTitle:L(@"关闭", @"Close") forState:UIControlStateNormal];
    [closeBtn setTitleColor:kDimTextColor() forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    closeBtn.backgroundColor = kCardColor();
    closeBtn.layer.cornerRadius = 10;
    [closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:closeBtn];
    cy += 50;

    cy += 40;
    _scrollView.contentSize = CGSizeMake(sw, cy);
}

#pragma mark - Card Builders

- (UIView *)makeCardAt:(CGRect)f {
    UIView *v = [[UIView alloc] initWithFrame:f];
    v.backgroundColor = kCardColor();
    v.layer.cornerRadius = 12;
    return v;
}

- (CGFloat)addSectionAt:(CGFloat)y icon:(NSString *)iconName title:(NSString *)title width:(CGFloat)w {
    CGFloat pad = 20;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(pad, y + 4, 16, 16)];
    iv.image = [UIImage systemImageNamed:iconName];
    iv.tintColor = kAccentColor();
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:iv];

    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(pad + 22, y, w - pad * 2 - 22, 24)];
    l.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    l.textColor = kDimTextColor();
    l.text = title;
    [_scrollView addSubview:l];
    return y + 28;
}

- (UIButton *)makeActionBtn:(CGRect)frame title:(NSString *)title color:(UIColor *)color tag:(NSInteger)tag {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = frame;
    b.tag = tag;
    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    b.backgroundColor = color;
    b.layer.cornerRadius = 8;
    return b;
}

#pragma mark - Actions

- (void)switchAccount:(UIButton *)btn {
    NSUInteger idx = btn.tag - 1000;
    NSMutableArray *accounts = lpLoadAccounts();
    if (idx >= accounts.count) return;
    NSDictionary *acc = accounts[idx];
    NSString *label = acc[@"label"] ?: @"?";

    lpSwitchToAccount(acc);

    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    [gen impactOccurred];

    UIViewController *vc = lpTopVC();
    if (!vc) return;
    UIAlertController *done = [UIAlertController alertControllerWithTitle:L(@"已切换", @"Switched")
                                                                 message:[NSString stringWithFormat:L(@"已切换到 %@\n请重启App生效", @"Switched to %@\nRestart app to apply"), label]
                                                          preferredStyle:UIAlertControllerStyleAlert];
    [done addAction:[UIAlertAction actionWithTitle:L(@"重启App", @"Restart") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) { exit(0); }]];
    [done addAction:[UIAlertAction actionWithTitle:L(@"稍后", @"Later") style:UIAlertActionStyleCancel handler:nil]];
    [vc presentViewController:done animated:YES completion:nil];
}

- (void)renameAccount:(UIButton *)btn {
    NSUInteger idx = btn.tag - 2000;
    NSMutableArray *accounts = lpLoadAccounts();
    if (idx >= accounts.count) return;
    NSString *oldLabel = accounts[idx][@"label"] ?: @"";

    UIViewController *vc = lpTopVC();
    if (!vc) return;
    UIAlertController *input = [UIAlertController alertControllerWithTitle:L(@"重命名", @"Rename")
                                                                  message:L(@"输入新的备注名", @"Enter new label")
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [input addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.text = oldLabel;
        tf.placeholder = L(@"备注名", @"Label");
    }];
    __weak LPAccountSheet *weakSelf = self;
    [input addAction:[UIAlertAction actionWithTitle:L(@"确定", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        NSString *newLabel = input.textFields.firstObject.text;
        if (!newLabel.length) return;
        NSMutableArray *accs = lpLoadAccounts();
        if (idx < accs.count) {
            NSMutableDictionary *updated = [accs[idx] mutableCopy];
            updated[@"label"] = newLabel;
            accs[idx] = updated;
            lpSaveAccounts(accs);
            [weakSelf rebuildContent];
        }
    }]];
    [input addAction:[UIAlertAction actionWithTitle:L(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:nil]];
    [vc presentViewController:input animated:YES completion:nil];
}

- (void)viewAccount:(UIButton *)btn {
    NSUInteger idx = btn.tag - 3000;
    NSMutableArray *accounts = lpLoadAccounts();
    if (idx >= accounts.count) return;
    NSDictionary *acc = accounts[idx];
    NSDictionary *cred = acc[@"cred"] ?: @{};
    NSString *label = acc[@"label"] ?: @"?";
    NSString *uid = [acc[@"uid"] description] ?: @"?";

    [self showDetailForLabel:label uid:uid cred:cred];
}

- (void)showDetailForLabel:(NSString *)label uid:(NSString *)uid cred:(NSDictionary *)cred {
    for (UIView *v in _scrollView.subviews) [v removeFromSuperview];

    CGFloat sw = self.frame.size.width;
    CGFloat pad = 20;
    CGFloat cw = sw - pad * 2;
    CGFloat cy = 4;

    _titleLabel.text = L(@"账号数据", @"Account Data");
    _currentLabel.text = [NSString stringWithFormat:@"%@ (uid:%@)", label, uid];

    // Back button
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(pad, cy, cw, 36);
    NSMutableAttributedString *backAttr = [[NSMutableAttributedString alloc] init];
    NSTextAttachment *chevron = [[NSTextAttachment alloc] init];
    chevron.image = [[UIImage systemImageNamed:@"chevron.left"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    chevron.bounds = CGRectMake(0, -2, 12, 12);
    [backAttr appendAttributedString:[NSAttributedString attributedStringWithAttachment:chevron]];
    [backAttr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", L(@"返回账号列表", @"Back to Accounts")]]];
    [backBtn setAttributedTitle:backAttr forState:UIControlStateNormal];
    [backBtn setTitleColor:kAccentColor() forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn addTarget:self action:@selector(backToList) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:backBtn];
    cy += 44;

    // Section: Identity
    cy = [self addSectionAt:cy icon:@"person.text.rectangle" title:L(@"身份信息", @"IDENTITY") width:sw];

    NSArray *identityKeys = @[@"uid", @"userName", @"LPhx_uid", @"userIsStu", @"userIsAdmin"];
    for (NSString *key in identityKeys) {
        id val = cred[key];
        cy = [self addDataRowAt:cy key:key value:val width:sw];
    }

    // Section: Auth Tokens
    cy += 8;
    cy = [self addSectionAt:cy icon:@"key.fill" title:L(@"认证令牌", @"AUTH TOKENS") width:sw];

    NSArray *tokenKeys = @[@"myaccess_token", @"myrefresh_token", @"refresh_expire"];
    for (NSString *key in tokenKeys) {
        id val = cred[key];
        cy = [self addDataRowAt:cy key:key value:val width:sw];
    }

    // Section: Login Config
    cy += 8;
    cy = [self addSectionAt:cy icon:@"gearshape.fill" title:L(@"登录配置", @"LOGIN CONFIG") width:sw];

    NSArray *configKeys = @[@"myLoginType", @"LoginTypeV320", @"islogin4"];
    for (NSString *key in configKeys) {
        id val = cred[key];
        cy = [self addDataRowAt:cy key:key value:val width:sw];
    }

    // Section: Raw Data (sanloginInfo)
    id sanInfo = cred[@"sanloginInfo"];
    if (sanInfo) {
        cy += 8;
        cy = [self addSectionAt:cy icon:@"doc.text.fill" title:L(@"原始登录数据", @"RAW LOGIN DATA") width:sw];

        NSString *sanStr = [NSString stringWithFormat:@"%@", sanInfo];
        CGFloat textH = [sanStr boundingRectWithSize:CGSizeMake(cw - 24, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: [UIFont monospacedSystemFontOfSize:9.5 weight:UIFontWeightRegular]}
                                             context:nil].size.height + 20;
        if (textH < 60) textH = 60;
        if (textH > 220) textH = 220;

        UIView *rawCard = [[UIView alloc] initWithFrame:CGRectMake(pad, cy, cw, textH)];
        rawCard.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.06 alpha:1.0];
        rawCard.layer.cornerRadius = 10;
        rawCard.layer.borderColor = [UIColor colorWithRed:0.6 green:0.5 blue:0.9 alpha:0.4].CGColor;
        rawCard.layer.borderWidth = 0.5;
        rawCard.clipsToBounds = YES;
        [_scrollView addSubview:rawCard];

        UILabel *rawLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, cw - 24, textH - 16)];
        rawLabel.font = [UIFont monospacedSystemFontOfSize:9.5 weight:UIFontWeightRegular];
        rawLabel.textColor = [UIColor colorWithRed:0.7 green:0.6 blue:1.0 alpha:1.0];
        rawLabel.numberOfLines = 0;
        rawLabel.text = sanStr;
        [rawCard addSubview:rawLabel];

        // Tap to copy raw data
        rawCard.userInteractionEnabled = YES;
        rawCard.accessibilityValue = sanStr;
        UITapGestureRecognizer *rawTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyDataRow:)];
        [rawCard addGestureRecognizer:rawTap];
        cy += textH + 8;
    }

    cy += 50;
    _scrollView.contentSize = CGSizeMake(sw, cy);

    // Animate in
    _scrollView.alpha = 0;
    _scrollView.transform = CGAffineTransformMakeTranslation(sw * 0.15, 0);
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self->_scrollView.alpha = 1;
        self->_scrollView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (CGFloat)addDataRowAt:(CGFloat)y key:(NSString *)key value:(id)val width:(CGFloat)w {
    CGFloat pad = 20;
    CGFloat cw = w - pad * 2;

    NSString *displayVal = val ? [NSString stringWithFormat:@"%@", val] : @"(null)";
    BOOL isLong = displayVal.length > 32;

    CGFloat cardH = isLong ? 56 : 44;
    UIView *card = [self makeCardAt:CGRectMake(pad, y, cw, cardH)];
    [_scrollView addSubview:card];

    // Key label
    UILabel *keyL = [[UILabel alloc] initWithFrame:CGRectMake(12, 6, 140, 18)];
    keyL.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightBold];
    keyL.textColor = kAccentColor();
    keyL.text = key;
    [card addSubview:keyL];

    // Value label
    UILabel *valL = [[UILabel alloc] initWithFrame:CGRectMake(isLong ? 12 : 140, isLong ? 24 : 6, cw - (isLong ? 24 : 152), isLong ? 26 : 32)];
    valL.font = [UIFont monospacedDigitSystemFontOfSize:isLong ? 10 : 12 weight:UIFontWeightRegular];
    valL.textColor = kTextColor();
    valL.textAlignment = isLong ? NSTextAlignmentLeft : NSTextAlignmentRight;
    valL.numberOfLines = isLong ? 2 : 1;
    valL.lineBreakMode = NSLineBreakByTruncatingMiddle;
    valL.text = displayVal;

    if ([key isEqualToString:@"uid"] || [key isEqualToString:@"LPhx_uid"]) {
        valL.textColor = [UIColor colorWithRed:0.4 green:0.8 blue:1.0 alpha:1.0];
    } else if ([key containsString:@"token"]) {
        valL.textColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.3 alpha:1.0];
    } else if ([displayVal isEqualToString:@"(null)"]) {
        valL.textColor = kDimTextColor();
    }

    [card addSubview:valL];

    // Tap to copy
    card.userInteractionEnabled = YES;
    card.accessibilityValue = displayVal;
    UITapGestureRecognizer *tapCopy = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyDataRow:)];
    [card addGestureRecognizer:tapCopy];

    return y + cardH + 6;
}

- (void)copyDataRow:(UITapGestureRecognizer *)tap {
    UIView *card = tap.view;
    NSString *val = card.accessibilityValue;
    if (!val || [val isEqualToString:@"(null)"]) return;
    [UIPasteboard generalPasteboard].string = val;

    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [gen impactOccurred];

    // Flash feedback
    UIColor *orig = card.backgroundColor;
    [UIView animateWithDuration:0.1 animations:^{
        card.backgroundColor = kAccentColor();
    } completion:^(BOOL f) {
        [UIView animateWithDuration:0.3 animations:^{
            card.backgroundColor = orig;
        }];
    }];

    // Toast
    UILabel *toast = [[UILabel alloc] init];
    toast.text = L(@"已复制", @"Copied");
    toast.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    toast.textColor = kBgColor();
    toast.backgroundColor = kAccentColor();
    toast.textAlignment = NSTextAlignmentCenter;
    toast.layer.cornerRadius = 14;
    toast.clipsToBounds = YES;
    [toast sizeToFit];
    CGFloat tw = toast.frame.size.width + 24;
    toast.frame = CGRectMake((self.frame.size.width - tw) / 2, self.frame.size.height - 120, tw, 28);
    [self addSubview:toast];
    toast.alpha = 0;
    toast.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [UIView animateWithDuration:0.2 animations:^{
        toast.alpha = 1;
        toast.transform = CGAffineTransformIdentity;
    } completion:^(BOOL f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{ toast.alpha = 0; } completion:^(BOOL f2) { [toast removeFromSuperview]; }];
        });
    }];
}

- (void)backToList {
    _titleLabel.text = L(@"账号管理", @"Account Manager");
    _scrollView.alpha = 0;
    _scrollView.transform = CGAffineTransformMakeTranslation(-self.frame.size.width * 0.15, 0);
    [self rebuildContent];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self->_scrollView.alpha = 1;
        self->_scrollView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)deleteAccount:(UIButton *)btn {
    NSUInteger idx = btn.tag - 4000;
    NSMutableArray *accounts = lpLoadAccounts();
    if (idx >= accounts.count) return;
    NSString *label = accounts[idx][@"label"] ?: @"?";

    UIViewController *vc = lpTopVC();
    if (!vc) return;
    __weak LPAccountSheet *weakSelf = self;
    UIAlertController *confirm = [UIAlertController alertControllerWithTitle:L(@"确认删除", @"Confirm Delete")
                                                                    message:[NSString stringWithFormat:L(@"删除账号 \"%@\"？", @"Delete account \"%@\"?"), label]
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [confirm addAction:[UIAlertAction actionWithTitle:L(@"删除", @"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        NSMutableArray *accs = lpLoadAccounts();
        if (idx < accs.count) {
            [accs removeObjectAtIndex:idx];
            lpSaveAccounts(accs);
            [weakSelf rebuildContent];
        }
    }]];
    [confirm addAction:[UIAlertAction actionWithTitle:L(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:nil]];
    [vc presentViewController:confirm animated:YES completion:nil];
}

- (void)importAccountAction {
    UIViewController *vc = lpTopVC();
    if (!vc) return;
    __weak LPAccountSheet *weakSelf = self;

    UIAlertController *input = [UIAlertController alertControllerWithTitle:L(@"导入账号", @"Import Account")
                                                                  message:L(@"粘贴 JSON 数据\n支持格式:\n1. {\"uid\":\"...\",\"myaccess_token\":\"...\",...}\n2. 从\"查看\"复制的完整数据", @"Paste JSON data\nSupported formats:\n1. {\"uid\":\"...\",\"myaccess_token\":\"...\",...}\n2. Full data copied from View")
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [input addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = L(@"粘贴JSON数据...", @"Paste JSON...");
        tf.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
        // Auto-fill from clipboard
        NSString *clip = [UIPasteboard generalPasteboard].string;
        if (clip.length > 0 && [clip containsString:@"uid"]) tf.text = clip;
    }];
    [input addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = L(@"备注名（可选）", @"Label (optional)");
    }];

    [input addAction:[UIAlertAction actionWithTitle:L(@"导入", @"Import") style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        NSString *jsonStr = input.textFields[0].text;
        NSString *label = input.textFields[1].text;
        if (!jsonStr.length) return;

        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *parsed = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        if (![parsed isKindOfClass:[NSDictionary class]]) {
            UIAlertController *err = [UIAlertController alertControllerWithTitle:L(@"导入失败", @"Import Failed")
                                                                        message:L(@"JSON 格式错误，请检查数据", @"Invalid JSON format")
                                                                 preferredStyle:UIAlertControllerStyleAlert];
            [err addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [vc presentViewController:err animated:YES completion:nil];
            return;
        }

        // Detect format and build credential dict
        NSMutableDictionary *filteredCred = [NSMutableDictionary new];
        NSString *uid = nil;

        if (parsed[@"cred"]) {
            // Full account format: {"label":"...", "uid":"...", "cred":{...}}
            NSDictionary *cred = parsed[@"cred"];
            uid = [cred[@"uid"] description] ?: [parsed[@"uid"] description];
            for (NSString *key in kLoginKeys()) {
                id val = cred[key];
                if (val && ![val isEqual:[NSNull null]]) filteredCred[key] = val;
            }
        } else if (parsed[@"uid"] && parsed[@"myaccess_token"]) {
            // NSUserDefaults format: {"uid":"...", "myaccess_token":"...", ...}
            uid = [parsed[@"uid"] description];
            for (NSString *key in kLoginKeys()) {
                id val = parsed[key];
                if (val && ![val isEqual:[NSNull null]]) filteredCred[key] = val;
            }
        } else if (parsed[@"openid"] || parsed[@"accesstoken"]) {
            // Raw server login data: {"openid":"...", "accesstoken":"...", "nick_name":"...", ...}
            uid = parsed[@"openid"] ? [parsed[@"openid"] description] : nil;
            if (parsed[@"accesstoken"]) filteredCred[@"myaccess_token"] = [parsed[@"accesstoken"] description];
            if (parsed[@"nick_name"])   filteredCred[@"userName"] = [parsed[@"nick_name"] description];
            if (parsed[@"loginType"])   filteredCred[@"myLoginType"] = [parsed[@"loginType"] description];
            if (uid)                    filteredCred[@"uid"] = uid;
            filteredCred[@"islogin4"] = @"1";
            // Store the entire raw JSON as sanloginInfo
            filteredCred[@"sanloginInfo"] = jsonStr;
        } else {
            // Unknown format, try to find any uid-like field
            for (NSString *k in @[@"uid", @"openid", @"user_id", @"userId"]) {
                if (parsed[k]) { uid = [parsed[k] description]; break; }
            }
            for (NSString *key in kLoginKeys()) {
                id val = parsed[key];
                if (val && ![val isEqual:[NSNull null]]) filteredCred[key] = val;
            }
        }

        if (!uid || [uid isEqualToString:@""] || [uid isEqualToString:@"(null)"]) {
            UIAlertController *err = [UIAlertController alertControllerWithTitle:L(@"导入失败", @"Import Failed")
                                                                        message:L(@"数据中缺少可识别的用户标识 (uid/openid)", @"Missing user identifier (uid/openid)")
                                                                 preferredStyle:UIAlertControllerStyleAlert];
            [err addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [vc presentViewController:err animated:YES completion:nil];
            return;
        }

        if (!label.length) label = filteredCred[@"userName"] ?: parsed[@"nick_name"] ?: parsed[@"label"] ?: [NSString stringWithFormat:@"imported_%@", uid];

        // Save to accounts
        NSMutableArray *accounts = lpLoadAccounts();
        BOOL updated = NO;
        for (NSUInteger i = 0; i < accounts.count; i++) {
            if ([[accounts[i][@"uid"] description] isEqualToString:uid]) {
                NSMutableDictionary *upd = [accounts[i] mutableCopy];
                upd[@"label"] = label;
                upd[@"cred"] = filteredCred;
                accounts[i] = upd;
                updated = YES;
                break;
            }
        }
        if (!updated) {
            [accounts addObject:@{@"label": label, @"uid": uid, @"cred": filteredCred}];
        }
        lpSaveAccounts(accounts);
        [weakSelf rebuildContent];

        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [gen impactOccurred];

        UIAlertController *ok = [UIAlertController alertControllerWithTitle:L(@"导入成功", @"Import Success")
                                                                   message:[NSString stringWithFormat:@"%@ (uid:%@)", label, uid]
                                                            preferredStyle:UIAlertControllerStyleAlert];
        [ok addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [vc presentViewController:ok animated:YES completion:nil];
    }]];

    [input addAction:[UIAlertAction actionWithTitle:L(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:nil]];
    [vc presentViewController:input animated:YES completion:nil];
}

- (void)saveCurrentAction {
    NSString *currentName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] ?: @"";
    UIViewController *vc = lpTopVC();
    if (!vc) return;
    __weak LPAccountSheet *weakSelf = self;
    UIAlertController *input = [UIAlertController alertControllerWithTitle:L(@"保存账号", @"Save Account")
                                                                  message:L(@"输入备注名", @"Enter label")
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [input addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.text = currentName;
        tf.placeholder = L(@"备注名", @"Label");
    }];
    [input addAction:[UIAlertAction actionWithTitle:L(@"保存", @"Save") style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        NSString *lbl = input.textFields.firstObject.text;
        if (!lbl.length) lbl = currentName;
        lpSaveCurrentAccount(lbl);
        [weakSelf rebuildContent];
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [gen impactOccurred];
    }]];
    [input addAction:[UIAlertAction actionWithTitle:L(@"取消", @"Cancel") style:UIAlertActionStyleCancel handler:nil]];
    [vc presentViewController:input animated:YES completion:nil];
}

#pragma mark - Show / Dismiss

- (void)showInView:(UIView *)parent {
    if (gAccSheetVisible) return;
    gAccSheetVisible = YES;
    [self rebuildContent];
    self.alpha = 0;
    _sheetView.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height * 0.72);
    [parent addSubview:self];
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.88 initialSpringVelocity:0 options:0 animations:^{
        self.alpha = 1;
        self->_sheetView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)dismiss {
    if (!gAccSheetVisible) return;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
        self->_sheetView.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height * 0.72);
    } completion:^(BOOL f) {
        [self removeFromSuperview];
        gAccSheetVisible = NO;
    }];
}

@end

static void lpShowAccountSheet(void) {
    UIViewController *vc = lpTopVC();
    if (!vc) return;
    CGRect sb = [UIScreen mainScreen].bounds;
    if (!gAccSheet) gAccSheet = [[LPAccountSheet alloc] initWithFrame:sb];
    [gAccSheet showInView:vc.view];
}

@interface LBJButton : UIButton
@end

@interface LPNewRunningEntryChangeVersionView : UIView
@property(retain, nonatomic) LBJButton *startButton;
@end

%hook LPNewRunningEntryChangeVersionView
- (void)layoutSubviews {
    %orig;
    LBJButton *btn = self.startButton;
    if (!btn) return;
    if (btn.tag == 88888) return;
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lp_longPressStartBtn:)];
    lp.minimumPressDuration = 1.0;
    btn.tag = 88888;
    [btn addGestureRecognizer:lp];

    // Immediate press animation via touch events
    [btn addTarget:self action:@selector(lp_btnTouchDown:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(lp_btnTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
}

%new
- (void)lp_btnTouchDown:(UIButton *)btn {
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        btn.transform = CGAffineTransformMakeScale(0.88, 0.88);
        btn.alpha = 0.75;
    } completion:nil];
}
      
%new
- (void)lp_btnTouchUp:(UIButton *)btn {
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.8 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        btn.transform = CGAffineTransformIdentity;
        btn.alpha = 1.0;
    } completion:nil];
}

%new
- (void)lp_longPressStartBtn:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;

    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    [gen impactOccurred];

    lpShowAccountSheet();
}
%end
