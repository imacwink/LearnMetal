//
//  ViewController.m
//  LUT-ObjC
//
//  Created by 王云刚 on 2020/7/20.
//

#import "ViewController.h"
#import "CameraEngine.h"
#import "MetalContext.h"
#import "MetalView.h"
#import "LutTexture.h"
#import "TextureLoader.h"
#import "DefineCollectionViewCell.h"

static NSString *indentifier = @"CellID";

@interface ViewController () <CameraEngineDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) MetalContext *mtlContext;
@property (nonatomic) MetalView *mtlView;
@property (nonatomic) LutTexture *textureRender;
@property (nonatomic) id<MTLTexture> lutTextureID;
@property(nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CameraEngine *cameraEngine;
@property (nonatomic, strong) NSMutableArray<NSString *> *lutArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addObserver];
    
    // 创建数据源;
    [self createDataSource];
    
    // 创建 CollectionView;
    [self createCollectionView];
    
    // 创建 Metal 渲染需要的上下文信息;
    self.mtlContext = [MetalContext shareMetalContext];
    
    // 创建 Metal 渲染需要的视图窗口;
    self.mtlView = [[MetalView alloc] init];
    
    // 根据相机采集的分辨率设置绘制区域;
    float cameraW = 720.0f;
    float cameraH = 1280.0f;
    float frameW = self.view.frame.size.width;
    float frameH = self.view.frame.size.height;
    float realW = frameW;
    float realH = cameraH * frameW / cameraW;
    float orginX = 0.0f;
    float orginY = (frameH - realH) / 2.0f;
    
    self.mtlView.frame = CGRectMake(orginX, orginY, realW, realH);
    [self.view addSubview:self.mtlView];
    
    // 加载 LUT;
    self.lutTextureID = [TextureLoader loadTexture:self.mtlContext.device imageNamed:@"lut2.png" pixelFormat:MTLPixelFormatRGBA8Unorm];
    
    // 创建真实渲染器，需要熏染一个三角形，同时需要将视图窗口的 Layer 信息传递给它;
    self.textureRender = [[LutTexture alloc] initWithLayer: self.mtlView.metalLayer context: self.mtlContext];
    
    // 创建相机;
    self.cameraEngine = [[CameraEngine alloc] initCE];
    self.cameraEngine.delegate = self;
}

- (void)createDataSource {
    self.lutArray = [[NSMutableArray alloc] init];
    [self.lutArray addObject:@"original.png"];
    [self.lutArray addObject:@"lut1.png"];
    [self.lutArray addObject:@"lut2.png"];
    [self.lutArray addObject:@"lut3.png"];
    [self.lutArray addObject:@"lut4.png"];
    [self.lutArray addObject:@"lut5.png"];
    [self.lutArray addObject:@"lut6.png"];
}

- (void)createCollectionView {
    CGRect collectionViewFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 100, [UIScreen mainScreen].bounds.size.width, 100);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal; /*设置 UICollectionView 为横向滚动*/
    layout.minimumLineSpacing = 50; /*每一行 Cell 之间的间距*/
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10); /*设置第一个 Cell 和最后一个 Cell,与父控件之间的间距*/
    layout.minimumLineSpacing = 8; /*根据需要编写*/
    layout.itemSize = CGSizeMake(60, 60); /*该行代码就算不写, item 也会有默认尺寸*/
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[DefineCollectionViewCell class] forCellWithReuseIdentifier:indentifier];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.lutArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DefineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indentifier forIndexPath:indexPath];
    if (nil == cell ) {
        cell = [[DefineCollectionViewCell alloc] init];
    }
    NSInteger row = [indexPath row];
    NSString * lutName = [self.lutArray objectAtIndex:row];
    [cell setImage:[UIImage imageNamed:lutName]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    NSString * lutName = [self.lutArray objectAtIndex:row];
    self.lutTextureID = [TextureLoader loadTexture:self.mtlContext.device imageNamed:lutName pixelFormat:MTLPixelFormatRGBA8Unorm];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)willResignActive {
    [self.cameraEngine stopCE];
}

- (void)didBecomeActive {
    [self.cameraEngine startCE];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    [self.cameraEngine startCE];
}

- (void)didOutputVideoBuffer:(CVPixelBufferRef)vpBuffer {
    if(vpBuffer) {
        [self.textureRender processDraw:[self.mtlContext textureFromPixelBuffer: vpBuffer] lut:self.lutTextureID];
    }
}

@end
