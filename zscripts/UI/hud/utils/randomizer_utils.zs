mixin class RandomizerWeaponDrawer {
    const WLINEHEIGHT = 24;
    const WLINESTART = 40;
    const WLINELEFT = 15;

    ui int compareS(int a, int b) {
        return a < b ? -1 : (a > b ? 1 : 0);
    }

    ui int compareF(double a, double b) {
        return a < b ? -1 : (a > b ? 1 : 0);
    }

    ui void drawStatLine(String name, out int y, int statA, int statB, bool shouldCompare, Vector2 pos, double right, double alpha, bool isPositive = true, int flags = DR_SCREEN_CENTER) {
        DrawStr("SEL21OFONT", name, pos + (WLINELEFT, WLINESTART + (y * WLINEHEIGHT)), flags, a: alpha, monospace: false);
        if(shouldCompare && statA != statB) {
            int compare = compareS(statA, statB);
            if(!isPositive) compare *= -1;
            DrawStr("SEL21OFONT", String.Format("\c[DARKGRAY]%d\c- ↔ \c%s%s%d", statB, compare > 0 ? "[green]" : (compare < 0 ? "[red]" : "[ice]"), (compare > 0 && isPositive) || (compare < 0 && !isPositive) ? "↑" : (compare != 0 ? "↓" : ""), statA), pos + (right, WLINESTART + ((y++) * WLINEHEIGHT)), DR_SCREEN_CENTER | DR_TEXT_RIGHT, a: alpha, monospace: false);
        }
        else DrawStr("SEL21OFONT", String.Format("%d", statA), pos + (right, WLINESTART + ((y++) * WLINEHEIGHT)), flags | DR_TEXT_RIGHT, a: alpha, monospace: false);
    }

    ui void drawStatLineF(String name, out int y, double statA, double statB, bool shouldCompare, Vector2 pos, double right, double alpha, bool isPositive = true, int flags = DR_SCREEN_CENTER) {
        DrawStr("SEL21OFONT", name, pos + (WLINELEFT, WLINESTART + (y * WLINEHEIGHT)), flags, a: alpha, monospace: false);
        if(shouldCompare && statA != statB) {
            int compare = compareF(statA, statB);
            if(!isPositive) compare *= -1;
            DrawStr("SEL21OFONT", String.Format("\c[DARKGRAY]%0.2f\c- ↔ \c%s%s%0.2f", statB, compare > 0 ? "[green]" : (compare < 0 ? "[red]" : "[ice]"), (compare > 0 && isPositive) || (compare < 0 && !isPositive) ? "↑" : (compare != 0 ? "↓" : ""), statA), pos + (right, WLINESTART + ((y++) * WLINEHEIGHT)), DR_SCREEN_CENTER | DR_TEXT_RIGHT, a: alpha, monospace: false);
        }
        else DrawStr("SEL21OFONT", String.Format("%0.2f", statA), pos + (right, WLINESTART + ((y++) * WLINEHEIGHT)), flags | DR_TEXT_RIGHT, a: alpha, monospace: false);
    }


    ui Vector2 DrawWeaponPickup(WeaponPickup pickup, SelacoWeapon currentWeapon, Vector2 pos, double alpha = 1.0) {
        if(!pickup.baseStats) return (0,0);

        SelacoWeaponBaseStats base;
        if(currentWeapon) currentWeapon.getBaseStats(base);

        let huddy = HUD(StatusBar);
        bool gassyAss = huddy && huddy.hasGasMask > 0;

        double width = 450;
        double height = 400;
        Font fnt = "SEL21OFONT";

        double titleLen = max(50, fnt.StringWidth(pickup.cleanTag) - 15);
        //double frameLeft = titleLen + 40;
        double edgeLeft = 40;
        width = max(width, titleLen + 45);

        // Try to determine the height of the container
        int numStats = 1;
        int numTraits = pickup.traits.size();
        if(pickup.baseStats.magazineSizeAbs != 0 || base.magazineSize != 0) numStats++;
        if(pickup.baseStats.spreadAbs != 0 || base.weaponSpread != 0) numStats++;
        if(pickup.baseStats.recoilAbs != 0 || base.weaponRecoil != 0) numStats++;
        if(pickup.baseStats.kickbackAbs != 0 || base.weaponKickback != 0) numStats++;
        if(pickup.baseStats.headshotMultiplierAbs != 0 || base.weaponHeadshotMultiplier != 0)  numStats++;
        if(pickup.baseStats.pelletsAbs != 0 || base.weaponPelletAmount != 0) numStats++;
        if(pickup.baseStats.stabilizationAbs != 0 || base.weaponStabilizationSpeed != 0) numStats++;
        if(pickup.baseStats.projectileSpeedAbs != 0 || base.weaponProjectileSpeed != 0) numStats++;
        if(pickup.baseStats.areaOfEffectAbs != 0 || base.weaponAreaOfEffect != 0) numStats++;

        int descriptionsSize = 0;
        int tsize = floor((width - 30) / 0.7);
        // Get description heights
        for(int x = 0; x < numTraits; x++) {
            BrokenLines lines = fnt.BreakLines(" • " .. pickup.traits[x].getDescription(), tsize);
            descriptionsSize += (lines.count() * (fnt.GetHeight() * 0.7)) + 10;
        }

        height = WLINESTART + (numStats * WLINEHEIGHT) + 22 + (numTraits * (WLINEHEIGHT + 4)) + descriptionsSize + 15 + WLINEHEIGHT + 20;


        // Draw 9 piece background
        TextureID tex = TexMan.CheckForTexture (gassyAss ? "PANTUTGM" : "PANTUT", TexMan.Type_Any);
        double textEdgeLeft = edgeLeft + titleLen;

        DrawTexClip(tex, pos, (0, 0), (edgeLeft, 40), flags: DR_SCREEN_CENTER, a: alpha);    // Top Left
        DrawTexClip(tex, pos + (edgeLeft, 0), (30, 0), (40, 40), flags: DR_SCREEN_CENTER | DR_SCALE_IS_SIZE, a: alpha, scale: (titleLen, 40));    // Top Left - Behind Title
        DrawTexClip(tex, pos + (textEdgeLeft, 0), (260, 0), (35, 40), flags: DR_SCREEN_CENTER, a: alpha);    // Top Left - End of Title
        DrawTexClip(tex, pos + (textEdgeLeft + 35, 0), (260 + 50, 0), (20, 40), flags: DR_SCREEN_CENTER | DR_SCALE_IS_SIZE, a: alpha, scale: (width - textEdgeLeft - 30 - 35, 40));    // Top Middle
        DrawTexClip(tex, pos + (width - 30, 0), (586, 0), (30, 40), flags: DR_SCREEN_CENTER, a: alpha);    // Top Right
        
        DrawTexClip(tex, pos + (0, 40), (0, 40), (edgeLeft, 50), flags: DR_SCREEN_CENTER | DR_SCALE_IS_SIZE, a: alpha, scale: (edgeLeft, height - 40 - 35));    // Middle Left
        DrawTexClip(tex, pos + (edgeLeft, 40), (edgeLeft, 40), (20, 50), flags: DR_SCREEN_CENTER | DR_SCALE_IS_SIZE, a: alpha, scale: (width - 30 - edgeLeft, height - 40 - 35));    // Middle
        DrawTexClip(tex, pos + (width - 30, 40), (586, 40), (30, 50), flags: DR_SCREEN_CENTER | DR_SCALE_IS_SIZE, a: alpha, scale: (30, height - 40 - 35));    // Middle Right
        
        DrawTexClip(tex, pos + (0, height - 35), (0, 197), (edgeLeft, 35), flags: DR_SCREEN_CENTER, a: alpha);    // Bottom Left
        DrawTexClip(tex, pos + (edgeLeft, height - 35), (edgeLeft, 197), (20, 35), flags: DR_SCREEN_CENTER | DR_SCALE_IS_SIZE, a: alpha, scale: (width - 30 - edgeLeft, 35));    // Bottom Middle
        DrawTexClip(tex, pos + (width - 30, height - 35), (586, 197), (30, 35), flags: DR_SCREEN_CENTER, a: alpha);   // Bottom Right

        // Title
        string clr = "";
        switch(pickup.rarityID)
        {
            case RARITY_UNCOMMON:
                clr = "\c[cyan]";
                break;
            case RARITY_RARE:
                clr = "\c[Yellow]";
                break;
            case RARITY_EPIC:
                clr = "\c[Purple]";
                break;
            case RARITY_LEGENDARY:
                clr = "\c[orange]";
                break;
        }
        DrawStr(fnt, clr .. pickup.cleanTag, pos + (15, 3), DR_SCREEN_CENTER, a: alpha, monospace: false, linespacing: 5);

        // Stats
        if(pickup.baseStats) {//•
            int y = 0;
            double right = width - WLINELEFT;
            
            // Damage
            drawStatLine("Damage", y, pickup.baseStats.damageAbs, base.weaponDamage, !!currentWeapon, pos, right, alpha);
            //drawStatLine("Fire Rate", y, int(round(35.0 / pickup.baseStats.fireRateAbs * 60)), currentWeapon ? int(round(35.0 / currentWeapon.weaponFireRate * 60)) : 0, !!currentWeapon, pos, right, alpha);
            
            int magSize = base.magazineSize;
            if(pickup.baseStats.magazineSizeAbs != 0 || magSize != 0) drawStatLine("Magazine", y, pickup.baseStats.magazineSizeAbs, magSize, !!currentWeapon, pos, right, alpha);

            if(pickup.baseStats.spreadAbs != 0 || base.weaponSpread != 0) drawStatLineF("Spread", y, pickup.baseStats.spreadAbs, base.weaponSpread, !!currentWeapon, pos, right, alpha, false);
            if(pickup.baseStats.recoilAbs != 0 || base.weaponRecoil != 0) drawStatLineF("Recoil", y, pickup.baseStats.recoilAbs, base.weaponRecoil, !!currentWeapon, pos, right, alpha, false);
            if(pickup.baseStats.kickbackAbs != 0 || base.weaponKickback != 0) drawStatLine("Kickback", y, pickup.baseStats.kickbackAbs, base.weaponKickback, !!currentWeapon, pos, right, alpha);
            if(pickup.baseStats.headshotMultiplierAbs != 0 || base.weaponHeadshotMultiplier != 0) drawStatLineF("Headshot Dmg", y, pickup.baseStats.headshotMultiplierAbs * 100.0, base.weaponHeadshotMultiplier * 100.0, !!currentWeapon, pos, right, alpha);
            if(pickup.baseStats.pelletsAbs != 0 || base.weaponPelletAmount != 0) drawStatLine("Pellets", y, pickup.baseStats.pelletsAbs, base.weaponPelletAmount, !!currentWeapon, pos, right, alpha);
            if(pickup.baseStats.stabilizationAbs != 0 || base.weaponStabilizationSpeed != 0) drawStatLineF("Stabilization", y, pickup.baseStats.stabilizationAbs, base.weaponStabilizationSpeed, !!currentWeapon, pos, right, alpha);
            if(pickup.baseStats.projectileSpeedAbs != 0 || base.weaponProjectileSpeed != 0) drawStatLine("Projectile Speed", y, pickup.baseStats.projectileSpeedAbs, base.weaponProjectileSpeed, !!currentWeapon, pos, right, alpha);
            if(pickup.baseStats.areaOfEffectAbs != 0 || base.weaponAreaOfEffect != 0) drawStatLine("Area of Effect", y, pickup.baseStats.areaOfEffectAbs, base.weaponAreaOfEffect, !!currentWeapon, pos, right, alpha);

            double ypos = WLINESTART + (y * WLINEHEIGHT) + 10;

            // Draw line
            Dim(0xFFCCCECE, 1.0, pos.x + 15, pos.y + ypos, width - 30, 2, flags: DR_SCREEN_CENTER);
            
            yPos += 10;
            // Add each trait
            y = 0;
            for(int x = 0; x < pickup.traits.size(); x++) {
                DrawStr(fnt, String.Format("%c %s", pickup.traits[x].effectIcon + 0x2070, pickup.traits[x].getTitle()), pos + (WLINELEFT, yPos), DR_SCREEN_CENTER, a: alpha, monospace: false);
                yPos += WLINEHEIGHT + 4;
                
                // Draw description
                yPos += DrawStrMultiline(fnt, " • " .. pickup.traits[x].getDescription(), pos + (WLINELEFT, yPos), width - 30, DR_SCREEN_CENTER, a: alpha, scale: (0.7, 0.7));
                yPos += 10;
            }
            
            yPos = ypos + (y * WLINEHEIGHT) + 15;
            
            // Draw the rarity of the item
            string rarityText = RandomizerHandler.getRarityLabel(pickup.rarityID);
            DrawStr(fnt, rarityText, pos + (right, yPos), DR_SCREEN_CENTER | DR_TEXT_RIGHT, a: alpha, monospace: false);
        }
        

        return (width, height);
    }


    ui Vector2 DrawWeaponInfo(SelacoWeapon currentWeapon, Vector2 pos, int flags = 0, double alpha = 1.0) {
        SelacoWeaponBaseStats base;
        currentWeapon.getBaseStats(base);

        double width = 450;
        double height = 400;
        Font fnt = "SEL21OFONT";

        double titleLen = max(50, fnt.StringWidth(currentWeapon.getTag()) - 15);
        double edgeLeft = 40;
        width = max(width, titleLen + 45);

        // Try to determine the height of the container
        int numStats = 1;
        int numUpgrades = currentWeapon.activeUpgrades.size();
        int numTraits = 0;
        if(currentWeapon.magazineSize != 0) numStats++;
        if(currentWeapon.weaponSpread != 0) numStats++;
        if(currentWeapon.weaponRecoil != 0) numStats++;
        if(currentWeapon.weaponKickback != 0) numStats++;
        if(currentWeapon.weaponHeadshotMultiplier != 0)  numStats++;
        if(currentWeapon.weaponPelletAmount != 0) numStats++;
        if(currentWeapon.weaponStabilizationSpeed != 0) numStats++;
        if(currentWeapon.weaponProjectileSpeed != 0) numStats++;
        if(currentWeapon.weaponAreaOfEffect != 0) numStats++;

        int descriptionsSize = 0;
        int tsize = floor((width - 30) / 0.7);
        // Get description heights
        for(int x = 0; x < numUpgrades; x++) {
            WeaponTrait t = WeaponTrait(currentWeapon.activeUpgrades[x]);
            if(t) {
                BrokenLines lines = fnt.BreakLines(" • " .. t.getDescription(), tsize);
                descriptionsSize += (lines.count() * (fnt.GetHeight() * 0.7)) + 10;
                numTraits++;
            }
        }

        height = WLINESTART + (numStats * WLINEHEIGHT) + 22 + (numTraits * (WLINEHEIGHT + 4)) + descriptionsSize + 15 + WLINEHEIGHT + 20;
        
        if(flags & DR_IMG_RIGHT) {
            flags &= ~DR_IMG_RIGHT;
            pos.x -= width;
        }

        if(flags & DR_IMG_BOTTOM) {
            flags &= ~DR_IMG_BOTTOM;
            pos.y -= height;
        }

        // Draw 9 piece background
        TextureID tex = TexMan.CheckForTexture ("PANTUT", TexMan.Type_Any);
        double textEdgeLeft = edgeLeft + titleLen;

        DrawTexClip(tex, pos, (0, 0), (edgeLeft, 40), flags: flags, a: alpha);    // Top Left
        DrawTexClip(tex, pos + (edgeLeft, 0), (30, 0), (40, 40), flags: flags | DR_SCALE_IS_SIZE, a: alpha, scale: (titleLen, 40));    // Top Left - Behind Title
        DrawTexClip(tex, pos + (textEdgeLeft, 0), (260, 0), (35, 40), flags: flags, a: alpha);    // Top Left - End of Title
        DrawTexClip(tex, pos + (textEdgeLeft + 35, 0), (260 + 50, 0), (20, 40), flags: flags | DR_SCALE_IS_SIZE, a: alpha, scale: (width - textEdgeLeft - 30 - 35, 40));    // Top Middle
        DrawTexClip(tex, pos + (width - 30, 0), (586, 0), (30, 40), flags: flags, a: alpha);    // Top Right
        
        DrawTexClip(tex, pos + (0, 40), (0, 40), (edgeLeft, 50), flags: flags | DR_SCALE_IS_SIZE, a: alpha, scale: (edgeLeft, height - 40 - 35));    // Middle Left
        DrawTexClip(tex, pos + (edgeLeft, 40), (edgeLeft, 40), (20, 50), flags: flags | DR_SCALE_IS_SIZE, a: alpha, scale: (width - 30 - edgeLeft, height - 40 - 35));    // Middle
        DrawTexClip(tex, pos + (width - 30, 40), (586, 40), (30, 50), flags: flags | DR_SCALE_IS_SIZE, a: alpha, scale: (30, height - 40 - 35));    // Middle Right
        
        DrawTexClip(tex, pos + (0, height - 35), (0, 197), (edgeLeft, 35), flags: flags, a: alpha);    // Bottom Left
        DrawTexClip(tex, pos + (edgeLeft, height - 35), (edgeLeft, 197), (20, 35), flags: flags | DR_SCALE_IS_SIZE, a: alpha, scale: (width - 30 - edgeLeft, 35));    // Bottom Middle
        DrawTexClip(tex, pos + (width - 30, height - 35), (586, 197), (30, 35), flags: flags, a: alpha);   // Bottom Right

        // Title
        string clr = "";
        switch(currentWeapon.pickupRarity)
        {
            case RARITY_UNCOMMON:
                clr = "\c[cyan]";
                break;
            case RARITY_RARE:
                clr = "\c[Yellow]";
                break;
            case RARITY_EPIC:
                clr = "\c[Purple]";
                break;
            case RARITY_LEGENDARY:
                clr = "\c[orange]";
                break;
        }
        DrawStr(fnt, clr .. currentWeapon.getTag(), pos + (15, 3), flags, a: alpha, monospace: false, linespacing: 5);

        // Stats
        {//•
            int y = 0;
            double right = width - WLINELEFT;
            
            // Damage
            drawStatLine("Damage", y, currentWeapon.weaponDamage, 0, false, pos, right, alpha, flags: flags);

            int magSize = currentWeapon.magazineSize;
            if(magSize != 0) drawStatLine("Magazine", y, magSize, 0, false, pos, right, alpha, flags: flags);

            if(currentWeapon.weaponSpread != 0) drawStatLineF("Spread", y, currentWeapon.weaponSpread, 0, false, pos, right, alpha, false, flags: flags);
            if(currentWeapon.weaponRecoil != 0) drawStatLineF("Recoil", y, currentWeapon.weaponRecoil, 0, false, pos, right, alpha, false, flags: flags);
            if(currentWeapon.weaponKickback != 0) drawStatLine("Kickback", y, currentWeapon.weaponKickback, 0, false, pos, right, alpha, flags: flags);
            if(currentWeapon.weaponHeadshotMultiplier != 0) drawStatLineF("Headshot Dmg", y, currentWeapon.weaponHeadshotMultiplier * 100.0, 0, false, pos, right, alpha, flags: flags);
            if(currentWeapon.weaponPelletAmount != 0) drawStatLine("Pellets", y, currentWeapon.weaponPelletAmount, 0, false, pos, right, alpha, flags: flags);
            if(currentWeapon.weaponStabilizationSpeed != 0) drawStatLineF("Stabilization", y, currentWeapon.weaponStabilizationSpeed, 0, false, pos, right, alpha, flags: flags);
            if(currentWeapon.weaponProjectileSpeed != 0) drawStatLine("Projectile Speed", y, currentWeapon.weaponProjectileSpeed, 0, false, pos, right, alpha, flags: flags);
            if(currentWeapon.weaponAreaOfEffect != 0) drawStatLine("Area of Effect", y, currentWeapon.weaponAreaOfEffect, 0, false, pos, right, alpha, flags: flags);

            double ypos = WLINESTART + (y * WLINEHEIGHT) + 10;

            // Draw line
            Dim(0xFFCCCECE, 1.0, pos.x + 15, pos.y + ypos, width - 30, 2, flags: flags);
            
            yPos += 10;
            // Add each trait
            y = 0;
            for(int x = 0; x < numUpgrades; x++) {
                if(currentWeapon.activeUpgrades[x] is 'WeaponTrait') {
                    let trait = WeaponTrait(currentWeapon.activeUpgrades[x]);
                    DrawStr(fnt, String.Format("%c %s", trait.effectIcon + 0x2070, trait.getTitle()), pos + (WLINELEFT, yPos), flags, a: alpha, monospace: false);
                    yPos += WLINEHEIGHT + 4;
                    
                    // Draw description
                    yPos += DrawStrMultiline(fnt, " • " .. trait.getDescription(), pos + (WLINELEFT, yPos), width - 30, flags, a: alpha, scale: (0.7, 0.7));
                    yPos += 10;
                }
            }
            
            yPos = ypos + (y * WLINEHEIGHT) + 15;
            
            // Draw the rarity of the item
            string rarityText = RandomizerHandler.getRarityLabel(currentWeapon.pickupRarity);
            DrawStr(fnt, rarityText, pos + (right, yPos), flags | DR_TEXT_RIGHT, a: alpha, monospace: false);
        }
        

        return (width, height);
    }
}