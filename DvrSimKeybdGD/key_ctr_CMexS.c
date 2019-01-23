/*  file name : key_ctr_CMexS.c
%============================================================================================
% The CMex S function can control the carsim live video simulation
 * Used as Matlab S function in Simulink
 * Needs Carsim 2016 later and carsim DS package
 *  Actions:
 *
 *      W-------------------forward
 *      S-------------------brake
 *      A-------------------turning left
 *      D-------------------turning right
 *      O-------------------On/Off
 *      Enter---------------Set
 *      X-------------------Cancel
 *      R-------------------Resume
 *      uparrow-------------SpdInc
 *      downarrow-----------SpdDec
 *      leftarrow-----------DisInc
 *      rightarrow----------DisDec
 *
 *  Outputs:
 *      throttle
 *      angle
 *      brake
 *      On
 *      Set
 *      Cancel
 *      Resume
 *      SpdInc
 *      SpdDec
 *      DisInc
 *      DisDec
%============================================================================================

%============================================================================================
%   2017-08-17	MH   Created
 *  2017-08-20	MH   Replaced kbhit()/getch() by GetAsyncKeyState();
 *  2017-08-23	MH   Changed speed to throttle to accommdate carsim simulation
 *            	MH   When uparrow/forward or leftarrow/rightarrow released, set throttle 
 *                   or angle to zero
 *  2017-08-24  MH   Added brake as the third discrete state
 *                   Added Shift [N R 1-7] as the fourth discrete state
 *  2017-08-25  MH   Added threshold for throttle; when throttle > threshold, smaller accel.
 *                   Speed acceleration then became more gentlely.
 *                   Added angle offset so that the switch between left turn and right turn
 *                   became more faster and experienced less delay
 *  2019-01-14  CX   delete gear part for EP21 Use
 *                   add 8 ADAS driver inputs
 *                   changed the angle calculation logic
%============================================================================================
*/

#define S_FUNCTION_NAME key_ctr_CMexS
#define S_FUNCTION_LEVEL 2

#define     Left                0x41   //Press A
#define     Right               0x44   //Press S  
#define     Forward             0x57   //Press W
#define     Brake               0x53   //Press D

#define     On                  0x4F   //Press O
#define     Set                 0xD   //Press Enter
#define     Cancel              0x58   //Press X
#define     Resume              0x52   //Press R

#define     SpdInc              0x26   //Press uparrow
#define     SpdDec              0x28   //Press downarrow
#define     DisInc              0x27   //Press rightarrow
#define     DisDec              0x25   //Press leftarrow

//#define     shift_up            0x41    //Press A
//#define     shift_down          0x5A    //Press Z
//#define     gear_max            7       // max.# of gear
//#define     gear_min            -1      // min.#(reverse) gear

#define     ang_accel           0.4       //turning left decel.
#define     ang_decel           -0.4      //turning right accel.
#define     ang_left_max        120      //max. degree of left turn
#define     ang_right_max       -120     //max. degree of right turn
#define     ang_accel_r2l       0.4     //right-turn to left-turn, turn faster(angle offset)
#define     ang_decel_l2r       -0.4     //left-turn to right-turn, turn faster(angle offset)

#define     throt_limit_up      1       //upper limitation of throttle
#define     throt_limit_lo      0       //lower limitation of throttle
#define     throt_accel         0.0025    //throttle up accel.
#define     throt_accel_slow    0.001   //throttle up accel. when throttle > threshold
#define     throt_thre          0.25     //threshold for changing throt accel

#define     brk_accel           0.02       //brake accel
#define     brk_limit           10      //limitation of brake pressure

#include "simstruc.h"

#include <stdio.h>
#include <conio.h>

static void UpdateVehicle(SimStruct *S, int_T tid);

/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 11);

    if (!ssSetNumInputPorts(S, 0)) return;
    
    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, 11);

    ssSetNumSampleTimes(S, 1);  /* Set number of sampling time */
    ssSetNumRWork(S, 0);    /* Set real work dimension */
    ssSetNumIWork(S, 0);    /* Set integer work dimension */
    ssSetNumPWork(S, 0);    /* Set pointer work dimension */
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    Specify the sample time as 1.0
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, 0.005);
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);      
}

#define MDL_INITIALIZE_CONDITIONS
/* Function: mdlInitializeConditions ========================================
 * Abstract:
 *    Initialize both discrete states to zero.
 */
static void mdlInitializeConditions(SimStruct *S)
{
    real_T *x0 = ssGetRealDiscStates(S);
    int_T  lp;

    for (lp=0;lp<11;lp++) { 
        *x0++=0; 
    }
}


#define MDL_OUTPUTS
/* Function: mdlOutputs ================================================== */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T            *y    = ssGetOutputPortRealSignal(S,0);
    real_T            *x    = ssGetRealDiscStates(S);

    UpdateVehicle(S, tid);    
   // printf("Throttle is %f ; Angle is %f; Brake pressure is %f; Shift is %f\n", \
           // x[0], x[1], x[2], x[3]);
    
    y[0]=x[0];  /* Output x[0] i.e. throttle */
    y[1]=x[1];  /* Output x[1] i.e. angle */
    y[2]=x[2];  /* Output x[2] i.e. brake pressure */
    y[3]=x[3];  /* On */
    y[4]=x[4];  /* On */
    y[5]=x[5];  /* On */
    y[6]=x[6];  /* On */
    y[7]=x[7];  /* On */
    y[8]=x[8];  /* On */
    y[9]=x[9];  /* On */
    y[10]=x[10];  /* On */

}



#define MDL_UPDATE
/* Function: mdlUpdate ==================================================*/
static void mdlUpdate(SimStruct *S, int_T tid)
{

}



/*==========================================================================================
% The function can control the self-addition/substraction of four variables (Throttle, angle,
 *  brake, and gear number)
% This function is forked from key_ctr_MatlabS.m in this folder
% Use GetAsyncKeyState() to read keyboard input; it reads the CAPTAL letter of keyboard
% i.e.A,B,C...
% ASCII code refers to Key_board_info.txt or windows.h.
%==========================================================================================*/

static void UpdateVehicle(SimStruct *S, int_T tid)
{
    real_T *x    = ssGetRealDiscStates(S);
    
    real_T throttle = x[0];
    real_T angle = x[1];
    real_T brake_pressure = x[2];
    real_T OnVal = x[3];
    real_T SetVal = x[4];
    real_T CancelVal = x[5];
    real_T ResumeVal = x[6];
    real_T SpdIncVal = x[7];
    real_T SpdDecVal = x[8];
    real_T DisIncVal = x[9];
    real_T DisDecVal = x[10];
    
    char key;
    if (GetAsyncKeyState(On))
    {
        OnVal = 1;
    }
    else
    {
        OnVal = 0;
    }
    if (GetAsyncKeyState(Set))
    {
        SetVal = 1;
    }
    else
    {
        SetVal = 0;
    }
    if (GetAsyncKeyState(Cancel))
    {
        CancelVal = 1;
    }
    else
    {
        CancelVal = 0;
    }
    if (GetAsyncKeyState(Resume))
    {
        ResumeVal = 1;
    }
    else
    {
        ResumeVal = 0;
    }
    if (GetAsyncKeyState(SpdInc))
    {
        SpdIncVal = 1;
    }
    else
    {
        SpdIncVal = 0;
    }
    if (GetAsyncKeyState(SpdDec))
    {
        SpdDecVal = 1;
    }
    else
    {
        SpdDecVal = 0;
    }
    if (GetAsyncKeyState(DisInc))
    {
        DisIncVal = 1;
    }
    else
    {
        DisIncVal = 0;
    }
    if (GetAsyncKeyState(DisDec))
    {
        DisDecVal = 1;
    }
    else
    {
        DisDecVal = 0;
    }   
    
    /* A moving control key is pressed ================================================== */
    if (GetAsyncKeyState(Left)||GetAsyncKeyState(Right)\
            ||GetAsyncKeyState(Forward)||GetAsyncKeyState(Brake))     
    {
        /* Determin operation modes based on keyboard input */
        if (GetAsyncKeyState(Left))
        {
            key = Left;
        }
        else if (GetAsyncKeyState(Right))
        {
            key = Right;
        }
        else if (GetAsyncKeyState(Forward))
        {
            key = Forward;
        }
        else if (GetAsyncKeyState(Brake))
        {
            key = Brake;
        }   
        
        /* Take actions based on keyboard entry */
        switch (key)
        {
            /* Determining angle value of the vehicle; [-180 0] turning right, [0 180] turning left. */
            /* Turning left ========================================================= */
            case Left:  /* leftarrow is pressed */
                // if previous state is right-turn, turn to left faster
                if (angle < 0)      
                {
                   angle = angle + ang_accel_r2l; 
                }
                else
                {
                    angle = angle + ang_accel;
                }
                                    
                if (angle > ang_left_max)
                {
                    angle = ang_left_max;
                }
                /* Left and forward */
                if (GetAsyncKeyState(Forward)) /* uparrow is pressed */
                {
                    if (throttle < throt_thre)
                    {
                        throttle = throttle + throt_accel;
                    }
                    // change throttle accel. when theorrle > threshold
                    else
                    {
                        throttle = throttle + throt_accel_slow;
                    }

                    if (throttle > throt_limit_up)
                    {
                        throttle = throt_limit_up;
                    }
                }
                /* Left and backward */
                else if (GetAsyncKeyState(Brake)) /* downarrow is pressed */
                {
                    brake_pressure = brake_pressure + brk_accel;
                    if (brake_pressure > brk_limit)
                    {
                        brake_pressure = brk_limit;
                    }                            
                }
                break;
            /* Turning right ========================================================= */
            case Right: /* rightarrow is pressed */
                // if previous state is left-turn, turn to right faster
                if (angle > 0)      
                {
                   angle = angle + ang_decel_l2r; 
                }
                else
                {
                    angle = angle + ang_decel;
                }
                
                if (angle < ang_right_max)
                {
                    angle = ang_right_max;
                }
                /* Determin if up/down is pressed */
                /* Right and forward */
                if (GetAsyncKeyState(Forward)) /* uparrow is pressed */
                {
                    if (throttle < throt_thre)
                    {
                        throttle = throttle + throt_accel;
                    }
                    // change throttle accel. when theorrle > threshold
                    else
                    {
                        throttle = throttle + throt_accel_slow;
                    }
                    
                    if (throttle > throt_limit_up)
                    {
                        throttle = throt_limit_up;
                    }
                }
                /* Left and backward */
                else if (GetAsyncKeyState(Brake)) /* downarrow is pressed */
                {
                    brake_pressure = brake_pressure + brk_accel;
                    if (brake_pressure > brk_limit)
                    {
                        brake_pressure = brk_limit;
                    }                            
                }
                break;
            /*% Determining throttle value of the vehicle; throttle belongs [0 1]. 
            % when upkey is pressed, the throttle increases up to 1.
            % Acceleration========================================================= */
            case Forward: /* uparrow is pressed */
                
                if (throttle < throt_thre)
                {
                    throttle = throttle + throt_accel;
                }
                // change throttle accel. when theorrle > threshold
                else
                {
                    throttle = throttle + throt_accel_slow;
                }
                
                if (throttle > throt_limit_up)
                {
                    throttle = throt_limit_up;
                }
                /* Determin if right/left is pressed */
                /* Right and forward */
                if (GetAsyncKeyState(Right)) /* rightarrow is pressed */
                {
                    // if previous state is left-turn, turn to right faster
                    if (angle > 0)      
                    {
                       angle = angle + ang_decel_l2r; 
                    }
                    else
                    {
                        angle = angle + ang_decel;
                    }
                    
                    if (angle < ang_right_max)
                    {
                        angle = ang_right_max;
                    }
                }
                /* Left and forward */
                if (GetAsyncKeyState(Left)) /* leftarrow is pressed */
                { 
                    // if previous state is right-turn, turn to left faster
                    if (angle < 0)      
                    {
                       angle = angle + ang_accel_r2l; 
                    }
                    else
                    {
                        angle = angle + ang_accel;
                    }
                    
                    if (angle > ang_left_max)
                    {
                        angle = ang_left_max;
                    }                  
                }                
                break;
            /* Deceleration/backward=============================================== */
            case Brake:  /* downarrow/brake is pressed */
                brake_pressure = brake_pressure + brk_accel;
                if (brake_pressure > brk_limit)
                {
                    brake_pressure = brk_limit;
                }
                /* Determin if right/left is pressed */
                    /* Right and forward */
                if (GetAsyncKeyState(Right)) /* rightarrow is pressed */
                {
                    // if previous state is left-turn, turn to right faster
                    if (angle > 0)      
                    {
                       angle = angle + ang_decel_l2r; 
                    }
                    else
                    {
                        angle = angle + ang_decel;
                    }
                    
                    if (angle < ang_right_max)
                    {
                        angle = ang_right_max;
                    }
                }
                /* Left and forward */
                if (GetAsyncKeyState(Left)) /* leftarrow is pressed */
                {
                    // if previous state is right-turn, turn to left faster
                    if (angle < 0)      
                    {
                       angle = angle + ang_accel_r2l; 
                    }
                    else
                    {
                        angle = angle + ang_accel;
                    }
                    
                    if (angle > ang_left_max)
                    {
                        angle = ang_left_max;
                    }
                } 
                break;
        }   
    }
    /* up/down/left/right is released ============================================================== 
       when up/down is released, the throttle is set to zero. */  
    if (!GetAsyncKeyState(Forward))
    {        
        throttle = 0;
    }

    if (!GetAsyncKeyState(Brake))
    {
        brake_pressure = 0;
    }
     
    x[0] = throttle;
    x[1] = angle;
    x[2] = brake_pressure;
    x[3] = OnVal;
    x[4] = SetVal;
    x[5] = CancelVal;
    x[6] = ResumeVal;
    x[7] = SpdIncVal;
    x[8] = SpdDecVal;
    x[9] = DisIncVal;
    x[10] = DisDecVal;
}
    


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
    UNUSED_ARG(S); /* unused input argument */
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
