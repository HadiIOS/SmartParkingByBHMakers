//
//  mapView.m
//  SmartParking
//
//  Created by Academy387 on 13/03/15.
//  Copyright (c) 2015 Academy387. All rights reserved.
//

#import "mapView.h"
#import <GoogleMaps/GoogleMaps.h>
#import "DataClass.h"
#import "ParkInfo.h"
#import "profileInfo.h"
static NSString *const BaseURLString = @"http://preview.hardver.ba/parkings/api/parkings/";

@interface mapView ()<NSURLConnectionDelegate, GMSMapViewDelegate>{
    GMSMapView *mapView_;
    NSMutableData *getResponseData;
    DataClass *dataClass;
}

@end

@implementation mapView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self deviceLocation];
    
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navBar.barTintColor = [self colorWithHexString:@"0088BF"];
    
    self.navigationItem.title = @"Parking";
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    navBar.translucent = NO;
    [navBar pushNavigationItem:self.navigationItem animated:NO];
    
    UIBarButtonItem *profile = [[UIBarButtonItem alloc] initWithTitle:@"Profile" style: UIBarButtonItemStyleDone target:self action:@selector(profileEnter)];
    self.navigationItem.rightBarButtonItem = profile;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self.view addSubview:navBar];

    
    CGRect f = self.view.frame;
    CGRect mapFrame = CGRectMake(f.origin.x, 64, f.size.width, f.size.height - 64);

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:43.8667
                                                            longitude:18.4167
                                                                 zoom:14];
    mapView_ = [GMSMapView mapWithFrame:mapFrame camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.mapType = kGMSTypeHybrid;
    mapView_.delegate = self;
    [self.view addSubview:mapView_];
    
    // Creates a marker in the center of the map.

 
    NSURL *url = [NSURL URLWithString:BaseURLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection)
    {
        getResponseData = [NSMutableData new];
    }

}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (void)profileEnter
{
    profileInfo *profile = [[profileInfo alloc] init];
    [self presentViewController:profile animated:YES completion:nil];
}

- (NSString *)deviceLocation
{
    NSString *theLocation = [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    
    
    return theLocation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - HTTP POST

-(void) connection:(NSURLConnection*) connetion didReceiveData:(NSData *)data
{
    [getResponseData appendData:data];
}

-(void) connection:(NSURLConnection*)connection didFailWithError:(NSError *)error
{
    NSLog(@"error: %@", [error localizedDescription]);
}

-(void) connectionDidFinishLoading:(NSURLConnection*) connection
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:getResponseData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"return: %@", dict);
    dataClass = [DataClass getInstance];
    dataClass.parkingData = (NSArray*)dict;
    for (NSDictionary *dic in dataClass.parkingData) {
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([[[dic objectForKey:@"gpsCoordinate"] objectForKey:@"latitude"] doubleValue], [[[dic objectForKey:@"gpsCoordinate"] objectForKey:@"longitude"] doubleValue]);
        marker.title = [dic objectForKey:@"name"];
        marker.snippet = [NSString stringWithFormat:@"Total Places: %@ \nFree Places: %@",[dic objectForKey:@"totalPlaces"],[dic objectForKey:@"freePlaces"]];
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = mapView_;
    }
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    int i = 0;
    for (NSDictionary *dic in dataClass.parkingData) {
        if ([marker.title isEqualToString:[dic objectForKey:@"name"]]) {
            break;
        }
        i++;
    }
    dataClass.index = i;
    ParkInfo *parkInfo = [[ParkInfo alloc] init];
    [self presentViewController:parkInfo animated:YES completion:nil];

    //info window tapped
}
@end
