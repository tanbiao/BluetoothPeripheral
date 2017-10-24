//
//  ViewController.m
//  蓝牙外设
//
//  Created by 谭彪 on 2017/10/20.
//  Copyright © 2017年 谭彪. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define SERVICE_UUID @"CDD1"
#define CHARACTERISTIC_UUID @"CDD2"

@interface ViewController ()<CBPeripheralManagerDelegate>

/*蓝牙外部设备管理者*/
@property(nonatomic,strong)  CBPeripheralManager *peripheralManager;

@property (weak, nonatomic) IBOutlet UITextField *sendTextF;

@property (weak, nonatomic) IBOutlet UITextField *readTextf;


@property(nonatomic,strong) CBMutableCharacteristic *characteristics;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"蓝牙外设";
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    
}

-(void)setupServiceAndCharacteristics
{
    CBMutableCharacteristic *characteristics = [
                                                [CBMutableCharacteristic alloc]
                                                initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_UUID]
                                                properties:
                                                CBCharacteristicPropertyRead |
                                                CBCharacteristicPropertyWrite |
                                                CBCharacteristicPropertyNotify
                                                value:nil
                                                permissions:CBAttributePermissionsReadable |
                                                CBAttributePermissionsWriteable
                                                ];
    
    self.characteristics = characteristics;
    
    CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICE_UUID] primary:YES];
    
    service.characteristics = @[characteristics];
    
    [self.peripheralManager addService:service];

}

- (IBAction)sendData:(UIButton *)sender
{

    BOOL sendSuccess = [self.peripheralManager updateValue:[self.sendTextF.text dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.characteristics onSubscribedCentrals:nil];
    
    if (sendSuccess)
    {
        NSLog(@"数据发送成功");
    }else {
        NSLog(@"数据发送失败");
    }
    
}

- (IBAction)readData:(UIButton *)sender
{
    
    
    
}


#pragma mark - CBPeripheralManagerDelegate

/*外部设备管理者设置代理就会来到这个方法*/
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    /*	CBManagerStateUnknown = 0,
     CBManagerStateResetting,
     CBManagerStateUnsupported,
     CBManagerStateUnauthorized,
     CBManagerStatePoweredOff,
     CBManagerStatePoweredOn,
     */
    switch (peripheral.state)
    {
        case CBManagerStateUnknown:
            NSLog(@"状态未知");
            break;
            
        case CBManagerStateResetting:
            NSLog(@"蓝牙状态重置");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"不支持蓝牙");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"蓝牙未授权");
            break;
            
        case CBManagerStatePoweredOff:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"蓝牙关闭"preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            [alert addAction:cancel];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            NSLog(@"蓝牙关闭");
        }
            break;
        case CBManagerStatePoweredOn:
            
            [self setupServiceAndCharacteristics];
            
            // 根据服务的UUID开始广播,如果没有广播,蓝牙中心收不到对应的服务
            [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:SERVICE_UUID]]}];

            NSLog(@"蓝牙状态开启,可以使用");
            
            break;
    }

}



/*收到获取数据*/
-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    // 请求中的数据，这里把文本框中的数据发给中心设备
    request.value = [self.sendTextF.text dataUsingEncoding:NSUTF8StringEncoding];
    // 成功响应请求
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    NSLog(@"%s",__FUNCTION__);

}

/*收到写数据的请求*/
-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    // 写入数据的请求
    CBATTRequest *request = requests.lastObject;
    // 把写入的数据显示在文本框中
    self.readTextf.text = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];

   NSLog(@"%s",__FUNCTION__);

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(nullable NSError *)error
{

   NSLog(@"%s",__FUNCTION__);
}

/*设备中心订阅成功*/
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    
   NSLog(@"%s",__FUNCTION__);
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    [self.view endEditing:YES];
}



@end
