class EndLevelMenu : SelacoGamepadMenu {
    UIAnimatedLabel thanksLabel, completeLabel;
    UIImage hardcoreImage, dawnImage, visbg, visbg2, skillImage, modeImage;
    UIButton continueButt, continueButt2, resetButt;
    UILabel smfLabel;
    UIVerticalLayout statsLayout, extraStatsLayout, wadsLayout;
    
    bool hasContinued, keyboardSelect;

    int, int inv(class<Inventory> cls) {
        let i = players[consoleplayer].mo.FindInventory(cls);
        if(i) {
            let maxA = i.maxAmount == 0 ? GetDefaultByType(cls).maxAmount : i.maxAmount;
            return i.amount, maxA;
        }

        return 0,  GetDefaultByType(cls).maxAmount;
    }

    override void init(Menu parent) {
		Super.init(parent);
        DontDim = true;
        animated = true;
        menuActive = Menu.OnNoPause;

        int secretsFound, secretsTotal;
        int datapadsFound, datapadsTotal;
        int tradingCardsFound, tradingCardsTotal;
        int upgradesFound, upgradesTotal;
        int clearanceTotal, clearanceFound;
        int cabinetCardsFound, cabinetCardsTotal;
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
        StatTracker cheats                  = Stats.FindTracker(STAT_YOUCHEATED);
        StatTracker timerT                  = Stats.FindTracker(STAT_TIMER);

        // If we aren't in a level currently, add values for each level of the demo (1-3)
        // Otherwise try to base it off the current hub
        int maxLevel = 3;
        int minLevel = 1;
        uint totalTime = 0;

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

                totalTime += timerT && timerT.levelValues.size() > x ? timerT.levelValues[x] : 0;
            }
        }

        
        //uint sessionTime = totalTime;
        totalTime = ceil(double(totalTime) / 35.0);

        /*let evt = LevelEventHandler(StaticEventHandler.Find("LevelEventHandler"));
        if (evt) {
            sessionTime = ceil(double(evt.totalTicks) / 35.0);
        }*/

        /*let d = Dawn(players[consolePlayer].mo);
        if(d) {
            totalTime = ceil(double(d.ticks) / 35.0);
        }*/

        visbg = new("UIImage").init((0,0), (10,10), "VIGNET3", imgStyle: UIImage.Image_Aspect_Fill);
        visbg.pinToParent();
        mainView.add(visbg);

        /*visbg2 = new("UIImage").init((0,0), (10,10), "CITYEND1", imgStyle: UIImage.Image_Aspect_Fill);
        visbg2.pinToParent();
        mainView.add(visbg2);
        visbg2.hidden = true;
        visbg2.alpha = 0;*/

        completeLabel = new("UIAnimatedLabel").init((0,0), (600, 80), StringTable.Localize("$MENU_LEVEL_COMPLETE"), "SEL52FONT", textAlign: UIView.Align_Middle, fontScale: (1, 1));
        completeLabel.pinWidth(710);
        completeLabel.pin(UIPin.Pin_Left, UIPin.Pin_Right, value: 0.042, isFactor: true);
        completeLabel.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 0.1, isFactor: true);
        completeLabel.charLimit = 0;
        completeLabel.clipsSubviews = false;
        mainView.add(completeLabel);

        let skill = Stats.GetLowestSkill();

        // Add skill image
        skillImage = new("UIImage").init((0,0), (160, 160), String.Format("CSKILL0%d", skill));
        //skillImage.pinWidth(160);
        //skillImage.pinHeight(160);
        //skillImage.pin(UIPin.Pin_Right, offset: 50);
        //skillImage.pin(UIPin.Pin_Top, offset: -40);
        skillImage.pin(UIPin.Pin_HCenter, UIPin.Pin_Right, value: 1.0, offset: 50 - 80 + (g_randomizer ? 25 : 0), isFactor: true);
        skillImage.pin(UIPin.Pin_VCenter, UIPin.Pin_Top, value: 1.0, offset: -40 + 80, isFactor: true);
        skillImage.alpha = 0;
        completeLabel.add(skillImage);

        if(g_randomizer) {
            modeImage = new("UIImage").init((0,0), (160, 160), String.Format("GAMODE0%d", g_randomizer ? 2 : 1));
            //modeImage.pinWidth(160);
            //modeImage.pinHeight(160);
            modeImage.pin(UIPin.Pin_HCenter, UIPin.Pin_Right, value: 1.0, offset: -175, isFactor: true);
            modeImage.pin(UIPin.Pin_VCenter, UIPin.Pin_Top, value: 1.0, offset: -40 + 80, isFactor: true);
            modeImage.alpha = 0;
            //modeImage.pin(UIPin.Pin_Top, offset: -40);
            completeLabel.add(modeImage);
        }
        

        // Create layout to show stats
        statsLayout = new("UIVerticalLayout").init((0, 0), (50, 50));
        statsLayout.layoutMode = UIViewManager.Content_SizeParent;
        statsLayout.itemSpacing = 0;
        statsLayout.pinWidth(710);
        statsLayout.pin(UIPin.Pin_Left, UIPin.Pin_Right, value: 0.042, isFactor: true);
        statsLayout.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 0.1, offset: 120, isFactor: true);
        mainView.add(statsLayout);

        // Create extra stats layout
        extraStatsLayout = new("UIVerticalLayout").init((0, 0), (50, 50));
        extraStatsLayout.layoutMode = UIViewManager.Content_SizeParent;
        extraStatsLayout.itemSpacing = 0;
        extraStatsLayout.pinWidth(730);
        extraStatsLayout.pin(UIPin.Pin_Left, UIPin.Pin_Right, value: 0.042, offset: -20, isFactor: true);
        extraStatsLayout.pin(UIPin.Pin_Bottom, UIPin.Pin_Bottom, value: 0.8, isFactor: true);
        mainView.add(extraStatsLayout);


        int thours = totalTime / 60 / 60;
        int tminutes = (totalTime - (thours * 60 * 60)) / 60;
        int tseconds = totalTime - (thours * 60 * 60) - (tminutes * 60);

        // Localize important stats
        string secretLine = String.Format("%s:", StringTable.Localize("$STAT_SECRETS"));
        string upgradeLine = String.Format("%s:", StringTable.Localize("$STAT_UPGRADES"));
        string datapadLine = String.Format("%s:", StringTable.Localize("$Datapads"));
        string securityClearanceLine = String.Format("%s:", StringTable.Localize("$STAT_CLEARANCE"));
        string tradingcardLine = String.Format("%s:", StringTable.Localize("$STAT_TRADINGCARD"));
        string storageLine = String.Format("%s:", StringTable.Localize("$STAT_STORAGECABINETS"));
        string timeLine = String.Format("%s:", StringTable.Localize("$STAT_TIME"));
        string skillName = StringTable.Localize(String.Format("$SKILL_%d", skill));
        int skillCol = Font.CR_UNTRANSLATED;

        // Determine skill colour
        if(skill == SKILL_SMF) skillCol = 0xFF905EC7;
        else if(skill == 4) skillCol = 0xFFB4B4FF;
        else if(skill == 6) skillCol = 0xF37CCCA5;

        // Add important stats
        //addStatLine(StringTable.Localize("$SKILL_TITLE") .. ":", skillName, monospace: false, valueCol: skillCol);
        /*if(g_randomizer) {
            addStatLine("\c[GOLD]" .. StringTable.Localize("$MENU_RANDOMIZER_CAMPAIGN"), "");
        }*/

        addStatLine(timeLine, String.Format("%s:%s:%s", BaseStatusBar.FormatNumber(thours, 2, 2, 2), BaseStatusBar.FormatNumber(tminutes, 2, 2, 2), BaseStatusBar.FormatNumber(tseconds, 2, 2, 2)), monospace: false);
        addStatLine(secretLine, String.Format("%d/%d", secretsFound, secretsTotal));
        addStatLine(upgradeLine, String.Format("%d/%d", upgradesFound, upgradesTotal));
        addStatLine(datapadLine, String.Format("%d/%d", datapadsFound, datapadsTotal));
        addStatLine(securityClearanceLine, String.Format("%d/%d", clearanceFound, clearanceTotal));
        //addStatLine(tradingcardLine, String.Format("%d/%d", tradingCardsFound, tradingCardsTotal));
        addStatLine(storageLine, String.Format("%d/%d", cabinetsUnlocked, cabinetsTotal));

        // Add extra stats
        if(cheats.value > 0) {
            addStatLine("\c[GOLD]Cheat mode enabled", "");
        }

        if(iGetCVar("g_playChristmasEvent", 0)) {
            addStatLine("\c[GREEN]Christmas has been saved!", "");
        }

        
        //string creditsLine = String.Format("%s:", StringTable.Localize("$STAT_CREDITS"));
        //string unlocksLine;

        //addExtraStatLine(timeLine, String.Format("%s:%s:%s", BaseStatusBar.FormatNumber(thours, 2, 2, 2), BaseStatusBar.FormatNumber(tminutes, 2, 2, 2), BaseStatusBar.FormatNumber(tseconds, 2, 2, 2)));
        //addExtraStatLine(creditsLine, String.Format("%d", inv("creditsCount")));
        //addExtraStatLine("Unlocks:", "Red Blood Mode \c[grey](Full game)");

        // Thanks label is 
        thanksLabel = new("UIAnimatedLabel").init((0,0), (600, 600), StringTable.Localize("$THANKS"), "PDA16FONT");
        thanksLabel.pin(UIPin.Pin_Left, UIPin.Pin_Right, value: 0.3, isFactor: true);
        thanksLabel.pin(UIPin.Pin_Right, UIPin.Pin_Right, value: 0.7, isFactor: true);
        thanksLabel.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 0.3, isFactor: true);
        thanksLabel.pin(UIPin.Pin_Bottom, UIPin.Pin_Bottom, value: 0.7, isFactor: true);
        thanksLabel.hidden = true;
        
        mainView.add(thanksLabel);


        continueButt = new("UIButton").init(
            (0,0), (200, 75),
            "Continue",
            "SELACOFONT",
            UIButtonState.Create("", 0xFF5B92FF),
            hover: UIButtonState.Create("", 0xFFB1FFFF),
            selectedHover: UIButtonState.Create("", 0xFFB1FFFF)
        );
        continueButt.label.multiline = false;
        continueButt.label.fontScale = (2, 2);
        continueButt.pinWidth(UIView.Size_Min);
        
        //continueButt.pin(UIPin.Pin_Right, UIPin.Pin_Right, value: 0.042, offset: 710, isFactor: true);
        continueButt.pin(UIPin.Pin_HCenter, UIPin.Pin_Right, value: 0.042, offset: 355, isFactor: true);
        continueButt.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 0.8, offset: 25, isFactor: true);
        continueButt.setDisabled();

        let btn = new("UIButton").init((0,0), (100, 30), "< EMPTY >", "PDA13FONT",
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: Font.CR_UNTRANSLATED),
                        UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
                        UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13))
                    );

        /*continueButt2 = new("UIButton").init(
            (0,0), (275, 40),
            "Press any key to Continue",
            "PDA18FONT",
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: Font.CR_UNTRANSLATED),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13))
        );
        continueButt2.setTextPadding(10,8,10,8);
        continueButt2.label.multiline = false;
        //continueButt2.label.fontScale = (2, 2);
        continueButt2.pinWidth(UIView.Size_Min);
        continueButt2.pin(UIPin.Pin_HCenter, value: isWidescreen ? 1.0 : 1.36, isFactor: true);
        continueButt2.pin(UIPin.Pin_Bottom, UIPin.Pin_Bottom, offset: -40);
        continueButt2.hidden = true;
        mainView.add(continueButt2);*/

        /*resetButt = new("UIButton").init(
            (0,0), (200, 75),
            "Stay",
            "SELACOFONT",
            UIButtonState.Create("", 0xFF5B92FF),
            hover: UIButtonState.Create("", 0xFFB1FFFF),
            selectedHover: UIButtonState.Create("", 0xFFB1FFFF)
        );
        resetButt.label.multiline = false;
        resetButt.label.fontScale = (2, 2);
        resetButt.pinWidth(UIView.Size_Min);
        
        resetButt.pin(UIPin.Pin_Left, UIPin.Pin_Right, value: 0.042, offset: -20, isFactor: true);
        resetButt.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 0.8, offset: 25, isFactor: true);
        resetButt.setDisabled();*/

        int dawnPic = 1;
        
        if(players[consolePlayer].mo.health <= 50) {
            if(inv("SelacoArmor") <= 0) {
                dawnPic = 4;
            } else {
                dawnPic = 2;
            }
        } else {
            if(inv("SelacoArmor") <= 0) {
                dawnPic = 3;
            }
        }

        dawnImage = new("UIImage").init((0,0), (685, 1080), "DAWNEND" .. dawnPic, imgStyle: UIImage.Image_Aspect_Fit, imgAnchor: UIImage.ImageAnchor_Bottom);
        dawnImage.pin(UIPin.Pin_HCenter, UIPin.Pin_Right, value: 0.75, isFactor: true);
        dawnImage.pin(UIPin.Pin_Top);
        dawnImage.pin(UIPin.Pin_Bottom);
        dawnImage.pinWidth(685);
        mainView.add(dawnImage);

        // Slightly animate Dawn in
        let anim = dawnImage.animateFrame(
            0.25,
            fromAlpha: 0.1,
            toAlpha: 1,
            ease: Ease_Out
        );

        let a = new("UIViewPinAnimation").initComponents(dawnImage, 0.25, ease: Ease_Out);
        a.addValues(UIPin.Pin_HCenter, startVal: 0.85, endVal: 0.75);
        animator.add(a);

        mainView.add(continueButt);
        //mainView.add(resetButt);

        continueButt.alpha = 0;
        //resetButt.alpha = 0;

        //continueButt.navLeft = resetButt;
        //resetButt.navRight = continueButt;

        // If we are using the keyboard or gamepad primarily, select the first card by default
        if(isMenuPrimarilyUsingKeyboard() || isPrimarilyUsingGamepad()) {
            navigateTo(continueButt);
        }


        // Add hardcore image if we are on hardcore
        if(inv("HardcoreMode") > 0) {
            hardcoreImage = new("UIImage").init((0,0), (110, 110), "MODESEL4");
            hardcoreImage.pin(UIPin.Pin_Right, offset: -110);
            hardcoreImage.pin(UIPin.Pin_Top, offset: 110);
            mainView.add(hardcoreImage);
        }


        // Add mod list
        if(Wads.HasMods()) {
            wadsLayout = new("UIVerticalLayout").init((0, 0), (50, 50));
            wadsLayout.layoutMode = UIViewManager.Content_SizeParent;
            wadsLayout.itemSpacing = 2;
            wadsLayout.pinWidth(300);
            wadsLayout.pin(UIPin.Pin_Right, offset: -140);
            wadsLayout.pin(UIPin.Pin_Bottom, offset: -80);
            wadsLayout.alpha = 0;
            mainView.add(wadsLayout);

            let wadTitleLabel = new("UILabel").init((0,0), (600, 60), "Mods Installed:", "SEL21OFONT", textAlign: UIView.Align_Right, fontScale: (0.75, 0.75));
            wadTitleLabel.pin(UIPin.Pin_Left);
            wadTitleLabel.pin(UIPin.Pin_Right);
            wadTitleLabel.pinHeight(UIView.Size_Min);
            wadsLayout.addManaged(wadTitleLabel);
            

            Array<string> modNames;
            UIHelper.GetModList(modNames);

            // Display mod files
            for(int y = 0; y < modNames.size(); y++) {
                let wadLabel = new("UILabel").init((0,0), (600, 60), modNames[y], "SEL21OFONT", textAlign: UIView.Align_Right, fontScale: (0.65, 0.65));
                wadLabel.alpha = 0.7;
                wadLabel.pin(UIPin.Pin_Left);
                wadLabel.pin(UIPin.Pin_Right);
                wadLabel.pinHeight(UIView.Size_Min);
                wadsLayout.addManaged(wadLabel);
            }
        }
	}


    void addStatLine(string name, string value, bool complete = false, bool monospace = true, int valueCol = Font.CR_UNTRANSLATED) {
        let v = new("UIView").init((0,0), (400, 60));
        let nameLabel = new("UIAnimatedLabel").init((0,0), (600, 60), name, "PDA35OFONT", textAlign: UIView.Align_Left, fontScale: (1, 1));
        nameLabel.pin(UIPin.Pin_Left);
        nameLabel.pin(UIPin.Pin_Right);
        nameLabel.charLimit = 0;

        let valueLabel = new("UIAnimatedLabel").init((0,0), (600, 60), value, "PDA35OFONT", valueCol, textAlign: UIView.Align_Right, fontScale: (1, 1));
        valueLabel.monospace = monospace;
        valueLabel.pin(UIPin.Pin_Left);
        valueLabel.pin(UIPin.Pin_Right);
        valueLabel.charLimit = 0;

        v.add(nameLabel);
        v.add(valueLabel);
        v.pin(UIPin.Pin_Left);
        v.pin(UIPin.Pin_Right);
        v.pinHeight(60);

        statsLayout.addManaged(v);
    }


    void addExtraStatLine(string name, string value) {
        let v = new("UIView").init((0,0), (400, 45));
        let nameLabel = new("UIAnimatedLabel").init((0,2), (600, 60), name, "PDA35OFONT", textAlign: UIView.Align_Left, fontScale: (0.8, 0.8));
        nameLabel.pin(UIPin.Pin_Left);
        nameLabel.pin(UIPin.Pin_Right);
        nameLabel.charLimit = 0;

        let valueLabel = new("UIAnimatedLabel").init((0,2), (600, 60), value, "PDA35OFONT", 0xFFFBC200, textAlign: UIView.Align_Right, fontScale: (0.8, 0.8));
        valueLabel.pin(UIPin.Pin_Left);
        valueLabel.pin(UIPin.Pin_Right);
        valueLabel.charLimit = 0;

        v.add(nameLabel);
        v.add(valueLabel);
        v.pin(UIPin.Pin_Left);
        v.pin(UIPin.Pin_Right);
        v.pinHeight(40);

        extraStatsLayout.addManaged(v);
    }


    override void ticker() {
        Super.ticker();
        animated = true;

        if(!hasContinued) {
            if(ticks == 1) {
                completeLabel.start(800);
                //timeLabel.start(90);

                if(hardcoreImage) {
                    hardcoreImage.animateFrame(
                        0.25,
                        fromAlpha: 0,
                        toAlpha: 1.0,
                        ease: Ease_In
                    );
                }

                // Animate skill image
                let anim = skillImage.animateFrame(
                    0.15,
                    fromSize: (380, 380),
                    toSize: (160, 160),
                    fromAlpha: 0,
                    toAlpha: 1.0,
                    ease: Ease_In
                );
                anim.startTime += 0.15;
                anim.endTime += 0.15;
                anim.layoutEveryFrame = true;
                
                let anim2 = new("UIViewShakeAnimation").init(
                    skillImage, 
                    0.5,
                    10,
                    7
                );

                anim2.startTime += 0.15 + 0.15;
                anim2.endTime += 0.15 + 0.15;
                animator.add(anim2);

                // Animate mode image in a funky way
                if(g_randomizer) {
                    let anim = modeImage.animateFrame(
                        0.15,
                        fromSize: (380, 380),
                        toSize: (160, 160),
                        fromAlpha: 0,
                        toAlpha: 1.0,
                        ease: Ease_In
                    );
                    anim.startTime += 0.15 + 0.15;
                    anim.endTime += 0.15 + 0.15;
                    anim.layoutEveryFrame = true;

                    let anim2 = new("UIViewShakeAnimation").init(
                        modeImage, 
                        0.5,
                        10,
                        7
                    );

                    anim2.startTime += 0.15 + 0.15 + 0.15;
                    anim2.endTime += 0.15 + 0.15 + 0.15;
                    animator.add(anim2);
                }
            }

            int extraStatsStartTick = 20 + (statsLayout.numManaged() * 15) + 15;

            if(ticks < 20 + (statsLayout.numManaged() * 15 + 50)) {
                for(int x = 0; x < statsLayout.numManaged(); x++) {
                    if(ticks == 20 + (x * 15)) {
                        let a = UIAnimatedLabel(statsLayout.getManaged(x).viewAt(0));
                        a.start(110);
                    } else if(ticks == 20 + (x * 15) + 10) {
                        let a = UIAnimatedLabel(statsLayout.getManaged(x).viewAt(1));
                        a.start(110);
                    } else if(ticks == 20 + (x * 15) + 7) {
                        MenuSound("item/iconhide");
                    }
                }
            } 
            
            if(ticks < extraStatsStartTick + 15 + (extraStatsLayout.numManaged() * 15) + 50) {
                for(int x = 0; x < extraStatsLayout.numManaged(); x++) {
                    if(ticks == extraStatsStartTick + (x * 15)) {
                        let a = UIAnimatedLabel(extraStatsLayout.getManaged(x).viewAt(0));
                        a.start(110);
                    } else if(ticks == extraStatsStartTick + (x * 15) + 5) {
                        let a = UIAnimatedLabel(extraStatsLayout.getManaged(x).viewAt(1));
                        a.start(110);
                    } else if(ticks == extraStatsStartTick + (x * 15) + 7) {
                        MenuSound("item/iconhide");
                    }
                }
            }

            if(ticks == 65 && wadsLayout) {
                wadsLayout.animateFrame(
                    0.25,
                    fromPos: wadsLayout.frame.pos + (40, 0),
                    toPos: wadsLayout.frame.pos,
                    fromAlpha: 0,
                    toAlpha: 1.0,
                    ease: Ease_In
                );
            }
            

            if(ticks == 140) {
                //resetButt.setDisabled(false);
                continueButt.setDisabled(false);

                /*let anim = resetButt.animateFrame(
                    0.25,
                    fromAlpha: 0,
                    toAlpha: 1.0,
                    ease: Ease_In
                );
                anim.startTime += 0.1;
                anim.endTime += 0.1;*/

                let anim = continueButt.animateFrame(
                    0.25,
                    fromAlpha: 0,
                    toAlpha: 1.0,
                    ease: Ease_In
                );

                anim.startTime += 0.2;
                anim.endTime += 0.2;
            }

        } else if(ticks > 30 && hasContinued) {
            EventHandler.SendNetworkEvent("endLevelCon");
            //MenuSound("ui/choose2");
            close();
        }
    }

    override UIControl findFirstControl(int mkey) {
        if(continueButt && !continueButt.isDisabled()) return continueButt;
        if(continueButt2 && !continueButt2.isDisabled()) return continueButt2;
        return Super.findFirstControl(mkey);
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(mkey == MKEY_BACK) { return true; }
        
        /*if(hasContinued && ticks > 35) {
            EventHandler.SendNetworkEvent("endLevelCon");
            MenuSound("ui/choose2");
            close();
            return true;
        }*/
        
        /*switch (mkey) {
            case MKEY_Right:
                if(activeControl == null && lastActiveControl != null) {
                    navigateTo(lastActiveControl);
                    return logController(mkey, fromController);
                } else if(activeControl == null) {
                    navigateTo(continueButt);
                    return logController(mkey, fromController);
                }
                break;
            case MKEY_Left:
                if(activeControl == null && lastActiveControl != null) {
                    navigateTo(lastActiveControl);
                    return logController(mkey, fromController);
                } else if(activeControl == null) {
                    navigateTo(resetButt);
                    return logController(mkey, fromController);
                }
                break;
            default:
                break;
        }*/

		return Super.MenuEvent(mkey, fromcontroller);
	}

    override bool onUIEvent(UIEvent ev) {
        // If we have continued and a button was pressed
        /*if((ev.type < UIEvent.Type_FirstMouseEvent || ev.Type == UIEvent.Type_LButtonDown) && hasContinued && ticks > 35) {
            EventHandler.SendNetworkEvent("endLevelCon");
            MenuSound("ui/choose2");
            close();
            return true;
        }*/
		return Super.onUIEvent(ev);
	}

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated) {
            if(ctrl == continueButt && !hasContinued) {
                MenuSound("ui/choose2");

                keyboardSelect = !fromMouseEvent;
                
                // Continue
                // For now this means a thanks for playing menu, which we will just transition to here
                continueButt.removeFromSuperview();
                //resetButt.removeFromSuperview();

                // Animate everything away
                double tps = 0.3 / (statsLayout.numManaged() + extraStatsLayout.numManaged());
                int esnm = extraStatsLayout.numManaged();
                double esm = esnm * tps;
                int cnt = 0;
                for(int x = esnm - 1; x >= 0; x--) {
                    animateAway(extraStatsLayout.getManaged(x), cnt * tps);
                    cnt++;
                }

                for(int x = statsLayout.numManaged() - 1; x >= 0; x--) {
                    animateAway(statsLayout.getManaged(x), (cnt * tps) + esm);
                    cnt++;
                }

                animateAway(completeLabel, (cnt + 1) * tps);
                animateAway(dawnImage, 0.3);
                animateAway(visbg, 0.3);
                if(wadsLayout) {
                    animateAway(wadsLayout, 0.3);
                }

                hasContinued = true;
                ticks = 0;

                mouseMovementShowsCursor = false;
                hideCursor(true);

                return;
            }/* else if(ctrl == continueButt2 && hasContinued) {
                EventHandler.SendNetworkEvent("endLevelCon");
                close();
                return;
            }*/

            /*if(ctrl == resetButt) {
                // Reset to start
                MenuSound("ui/choose2");
                // Reset somehow?
                EventHandler.SendNetworkEvent("endLevelRes");
                close();
            }*/
        }
    }

    void animateAway(UIView v, double timeOffset = 0) {
        let anim = v.animateFrame(
            0.25,
            fromAlpha: 1,
            toAlpha: 0,
            ease: Ease_In
        );
        anim.startTime += timeOffset;
        anim.endTime += timeOffset;
    }

    override bool navigateTo(UIControl con, bool mouseSelection) {
		let ac = activeControl;

        let ff = Super.navigateTo(con, mouseSelection);

        if(ac != activeControl) {
            MenuSound("menu/cursor");
        }
        
        return ff;
	}
}