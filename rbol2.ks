
// Code for Falcon 4 Upper stage

set uSMass to 27.   // Mass of upper stage  (round up)
set runmode2 to 1.
set init to false.


until runmode2 = 0 {

    if SHIP:MASS < uSMass {

        if init = false {

            lock throttle to (0.2).
            wait 1.
            lock throttle to 0.
            Lock Steering to heading(90, 0).
            wait 4.
            lock throttle to 1.
            set init to true.

        }

        if SHIP:PERIAPSIS > 80000 {

            set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
            set runmode2 to 0.
            ag9 on.
            ag10 on.

        }
      
    } 

}
