Tstep=0.001;

ratioGearF  = 1;
 ratioGearR  = 1;
 JMotor1     = 0.0018; %惯量
 BMotor1     = 3.2e-4; %阻尼
 Delay1      = 0.0015; %延时
 MaxPower1   = 86000; %最大功率86KW
 MaxTorque1  = 255; %最大扭矩
 
 JMotor2     = 0.0018; %惯量
 BMotor2     = 3.2e-4; %阻尼
 Delay2      = 0.0015; %延时
 MaxPower2   = 53000; %最大功率86KW
 MaxTorque2  = 155; %最大扭矩
 
 Tmax  = MaxTorque2 + 2*MaxTorque1; %四驱最大扭矩
 TmaxR = MaxTorque2 + MaxTorque1;   %后驱最大扭矩
 
 PControlB = 90;      %D档，Ax制动控制P
 IControlB = 0.0005;  %D档，Ax制动控制I
 DControlB = 0.0008;  %D档，Ax制动控制D

 BrkDelayTime  = 0; %实际减速度相对期望减速度延时时间
 TorqDelayTime = 0; %实际扭矩相对期望扭矩延时时间