
//  Space-Plane Basic


// ag1 must be engine mode toggle
//  stage 1: main atmo thrusters
//  stage 2: activates orbital maneuvering thrusters 

// flight parameters

set targetApoapsis to 100000.
set targetPeriapsis to 100000.
set Isp to 305.                        //ISP in vacuum for circularization engines   *305 rapier 

//Init
set trgHeading to (90.1000000000000).
set targetPitch to (-5).
set tme to 0.
set srtTme to TIME:SECONDS.
set modeDis to "Spin Up".
set pAirSpd to 0.
set deltaV to 0.
set burnTme to 0.


RCS off.
lights off.
lock throttle to 0.
sas off.
gear on.
abort off.

set STEERINGMANAGER:MAXSTOPPINGTIME to 2.
set STEERINGMANAGER:PITCHPID:KD to (5).
set STEERINGMANAGER:YAWPID:KD to (1).
set STEERINGMANAGER:ROLLPID:KD to (1).
set STEERINGMANAGER:PITCHTS to (0.25).
set STEERINGMANAGER:ROLLTS to (2).
set STEERINGMANAGER:YAWTS to (1).

set runmode to 1.

until runmode = 0 {


    if runmode = 1 {

        stage.
        lock steering to heading(trgHeading, 0).
        lock throttle to 1.
        brakes on.
        wait 10.
        brakes off.
        set srtTme to TIME:SECONDS.
        set runmode to 2.
        set modeDis to "Takeoff".

    }
    else if runmode = 2 {

        if SHIP:AIRSPEED > 145 {

            set targetPitch to 10.
        }
        else {

            set targetPitch to (SHIP:FACING:PITCH - 5).
        }

        if ALT:RADAR > 5 and (gear) {

            set trgHeading to (91.0000).
            gear off.
        }

        if SHIP:AIRSPEED > 300 {

            set runmode to 3.
            set modeDis to "Initial Climb".
        }

    }
    else if runmode = 3 {

        if SHIP:AIRSPEED > 310 and ALT:RADAR < 5900 {

            set targetPitch to (targetPitch + 0.01).

        }
        else if SHIP:AIRSPEED < 300 and ALT:RADAR < 5900 {

            set targetPitch to (targetPitch - 0.01).

        }

        if ALT:RADAR > 6000 and targetPitch > 10 {

            set targetPitch to 10.

        }

        if SHIP:AIRSPEED > 301 and ALT:RADAR > 5900 and targetPitch = 10 {

            set targetPitch to -10.
            set runmode to 4.
            set modeDis to "Mach Dive".

        }

    }
    else if runmode = 4 {

        if SHIP:AIRSPEED > 560 {

            set runmode to 5.
            set STEERINGMANAGER:MAXSTOPPINGTIME to (0.04).
            set STEERINGMANAGER:PITCHPID:KD to (1).
            set modeDis to "Mach Turn".


        }
        

    }
    else if runmode = 5 {

         if SHIP:AIRSPEED > 570 and targetPitch < 20 {

            set targetPitch to (targetPitch + 0.05).

        }
        else if SHIP:AIRSPEED < 560 and targetPitch < 20 {

            set targetPitch to (targetPitch - 0.05).

        }


        if pAirSpd > SHIP:AIRSPEED and ALT:RADAR > 8000 {

            set runmode to 6.
            set modeDis to "Apo Raise".
            set targetPitch to 45.
            ag1 on.

        }

        set pAirSpd to SHIP:AIRSPEED.

    }
    else if runmode = 6 {
        

        if SHIP:APOAPSIS > (targetApoapsis + 1000) {

            lock throttle to 0.
            unlock steering.
            set STEERINGMANAGER:MAXSTOPPINGTIME to (2).  //
            set STEERINGMANAGER:PITCHTS to (3).
            sas on.
            stage.
            wait 1.
            set sasmode to "PROGRADE".
            set runmode to 7.
            set modeDis to "Calculate Burn".

        }

    }
    else if runmode = 7 {
        
        set deltaV to (2246.1 - velocityat(SHIP, ETA:APOAPSIS + TIME):ORBIT:MAG).

        set massKg to (SHIP:MASS * 1000).
        set brnMassFnl to ((massKg)/(CONSTANT:E^(SHIP:AIRSPEED/(Isp * 9.81)))).

        set acelI to ((SHIP:MAXTHRUST * 1000) / massKg).
        set acelF to ((SHIP:MAXTHRUST * 1000) / brnMassFnl).
        set burnTme to (deltaV / ((acelI + acelF) / 2)).

        if SHIP:ALTITUDE > 70000 {

            sas off.
            lock steering to heading(trgHeading, 0).
            set targetPitch to 0.
            set STEERINGMANAGER:MAXSTOPPINGTIME to (5).
            set STEERINGMANAGER:PITCHPID:KD to (3).

            if ETA:APOAPSIS < (burnTme/2) {


                lock throttle to 1.
                set runmode to 8.
                set modeDis to "Curcularize Burn".


            }


        }

    }
    else if runmode = 8 {


        if SHIP:PERIAPSIS > (targetPeriapsis - 2000) {

            lock throttle to 0.
            ag9 on.
            ag10 on.
            set runmode to 0.

        }


    }
    



    update().
    prnt().

}


function update {

    if runmode < 6 {

        lock steering to heading(trgHeading, (targetPitch + 5)).

    }

    set tme to (TIME:SECONDS - srtTme).


}

function prnt {

    clearscreen.

    
    print "T+ SECONDS:    " + ROUND(tme, 2) at (0,2).
    print "Mode:          " + runmode + ": " + modeDis at (0,3).

    print "Target Pitch:  " + ROUND(targetPitch, 2) at (0,5).

    print "Apoapsis:      " + ROUND(SHIP:APOAPSIS, 2) at (0,7).
    print "Delta V est:   " + ROUND(deltaV, 2) at (0,8). 
    print "Burn Time:     " + ROUND(burnTme, 2) at (0,9).
}
