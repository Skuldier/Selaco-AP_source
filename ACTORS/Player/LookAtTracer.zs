class LookAtTracer : LineTracer {
    Actor firstUnuseableActor;
    Actor ignoredActor;
    Actor secondaryHit;         // The last actor that was hit, which was not priority 1
    
    const breakableGlassScript = -int('BreakableGlass3');

    // We are looking for interactable objects such as linedefs or actors
    // The only struggle is skipping unnecessary linedefs
    override ETraceStatus TraceCallback() {
        if(Results.HitType == TRACE_HitFloor || Results.HitType == TRACE_HitCeiling) { 
            Results.HitType = TRACE_HitNone; 
            return TRACE_Abort;
        }

        // Linedefs
        if(Results.HitType == TRACE_HitWall) {
            // Line blocks USE commands
            if(Results.HitLine.Flags & (Line.ML_BLOCKUSE | Line.ML_BLOCKEVERYTHING | Line.ML_BLOCKING)) {
                if(Results.HitLine.Special == 0) {
                    return TRACE_Abort;  // Cancel if this line does nothing
                } else if(Results.HitLine.flags & Line.ML_CHECKSWITCHRANGE || !(Results.HitLine.Activation & (SPAC_UseThrough | SPAC_Use | SPAC_UseBack))) {
                    return TRACE_Abort;  // Cancel if unusable
                } else if(!(Results.HitLine.Activation & SPAC_UseBack) && Results.Side != Line.front) {
                    return TRACE_Abort;  // Cancel if on back-side
                }

                return TRACE_Stop;
            }

            // Special case for breakable glass
            if((Results.HitLine.Special == 49 || Results.HitLine.Special == 84) && Results.HitLine.args[0] == breakableGlassScript) {
                return TRACE_Stop;
            }

            // Middle of line requires more testing
            if(Results.Tier == TIER_Middle && !(Results.HitLine.flags & Line.ML_BLOCKING)) {
                if(Results.HitLine.Special == 0) {
                    return TRACE_Skip;  // Skip if this line is activateable but does nothing
                } else if(Results.HitLine.flags & Line.ML_CHECKSWITCHRANGE || !(Results.HitLine.Activation & (SPAC_UseThrough | SPAC_Use | SPAC_UseBack))) {
                    return TRACE_Skip;  // Skip if unusable
                } else if(!(Results.HitLine.Activation & SPAC_UseBack) && Results.Side != Line.front) {
                    return TRACE_Skip;  // Skip if useable but backside
                }
            } else if(Results.HitLine.Special == 0 || !(Results.HitLine.Activation & (SPAC_UseThrough | SPAC_Use | SPAC_UseBack)) || !(Results.HitLine.Activation & SPAC_UseBack) && Results.Side != Line.front) {
                return TRACE_Abort;
            }
        }


        // Actors
        if(Results.HitType == TRACE_HitActor) {
            if(Results.HitActor == null) {
                S_StartSound("weaponwheel/selection", CHAN_UI, CHANF_UI, volume: 4);   // wetfart
                S_StartSound("weaponwheel/selection", CHAN_AUTO);
                S_StartSound("weaponwheel/selection", CHAN_AUTO);
                Console.Printf("\c[YELLOW]LOOKAT TRACER Somehow looked at a NULL Actor. Is something broken?");
                return TRACE_Skip;  // Avoid a null pointer crash, this scenario is not ideal
            }

            // Skip the player
            if(Results.HitActor == players[consolePlayer].mo || Results.HitActor == ignoredActor) return TRACE_Skip;

            // Return activateable actors, otherwise skip
            if(Results.HitActor.activationtype & (AF_Activate | AF_Deactivate | AF_Switch)) {
                // Ignore ladders when the player is already on one
                if(Results.HitActor is 'LadderUsable') {
                    if(Dawn(players[consolePlayer].mo).curLadder || !LadderUsable(Results.HitActor).dawnCanUseLadder(Dawn(players[consolePlayer].mo))) return TRACE_Skip;
                    secondaryHit = Results.HitActor;
                    return TRACE_Skip;
                }
                
                let act = SelacoActor(Results.HitActor);
                if(act && act.bUsable) {
                    return act.CanInteractFrom(players[consolePlayer].mo, Results.HitPos) ? TRACE_Stop : TRACE_Skip;
                }

                return TRACE_Stop;
            } else {
                if(!firstUnuseableActor) {
                    firstUnuseableActor = Results.HitActor;
                }
                return TRACE_Skip;
            }
        }

		return TRACE_Stop; // Return STOP ends the raycast with the last hit object/line
	}


    // I haven't found a function for this yet, I hate to have to do it manually
    static clearscope Vector3 VecFromAngle(double yaw, double pitch, double length = 1.0) {
        Vector3 r;

        double hcosb = cos(pitch);
        r.x = cos(yaw) * hcosb;
        r.y = sin(yaw) * hcosb;
        r.z = -sin(pitch);

        return r * length;
    }
}