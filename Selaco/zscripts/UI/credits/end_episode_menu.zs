class EndEpisodeMenu : SelacoGamepadMenu {
    UIVerticalLayout statsLayout, accoLayout, accoLayout2, wadsLayout;
    UIAnimatedLabel accoTitle;
    UIButton continueButt;
    UIImage hardcoreImage, backgroundImage;
    UIView backgroundView;
    UIView accoContainer;
    UILabel stage2Text1, stage2Text2;
    UIImage modeImage;
    Array<UIView> fogViews;
    bool unlockedHardboiled, unlockedSpecialCampaign, unlockedBottomlessMags;   // Pass these to credits

    int closingTicks;

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
        ignoreUIScaling = true;
        menuActive = Menu.OnNoPause;

        backgroundView = new("UIView").init((0,0),(0,0));
        backgroundView.pinToParent();
        backgroundView.alpha = 0;
        mainView.add(backgroundView);

        S_ChangeMusic("INTRSTAR", looping: false, force: true);

        mainView.backgroundColor = 0xFF000000;

        int secretsFound, secretsTotal;
        int datapadsFound, datapadsTotal;
        int upgradesFound, upgradesTotal;
        int clearanceTotal, clearanceFound;
        int cabinetCardsFound, cabinetCardsTotal;
        int cabinetsUnlocked, cabinetsTotal;
        int kills, totalEnemies;

        // Get trackers
        StatTracker secretTracker           = Stats.FindTracker(STAT_SECRETS_FOUND);
        StatTracker datapadTracker          = Stats.FindTracker(STAT_DATAPADS_FOUND);
        StatTracker upgradesTracker         = Stats.FindTracker(STAT_UPGRADES_FOUND);
        StatTracker clearanceTracker        = Stats.FindTracker(STAT_CLEARANCE_CARDS);
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

        if(level.cluster != 0) {
            Array<int> countedLevelNums;

            for(int y = 0; y < LevelInfo.GetLevelInfoCount(); y++) {
                let info = LevelInfo.GetLevelInfo(y);
                if(info.cluster != level.cluster) continue;

                int x = info.levelnum;

                if(countedLevelNums.find(x) == countedLevelNums.size()) {
                    secretsFound += secretTracker && secretTracker.levelValues.size() > x ? secretTracker.levelValues[x] : 0;
                    secretsTotal += secretTracker && secretTracker.levelPossibleValues.size() > x ? secretTracker.levelPossibleValues[x] : 0;
                    
                    datapadsFound += datapadTracker && datapadTracker.levelValues.size() > x  ? datapadTracker.levelValues[x] : 0;
                    datapadsTotal += datapadTracker && datapadTracker.levelPossibleValues.size() > x ? datapadTracker.levelPossibleValues[x] : 0;

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
        }

        totalTime = ceil(double(totalTime) / 35.0);

        backgroundImage = new("UIImage").init((0,0), (10,10), "MENU5", imgStyle: UIImage.Image_Aspect_Fill, imgScale: (1.1, 1.1), imgAnchor: UIImage.ImageAnchor_Top);
        backgroundImage.pinToParent();
        backgroundView.add(backgroundImage);

        for(int x = 0; x < 30; x++) {
            let fog = new("ELFog").init((0,0), (frandom(600, 800), frandom(400, 600)), "ELFOG01");
            fog.pin(UIPin.Pin_HCenter, UIPin.Pin_Right, value: frandom(0, 1), isFactor: true);
            fog.pin(UIPin.Pin_VCenter, value: frandom(1.5, 2.2), isFactor: true);

            backgroundView.add(fog);
            fogViews.push(fog);
        }

        for(int x = 0; x < 25; x++) {
            let fog = new("ELSprite").init((0,0), (16, 16) * frandom(0.5, 1.3), "ELSPRI01");

            if(random(0,100) < 25)
                fog.pin(UIPin.Pin_HCenter, UIPin.Pin_Right, value: frandom(0, 0.14), isFactor: true);
            else
                fog.pin(UIPin.Pin_HCenter, UIPin.Pin_Right, value: frandom(0.22, 1), isFactor: true);

            fog.pin(UIPin.Pin_VCenter, value: frandom(0.05, 1.35), isFactor: true);

            backgroundView.add(fog);
            fogViews.push(fog);
        }
        

        let visbg = new("UIImage").init((0,0), (600,900), "STDFADE1");
        visbg.pin(UIPin.Pin_Right);
        visbg.pin(UIPin.Pin_Top);
        visbg.pin(UIPin.Pin_Bottom);
        visbg.pinWidth(820);
        mainView.add(visbg);

        // Create layout to show stats
        statsLayout = new("UIVerticalLayout").init((0, 0), (50, 50));
        statsLayout.itemSpacing = 0;
        statsLayout.pinWidth(710);
        statsLayout.pin(UIPin.Pin_Right, offset: -120);
        statsLayout.pin(UIPin.Pin_Top, offset: 100);
        statsLayout.pin(UIPin.Pin_Bottom);
        mainView.add(statsLayout);

        accoContainer = new("UIView").init((0,0), (0,0));
        accoContainer.pinHeight(UIView.Size_Min);
        accoContainer.pin(UIPin.Pin_Left);
        accoContainer.pin(UIPin.Pin_Right);
        accoContainer.clipsSubviews = false;

        accoLayout = new("UIVerticalLayout").init((0, 0), (50, 50));
        accoLayout.itemSpacing = 0;
        accoLayout.pin(UIPin.Pin_Left);
        accoLayout.pin(UIPin.Pin_Right, value: 0.5, isFactor: true);
        accoLayout.layoutMode = UIViewManager.Content_SizeParent;
        accoContainer.add(accoLayout);

        accoLayout2 = new("UIVerticalLayout").init((0, 0), (50, 50));
        accoLayout2.itemSpacing = 0;
        accoLayout2.pin(UIPin.Pin_Left, UIPin.Pin_Right, value: 0.5, isFactor: true);
        accoLayout2.pin(UIPin.Pin_Right);
        accoLayout2.layoutMode = UIViewManager.Content_SizeParent;
        accoContainer.add(accoLayout2);

        
        if(g_randomizer) {
            modeImage = new("UIImage").init((0,0), (160, 160), String.Format("GAMODE0%d", g_randomizer ? 2 : 1));
            modeImage.pin(UIPin.Pin_HCenter, UIPin.Pin_Left, value: 1.0, offset: 80 + 60, isFactor: true);
            modeImage.pin(UIPin.Pin_VCenter, UIPin.Pin_Top, value: 1.0, offset: 80 + 60, isFactor: true);
            modeImage.alpha = 0;
            mainView.add(modeImage);
        }


        // Add Title
        let titleLabel = new("UIAnimatedLabel").init((0,0), (500, 60), "CHAPTER 1 - RESULTS", "SEL52FONT", textAlign: UIView.Align_Center);
        titleLabel.pinWidth(1.0, isFactor: true);
        titleLabel.pinHeight(UIView.Size_Min);
        titleLabel.charLimit = 0;
        titleLabel.start(110, timeOffset: -0.89);
        statsLayout.addManaged(titleLabel);

        statsLayout.addSpacer(35);

        int thours = totalTime / 60 / 60;
        int tminutes = (totalTime - (thours * 60 * 60)) / 60;
        int tseconds = totalTime - (thours * 60 * 60) - (tminutes * 60);
        
        let skill = Stats.GetLowestSkill();
        
        // Localize important stats
        string timeLine = String.Format("%s:", StringTable.Localize("$STAT_TIME"));
        string secretLine = String.Format("%s:", StringTable.Localize("$STAT_SECRETS"));
        string upgradeLine = String.Format("%s:", StringTable.Localize("$STAT_UPGRADES"));
        string datapadLine = String.Format("%s:", StringTable.Localize("$Datapads"));
        string securityClearanceLine = String.Format("%s:", StringTable.Localize("$STAT_CLEARANCE"));
        string tradingcardLine = String.Format("%s:", StringTable.Localize("$STAT_TRADINGCARD"));
        string storageLine = String.Format("%s:", StringTable.Localize("$STAT_STORAGECABINETS"));
        string skillName = StringTable.Localize(String.Format("$SKILL_%d", skill));
        int skillCol = Font.CR_UNTRANSLATED;

        // Determine skill colour
        if(skill == SKILL_SMF) skillCol = 0xFF905EC7;
        else if(skill == 4) skillCol = 0xFFB4B4FF;
        else if(skill == 6) skillCol = 0xF37CCCA5;

        double timeOffset = -1.25;

        // Add important stats
        //if(g_randomizer) addStatLine("\c[GOLD]" .. StringTable.Localize("$MENU_RANDOMIZER_CAMPAIGN"), "", timeOffset, monospace: false);
        addStatLine(StringTable.Localize("$SKILL_TITLE") .. ":", skillName, timeOffset, monospace: false, valueCol: skillCol);
        addStatLine(timeLine, String.Format("%s:%s:%s", BaseStatusBar.FormatNumber(thours, 2, 2, 2), BaseStatusBar.FormatNumber(tminutes, 2, 2, 2), BaseStatusBar.FormatNumber(tseconds, 2, 2, 2)), timeOffset);
        if(!g_halflikemode) addStatLine(secretLine, String.Format("%d/%d", secretsFound, secretsTotal), timeOffset);
        addStatLine(upgradeLine, String.Format("%d/%d", upgradesFound, upgradesTotal), timeOffset);
        addStatLine(datapadLine, String.Format("%d/%d", datapadsFound, datapadsTotal), timeOffset);
        addStatLine(securityClearanceLine, String.Format("%d/%d", clearanceFound, clearanceTotal), timeOffset);
        addStatLine(storageLine, String.Format("%d/%d", cabinetsUnlocked, cabinetsTotal), timeOffset);

        statsLayout.addSpacer(35);
        accoTitle = new("UIAnimatedLabel").init((0,0), (500, 60), "ACCOLADES", "SEL52FONT", textAlign: UIView.Align_Center, fontScale: (0.75, 0.75));
        accoTitle.pinWidth(1.0, isFactor: true);
        accoTitle.pinHeight(UIView.Size_Min);
        accoTitle.charLimit = 0;
        accoTitle.start(110, timeOffset: timeOffset);
        timeOffset -= 0.1;
        statsLayout.addManaged(accoTitle);

        statsLayout.addSpacer(15);
        statsLayout.addManaged(accoContainer);

        // Add Accolades
        let s = Stats.FindStats();
        if(s && (s.achievements.size() > 0 || sv_cheats > 0 || cheats.value > 0)) {
            for(int x = 0; x < s.achievements.size(); x++) {
                string achTitle = "";

                switch(s.achievements[x]) {
                    case IACH_WILSON:
                        achTitle = "Returned Wilson";
                        break;
                    case IACH_VACBOT1:
                        achTitle = "Repaired VAC-BOT";
                        break;
                    case IACH_VACBOT2:
                        achTitle = "Rescued VAC-BOT";
                        break;
                    default:
                        continue;
                }

                let acco = new("UIAnimatedLabel").init((0,0), (500, 60), achTitle, "PDA35OFONT", textColor: 0xFFFFBF00, textAlign: UIView.Align_Center, fontScale: (0.65, 0.65));
                acco.pinWidth(1.0, isFactor: true);
                acco.pinHeight(UIView.Size_Min);
                acco.charLimit = 0;
                acco.start(110, timeOffset: timeOffset);
                timeOffset -= 0.1;
                accoLayout.addManaged(acco);
            }

            if(sv_cheats > 0 || cheats.value > 0) {
                let acco = new("UIAnimatedLabel").init((0,0), (500, 60), "Cheats used!", "PDA35OFONT", textColor: 0xFFFF4747, textAlign: UIView.Align_Center, fontScale: (0.65, 0.65));
                acco.pinWidth(1.0, isFactor: true);
                acco.pinHeight(UIView.Size_Min);
                acco.start(110, timeOffset: timeOffset);
                timeOffset -= 0.1;
                acco.charLimit = 0;
                accoLayout.addManaged(acco);
            }
        }

        Dawn d = Dawn(players[consoleplayer].mo);

        if(g_hardcoremode)  addAccolade(StringTable.Localize("$GAMEPLAY_MODIFIER_HARDCORE"),        timeOffset, 0xFFDD3333);
        if(g_bottomlessMags)  addAccolade(StringTable.Localize("$GAMEPLAY_MODIFIER_BOTTOMLESSMAGS"),  timeOffset, 0xFF56e257);
        if(g_scarcityMode)  addAccolade(StringTable.Localize("$GAMEPLAY_MODIFIER_ITEMSCARCITY"),    timeOffset);
        if(g_rifleStart)    addAccolade(StringTable.Localize("$GAMEPLAY_MODIFIER_RIFLESTART"),      timeOffset);
        //if(g_randomizer)    addAccolade(StringTable.Localize("$GAMEPLAY_MODIFIER_RANDOMIZER"),      timeOffset);
        if(g_hardboiled)    addAccolade(StringTable.Localize("$GAMEPLAY_MODIFIER_HARDBOILED"),      timeOffset);
        if(g_allowsavescumming)    addAccolade(StringTable.Localize("$GAMEPLAY_MODIFIER_SAVESCUMMER"),      timeOffset);
        if(g_nohealthregeneration)    addAccolade(StringTable.Localize("$GAMEPLAY_MODIFIER_NOHEALTHREGEN"),   timeOffset);
        if(g_armorup)       addAccolade(StringTable.Localize("$GAMEPLAY_MODIFIER_ARMORUP"),         timeOffset, 0xFF56e257);
        if(g_extraammo)     addAccolade(StringTable.Localize("$GAMEPLAY_MODIFIER_EXTRAAMMO"),       timeOffset, 0xFF56e257);
        
        // Shame Scarab mode users
        if(d && d.countInv("AltFireScarabMode")) {
            addAccolade(StringTable.Localize("$SCARAB_MODE_USER"), timeOffset, 0xFFDC73FF);
        }
        
        if((developer || (!sv_cheats && cheats.value == 0)) && Globals.GetInt("g_hardboiled") == 0 && skill > 2 && skill < 6) {
            //addAccolade(StringTable.Localize("$HARDBOILED_UNLOCKED"), timeOffset, 0xFFFAD364);
            unlockedHardboiled = true;
        }

        if((developer || (!sv_cheats && cheats.value == 0)) && Globals.GetInt("g_randomizer") == 0) {
            //addAccolade(StringTable.Localize("$RANDOMIZER_UNLOCKED"), timeOffset, 0xFFFAD364);
            unlockedSpecialCampaign = true;
        }

        if((developer || (!sv_cheats && cheats.value == 0)) && Globals.GetInt("g_bottomlessMags") == 0 && secretTracker && secretTracker.value >= 50) {
            unlockedBottomlessMags = true;
        }
        

        // Move accoLayout over if the second one is empty
        if(accoLayout2.numManaged() == 0) {
            accoLayout.firstPin(UIPin.Pin_Right).value = 1.0;
        }

        if(accoLayout.numManaged() == 0) {
            statsLayout.removeManaged(accoTitle);
        }

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
        
        //continueButt.pin(UIPin.Pin_Right, offset: -120);
        continueButt.pin(UIPin.Pin_HCenter, UIPin.Pin_Right, value: 1.0, offset: -(355 + 120), isFactor: true);
        continueButt.pin(UIPin.Pin_Bottom, UIPin.Pin_Bottom, offset: -80);
        continueButt.setDisabled();

        mainView.add(continueButt);

        continueButt.alpha = 0;
        
        // If we are using the keyboard or gamepad primarily, select the first card by default
        if(isMenuPrimarilyUsingKeyboard() || isPrimarilyUsingGamepad()) {
            navigateTo(continueButt);
        }


        // Add stage 2 views
        stage2Text1 = new("UILabel").init((0,0), (500, 60), StringTable.Localize("$END_EPISODE_HEADER"), "K32FONT", textAlign: UIView.Align_Center);
        stage2Text1.pinWidth(1.0, isFactor: true);
        stage2Text1.pinHeight(UIView.Size_Min);
        stage2Text1.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        stage2Text1.pin(UIPin.Pin_VCenter, value: 1.0, offset: -200, isFactor: true);
        stage2Text1.alpha = 0;
        mainView.add(stage2Text1);

        stage2Text2 = new("UILabel").init((0,0), (500, 60), StringTable.Localize("$END_EPISODE_TEXT"), "K32FONT", textAlign: UIView.Align_Center, fontScale: (0.78, 0.78));
        stage2Text2.multiline = true;
        stage2Text2.pinWidth(1200);
        stage2Text2.pinHeight(UIView.Size_Min);
        stage2Text2.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        stage2Text2.pin(UIPin.Pin_Top, UIPin.Pin_VCenter, value: 1.0, offset: -50, isFactor: true);
        stage2Text2.alpha = 0;
        mainView.add(stage2Text2);

        // Add hardcore image if we are on hardcore
        if(inv("HardcoreMode") > 0) {
            hardcoreImage = new("UIImage").init((0,0), (80, 80), "MODESEL4");
            hardcoreImage.pin(UIPin.Pin_Right, offset: -80);
            hardcoreImage.pin(UIPin.Pin_Top, offset: 80);
            hardcoreImage.alpha = 0;
            mainView.add(hardcoreImage);
        }


        // Add mod listing
        // Add mod list
        if(Wads.HasMods()) {
            wadsLayout = new("UIVerticalLayout").init((0, 0), (50, 50));
            wadsLayout.layoutMode = UIViewManager.Content_SizeParent;
            wadsLayout.itemSpacing = 2;
            wadsLayout.pinWidth(300);
            wadsLayout.pin(UIPin.Pin_Left, offset: 140);
            wadsLayout.pin(UIPin.Pin_Bottom, offset: -80);
            wadsLayout.alpha = 0;
            mainView.add(wadsLayout);
            
            // Display mod files
            let wadTitleLabel = new("UILabel").init((0,0), (600, 60), "Mods Installed:", "SEL21OFONT", textAlign: UIView.Align_Left, fontScale: (0.75, 0.75));
            wadTitleLabel.pin(UIPin.Pin_Left);
            wadTitleLabel.pin(UIPin.Pin_Right);
            wadTitleLabel.pinHeight(UIView.Size_Min);
            wadsLayout.addManaged(wadTitleLabel);
            

            Array<string> modNames;
            UIHelper.GetModList(modNames);

            for(int y = 0; y < modNames.size(); y++) {
                let wadLabel = new("UILabel").init((0,0), (600, 60), modNames[y], "SEL21OFONT", textAlign: UIView.Align_Left, fontScale: (0.65, 0.65));
                wadLabel.alpha = 0.7;
                wadLabel.pin(UIPin.Pin_Left);
                wadLabel.pin(UIPin.Pin_Right);
                wadLabel.pinHeight(UIView.Size_Min);
                wadsLayout.addManaged(wadLabel);
            }
        }
	}


    void addAccolade(string txt, out double timeOffset, int color = 0xFFFFFFFF) {
        let acco = new("UIAnimatedLabel").init((0,0), (500, 60), txt, "PDA35OFONT", textColor: color, textAlign: UIView.Align_Center, fontScale: (0.65, 0.65));
        acco.pinWidth(1.0, isFactor: true);
        acco.pinHeight(UIView.Size_Min);
        acco.start(110, timeOffset: timeOffset);
        timeOffset -= 0.1;
        acco.charLimit = 0;

        if(accoLayout.numManaged() > 3) {
            accoLayout2.addManaged(acco);
        } else {
            accoLayout.addManaged(acco);
        }
    }


    void addStatLine(string name, string value, out double timeOffset, bool complete = false, bool monospace = true, int valueCol = Font.CR_UNTRANSLATED) {
        let v = new("UIView").init((0,0), (400, 60));
        let nameLabel = new("UIAnimatedLabel").init((0,0), (600, 60), name, "PDA35OFONT", textAlign: UIView.Align_Left);
        nameLabel.pin(UIPin.Pin_Left);
        nameLabel.pin(UIPin.Pin_Right);
        nameLabel.charLimit = 0;
        nameLabel.start(110, timeOffset: timeOffset);

        timeOffset -= 0.28;

        let valueLabel = new("ELUIAnimatedLabel").init((0,0), (600, 60), value, "PDA35OFONT", textColor: valueCol, textAlign: UIView.Align_Right);
        valueLabel.monospace = monospace;
        valueLabel.pin(UIPin.Pin_Left);
        valueLabel.pin(UIPin.Pin_Right);
        valueLabel.charLimit = 0;
        valueLabel.start(110, timeOffset: timeOffset);

        timeOffset -= 0.14;

        v.add(nameLabel);
        v.add(valueLabel);
        v.pin(UIPin.Pin_Left);
        v.pin(UIPin.Pin_Right);
        v.pinHeight(60);

        statsLayout.addManaged(v);
    }


    override void ticker() {
        Super.ticker();
        animated = true;

        if(ticks == 1) {
            if(hardcoreImage) {
                hardcoreImage.animateFrame(
                    0.75,
                    fromAlpha: 0,
                    toAlpha: 1.0,
                    ease: Ease_In
                );
            }

            let anim = continueButt.animateFrame(
                0.25,
                fromAlpha: 0,
                toAlpha: 1.0,
                ease: Ease_In
            );
            anim.startTime += 4.5;
            anim.endTime += 4.5;


            backgroundView.animateFrame(
                5.25,
                fromAlpha: 0,
                toAlpha: 1.0,
                ease: Ease_Out
            );

            backgroundImage.animateImage(
                20.0,
                fromScale: (1.1, 1.1),
                toScale: (1,1),
                ease: Ease_Out
            );


            if(wadsLayout) {
                let anim = wadsLayout.animateFrame(
                    0.25,
                    fromPos: wadsLayout.frame.pos - (40, 0),
                    toPos: wadsLayout.frame.pos,
                    fromAlpha: 0,
                    toAlpha: 0.65,
                    ease: Ease_In
                );
                anim.startTime += 3.5;
                anim.endTime += 3.5;
            }
            
            if(modeImage) {
                let anim = modeImage.animateFrame(
                    0.25,
                    fromSize: (380, 380),
                    toSize: (160, 160),
                    fromAlpha: 0,
                    toAlpha: 1.0,
                    ease: Ease_In
                );
                anim.startTime += 0.35;
                anim.endTime += 0.35;
                anim.layoutEveryFrame = true;

                let anim2 = new("UIViewShakeAnimation").init(
                    modeImage, 
                    0.5,
                    10,
                    7
                );

                anim2.startTime += 0.25 + 0.35;
                anim2.endTime += 0.25 + 0.35;
                animator.add(anim2);
            }
        } else if(ticks == 4 * 35 + 15) {
            continueButt.setDisabled(false);
        }

        /*if(ticks < 20 + (statsLayout.numManaged() * 15 + 50)) {
            for(int x = 0; x < statsLayout.numManaged(); x++) {
                if(ticks == 20 + (x * 15) && statsLayout.getManaged(x).numSubviews()) {
                    let a = UIAnimatedLabel(statsLayout.getManaged(x).viewAt(0));
                    if(a) a.start(110);
                } else if(ticks == 20 + (x * 15) + 10 && statsLayout.getManaged(x).numSubviews() > 1) {
                    let a = UIAnimatedLabel(statsLayout.getManaged(x).viewAt(1));
                    if(a) a.start(110);
                } else if(ticks == 20 + (x * 15) && statsLayout.getManaged(x) is 'UIAnimatedLabel') {
                    UIAnimatedLabel(statsLayout.getManaged(x)).start(110);
                } else if(ticks == 20 + (x * 15) + 7) {
                    MenuSound("item/iconhide");
                }
            }
        }*/

        int closingPast = ticks - closingTicks - (35 * 10);
        if(closingTicks > 0 && closingPast > 0) {
            SetMusicVolume(Level.MusicVolume - (closingPast * 0.007));
        }

        if(closingTicks > 0 && closingPast == 1) {
            animateClosed();
        }


        if(closingTicks > 0 && closingPast > 6 * 35) {
            moveToCredits();
        }
    }

    void moveToCredits() {
        S_ChangeMusic("", looping: false, force: true);

        let m = new("EndGameCreditsMenu");
        m.init(self);
        m.unlockedSpecialCampaign = unlockedSpecialCampaign;
        m.unlockedHardboiled = unlockedHardboiled;
        m.unlockedBottomlessMags = unlockedBottomlessMags;
        m.ActivateMenu();
    }

    override UIControl findFirstControl(int mkey) {
        if(continueButt && !continueButt.isDisabled()) return continueButt;
        return Super.findFirstControl(mkey);
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(mkey == MKEY_BACK) { return true; }
        
		return Super.MenuEvent(mkey, fromcontroller);
	}

    override bool onUIEvent(UIEvent ev) {
        if((ev.type == UIEvent.Type_KeyUp || ev.type == UIEvent.Type_Char) && ev.IsShift && ev.IsCtrl && ev.keyChar == UIEvent.Key_Tab) {
            MenuSound("menu/advance");
            moveToCredits();
        }

		return Super.onUIEvent(ev);
	}

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated) {
            if(ctrl == continueButt) {
                MenuSound("ui/choose2");
                continueButt.setDisabled(true);
                animateStage2();
            }
        }
    }


    void animateStage2() {
        closingTicks = ticks;

        continueButt.animateFrame(
            0.15,
            toAlpha: 0,
            ease: Ease_In
        );

        if(hardcoreImage) hardcoreImage.animateFrame(
            0.5,
            toAlpha: 0.5,
            ease: Ease_In
        );

        backgroundView.animateFrame(
            2.8,
            toAlpha: 0.2,
            ease: Ease_Out
        );

        for(int x = 0; x < fogViews.size(); x++) {
            let anim = fogViews[x].animateFrame(
                2.8,
                toAlpha: 0.2,
                ease: Ease_Out
            );
        }

        let anim = stage2Text1.animateFrame(
            0.5,
            toAlpha: 1.0,
            ease: Ease_In
        );
        anim.startTime += 3.0;
        anim.endTime += 3.0;

        anim = stage2Text2.animateFrame(
            0.5,
            toAlpha: 1.0,
            ease: Ease_In
        );
        anim.startTime += 5.5;
        anim.endTime += 5.5;


        for(int x = statsLayout.numManaged() - 1, cnt = 0; x >= 0; x--) {
            let v = statsLayout.getManaged(cnt);

            if(v) {
                animateAway(v, x * 0.025);
                cnt++;
            }
        }


        if(wadsLayout) {
            wadsLayout.animateFrame(
                0.25,
                toAlpha: 0.2,
                ease: Ease_In
            );
        }

        if(modeImage) {
            modeImage.animateFrame(
                0.5,
                toAlpha: 0.1,
                ease: Ease_In
            );
        }
    }


    void animateClosed() {
        if(hardcoreImage) hardcoreImage.animateFrame(
            0.5,
            toAlpha: 0,
            ease: Ease_In
        );

        let anim = backgroundView.animateFrame(
            4.15,
            toAlpha: 0,
            ease: Ease_In
        );
        anim.startTime += 0.2;
        anim.endTime += 0.2;

        for(int x = 0; x < fogViews.size(); x++) {
            let anim = fogViews[x].animateFrame(
                4.5,
                toAlpha: 0,
                ease: Ease_In
            );
        }

        stage2Text1.animateFrame(
            4.5,
            toAlpha: 0,
            ease: Ease_In
        );

        stage2Text2.animateFrame(
            4.5,
            toAlpha: 0,
            ease: Ease_In
        );

        if(wadsLayout) {
            let anim = wadsLayout.animateFrame(
                0.25,
                toAlpha: 0,
                ease: Ease_In
            );
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


class ELFog : UIImage {
    double seed;

    ELFog init(Vector2 pos, Vector2 size, string image, NineSlice slices = null, ImageStyle imgStyle = Image_Scale, Vector2 imgScale = (1,1), ImageAnchor imgAnchor = ImageAnchor_Middle) {
        Super.init(pos, size, image, slices, imgStyle, imgScale, imgAnchor);

        seed = random(0,360);

        return self;
    }


    override void draw() {
        if(hidden) { return; }

        double time = getMenu().getRenderTime();
        Vector2 pos = frame.pos;
        Vector2 size = frame.size;
        double ccalpha = cAlpha;
        frame.pos.x += -sin(time * 50.0 + seed) * 200.0;
        frame.pos.y += cos(time * 45.0 + seed) * 100.0;
        frame.size *= 1.15 + (sin(time * 35 + seed) * 0.5);
        cAlpha *= 0.5 + (sin(time * 53.0 + seed) * 0.5);

        Super.draw();

        frame.pos = pos;
        frame.size = size;
        cAlpha = ccalpha;
    }
}


class ELSprite : UIImage {
    double seed, speed;
    double dir;

    ELSprite init(Vector2 pos, Vector2 size, string image, NineSlice slices = null, ImageStyle imgStyle = Image_Scale, Vector2 imgScale = (1,1), ImageAnchor imgAnchor = ImageAnchor_Middle) {
        Super.init(pos, size, image, slices, imgStyle, imgScale, imgAnchor);

        seed = frandom(0,360);
        speed = frandom(10, 30);
        dir = random(0,100) > 50 ? 1.0 : -1.0;

        return self;
    }


    override void draw() {
        if(hidden) { return; }

        double time = getMenu().getRenderTime();
        Vector2 pos = frame.pos;
        Vector2 size = frame.size;
        double ccalpha = cAlpha;
        frame.pos.x += -sin(time * (speed * 1.15) + seed) * 50.0 * dir;
        frame.pos.y += cos(time * speed + seed) * 100.0 * dir;
        frame.size *= 1.15 + (sin(time * 35 + seed) * 0.5);
        cAlpha *= 0.5 + (sin(time * (speed * 2.1) + seed) * 0.5);

        Super.draw();

        frame.pos = pos;
        frame.size = size;
        cAlpha = ccalpha;
    }
}


class ELUIAnimatedLabel : UIAnimatedLabel {
    bool hasSounded;

    override void draw() {
        let cl = charLimit;

        Super.Draw();

        let cnt = max(1, text.CodePointCount() - 3);
        if(!hasSounded && charLimit >= cnt) {
            hasSounded = true;

            // Play the sound
            Menu.MenuSound("item/iconhide");
        }
    }
}