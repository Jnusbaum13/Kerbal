

set pidVirt to PIDLOOP(1, 1, 1, -0.001, 0.001).
set pidAirSpd to PIDLOOP(1, 1, 1, -0.001, 0.001).
set pidHS to PIDLOOP(1, 1, 1, -0.001, 0.001).


function pidVertical {
 
    
    PARAMETER trgt, p is 1, i is 1, d is 1.




    set pidVirt:SETPOINT to trgt.
    set pidVirt:KP to p.
    set pidVirt:KI to i.
    set pidVirt:KD to d.


    set pidVirt:MAXOUTPUT to 0.005 * MAX(1, (pidVirt:ERROR / 2)).
    set pidVirt:MinOUTPUT to -0.005 * MAX(1, (pidVirt:ERROR / 2)).




    set out to pidVirt:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED).
    return (throttle + out).


}

function pidAirspeed {
 
    
    PARAMETER trgt, p is 1, i is 1, d is 1.




    set pidAirSpd:SETPOINT to trgt.
    set pidAirSpd:KP to p.
    set pidAirSpd:KI to i.
    set pidAirSpd:KD to d.


    set pidAirSpd:MAXOUTPUT to 0.005 * MAX(1, (pidAirSpd:ERROR / 2)).
    set pidAirSpd:MinOUTPUT to -0.005 * MAX(1, (pidAirSpd:ERROR / 2)).




    set out to pidAirSpd:UPDATE(TIME:SECONDS, SHIP:AIRSPEED).
    return (throttle + out).


}

function pidHoverSlam {
 
    
    PARAMETER trgt, p is 1, i is 1, d is 1, gain is 0.005.

    set pidHS:SETPOINT to trgt.
    set pidHS:KP to p.
    set pidHS:KI to i.
    set pidHS:KD to d.

    //set pidHS:MAXOUTPUT to 0.03 * MAX(1, (pidHS:ERROR / 2)).
    //set pidHS:MinOUTPUT to -0.03 * MAX(1, (pidHS:ERROR / 2)).

    set pidHS:MAXOUTPUT to gain * MAX(1, (pidHS:ERROR / 2)).
    set pidHS:MinOUTPUT to -gain * MAX(1, (pidHS:ERROR / 2)).




    set out to pidHS:UPDATE(TIME:SECONDS, ALT:RADAR).
    return (SHIP:CONTROL:PILOTMAINTHROTTLE + out).


}