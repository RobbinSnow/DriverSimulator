Tstep=0.001;

ratioGearF  = 1;
 ratioGearR  = 1;
 JMotor1     = 0.0018; %����
 BMotor1     = 3.2e-4; %����
 Delay1      = 0.0015; %��ʱ
 MaxPower1   = 86000; %�����86KW
 MaxTorque1  = 255; %���Ť��
 
 JMotor2     = 0.0018; %����
 BMotor2     = 3.2e-4; %����
 Delay2      = 0.0015; %��ʱ
 MaxPower2   = 53000; %�����86KW
 MaxTorque2  = 155; %���Ť��
 
 Tmax  = MaxTorque2 + 2*MaxTorque1; %�������Ť��
 TmaxR = MaxTorque2 + MaxTorque1;   %�������Ť��
 
 PControlB = 90;      %D����Ax�ƶ�����P
 IControlB = 0.0005;  %D����Ax�ƶ�����I
 DControlB = 0.0008;  %D����Ax�ƶ�����D

 BrkDelayTime  = 0; %ʵ�ʼ��ٶ�����������ٶ���ʱʱ��
 TorqDelayTime = 0; %ʵ��Ť���������Ť����ʱʱ��