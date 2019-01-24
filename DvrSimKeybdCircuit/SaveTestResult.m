TestResult.Time=Time;TestResult.ACCReqSt=ACCReqSt;TestResult.ACCReqVa=ACCReqVa;
TestResult.ACCSysSt=ACCSysSt;TestResult.AEBReqSt=AEBReqSt;TestResult.AEBReqVa=AEBReqVa;
TestResult.AEBSysSt=AEBSysSt;TestResult.AVz=AVz;TestResult.Ax=Ax;
TestResult.Ay=Ay;TestResult.CanclSw=CanclSw;TestResult.DisDecSw=DisDecSw;
TestResult.DisIncSw=DisIncSw;TestResult.LockedID=LockedID;TestResult.LockedVx=LockedVx;
TestResult.LockedX=LockedX;TestResult.LockedY=LockedY;TestResult.MemSpd=MemSpd;
TestResult.OnSw=OnSw;TestResult.RsmSw=RsmSw;TestResult.SetSpd=SetSpd;
TestResult.SetSw=SetSw;TestResult.SpdDecSw=SpdDecSw;TestResult.SpdIncSw=SpdIncSw;
TestResult.Steer_SW=Steer_SW;TestResult.StrAV_SW=StrAV_SW;TestResult.ToqReqSt=ToqReqSt;
TestResult.ToqReqVa=ToqReqVa;TestResult.T_Stamp=T_Stamp;TestResult.Vx=Vx;
save('TestResult.mat','-struct','TestResult')
% save('Testresults.mat','Time','ACCReqSt','ACCReqVa','ACCSysSt','AEBReqSt','AEBReqVa','AEBSysSt','AVz','Ax','Ay','CanclSw','DisDecSw','DisIncSw','LockedID','LockedVx','LockedX','LockedY','MemSpd','OnSw','RsmSw','SetSpd','SetSw','SpdDecSw','SpdIncSw','Steer_SW','StrAV_SW','ToqReqSt','ToqReqVa','T_Stamp','Vx')