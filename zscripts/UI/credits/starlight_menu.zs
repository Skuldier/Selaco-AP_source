class StarlightMenu : SelacoGamepadMenu {
    enum StarlightLevel {
        Starlight_Green = 1,
        Starlight_Red,
        Starlight_Blue,
        Starlight_Purple
    };

    UIImage hardcoreImage;
    UIButton continueButt;
    //UIButton resetButton;
    UIVerticalLayout statsLayout;

    UIScrollBG scrollBG, scrollBG2;
    UIImage starlightText, starlightLogo, visBG;
    RevealImage circleImages[4], lineImages[3];
    UIImage keyImages[4];
    UIAnimatedLabel completeLabel, descriptionLabel;
    StarlightCompletion completedLevels[4];
    StarlightCompletion mostRecentCompletion;
    int numLevelsCompleted, currentLevel;
    
    bool hasContinued, isClosing, isResetting, keyboardSelect;
    bool hasSeenBefore;

    int, int inv(class<Inventory> cls) {
        let i = players[consoleplayer].mo.FindInventory(cls);
        if(i) {
            let maxA = i.maxAmount == 0 ? GetDefaultByType(cls).maxAmount : i.maxAmount;
            return i.amount, maxA;
        }

        return 0,  GetDefaultByType(cls).maxAmount;
    }


    void checkKey(class<StarlightCompletion> cls) {
        let clev = StarlightCompletion(players[consolePlayer].mo.FindInventory(cls));
        if(clev) {
            completedLevels[clev.order] = clev;
            numLevelsCompleted++;
            if(!mostRecentCompletion || clev.order > mostRecentCompletion.order) mostRecentCompletion = clev;
        }
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
        StatTracker clearanceTracker        = Stats.FindTracker(STAT_CLEARANCE_CARDS);
        StatTracker cabinetCardTracker      = Stats.FindTracker(STAT_CABINETCARDS_FOUND);
        StatTracker cabinetTracker          = Stats.FindTracker(STAT_STORAGECABINETS_OPENED);
        StatTracker killTracker             = Stats.FindTracker(STAT_KILLS);
        StatTracker cheats                  = Stats.FindTracker(STAT_YOUCHEATED);


        // Determine which keys we have, in what order
        checkKey('StarlightGreenCompleted');
        checkKey('StarlightRedCompleted');
        checkKey('StarlightPurpleCompleted');
        checkKey('StarlightBlueCompleted');

        // TODO: LANGUAGE this shit
        // You wont. - Nexxtic
        string keyText = "NO KEY RETRIEVED!?";
        string descriptionText = "No description found!";

        // Determine which level we are on
        switch(level.levelNum) {
            case 26:
                currentLevel = Starlight_Green;
                hasSeenBefore = players[consolePlayer].mo.countInv("StarlightGreenCompleted") > 1;
                keyText = hasSeenBefore ? "\c[GREEN]GREEN SECTOR" : "\c[GREEN]GREEN KEY RETRIEVED";
                descriptionText = "$STARLIGHT_INTERMISSION_GREEN";
                break;
            case 27:
                currentLevel = Starlight_Red;
                hasSeenBefore = players[consolePlayer].mo.countInv("StarlightRedCompleted") > 1;
                keyText = hasSeenBefore ? "\c[RED]RED SECTOR" : "\c[RED]RED KEY RETRIEVED";
                descriptionText = "$STARLIGHT_INTERMISSION_RED";
                break;
            case 28:
                currentLevel = Starlight_Blue;
                hasSeenBefore = players[consolePlayer].mo.countInv("StarlightBlueCompleted") > 1;
                keyText = hasSeenBefore ? "\c[LIGHTBLUE]BLUE SECTOR" : "\c[LIGHTBLUE]BLUE KEY RETRIEVED";
                descriptionText = "$STARLIGHT_INTERMISSION_BLUE";
                break;
            case 29:
                currentLevel = Starlight_Purple;
                hasSeenBefore = players[consolePlayer].mo.countInv("StarlightPurpleCompleted") > 1;
                keyText = hasSeenBefore ? "\c[PURPLE]PURPLE SECTOR" : "\c[PURPLE]PURPLE KEY RETRIEVED";
                descriptionText = "$STARLIGHT_INTERMISSION_PURPLE";
                break;
            default:
                currentLevel = -1;
                if(mostRecentCompletion is 'StarlightGreenCompleted') { keyText = "\c[GREEN]GREEN KEY RETRIEVED"; descriptionText = "$STARLIGHT_INTERMISSION_GREEN"; }
                else if(mostRecentCompletion is 'StarlightRedCompleted') { keyText = "\c[RED]RED KEY RETRIEVED"; descriptionText = "$STARLIGHT_INTERMISSION_RED"; }
                else if(mostRecentCompletion is 'StarlightBlueCompleted') { keyText = "\c[LIGHTBLUE]BLUE KEY RETRIEVED"; descriptionText = "$STARLIGHT_INTERMISSION_BLUE"; }
                else if(mostRecentCompletion is 'StarlightPurpleCompleted') { keyText = "\c[PURPLE]PURPLE KEY RETRIEVED"; descriptionText = "$STARLIGHT_INTERMISSION_PURPLE"; }
                break;
        }


        // Get stats for this map only
        int x = level.levelnum;

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

        
        // Get total played time
        uint totalTime = ceil(double(level.time) / 35.0);

        visbg = new("UIImage").init((0,0), (10,10), "STRLTBK2", imgStyle: UIImage.Image_Aspect_Fill);
        visbg.alpha = 0;
        visbg.pinToParent();
        mainView.add(visbg);

        scrollBG = new("UIScrollBG").init("STRLTBKG", null);
        //scrollBG.alpha = 0.025;
        scrollBG.alpha = 0;
        scrollBG.force = (-0.02, 0);
        scrollBG.edgeOffset = (0,0);
        scrollBG.ignoreMouse = true;
        scrollBG.filter = true;
        scrollBG.scrollScale = (1.5, 1.5);
        mainView.add(scrollBG);

        scrollBG2 = new("UIScrollBG").init("STRLTBK3", null);
        scrollBG2.alpha = 0;
        scrollBG2.force = (-0.028, 0);
        scrollBG2.wobbleSpeed = 360.0 / 15.0;
        scrollBG2.wobbleAmount = 0.35;
        scrollBG2.edgeOffset = (0,0);
        scrollBG2.ignoreMouse = true;
        scrollBG2.filter = true;
        scrollBG2.scrollScale = (1.5, 1.5);
        mainView.add(scrollBG2);
        scrollBG2.move = (10, 8);

        starlightLogo = new("UIImage").init((0,0), (320, 380), "STRLTLOG");
        starlightLogo.pin(UIPin.Pin_HCenter, value: 1, isFactor: true);
        starlightLogo.pin(UIPin.Pin_VCenter, UIPin.Pin_Top, offset: 230);
        starlightLogo.alpha = 0;
        mainView.add(starlightLogo);

        starlightText = new("UIImage").init((0,0), (650, 70), "STRLTTXT");
        starlightText.pin(UIPin.Pin_HCenter, value: 1, isFactor: true);
        starlightText.pin(UIPin.Pin_VCenter, UIPin.Pin_Top, offset: 470);
        starlightText.pinWidth(UIView.Size_Min);
        starlightText.pinHeight(UIView.Size_Min);
        starlightText.alpha = 0;
        mainView.add(starlightText);


        completeLabel = new("UIAnimatedLabel").init((0,0), (600, 80), keytext, "SEL46FONT", textAlign: UIView.Align_Center | UIView.Align_Top, fontScale: (0.72, 0.75));
        completeLabel.pin(UIPin.Pin_HCenter, value: 1, isFactor: true);
        completeLabel.pin(UIPin.Pin_Top, offset: 510);
        completeLabel.charLimit = 0;
        completeLabel.shadowOffset = (3, 3);
        mainView.add(completeLabel);

        // Create layout to show stats
        statsLayout = new("UIVerticalLayout").init((0, 0), (50, 50));
        statsLayout.layoutMode = UIViewManager.Content_SizeParent;
        statsLayout.itemSpacing = 0;
        statsLayout.pinWidth(500);
        statsLayout.pin(UIPin.Pin_HCenter, value: 1, isFactor: true);
        statsLayout.pin(UIPin.Pin_Top, offset: 585);
        mainView.add(statsLayout);


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

        // Add important stats
        if(secretsTotal > 0)    addStatLine(secretLine, String.Format("%d/%d", secretsFound, secretsTotal));
        if(upgradesTotal > 0)   addStatLine(upgradeLine, String.Format("%d/%d", upgradesFound, upgradesTotal));
        if(datapadsTotal > 0)   addStatLine(datapadLine, String.Format("%d/%d", datapadsFound, datapadsTotal));
        if(clearanceTotal > 0)  addStatLine(securityClearanceLine, String.Format("%d/%d", clearanceFound, clearanceTotal));
        if(cabinetsTotal > 0)   addStatLine(storageLine, String.Format("%d/%d", cabinetsUnlocked, cabinetsTotal));

        // Add extra stats
        if(cheats.value > 0) {
            addStatLine("\c[GOLD]Cheat mode enabled", "");
        }

        string timeLine = String.Format("%s:", StringTable.Localize("$STAT_TIME"));
        string creditsLine = String.Format("%s:", StringTable.Localize("$STAT_CREDITS"));

        //addExtraStatLine(timeLine, String.Format("%s:%s:%s", BaseStatusBar.FormatNumber(thours, 2, 2, 2), BaseStatusBar.FormatNumber(tminutes, 2, 2, 2), BaseStatusBar.FormatNumber(tseconds, 2, 2, 2)));
        //addExtraStatLine(creditsLine, String.Format("%d", inv("creditsCount")));
        let hiState = CommonUI.barBackgroundState();
        hiState.textColor = 0xFFB4B4FF;

        // Continue button 1
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

        continueButt.pin(UIPin.Pin_Top, offset: 820);
        //continueButt.pin(UIPin.Pin_HCenter, UIPin.Pin_HCenter, value: 1, offset: -200, isFactor: true);
        continueButt.pin(UIPin.Pin_HCenter, UIPin.Pin_HCenter, value: 1, isFactor: true);
        continueButt.setDisabled();
        mainView.add(continueButt);
        continueButt.alpha = 0;

        // Reset Button
        /*resetButton = new("UIButton").init(
            (0,0), (200, 75),
            "Stay Here",
            "SELACOFONT",
            UIButtonState.Create("", 0xFF5B92FF),
            hover: UIButtonState.Create("", 0xFFB1FFFF),
            selectedHover: UIButtonState.Create("", 0xFFB1FFFF)
        );
        resetButton.label.multiline = false;
        resetButton.label.fontScale = (2, 2);
        resetButton.pinWidth(UIView.Size_Min);

        resetButton.pin(UIPin.Pin_Top, offset: 820);
        resetButton.pin(UIPin.Pin_HCenter, UIPin.Pin_HCenter, value: 1, offset: 200, isFactor: true);
        resetButton.setDisabled();
        mainView.add(resetButton);
        resetButton.alpha = 0;*/

        // If we are using the keyboard or gamepad primarily, select the first card by default
        /*if(isMenuPrimarilyUsingKeyboard() || isPrimarilyUsingGamepad()) {
            navigateTo(continueButt);
        }*/


        // Add hardcore image if we are on hardcore
        if(inv("HardcoreMode") > 0) {
            hardcoreImage = new("UIImage").init((0,0), (110, 110), "MODESEL4");
            hardcoreImage.pin(UIPin.Pin_Right, offset: -110);
            hardcoreImage.pin(UIPin.Pin_Top, offset: 110);
            hardcoreImage.alpha = 0;
            mainView.add(hardcoreImage);
        }


        // Create second page items
        let circMid = 545 - 60;

        // Lines
        for(int x = 0; x < 3; x++) {
            lineImages[x] = new("RevealImage").init((0,0), (70, 34), "STRLTLIN");
            lineImages[x].pin(UIPin.Pin_HCenter, value: 1, offset: -339 + 113 + (226 * x), isFactor: true);
            lineImages[x].pin(UIPin.Pin_VCenter, UIPin.Pin_Top, offset: circMid);
            mainView.add(lineImages[x]);
            lineImages[x].alpha = 0;
        }

        // Circles
        for(int x = 0; x < 4; x++) {
            circleImages[x] = new("RevealImage").init((0,0), (180, 180), "STRLTCIR");
            circleImages[x].pin(UIPin.Pin_HCenter, value: 1, offset: -339 + (226 * x), isFactor: true);
            circleImages[x].pin(UIPin.Pin_VCenter, UIPin.Pin_Top, offset: circMid);
            mainView.add(circleImages[x]);
            circleImages[x].alpha = 0;

            keyImages[x] = new("UIImage").init((0,0), (180, 180), "");
            keyImages[x].pin(UIPin.Pin_HCenter, value: 1, offset: -339 + (226 * x), isFactor: true);
            keyImages[x].pin(UIPin.Pin_VCenter, UIPin.Pin_Top, offset: circMid);
            mainView.add(keyImages[x]);
            keyImages[x].alpha = 0;

            let clev = completedLevels[x];
            if(clev) {
                if(clev is 'StarlightGreenCompleted') {
                    circleImages[x].blendColor = 0xFF00D900;
                    keyImages[x].setImage("STRLTCRG");
                }
                else if(clev is 'StarlightRedCompleted') {
                    circleImages[x].blendColor = 0xFFF83D44;
                    keyImages[x].setImage("STRLTCRR");
                }
                else if(clev is 'StarlightPurpleCompleted') {
                    circleImages[x].blendColor = 0xFFA300D9;
                    keyImages[x].setImage("STRLTCRP");
                }
                else if(clev is 'StarlightBlueCompleted') {
                    circleImages[x].blendColor = 0xFF3DD1F8;
                    keyImages[x].setImage("STRLTCRB");
                }
            } else {
                keyImages[x].setImage("STRLTCRQ");
            }
        }

        

        descriptionLabel = new("UIAnimatedLabel").init((0,0), (860, 100), StringTable.Localize(descriptionText), "PDA18FONT");
        descriptionLabel.pin(UIPin.Pin_HCenter, value: 1, isFactor: true);
        descriptionLabel.pin(UIPin.Pin_Top, offset: circMid + 120);
        descriptionLabel.charLimit = 0;
        descriptionLabel.alpha = 0;
        descriptionLabel.shadowOffset = (2, 2);
        mainView.add(descriptionLabel);


        //continueButt.navRight = resetButton;
        //resetButton.navLeft = continueButt;
	}


    void addStatLine(string name, string value, bool complete = false) {
        let v = new("UIView").init((0,0), (400, 60));
        let nameLabel = new("UIAnimatedLabel").init((0,0), (600, 30), name, "SEL21FONT", textAlign: UIView.Align_Left, fontScale: (1,1));
        nameLabel.pin(UIPin.Pin_Left);
        nameLabel.pin(UIPin.Pin_Right);
        nameLabel.charLimit = 0;

        let valueLabel = new("UIAnimatedLabel").init((0,0), (600, 30), value, "SEL21FONT", textAlign: UIView.Align_Right, fontScale: (1,1));
        valueLabel.monospace = true;
        valueLabel.pin(UIPin.Pin_Left);
        valueLabel.pin(UIPin.Pin_Right);
        valueLabel.charLimit = 0;

        v.add(nameLabel);
        v.add(valueLabel);
        v.pin(UIPin.Pin_Left);
        v.pin(UIPin.Pin_Right);
        v.pinHeight(30);

        statsLayout.addManaged(v);
    }

    
    const STATS_START_TICKS = 65;
    const IN_START_TIME = 0.3;

    override void ticker() {
        Super.ticker();
        animated = true;

        if(!hasContinued && !isClosing) {
            if(ticks == 1) {
                visbg.animateFrame(
                    1,
                    fromAlpha: 0,
                    toAlpha: 1.0,
                    ease: Ease_Out
                );

                scrollBG.animateFrame(
                    4,
                    fromAlpha: 0,
                    toAlpha: 0.025,
                    ease: Ease_In_Out
                );

                scrollBG2.animateFrame(
                    6,
                    fromAlpha: 0,
                    toAlpha: 0.025,
                    ease: Ease_In_Out
                );

                let anim = starlightLogo.animateFrame(
                    0.2,
                    fromSize: starlightLogo.frame.size * 1.5,
                    toSize: starlightLogo.frame.size,
                    fromAlpha: 0,
                    toAlpha: 1.0,
                    ease: Ease_Out
                );
                anim.layoutEveryFrame = true;
                anim.startTime += IN_START_TIME;
                anim.endTime += IN_START_TIME;

                anim = starlightText.animateFrame(
                    0.25,
                    fromPos: starlightText.frame.pos + (0, 75),
                    toPos: starlightText.frame.pos,
                    fromAlpha: 0,
                    toAlpha: 1.0,
                    ease: Ease_Out
                );
                anim.startTime += 0.17 + IN_START_TIME;
                anim.endTime += 0.17 + IN_START_TIME;
                
                completeLabel.start(80);
                completeLabel.animStart += 0.55 + IN_START_TIME;

                if(hardcoreImage) {
                    anim = hardcoreImage.animateFrame(
                        0.25,
                        fromAlpha: 0,
                        toAlpha: 1.0,
                        ease: Ease_In
                    );
                    anim.startTime += 0.55 + IN_START_TIME;
                    anim.endTime += 0.55 + IN_START_TIME;
                }
            }

            if(ticks < STATS_START_TICKS + (statsLayout.numManaged() * 15 + 50)) {
                for(int x = 0; x < statsLayout.numManaged(); x++) {
                    if(ticks == STATS_START_TICKS + (x * 15)) {
                        let a = UIAnimatedLabel(statsLayout.getManaged(x).viewAt(0));
                        a.start(110);
                    } else if(ticks == STATS_START_TICKS + (x * 15) + 10) {
                        let a = UIAnimatedLabel(statsLayout.getManaged(x).viewAt(1));
                        a.start(110);
                    } else if(ticks == STATS_START_TICKS + (x * 15) + 7) {
                        MenuSound("item/iconhide");
                    }
                }
            } 

            if(ticks == 150) {
                continueButt.setDisabled(false);
                //resetButton.setDisabled(false);

                if(isMenuPrimarilyUsingKeyboard() || isPrimarilyUsingGamepad()) {
                    navigateTo(continueButt);
                }

                let anim = continueButt.animateFrame(
                    0.25,
                    fromAlpha: 0,
                    toAlpha: 1.0,
                    ease: Ease_In
                );

                /*resetButton.animateFrame(
                    0.25,
                    fromAlpha: 0,
                    toAlpha: 1.0,
                    ease: Ease_In
                );*/
            }

        }
        else if(!isClosing) {
            if(ticks == 8) {
                // Start continue and reset fade in
                continueButt.firstPin(UIPin.Pin_HCenter).offset = 0;
                continueButt.layout();

                let anim = continueButt.animateFrame(
                    0.25,
                    fromAlpha: 0,
                    toAlpha: 1,
                    ease: Ease_In
                );
                anim.startTime += 3;
                anim.endTime += 3;

                /*anim = resetButton.animateFrame(
                    0.25,
                    fromAlpha: 0,
                    toAlpha: 1,
                    ease: Ease_In
                );
                anim.startTime += 3.1;
                anim.endTime += 3.1;*/
            }
            if(ticks == TICRATE * 3) {
                continueButt.setDisabled(false);

                if(isMenuPrimarilyUsingKeyboard() || isPrimarilyUsingGamepad()) {
                    navigateTo(continueButt);
                }
            }
        } else if(isClosing && ticks == 36) {
            if(isResetting) EventHandler.SendNetworkEvent("endStarlightRes");
            else EventHandler.SendNetworkEvent("endStarlightCon");
            close();
        }
    }


    override UIControl findFirstControl(int mkey) {
        /*switch(mkey) {
            case MKEY_Left:
                return continueButt;
            case MKEY_Right:
                return resetButton.isDisabled() ? continueButt : resetButton;
            default:
                return continueButt;
        }*/
        return continueButt;

        return Super.findFirstControl(mkey);
    }


    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(mkey == MKEY_BACK) { return true; }  // Block the back key
        
        switch (mkey) {

            default:
                break;
        }

		return Super.MenuEvent(mkey, fromcontroller);
	}

    override bool onUIEvent(UIEvent ev) {
		return Super.onUIEvent(ev);
	}

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(!isClosing && event == UIHandler.Event_Activated) {
            if(ctrl == continueButt) {
                MenuSound("ui/choose2");

                keyboardSelect = !fromMouseEvent;

                if(!hasContinued && !hasSeenBefore) {
                    ticks = 0;
                    animateContinue();
                } else {
                    isClosing = true;
                    animateAway();
                    ticks = 0;
                }
                

                return;
            } /*else if(ctrl == resetButton) {
                isClosing = true;
                isResetting = true;
                animateAway();
                ticks = 0;
            }*/
        }
    }

    void animateContinue() {
        hasContinued = true;

        // Animate first page out
        continueButt.setDisabled();
        continueButt.animateFrame(
            0.15,
            toAlpha: 0,
            ease: Ease_Out
        );
        clearNavigation();

        /*resetButton.setDisabled();
        resetButton.animateFrame(
            0.15,
            toAlpha: 0,
            ease: Ease_Out
        );*/
        
        let anim = starlightText.animateFrame(
            0.35,
            fromPos: starlightText.frame.pos,
            toPos: starlightText.frame.pos + (0, 35),
            toAlpha: 0,
            ease: Ease_In
        );
        anim.startTime += 0.15;
        anim.endTime += 0.15;
        
        anim = completeLabel.animateFrame(
            0.15,
            toAlpha: 0,
            ease: Ease_In
        );
        anim.startTime += 0.1;
        anim.endTime += 0.1;


        anim = statsLayout.animateFrame(
            0.25,
            fromPos: statsLayout.frame.pos,
            toPos: statsLayout.frame.pos + (0, 75),
            toAlpha: 0,
            ease: Ease_In
        );
        anim.startTime += 0.15;
        anim.endTime += 0.15;


        anim = starlightLogo.animateFrame(
            0.55,
            toSize: starlightLogo.frame.size * 0.75,
            ease: Ease_In_Out
        );
        anim.startTime += 0.4;
        anim.endTime += 0.4;
        anim.layoutEveryFrame = true;


        // Animate second page in
        // Animate each circle in
        for(int x = 0; x < 4; x++) {
            circleImages[x].setAlpha(1);
            circleImages[x].revealTime = 0.2;
            circleImages[x].startAnim(0.7 + (x * 0.25));

            anim = keyImages[x].animateFrame(
                0.25,
                fromSize: keyImages[x].frame.size * 1.5,
                toSize: keyImages[x].frame.size,
                toAlpha: 1,
                ease: Ease_Out
            );
            anim.startTime += 0.5 + 0.15 + (x * 0.25);
            anim.endTime += 0.5 + 0.15 + (x * 0.25);
            anim.layoutEveryFrame = true;
        }

        // Each line
        for(int x = 0; x < 3; x++) {
            if(x + 1 > numLevelsCompleted) break;

            lineImages[x].setAlpha(1);
            lineImages[x].revealTime = 0.18;
            lineImages[x].startAnim(0.7 + 0.19 + 0.15 + (x * 0.25));
        }

        // Animate keys/placeholders in


        // Animate description in
        anim = descriptionLabel.animateFrame(
            0.1,
            toAlpha: 1,
            ease: Ease_Out
        );
        anim.startTime += 1.55;
        anim.endTime += 1.55;
        descriptionLabel.start(80);
        descriptionLabel.animStart += 1.55;

    }


    void animateAway() {
        mainView.animateFrame(
            1,
            toAlpha: 0,
            ease: Ease_In_Out
        );

        continueButt.animateFrame(
            0.15,
            toAlpha: 0,
            ease: Ease_In
        );

        /*if(resetButton.alpha > 0) {
            resetButton.animateFrame(
                0.15,
                toAlpha: 0,
                ease: Ease_In
            );
        }*/


        if(hasContinued) {
            for(int x = 0; x < 4; x++) {
                let anim = circleImages[x].animateFrame(
                    0.2,
                    toPos: circleImages[x].frame.pos + (0, 40),
                    toAlpha: 0,
                    ease: Ease_In
                );
                anim.startTime += 0.15 + (x * 0.1);
                anim.endTime += 0.15 + (x * 0.1);

                anim = keyImages[x].animateFrame(
                    0.25,
                    toPos: keyImages[x].frame.pos + (0, 45),
                    toAlpha: 0,
                    ease: Ease_In
                );
                anim.startTime += (x * 0.15);
                anim.endTime += (x * 0.15);
            }

            for(int x = 0; x < 3; x++) {
                if(x + 1 > numLevelsCompleted) break;

                lineImages[x].animateFrame(
                    0.1,
                    toAlpha: 0,
                    ease: Ease_Out
                );
            }


            let anim = descriptionLabel.animateFrame(
                0.25,
                toPos: descriptionLabel.frame.pos + (0, 80),
                toAlpha: 0,
                ease: Ease_In
            );
            anim.startTime += 0.15;
            anim.endTime += 0.15;

        } else {

            let anim = statsLayout.animateFrame(
                0.25,
                toPos: statsLayout.frame.pos + (0, 80),
                toAlpha: 0,
                ease: Ease_In
            );
            anim.startTime += 0.15;
            anim.endTime += 0.15;

            anim = completeLabel.animateFrame(
                0.15,
                toAlpha: 0,
                ease: Ease_In
            );
            anim.startTime += 0.1;
            anim.endTime += 0.1;

            anim = starlightText.animateFrame(
                0.35,
                fromPos: starlightText.frame.pos,
                toPos: starlightText.frame.pos + (0, 35),
                toAlpha: 0,
                ease: Ease_In
            );
            anim.startTime += 0.15;
            anim.endTime += 0.15;
        }
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