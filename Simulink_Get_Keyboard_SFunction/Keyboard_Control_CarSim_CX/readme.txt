modified by CX from Hemu

use the "Keyboard Input" function "GetAsyncKeyState" to get the driver's input

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
 
 if no change needed, directly use the mex64 file in Sfuntion in simulink
 
 you can alse change the keyboard mapping in the .c file and then mex it in matlab.