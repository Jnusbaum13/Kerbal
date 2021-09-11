
// Flies to set altitude and then preforms hover slam landing



//**User Variables**

set trgtVel to 300.     // assending velocity

set drCo to (2.0).    // increse to stop later. (Probably constant)                                FLAT: 2.0        Cone: 0.8
set diameter to (2.5).   // rocket diameter                                                                          *2.5 Falcon 4
set isp to (281.7).    // weighted average of specific impulse (thrust percentage weight)                            *281.7 falcon 4
set rctHt to (4.78).         // height just above rocket on pad (alt radar on pad)   4.78                                *4.78 Falcon 4

set turn to true.  // if true, craft will preform gravity turn.
set trgHeading to 90.    // 90: EAST       0: NORTH
set maxPtch to 17. // Used for mag grav turn angle
set refAlt to 43000.   // Used for grav turn. increase to turn slower
set cutSpd to 1405.    // ajust to change downrange landing distance.  1455 *old

set thrtlStrt to (0.7). // increase to increase efficency but will reduce accuracy. Max 1.0 Min 0.7

//for accel calc
set aI to 0.
set aF to 0.
set accel to 0.
set drag to 0.
set radius to (diameter / 2).
set area to ((radius * radius) * CONSTANT:PI).
set massKg to 0.
set atm to KERBIN:ATM.
set calcBurn to false.
set burnAlt to 0.
set brnMassFnl to 0.
// for Landing burn Pid
set Lgain to 0.03.


// for accelCnt and rec

set aAve to 0.
set cnt to 0.
set aTot to 0.
set a to 0.

// for recVar
set recAAVE to 0.
set recAccel to 0.
set recAlt to 0.
set burnAltR to 0.

// safty sets
RCS off.
lights off.
set throttle to 0.
sas off.
abort off.
clearscreen.


//Initial variables
set runmode to 1.
runoncepath("0:/pd2.ks").
set srtTme to TIME:SECONDS.
set tme to 0.
set fairing to true. 
set mainCut to false.

// ajusting load distance   *wait between load and pack changes
SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:UNLOAD TO 40000.
SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:LOAD TO 39500.
WAIT 0.001. 
SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:PACK TO 39999.
SET KUNIVERSE:DEFAULTLOADDISTANCE:SUBORBITAL:UNPACK TO 39000.
WAIT 0.001. 

SET KUNIVERSE:DEFAULTLOADDISTANCE:ORBIT:UNLOAD TO 40000.
SET KUNIVERSE:DEFAULTLOADDISTANCE:ORBIT:LOAD TO 39500.
WAIT 0.001.  
SET KUNIVERSE:DEFAULTLOADDISTANCE:ORBIT:PACK TO 39999.
SET KUNIVERSE:DEFAULTLOADDISTANCE:ORBIT:UNPACK TO 39000.
WAIT 0.001.

until runmode = 0 {

    if runmode = 1 {

        if tme > 0 {

            lock steering to up.
            stage.
            set runmode to 2.
            accelCntR().
            lock throttle to 1.
        }
        
    }
    else if runmode = 2 {

        if tme > (0.1) {
            gear off.
        }

        if SHIP:AIRSPEED < cutSpd and mainCut = false {   // and mainCut = false

            //if ALT:RADAR < 8000 {

                //set throttle to pidAirspeed(300, 1, 1, 1). // all pids 1, 0, 1
            //}
            //else if ALT:RADAR < 30000 {
                
                //set throttle to pidAirspeed(850, 1, 1, 1).
            //}
            //else if ALT:RADAR < 35000 {

                //set throttle to pidAirspeed(1000, 1, 1, 1).
            //}
            //else {

                //set throttle to (1.0).
            //}

            if ALT:RADAR < 8000 {

                set throttle to pidAirspeed(300, 1, 1, 1).
            }
            else if SHIP:AIRSPEED > 750 {
                //0.02565  pidAirspeed(((0.02565 * ALT:RADAR) + 92.60905), 1, 1, 1)
                set throttle to MAX(0.4, pidAirspeed(((0.026 * ALT:RADAR) + 92.60905), 1, 1, 1)).
            }
            else {

                set throttle to 1.
            }

            if turn and (ALT:RADAR > 8000) {

                set targetPitch to max( maxPtch, 90 * (1 - ALT:RADAR / refAlt)).
                lock steering to heading( trgHeading, targetPitch).
            }
        }
        else {

            set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
            lock throttle to 0.
            unlock throttle.
            set mainCut to true.
        }

        if ALT:RADAR > 70000 and fairing = true {

            stage.
            set fairing to false.

        }


        if SHIP:VERTICALSPEED < 100 and tme > 40 {
            stage.
            set runmode to 3.
            accelCntR().
            unlock steering.
            sas on.
            wait 1.
            set sasmode to "RETROGRADE".
        }

    }
    else if runmode = 3 {

        if SHIP:ALTITUDE < 65000 {

            // starts calculating burn altitude
            set calcBurn to true.

            //if (ALT:RADAR - rctHt) <= burnAlt
            if ((ALT:RADAR - rctHt) <= burnAlt) and ALT:RADAR < 5000 {
            
                recVar(2).
                accelCntR().
                set burnAltR to burnAlt.
                set SHIP:CONTROL:PILOTMAINTHROTTLE to thrtlStrt.
                gear on.
                set runmode to 4.
            }

        }

        
    }
    else if runmode = 4 {

        set SHIP:CONTROL:PILOTMAINTHROTTLE to MAX(pidHoverSlam(burnAlt, 1, 1, 1, Lgain), 0.1).

        if SHIP:VERTICALSPEED > -2 {

            recVar(1).
            recVar(3).
            accelCntR().
            sas off.
            set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
            lock steering to up.
            set runmode to 5.
        }

        
    }
    else if runmode = 5 {

        set throttle to pidVertical(-8).

        if ALT:RADAR < (rctHt + 1) {

            sas on.
            rcs on.
            set throttle to 0.
            set runmode to 0.
        }
    } 
   
    update().
 
}




function update {


    set tme to (TIME:SECONDS - srtTme - 10).
    set massKg to (SHIP:MASS * 1000).
    set brnMassFnl to ((massKg)/(CONSTANT:E^(SHIP:AIRSPEED/(isp * 9.81)))).

    // attempts to calculate suicide burn altitude
    if calcBurn {

        set density to atm:ALTITUDEPRESSURE(ALT:RADAR) / (8.31 * atm:ALTITUDETEMPERATURE(ALT:RADAR)).
        set drag to ((density * (SHIP:AIRSPEED * SHIP:AIRSPEED) * area * drCo) / 2).

        if runmode > 3 {

            set aI to (((((SHIP:MAXTHRUST * SHIP:CONTROL:PILOTMAINTHROTTLE) * 1000) + drag) / massKg) - 9.81).
            set aF to ((((SHIP:MAXTHRUST * SHIP:CONTROL:PILOTMAINTHROTTLE) * 1000) / brnMassFnl) - 9.81).
           
        }
        else {

            set aI to (((((SHIP:MAXTHRUST * thrtlStrt) * 1000) + drag) / massKg) - 9.81).
            set aF to ((((SHIP:MAXTHRUST * thrtlStrt) * 1000) / brnMassFnl) - 9.81).
            
        }
        
        if (gear) {
            set accel to ((a + aF) / 2).
        }
        else {
            set accel to ((aI + aF) / 2).
        }
        set burnAlt to ((SHIP:AIRSPEED * SHIP:AIRSPEED) / (1 * accel)).

    }

    accelCnt().
    prnt().
}




function prnt {

    clearscreen.

    print "Game Time      " + TIME at (0,2).

    if tme < 0 {

        print "T- SECONDS:    " + ROUND(tme, 2) at (0,3).
    }
    else {

        print "T+ SECONDS:    " + ROUND(tme, 2) at (0,3).
    }
    print "Mode:          " + runmode  at (0,4).

    print "Altitude:      " + ROUND(ALT:RADAR - rctHt, 2) at (0,6).
    print "Velocity:      " + ROUND(SHIP:AIRSPEED, 2) at (0,7).
    
    print "Horz Speed:    " + ROUND(SHIP:GROUNDSPEED, 2) at (0,9).
    print "Vert Speed:    " + ROUND(SHIP:VERTICALSPEED, 2) at (0,8).
    print "Mass:          " + ROUND(massKg, 2) at (0,10).
    if runmode > 2 {

        print "Throttle       " + (ROUND(SHIP:CONTROL:PILOTMAINTHROTTLE , 2) * 100) + "%" at (0, 11).
    }
    else {

        print "Throttle       " + (ROUND(throttle , 2) * 100) + "%" at (0, 11).
    }

    print "burnAlt:       " + ROUND(burnAlt, 2) at (0,13).
    print "Aave:          " + ROUND(accel, 2) at (0,14).
    print "Af:            " + ROUND(aF, 2) at (0,15).
    print "Ai:            " + ROUND(aI, 2) at (0,16).
    print "Drag:          " + ROUND(drag, 2) at (0,17).
    
    print "Avr Accel:     " + ROUND(aAve, 2) at (0,19).
    print "Inst Accel:    " + ROUND(a, 2) at (0,20).

    print "Rc Exp a ave   " + ROUND(recAAVE , 2) at (0, 22).
    print "Rc Est a ave   " + ROUND(recAccel , 2) at (0, 23).
    print "Rc Fnl Alt     " + ROUND(recAlt , 2) at (0, 24).

    if runmode > 4 or runmode = 0 {

        print "Err a              " + ROUND(((ABS(recAAVE - recAccel) / recAAVE) * 100) , 2)  + "%" at (0, 26).
        print "Err Alt            " + ROUND((recAlt / burnAltR) * 100 , 2) + "%" at (0, 27).

    }


    //print "MAX Thrust: " + ROUND(SHIP:MAXTHRUST, 2) at (0,20).

    //print "" + ROUND( , 2) at (0, ).

}


function accelCnt {


    set a to SHIP:SENSORS:ACC:MAG.

    set aTot to (aTot + a).
    set cnt to (cnt + 1).
    set aAve to (aTot / cnt).


}


function accelCntR {

    set aTot to 0.
    set cnt to 0.
}


// records variable when run
function recVar {

    PARAMETER var.

    if var = 1 {  // Record aAve

        set recAAVE to aAve.
    }
    else if var = 2 {  // Record est accel

        set recAccel to accel.

    }
    else if var = 3 {  // Record brnStop alt

        set recAlt to (ALT:RADAR - rctHt).

    }

}

