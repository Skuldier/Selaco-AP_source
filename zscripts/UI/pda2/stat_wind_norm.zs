class PDAStatWindowNormal : PDAStatWindow {
    const midVal = 1;
    const midOffset = -70;
    const midSpacer = -10;

    int, int inv(class<Inventory> cls) {
        let i = players[consoleplayer].mo.FindInventory(cls);
        if(i) {
            let maxA = i.maxAmount == 0 ? GetDefaultByType(cls).maxAmount : i.maxAmount;
            return i.amount, maxA;
        }

        return 0,  GetDefaultByType(cls).maxAmount;
    }

    PDAStatWindowNormal init(Vector2 pos, Vector2 size) {
        Super.init(pos, size, "Area Statistics", "ITEMS AND DATA");

        int linePos = 12;

        int secretsFound, secretsTotal;
        int localSecretsFound, localSecretsTotal;
        int datapadsFound, datapadsTotal;
        int tradingCardsFound, tradingCardsTotal;
        int upgradesFound, upgradesTotal;
        int cabinetCardsFound, cabinetCardsTotal;
        int clearanceTotal, clearanceFound;
        int cabinetsUnlocked, cabinetsTotal;
        int kills, totalEnemies;

        // Get trackers
        StatTracker secretTracker           = Stats.FindTracker(STAT_SECRETS_FOUND);
        StatTracker datapadTracker          = Stats.FindTracker(STAT_DATAPADS_FOUND);
        StatTracker tradingCardTracker      = Stats.FindTracker(STAT_TRADINGCARDS_FOUND);
        StatTracker upgradesTracker         = Stats.FindTracker(STAT_UPGRADES_FOUND);
        StatTracker clearanceTracker         = Stats.FindTracker(STAT_CLEARANCE_CARDS);
        StatTracker cabinetCardTracker      = Stats.FindTracker(STAT_CABINETCARDS_FOUND);
        StatTracker cabinetTracker          = Stats.FindTracker(STAT_STORAGECABINETS_OPENED);
        StatTracker killTracker             = Stats.FindTracker(STAT_KILLS);

        if(level.levelGroup != 0) {

            for(int y = 0; y < LevelInfo.GetLevelInfoCount(); y++) {
                let info = LevelInfo.GetLevelInfo(y);
                if(info.levelGroup != level.levelGroup) continue;

                int x = info.levelnum;

                secretsFound += secretTracker && secretTracker.levelValues.size() > x ? secretTracker.levelValues[x] : 0;
                secretsTotal += secretTracker && secretTracker.levelPossibleValues.size() > x ? secretTracker.levelPossibleValues[x] : 0;
                
                datapadsFound += datapadTracker && datapadTracker.levelValues.size() > x  ? datapadTracker.levelValues[x] : 0;
                datapadsTotal += datapadTracker && datapadTracker.levelPossibleValues.size() > x ? datapadTracker.levelPossibleValues[x] : 0;

                tradingCardsFound += tradingCardTracker && tradingCardTracker.levelValues.size() > x  ? tradingCardTracker.levelValues[x] : 0;
                tradingCardsTotal += tradingCardTracker && tradingCardTracker.levelPossibleValues.size() > x ? tradingCardTracker.levelPossibleValues[x] : 0;

                upgradesFound += upgradesTracker && upgradesTracker.levelValues.size() > x  ? upgradesTracker.levelValues[x] : 0;
                upgradesTotal += upgradesTracker && upgradesTracker.levelPossibleValues.size() > x ? upgradesTracker.levelPossibleValues[x] : 0;

                clearanceFound += clearanceTracker && clearanceTracker.levelValues.size() > x  ? clearanceTracker.levelValues[x] : 0;
                clearanceTotal += clearanceTracker && clearanceTracker.levelPossibleValues.size() > x ? clearanceTracker.levelPossibleValues[x] : 0;

                cabinetCardsFound += cabinetCardTracker && cabinetCardTracker.levelValues.size() > x  ? cabinetCardTracker.levelValues[x] : 0;
                cabinetCardsTotal += cabinetCardTracker && cabinetCardTracker.levelPossibleValues.size() > x ? cabinetCardTracker.levelPossibleValues[x] : 0;

                cabinetsUnlocked += cabinetTracker && cabinetTracker.levelValues.size() > x  ? cabinetTracker.levelValues[x] : 0;
                cabinetsTotal += cabinetTracker && cabinetTracker.levelPossibleValues.size() > x ? cabinetTracker.levelPossibleValues[x] : 0;

                kills += killTracker && killTracker.levelValues.size() > x  ? killTracker.levelValues[x] : 0;
                totalEnemies += killTracker && killTracker.levelPossibleValues.size() > x ? killTracker.levelPossibleValues[x] : 0;
            }
        }

        if(level.levelNum >= 0 && level.levelNum < StatTracker.MAX_LEVEL_NUM) {
            localSecretsFound = secretTracker.levelValues[level.levelNum];
            localSecretsTotal = secretTracker.levelPossibleValues[level.levelNum];
        }
        
        // Localize important stats
        string secretLine = String.Format("%s:", StringTable.Localize("$STAT_SECRETS"));
        string upgradeLine = String.Format("%s:", StringTable.Localize("$STAT_UPGRADES"));
        string datapadLine = String.Format("%s:", StringTable.Localize("$Datapads"));
        string cabinetsLine = String.Format("%s:", StringTable.Localize("$PDA_STAT_CABINETCARDS")); 
        string cabinetsOpenedLine = String.Format("%s:", StringTable.Localize("$PDA_STAT_OPENEDSTORAGE")); 
        string securityClearanceLine = String.Format("%s:", StringTable.Localize("$STAT_CLEARANCE"));
        string tradingcardLine = String.Format("%s:", StringTable.Localize("$STAT_TRADINGCARD"));
        string areaSecretsLine = String.Format("%s:", StringTable.Localize("$PDA_STAT_AREASECRETS"));
        string totalSecretsLine = String.Format("%s:", StringTable.Localize("$PDA_STAT_TOTALSECRETS"));

        makeLine(linePos, upgradeLine, String.format("%d / %d", upgradesFound, upgradesTotal), upgradesFound == upgradesTotal);
        makeLine(linePos, datapadLine, String.format("%d / %d", datapadsFound, datapadsTotal), datapadsFound == datapadsTotal);
        linePos += 25;
        makeLine(linePos, cabinetsLine, String.format("%d / %d", cabinetCardsFound, cabinetCardsTotal), cabinetCardsFound == cabinetCardsTotal);
        makeLine(linePos, cabinetsOpenedLine, String.format("%d / %d", cabinetsUnlocked, cabinetsTotal), cabinetsUnlocked == cabinetsTotal);
        makeLine(linePos, securityClearanceLine, String.format("%d / %d", clearanceFound, clearanceTotal), clearanceFound == clearanceTotal);
        if(!g_halflikemode) {
            linePos += 25;
            makeLine(linePos, areaSecretsLine, String.format("%d / %d", localSecretsFound, localSecretsTotal), localSecretsFound == localSecretsTotal);
            makeLine(linePos, totalSecretsLine, String.format("%d / %d", secretsFound, /*Level.found_secrets,*/ secretsTotal), secretsFound == secretsTotal);
        }
        
        //, Level.found_secrets == Level.total_secrets ? "\c[GREEN]" : "", Level.total_secrets), secretsFound == secretsTotal);
        //makeLine(linePos, "Trading Cards:", String.format("%d / %d", tradingCardsFound, tradingCardsTotal), tradingCardsFound == tradingCardsTotal);

        self.frame.size.y = round((60 + linePos + 14) / 2.0) * 2 + 1;   // Round to nearest even (odd) number

        return self;
    }

    UILabel, UILabel makeLine(out int yPos, string txt, string valText, bool finished = false) {
        let txtA = new("UILabel").init((0, yPos), (1, 25), txt, "SEL21FONT", 0xFFB9C0D1, textAlign: UIView.Align_Right | UIView.Align_Middle, fontScale: (0.875, 0.875));
        txtA.multiline = false;
        txtA.autoScale = true;
        txtA.pin(UIPin.Pin_Left, offset: 15);
        txtA.pin(UIPin.Pin_Right, value: midVal, offset: midOffset + midSpacer, isFactor: true);
        contentView.add(txtA);

        let txtB = new("UILabel").init((0, yPos), (1, 25), valText, "SEL21FONT", finished ? 0xFF11CC11 : 0xFF8E99B7, UIView.Align_Middle, fontScale: (0.875, 0.875));
        txtB.multiline = false;
        txtB.autoScale = true;
        txtB.pin(UIPin.Pin_Left, UIPin.Pin_Right, value: midVal, offset: midOffset, isFactor: true);
        txtB.pin(UIPin.Pin_Right, offset: -10);
        contentView.add(txtB);

        yPos += 25;

        return txtA, txtB;
    }
}


class PDAStatWindowObjectives : PDAStatWindow {
    const midVal = 0.62;
    const midOffset = 6;

    UIVerticalLayout vlayout;

    PDAStatWindowObjectives init(Vector2 pos, Vector2 size) {
        Super.init(pos, size, "Current Objectives", "SHOWING ONLY ACTIVE");

        let os = Objectives.FindObjectives();
        if(!os || os.objs.size() == 0) {
            // Show "No Objectives"
            let txtA = new("UILabel").init((0, 25), (1, 25), "No Objectives", "SEL14FONT", textAlign: UIView.Align_Centered);
            txtA.multiline = false;
            txtA.pin(UIPin.Pin_Left, offset: 5);
            txtA.pin(UIPin.Pin_Right, offset: -5);
            contentView.add(txtA);
            return self;
        }

        vlayout = new("UIVerticalLayout").init((0, 0), (1,1));
        vlayout.layoutMode = UIViewManager.Content_SizeParent;
        vlayout.padding.top = 12;
        vlayout.pinToParent();
        vlayout.itemSpacing = 8;
        contentView.add(vlayout);
        
        for(int x = 0; x < os.objs.size(); x++) {
            let o = os.objs[x];
            if(o.hideOutsideMap && o.mapNum != Level.levelnum) { continue; }
            if(o.status != Objective.STATUS_ACTIVE) { continue; }

            vlayout.addManaged(makeLine(o.icon .. (o.status + 1), o.title, 0));

            for(int y = 0; y < o.children.size(); y++) {
                let o2 = o.children[y];
                
                if(o2.hideOutsideMap && o2.mapNum != Level.levelnum) { continue; }
                if(o2.status != Objective.STATUS_ACTIVE) { continue; }

                vlayout.addManaged(makeLine(o2.icon .. (o2.status + 4), o2.title, 1));
            }
        }

        //self.frame.size.y = round((60 + linePos + 14) / 2.0) * 2 + 1;   // Round to nearest even (odd) number
        

        return self;
    }


    UILabel makeLine(string img, string txt, int indent) {
        Font fnt = Font.FindFont(indent == 0 ? "SEL14FONT": "PDA13FONT");
        int left = 15 + (20 * indent);

        let txtA = new("UILabel").init((0, 0), (100, 22), txt, fnt, fontScale: indent == 0 ? (1,1) : (0.8, 0.8));
        txtA.multiline = true;
        txtA.pin(UIPin.Pin_Left, offset: left + 24);
        txtA.pin(UIPin.Pin_Right, offset: -15);
        txtA.pinHeight(UIView.Size_Min);
        txtA.clipsSubviews = false;

        // Add image directly to the label, that way we don't have to use a container that auto-sizes
        if(img != "") {
            let imgA = new("UIImage").init((indent == 0 ? -28 : -25, -4), (24, 24), img, imgStyle: UIImage.Image_Center, imgScale: (0.63, 0.63));
            txtA.add(imgA);
        }

        return txtA;
    }

    override void layout(Vector2 parentScale, double parentAlpha) {
        Super.layout(parentScale, parentAlpha);

        if(vlayout) self.frame.size.y = vlayout.frame.size.y + 60 + 14;
    }
}