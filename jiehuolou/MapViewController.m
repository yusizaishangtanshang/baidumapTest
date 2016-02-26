//
//  MapViewController.m
//  jiehuolou
//
//  Created by 贺东方 on 16/2/25.
//  Copyright © 2016年 hexiaoyi. All rights reserved.
//

#import "MapViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
@interface MapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKOfflineMapDelegate,BMKAnnotation>

@end

@implementation MapViewController
{
    BMKMapView *_mapView;
    BMKLocationService *_locService;
    BMKOfflineMap *_offlineMap;
    BMKUserLocation *_userLocation;
    BMKPointAnnotation* pointAnnotation;
    CLLocationCoordinate2D _userCoordinate;
    NSArray* _arrayHotCityData;//热门城市
    NSArray* _arrayOfflineCityData;//全国支持离线地图的城市
    NSMutableArray * _arraylocalDownLoadMapInfo;//本地下载的离线地图
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        self.navigationController.navigationBar.translucent = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    _userCoordinate.longitude = 31;
    _userCoordinate.latitude = 120;
    [self confUI];
    [self confMapView];
    [self getLoaction];
    [self confofflineMap];
}
- (void)confUI
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.text = @"";
    [self.view addSubview:btn];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.text = @"";
    [self.view addSubview:btn2];
}
- (void)confMapView
{
    //配置mapView
    CGRect rect = CGRectMake(0,100 , self.view.bounds.size.width, self.view.bounds.size.height);
    _mapView = [[BMKMapView alloc]initWithFrame:rect];
    [self.view addSubview:_mapView];
    _mapView.mapType = BMKMapTypeStandard;
    _mapView.showsUserLocation = YES;
    BMKCoordinateRegion region;
    region.center = _userLocation.location.coordinate;
    region.span.latitudeDelta = 0.1;
    region.span.longitudeDelta = 0.2;
    _mapView.region = region;
}

- (void)getLoaction
{
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;
    _userLocation = _locService.userLocation;
}
- (void)confofflineMap
{
    //初始化离线地图服务
    _offlineMap = [[BMKOfflineMap alloc]init];
    //获取热门城市
    _arrayHotCityData = [_offlineMap getHotCityList];
    //获取支持离线下载城市列表
    _arrayOfflineCityData = [_offlineMap getOfflineCityList];
    //初始化Segment
    
}

#pragma mark 添加标注--大头针
//添加标注
- (void)addPointAnnotation:(CLLocationCoordinate2D)coordinate
{
    if (pointAnnotation == nil) {
        pointAnnotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        coor.latitude = 31;
        coor.longitude = 120;
        pointAnnotation.coordinate = coordinate;
        pointAnnotation.title = @"test";
        pointAnnotation.subtitle = @"此Annotation可拖拽!";
    }
    [_mapView addAnnotation:pointAnnotation];
}

#pragma mark - locService Delegate

- (void)willStartLocatingUser
{
    NSLog(@"kaishi dingwei");
}
/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
            NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    [_locService stopUserLocationService];
}
/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

#pragma mark - BMKMapViewDelegate
- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _offlineMap.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _offlineMap.delegate = nil;
}
- (void)viewDidAppear:(BOOL)animated
{
    CLLocationCoordinate2D coor;
    coor.latitude = 31;
    coor.longitude = 120;
    [self addPointAnnotation:coor];
}
- (void)onGetOfflineMapState:(int)type withState:(int)state
{
    
}
// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    BMKPinAnnotationView *annotationView;
    //普通annotation
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        NSString *AnnotationViewID = @"renameMark";
        annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            // 设置颜色
//            annotationView.pinColor = BMKPinAnnotationColorPurple;
            // 从天上掉下效果
//            annotationView.animatesDrop = YES;
            // 设置可拖拽
//            annotationView.draggable = YES;
            //设置大头针的图片
            annotationView.image = [UIImage imageNamed:@"poi_3.png"];
            //设置弹出view
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
            view.backgroundColor = [UIColor redColor];
            annotationView.paopaoView = [[BMKActionPaopaoView alloc]initWithCustomView:view];
        }
        return annotationView;
    }
    return nil;
    
}

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"BMKMapView控件初始化完成" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
    [alert show];
    alert = nil;
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
//    [self addPointAnnotation:coordinate];
    NSLog(@"map view: click blank");
}
//
//- (void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate {
//    NSLog(@"map view: double click");
//}


@end
