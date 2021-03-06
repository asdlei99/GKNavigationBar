//
//  UIViewController+GKCategory.m
//  GKNavigationBar
//
//  Created by QuintGao on 2019/10/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "UIViewController+GKCategory.h"
#import "UIBarButtonItem+GKCategory.h"
#import "UIImage+GKCategory.h"
#import "GKTransitionDelegateHandler.h"

NSString *const GKViewControllerPropertyChangedNotification = @"GKViewControllerPropertyChangedNotification";

@implementation UIViewController (GKCategory)

static char kAssociatedObjectKey_interactivePopDisabled;
- (void)setGk_interactivePopDisabled:(BOOL)gk_interactivePopDisabled {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_interactivePopDisabled, @(gk_interactivePopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (BOOL)gk_interactivePopDisabled {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_interactivePopDisabled) boolValue];
}

static char kAssociatedObjectKey_fullScreenPopDisabled;
- (void)setGk_fullScreenPopDisabled:(BOOL)gk_fullScreenPopDisabled {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_fullScreenPopDisabled, @(gk_fullScreenPopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (BOOL)gk_fullScreenPopDisabled {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_fullScreenPopDisabled) boolValue];
}

static char kAssociatedObjectKey_maxPopDistance;
- (void)setGk_maxPopDistance:(CGFloat)gk_maxPopDistance {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_maxPopDistance, @(gk_maxPopDistance), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self postPropertyChangeNotification];
}

- (CGFloat)gk_maxPopDistance {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_maxPopDistance) floatValue];
}

static char kAssociatedObjectKey_navBarAlpha;
- (void)setGk_navBarAlpha:(CGFloat)gk_navBarAlpha {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navBarAlpha, @(gk_navBarAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    self.gk_navigationBar.gk_navBarBackgroundAlpha = gk_navBarAlpha;
}

- (CGFloat)gk_navBarAlpha {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_navBarAlpha) floatValue];
}

static char kAssociatedObjectKey_statusBarHidden;
- (void)setGk_statusBarHidden:(BOOL)gk_statusBarHidden {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_statusBarHidden, @(gk_statusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (BOOL)gk_statusBarHidden {
    id hidden = objc_getAssociatedObject(self, &kAssociatedObjectKey_statusBarHidden);
    return (hidden != nil) ? [hidden boolValue] : GKConfigure.statusBarHidden;
}

static char kAssociatedObjectKey_statusBarStyle;
- (void)setGk_statusBarStyle:(UIStatusBarStyle)gk_statusBarStyle {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_statusBarStyle, @(gk_statusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self preferredStatusBarStyle];
        
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (UIStatusBarStyle)gk_statusBarStyle {
    id style = objc_getAssociatedObject(self, &kAssociatedObjectKey_statusBarStyle);
    return (style != nil) ? [style integerValue] : GKConfigure.statusBarStyle;
}

static char kAssociatedObjectKey_backStyle;
- (void)setGk_backStyle:(GKNavigationBarBackStyle)gk_backStyle {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_backStyle, @(gk_backStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.navigationController.childViewControllers.count <= 1) return;
    
    if (self.gk_backStyle != GKNavigationBarBackStyleNone) {
        NSString *imageName = gk_backStyle == GKNavigationBarBackStyleBlack ? @"btn_back_black" : @"btn_back_white";
        
        UIImage *backImage = [UIImage gk_imageNamed:imageName];
        
        if (self.gk_NavBarInit) {
            self.gk_navigationItem.leftBarButtonItem = [UIBarButtonItem gk_itemWithImage:backImage target:self action:@selector(backItemClick:)];
        }
    }
}

- (GKNavigationBarBackStyle)gk_backStyle {
    id style = objc_getAssociatedObject(self, &kAssociatedObjectKey_backStyle);
    
    return (style != nil) ? [style integerValue] : GKConfigure.backStyle;
}

static char kAssociatedObjectKey_pushDelegate;
- (void)setGk_pushDelegate:(id<GKViewControllerPushDelegate>)gk_pushDelegate {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_pushDelegate, gk_pushDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<GKViewControllerPushDelegate>)gk_pushDelegate {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_pushDelegate);
}

static char kAssociatedObjectKey_popDelegate;
- (void)setGk_popDelegate:(id<GKViewControllerPopDelegate>)gk_popDelegate {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_popDelegate, gk_popDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<GKViewControllerPopDelegate>)gk_popDelegate {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_popDelegate);
}

#pragma mark - Private Methods
// 发送属性改变通知
- (void)postPropertyChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:GKViewControllerPropertyChangedNotification object:@{@"viewController": self}];
}

- (void)backItemClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

@implementation UIViewController (GKNavigationBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray <NSString *> *oriSels = @[@"viewWillAppear:",
                                          @"viewDidAppear:",
                                          @"viewWillDisappear:",
                                          @"viewWillLayoutSubviews"];
        
        [oriSels enumerateObjectsUsingBlock:^(NSString * _Nonnull oriSel, NSUInteger idx, BOOL * _Nonnull stop) {
            gk_swizzled_instanceMethod(self, oriSel, self);
        }];
    });
}

- (void)gk_viewWillAppear:(BOOL)animated {
    if (self.gk_NavBarInit) {
        // 隐藏系统导航栏
        [self.navigationController setNavigationBarHidden:YES];
        
        // 将自定义导航栏放置顶层
        if (self.gk_navigationBar && !self.gk_navigationBar.hidden) {
            [self.view bringSubviewToFront:self.gk_navigationBar];
        }
        
        // 重置navItem_space
        [GKConfigure updateConfigure:^(GKNavigationBarConfigure * _Nonnull configure) {
            configure.gk_navItemLeftSpace  = self.gk_navItemLeftSpace;
            configure.gk_navItemRightSpace = self.gk_navItemRightSpace;
        }];
        
        // 状态栏是否隐藏
        self.gk_navigationBar.gk_statusBarHidden = self.gk_statusBarHidden;
    }
    [self gk_viewWillAppear:animated];
}

- (void)gk_viewDidAppear:(BOOL)animated {
    // 每次视图出现是重新设置当前控制器的手势
    [[NSNotificationCenter defaultCenter] postNotificationName:GKViewControllerPropertyChangedNotification object:@{@"viewController": self}];
    
    [self gk_viewDidAppear:animated];
}

- (void)gk_viewWillDisappear:(BOOL)animated {
    if (self.gk_NavBarInit) {
        // 重置navItem_space
        [GKConfigure updateConfigure:^(GKNavigationBarConfigure * _Nonnull configure) {
            configure.gk_navItemLeftSpace  = self.last_navItemLeftSpace;
            configure.gk_navItemRightSpace = self.last_navItemRightSpace;
        }];
    }
    [self gk_viewWillDisappear:animated];
}

- (void)gk_viewWillLayoutSubviews {
    if (self.gk_NavBarInit) {
        [self setupNavBarFrame];
    }
    [self gk_viewWillLayoutSubviews];
}

#pragma mark - 状态栏
- (BOOL)prefersStatusBarHidden {
    return self.gk_statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.gk_statusBarStyle;
}

#pragma mark - 添加自定义导航栏
static char kAssociatedObjectKey_navigationBar;
- (void)setGk_navigationBar:(GKCustomNavigationBar *)gk_navigationBar {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navigationBar, gk_navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self setupNavBarFrame];
}

- (GKCustomNavigationBar *)gk_navigationBar {
    GKCustomNavigationBar *navigationBar = objc_getAssociatedObject(self, &kAssociatedObjectKey_navigationBar);
    if (!navigationBar) {
        navigationBar = [[GKCustomNavigationBar alloc] init];
        [self.view addSubview:navigationBar];
        
        self.gk_NavBarInit = YES;
        self.gk_navigationBar = navigationBar;
        
        // 设置导航栏外观
        [self setupNavBarAppearance];
    }
    return navigationBar;
}

static char kAssociatedObjectKey_navigationItem;
- (void)setGk_navigationItem:(UINavigationItem *)gk_navigationItem {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navigationItem, gk_navigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationBar.items = @[gk_navigationItem];
}

- (UINavigationItem *)gk_navigationItem {
    UINavigationItem *navigationItem = objc_getAssociatedObject(self, &kAssociatedObjectKey_navigationItem);
    if (!navigationItem) {
        navigationItem = [[UINavigationItem alloc] init];
        self.gk_navigationItem = navigationItem;
    }
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navigationItem);
}

static char kAssociatedObjectKey_navbarInit;
- (void)setGk_NavBarInit:(BOOL)gk_NavBarInit {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navbarInit, @(gk_NavBarInit), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gk_NavBarInit {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_navbarInit) boolValue];
}

#pragma mark - 常用属性快速设置
static char kAssociatedObjectKey_navBackgroundColor;
- (void)setGk_navBackgroundColor:(UIColor *)gk_navBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navBackgroundColor, gk_navBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self.gk_navigationBar setBackgroundImage:[UIImage gk_imageWithColor:gk_navBackgroundColor] forBarMetrics:UIBarMetricsDefault];
}

- (UIColor *)gk_navBackgroundColor {
    id objc = objc_getAssociatedObject(self, &kAssociatedObjectKey_navBackgroundColor);
    return (objc != nil) ? objc : GKConfigure.backgroundColor;
}

static char kAssociatedObjectKey_navBackgroundImage;
- (void)setGk_navBackgroundImage:(UIImage *)gk_navBackgroundImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navBackgroundImage, gk_navBackgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self.gk_navigationBar setBackgroundImage:gk_navBackgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (UIImage *)gk_navBackgroundImage {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navBackgroundImage);
}

static char kAssociatedObjectKey_navShadowColor;
- (void)setGk_navShadowColor:(UIColor *)gk_navShadowColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navShadowColor, gk_navShadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationBar.shadowImage = [UIImage gk_changeImage:[UIImage gk_imageNamed:@"nav_line"] color:gk_navShadowColor];
}

- (UIColor *)gk_navShadowColor {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navShadowColor);
}

static char kAssociatedObjectKey_navShadowImage;
- (void)setGk_navShadowImage:(UIImage *)gk_navShadowImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navShadowImage, gk_navShadowImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationBar.shadowImage = gk_navShadowImage;
}

- (UIImage *)gk_navShadowImage {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navShadowImage);
}

static char kAssociatedObjectKey_navLineHidden;
- (void)setGk_navLineHidden:(BOOL)gk_navLineHidden {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navLineHidden, @(gk_navLineHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationBar.gk_navLineHidden = gk_navLineHidden;
    
    if (GKDeviceVersion >= 11.0f) {
        self.gk_navShadowImage = gk_navLineHidden ? [UIImage new] : self.gk_navShadowImage;
    }
    [self.gk_navigationBar layoutSubviews];
}

- (BOOL)gk_navLineHidden {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_navLineHidden) boolValue];
}

static char kAssociatedObjectKey_navTitleView;
- (void)setGk_navTitleView:(UIView *)gk_navTitleView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navTitleView, gk_navTitleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationItem.titleView = gk_navTitleView;
}

- (UIView *)gk_navTitleView {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navTitleView);
}

static char kAssociatedObjectKey_navTitleColor;
- (void)setGk_navTitleColor:(UIColor *)gk_navTitleColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navTitleColor, gk_navTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: gk_navTitleColor, NSFontAttributeName: self.gk_navTitleFont};
}

- (UIColor *)gk_navTitleColor {
    id objc = objc_getAssociatedObject(self, &kAssociatedObjectKey_navTitleColor);
    return (objc != nil) ? objc : GKConfigure.titleColor;
}

static char kAssociatedObjectKey_navTitleFont;
- (void)setGk_navTitleFont:(UIFont *)gk_navTitleFont {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navTitleFont, gk_navTitleFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.gk_navTitleColor, NSFontAttributeName: gk_navTitleFont};
}

- (UIFont *)gk_navTitleFont {
    id objc = objc_getAssociatedObject(self, &kAssociatedObjectKey_navTitleFont);
    return (objc != nil) ? objc : GKConfigure.titleFont;
}

static char kAssociatedObjectKey_navLeftBarButtonItem;
- (void)setGk_navLeftBarButtonItem:(UIBarButtonItem *)gk_navLeftBarButtonItem {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navLeftBarButtonItem, gk_navLeftBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationItem.leftBarButtonItem = gk_navLeftBarButtonItem;
}

- (UIBarButtonItem *)gk_navLeftBarButtonItem {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navLeftBarButtonItem);
}

static char kAssociatedObjectKey_navLeftBarButtonItems;
- (void)setGk_navLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)gk_navLeftBarButtonItems {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navLeftBarButtonItems, gk_navLeftBarButtonItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationItem.leftBarButtonItems = gk_navLeftBarButtonItems;
}

- (NSArray<UIBarButtonItem *> *)gk_navLeftBarButtonItems {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navLeftBarButtonItems);
}

static char kAssociatedObjectKey_navRightBarButtonItem;
- (void)setGk_navRightBarButtonItem:(UIBarButtonItem *)gk_navRightBarButtonItem {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navRightBarButtonItem, gk_navRightBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationItem.rightBarButtonItem = gk_navRightBarButtonItem;
}

- (UIBarButtonItem *)gk_navRightBarButtonItem {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navRightBarButtonItem);
}

static char kAssociatedObjectKey_navRightBarButtonItems;
- (void)setGk_navRightBarButtonItems:(NSArray<UIBarButtonItem *> *)gk_navRightBarButtonItems {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navRightBarButtonItems, gk_navRightBarButtonItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.gk_navigationItem.rightBarButtonItems = gk_navRightBarButtonItems;
}

- (NSArray<UIBarButtonItem *> *)gk_navRightBarButtonItems {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_navRightBarButtonItems);
}

static char kAssociatedObjectKey_navItemLeftSpace;
- (void)setGk_navItemLeftSpace:(CGFloat)gk_navItemLeftSpace {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navItemLeftSpace, @(gk_navItemLeftSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.isSettingItemSpace) return;
    
    [GKConfigure updateConfigure:^(GKNavigationBarConfigure * _Nonnull configure) {
        configure.gk_navItemLeftSpace = gk_navItemLeftSpace;
        configure.gk_navItemRightSpace = self.gk_navItemRightSpace;
    }];
}

- (CGFloat)gk_navItemLeftSpace {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_navItemLeftSpace) floatValue];
}

static char kAssociatedObjectKey_navItemRightSpace;
- (void)setGk_navItemRightSpace:(CGFloat)gk_navItemRightSpace {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navItemRightSpace, @(gk_navItemRightSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.isSettingItemSpace) return;
    
    [GKConfigure updateConfigure:^(GKNavigationBarConfigure * _Nonnull configure) {
        configure.gk_navItemLeftSpace = self.gk_navItemLeftSpace;
        configure.gk_navItemRightSpace = gk_navItemRightSpace;
    }];
}

- (CGFloat)gk_navItemRightSpace {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_navItemRightSpace) floatValue];
}

#pragma mark - Public Methods
- (void)showNavLine {
    self.gk_navLineHidden = NO;
}

- (void)hideNavLine {
    self.gk_navLineHidden = YES;
}

- (void)refreshNavBarFrame {
    [self setupNavBarFrame];
}

- (UIViewController *)gk_visibleViewControllerIfExist {
    if (self.presentedViewController) {
        return [self.presentedViewController gk_visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).visibleViewController gk_visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController gk_visibleViewControllerIfExist];
    }
    
    if (self.isViewLoaded && self.view.window) {
        return self;
    }else {
        NSLog(@"找不到可见的控制器，viewController.self = %@，self.view.window = %@", self, self.view.window);
        return nil;
    }
}

#pragma mark - Private Methods
- (void)setupNavBarAppearance {
    GKNavigationBarConfigure *configure = GKConfigure;
    
    self.isSettingItemSpace     = YES;
    self.gk_navItemLeftSpace    = configure.gk_navItemLeftSpace;
    self.gk_navItemRightSpace   = configure.gk_navItemRightSpace;
    self.last_navItemLeftSpace  = configure.gk_navItemLeftSpace;
    self.last_navItemRightSpace = configure.gk_navItemRightSpace;
    self.isSettingItemSpace     = NO;
}

- (void)setupNavBarFrame {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat navBarH = 0.0f;
    if (width > height) { // 横屏
        if (GK_NOTCHED_SCREEN) {
            navBarH = GK_NAVBAR_HEIGHT;
        }else {
            if (width == 736.0f && height == 414.0f) {  // plus横屏
                navBarH = self.gk_statusBarHidden ? GK_NAVBAR_HEIGHT : GK_STATUSBAR_NAVBAR_HEIGHT;
            }else { // 其他机型横屏
                navBarH = self.gk_statusBarHidden ? 32.0f : 52.0f;
            }
        }
    }else { // 竖屏
        navBarH = self.gk_statusBarHidden ? (GK_SAFEAREA_TOP + GK_NAVBAR_HEIGHT) : GK_STATUSBAR_NAVBAR_HEIGHT;
    }
    self.gk_navigationBar.frame = CGRectMake(0, 0, width, navBarH);
    self.gk_navigationBar.gk_statusBarHidden = self.gk_statusBarHidden;
    [self.gk_navigationBar layoutSubviews];
}

static char kAssociatedObjectKey_lastNavItemLeftSpace;
- (void)setLast_navItemLeftSpace:(CGFloat)last_navItemLeftSpace {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_lastNavItemLeftSpace, @(last_navItemLeftSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)last_navItemLeftSpace {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_lastNavItemLeftSpace) floatValue];
}

static char kAssociatedObjectKey_lastNavItemRightSpace;
- (void)setLast_navItemRightSpace:(CGFloat)last_navItemRightSpace {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_lastNavItemRightSpace, @(last_navItemRightSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)last_navItemRightSpace {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_lastNavItemRightSpace) floatValue];
}

static char kAssociatedObjectKey_isSettingItemSpace;
- (void)setIsSettingItemSpace:(BOOL)isSettingItemSpace {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_isSettingItemSpace, @(isSettingItemSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSettingItemSpace {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_isSettingItemSpace) boolValue];
}

@end
