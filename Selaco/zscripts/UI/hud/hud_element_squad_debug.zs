class HUDElementSquadDebug : HUDElementStartup {
    BattleOverseer overseer;
    bool showMe;

    override HUDElement init() {
        Super.init();

        overseer = BattleOverseer(EventHandler.Find("BattleOverseer"));
        showMe = iGetCVAR("AI_SHOWSQUADINFO") > 0;

        return self;
    }

    override void onAttached(HUD owner, Dawn player) {
        Super.onAttached(owner, player);

        overseer = BattleOverseer(EventHandler.Find("BattleOverseer"));
    }

    override bool tick() {
        if(!overseer) return true;

        if(ticks % 15 == 0) {
            showMe = iGetCVAR("AI_SHOWSQUADINFO") > 0;
        }

        return Super.tick();
    }

    const LINE_HEIGHT = 40;
    const LINE_HEIGHT_2 = 20;

    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        if(!overseer || !showMe) return;

        Vector2 pos = (-550, 100);

        Font fnt = "SEL21FONT";
        Font fnt2 = "PDA16FONT";

        
        DrawStr(fnt, "Squad Info", pos, DR_SCREEN_RIGHT, Font.CR_UNTRANSLATED, alpha, false, scale: (1, 1));
        pos.y += LINE_HEIGHT;

        DrawStr(fnt2, String.Format("Num Squads: %d", overseer.squads.size()), pos, DR_SCREEN_RIGHT, Font.CR_UNTRANSLATED, alpha, false, scale: (1, 1));
        pos.y += LINE_HEIGHT_2;

        DrawStr(fnt2, String.Format("Free Agents: %d", overseer.freeAgents.size()), pos, DR_SCREEN_RIGHT, Font.CR_UNTRANSLATED, alpha, false, scale: (1, 1));
        pos.y += LINE_HEIGHT_2;
        pos.y += LINE_HEIGHT;


        // Draw each squad
        for(int x = 0; x < overseer.squads.size(); x++) {
            BattleSquad squad = overseer.squads[x];
            if(!squad) continue;
            
            DrawStr(fnt, String.Format("\c[%s]Squad %d [%s] %s", squad.wiped ? "RED" : "GREEN", x, squad.name, squad.wiped ? "WIPED" : ""), pos, DR_SCREEN_RIGHT, Font.CR_UNTRANSLATED, alpha, false, scale: (1, 1));
            
            // Draw vision icon if squad knows player location
            if(!squad.wiped && squad.playerPositionKnown) DrawImgAdvanced("EYE1A0", pos - (20, 0), DR_SCREEN_RIGHT | DR_IMG_RIGHT | DR_NO_SPRITE_OFFSET);
            pos.y += LINE_HEIGHT;

            if(squad.wiped) continue;

            DrawStr(fnt2, String.Format("Time: %d", (level.time - squad.squadInitTime) / 35), pos, DR_SCREEN_RIGHT, Font.CR_UNTRANSLATED, alpha, false, scale: (1, 1));
            pos.y += LINE_HEIGHT_2;

            DrawStr(fnt2, String.Format("Last Saw Dawn: %d", (level.time - squad.playerLastKnownPosTime) / 35), pos, DR_SCREEN_RIGHT, Font.CR_UNTRANSLATED, alpha, false, scale: (1, 1));
            pos.y += LINE_HEIGHT_2;

            // Determine status
            string statusText = "Unknown";
            switch(squad.squadStatus) {
                case SQUAD_Idle:
                    statusText = "\c[GREEN]Idle";
                    break;
                case SQUAD_Chase:
                    statusText = "\c[RED]Chasing";
                    break;
                case SQUAD_WillPatrol:
                    statusText = String.Format("\c[YELLOW]Will Patrol - %d", (squad.PATROL_AFTER * TICRATE) - (level.time - squad.patrolStartTime));
                    break;
                case SQUAD_Patrol:
                    statusText = String.Format("\c[GREEN]Patrolling - %d", (squad.RETURN_AFTER * TICRATE) - (level.time - squad.patrolStartTime));
                    break;
                case SQUAD_Return:
                    statusText = "\c[HI]Returning To Spawn";
                    break;
            }

            DrawStr(fnt2, String.Format("Status: %s", statusText), pos, DR_SCREEN_RIGHT, Font.CR_UNTRANSLATED, alpha, false, scale: (1, 1));
            pos.y += LINE_HEIGHT_2;

            DrawStr(fnt2, String.Format("Members: %d / %d", squad.members.size(), squad.maxSquadSize), pos, DR_SCREEN_RIGHT, Font.CR_UNTRANSLATED, alpha, false, scale: (1, 1));
            pos.y += LINE_HEIGHT_2;

            for(int y = 0; y < squad.members.size(); y++) {
                EnemySoldier member = squad.members[y];
                if(!member) continue;
                DrawStr('PDA7FONT', String.Format("%s [%s] %d/%dhp A: %d E: $d D: %d", member.alienName, member.getClassName(), member.health, member.startinghealth, member.aggressiveness, member.evadeChance, member.combatDistance), pos, DR_SCREEN_RIGHT, Font.CR_UNTRANSLATED, alpha, false, scale: (1, 1));
                pos.y += 10;
                DrawStr('PDA7FONT', String.Format("   T: %s LT: %s LH: %s LL: %s ST: %s", member.target ? member.target.getClassName() : 'N/A', member.LastEnemy ? member.LastEnemy.getClassName() : 'N/A', member.LastHeard ? member.LastHeard.getClassName() : 'N/A', member.LastLookActor ? member.LastLookActor.getClassName() : 'N/A', member.CurSector.SoundTarget ? member.CurSector.SoundTarget.getClassName() : 'N/A'), pos, DR_SCREEN_RIGHT, Font.CR_UNTRANSLATED, alpha, false, scale: (1, 1));
                pos.y += 10;
            }


            pos.y += LINE_HEIGHT;
        }
    }
}