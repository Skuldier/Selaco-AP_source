class TrainMenu : SelacoGamepadMenu {
    UIScrollBG scrollBG;
    UIVerticalLayout chapterLayout, customLevelLayout, statLayout;
    UIVerticalScroll levelScroll, customScroll;
    //UIImage levelImage;
    UIView chapterWindow, levelWindow, displayWindow, container;
    UIView progressContainer;
    UILabel displayTitle;
    UIAnimatedLabel pDatapads, pSecrets, pUpgrades, pCabinets, pSecurityCards;
    UIButton travelButton;
    Array<LevelButton2> levelButtons;

    int curChapter, curLevelNum;
    int closing;

    bool useController;

    const PROGRESS_LEFT = 140;

    override void init(Menu parent) {
		Super.init(parent);

        ReceiveAllInputEvents = true;
        menuActive = Menu.OnNoPause;

        useController = isUsingController() || isUsingGamepad();

        container = new("UIView").init();
        container.pinWidth(1.0, offset: -160, isFactor: true);
        container.pinHeight(920);
        container.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        container.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        container.clipsSubviews = false;
        container.maxSize = (1525, 99999);
        container.alpha = 0;
        mainView.add(container);

        closing = 0;

        let sbg = new("UIImage").init((0,0), (100,100), "", NineSlice.Create("TRAINWI4", (16, 16), (100, 444)));
        sbg.pinToParent(0, 0, 0, 0);
        container.add(sbg);

        // Create background for campaign window
        let mainContainer = new("UIView").init((0,0), (350, 100));// NineSlice.Create("trainwi1", (40, 110), (166, 348)));
        mainContainer.ignoresClipping = true;
        mainContainer.pinToParent(60, 145, -60, -40);
        container.add(mainContainer);

        // Add seperator 
        let sep = new("UIView").init((0,0), (1,2));
        sep.backgroundColor = 0xFF657498;
        sep.pin(UIPin.Pin_Left);
        sep.pin(UIPin.Pin_Right);
        sep.pinHeight(2);
        sep.pin(UIPin.Pin_Top);
        mainContainer.add(sep);

        // Add header logo
        let headerLogo = new("UIImage").init((50, 40), (85, 73), "TRAINACE");
        container.add(headerLogo);

        // Add header text
        let headerText = new("UILabel").init((120, 46), (350, 55), "ACES TRAVEL NETWORK", "SEL46FONT");
        headerText.scaleToHeight(44);
        headerText.pin(UIPin.Pin_Right, offset: -15);
        headerText.pin(UIPin.Pin_Left, offset: 120);
        headerText.clipsSubviews = false;
        container.add(headerText);

        // Make manual shadow, because stencil based shadows look bad here
        let headerText2 = new("UILabel").init((120, 50), (350, 55), "A", "SEL46FONT", 0xFF3A4256);
        headerText2.scaleToHeight(44);
        headerText2.pin(UIPin.Pin_Right, offset: -15);
        headerText2.pin(UIPin.Pin_Left, offset: 115);
        container.add(headerText2);
        container.moveBehind(headerText2, headerText);

        // Add subtext
        let headerSubtext = new("UILabel").init((135, 88), (350, 45), "SELECT A DESTINATION", "SEL21FONT");
        //headerSubtext.scaleToHeight(26);
        headerSubtext.alpha = 0.5;
        container.add(headerSubtext);


        // Create tabs for campaign window

        // Scroll bar config
        let scrollConfig = UIScrollBarConfig.Create(
            8, 8,
            NineSlice.Create("trainscr", (4, 4), (4, 18)),
            null,
            UIButtonState.CreateSlices("trainscr", (4, 4), (4, 18)),
            UIButtonState.CreateSlices("trainscr", (4, 4), (4, 18)),
            UIButtonState.CreateSlices("trainscr", (4, 4), (4, 18)),
            insetA: 8,
            insetB: 8
        );

        // Scroll view for campaign window
        levelScroll = new("UIVerticalScroll").initFromConfig((-5,0), (960, 100), scrollConfig);
        levelScroll.autoHideScrollbar = true;
        //levelScroll.autoHideAdjustsSize = true;
        levelScroll.pin(UIPin.Pin_Top, offset: 2);
        levelScroll.pin(UIPin.Pin_Bottom);

        levelScroll.scrollbar.firstPin(UIPin.Pin_Right).offset = -4;
        levelScroll.scrollbar.rejectHoverSelection = true;
        levelScroll.scrollbar.bgImage.blendColor = 0xFF657397;
        levelScroll.rejectHoverSelection = true;
        levelScroll.mLayout.setPadding(0, 5, 0, 5);
        chapterLayout = UIVerticalLayout(levelScroll.mLayout);
        mainContainer.add(levelScroll);


        // Create Display window
        displayWindow = new("UIView").init();
        displayWindow.pin(UIPin.Pin_Right);
        displayWindow.pin(UIPin.Pin_Left, offset: 960);
        displayWindow.pin(UIPin.Pin_Top, 10);
        displayWindow.pin(UIPin.Pin_Bottom);
        mainContainer.add(displayWindow);

        // Display window title
        displayTitle = new("UILabel").init((15, 40), (350, 51), "No Map Selected", "SEL46FONT", textAlign: UIView.Align_Middle, fontScale: (0.7, 0.7));
        displayTitle.pin(UIPin.Pin_Right, offset: 0);
        displayTitle.pin(UIPin.Pin_Left, offset: 0);
        displayTitle.multiline = true;
        displayTitle.pinHeight(UIView.Size_Min);

        statLayout = new("UIVerticalLayout").init((0,0), (0,0));
        statLayout.pinToParent(0, 40);
        statLayout.itemSpacing = 5;
        displayWindow.add(statLayout);
        
        statLayout.addManaged(displayTitle);
        statLayout.addSpacer(20);

        // Add all the stat lines
        UIView v;
        UIAnimatedLabel al;
        [v, pSecurityCards, al] = makeStatLine("Security Cards");
        statLayout.addManaged(v);
        al.start(100, 4);
        [v, pDatapads, al] = makeStatLine("Datapads Collected");
        statLayout.addManaged(v);
        al.start(100, 3);
        [v, pUpgrades, al] = makeStatLine("Upgrades Found");
        statLayout.addManaged(v);
        al.start(100, 2);
        [v, pCabinets, al] = makeStatLine("Cabinets Unlocked");
        statLayout.addManaged(v);
        al.start(100, 1);
        [v, pSecrets, al] = makeStatLine("Secrets Found");
        if(!g_halflikemode) {
            statLayout.addManaged(v);
            al.start(100, 0);
        }


        // Create start button
        travelButton = new("UIButton").init(
            (0,0), (255, 75), "TRAVEL", "SEL46FONT",
            UIButtonState.CreateSlices  ("trainbt5",    (8,8), (38, 52), textColor: 0xFFFFFFFF),
            hover: UIButtonState.CreateSlices   ("trainbt7",    (8,8), (38, 52), textColor: 0xFFFFFFFF),
            pressed: UIButtonState.CreateSlices ("trainbt8",    (8,8), (38, 52), textColor: 0xFFFFFFFF),
            disabled: UIButtonState.CreateSlices("trainbt6",    (8,8), (38, 52), textColor: 0xFFAAAAAA)
        );
        travelButton.label.fontScale = (0.9, 0.9);
        //travelButton.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        travelButton.pin(UIPin.Pin_Left, offset: 25);
        travelButton.pin(UIPin.Pin_Right, offset: -25);
        travelButton.pin(UIPin.Pin_Bottom, offset: -15);
        travelButton.rejectHoverSelection = true;
        displayWindow.add(travelButton);


        curChapter = 0; // TODO: Detect current chapter
        addMapsForChapter(curChapter);
    }


    // Make sure container is large enough, if it's too small just make it fill the screen
    override void layoutChange(int screenWidth, int screenHeight) {
		container.pinWidth(1.0, offset: -160, isFactor: true);

        Super.layoutChange(screenWidth, screenHeight);

        Console.Printf("Frame size Before: %f %f", container.frame.size.x, container.frame.size.y);

        if(container.frame.size.x < 1400) {
            container.pinWidth(mainView.frame.size.x + 12);
        }

        mainView.layout();

        Console.Printf("Frame size: %f %f", container.frame.size.x, container.frame.size.y);
	}


    UIView, UIAnimatedLabel, UIAnimatedLabel makeStatLine(string title, string placeholder = "999/999") {
        let view = new("UIView").init((0,0), (100, 25));
        view.pinHeight(35);
        view.pin(UIPin.Pin_Left);
        view.pin(UIPin.Pin_Right);
        view.backgroundColor = 0x33000000;

        let tt = new("UIAnimatedLabel").init((0,0), (100, 25), title, "PDA16FONT", textAlign: UIView.Align_VCenter, fontScale: (0.85, 1.0));
        tt.multiline = false;
        tt.pinToParent(10, 0, -115, 0);
        view.add(tt);


        let lab = new("UIAnimatedLabel").init((0, 0), (150, 25), placeholder, "PDA16FONT", textAlign: UIView.Align_Right | UIView.Align_VCenter, fontScale: (0.85, 1.0));
        lab.multiline = false;
        lab.monospace = true;
        lab.pin(UIPin.Pin_Right, offset: -10);
        lab.pin(UIPin.Pin_Top);
        lab.pin(UIPin.Pin_Bottom);
        lab.pinWidth(115);
        lab.charLimit = 0;
        view.add(lab);

        return view, lab, tt;
    }


    override void onFirstTick() {
        Super.onFirstTick();

        pDatapads.start(25, 3);
        pUpgrades.start(25, 2);
        pCabinets.start(25, 1);
        pSecrets.start(25, 0);

        // Animate container in
        container.animateFrame(
            0.20,
            fromPos: container.frame.pos + (0, 100),
            toPos: container.frame.pos,
            fromAlpha: 0.0,
            toAlpha: 1.0,
            ease: Ease_Out
        );

        // Animate all level buttons
        double delay = 0.05;
        for(int x = 0; x < levelButtons.size(); x++) {
            LevelButton2 lb = LevelButton2(levelButtons[x]);
            let anim = lb.levelImage.animateFrame(
                0.18,
                toAlpha: 1.0,
                ease: Ease_In
            );
            anim.startTime += delay;
            anim.endTime += delay;
            delay += 0.01;
        }
    }


    override void ticker() {
        Super.ticker();
        
        animated = true;

        // Scroll with gamepad
        if(levelScroll.contentsCanScroll()) {
            let v = getGamepadRawLook();
            if(abs(v.y) > 0.1) {
                levelScroll.scrollByPixels((v.y * CommonUI.STANDARD_SCROLL_AMOUNT), true, false, false);
            }
        }

        if(closing > 0 && ticks == closing + 9) {
            close();
        }
    }


    void addMapsForChapter(int chapter, bool selectFirst = true) {
        int num = LevelInfo.GetLevelInfoCount();
        int count = 0;
        LevelButton2 lastBtn;
        LevelButton2 firstBtn;

        // Get unlocked saferooms
        Array<int> saferooms;

        let item = SafeRoomItem(players[consolePlayer].mo.FindInventory("SafeRoomItem"));
        if(item) {
            saferooms.append(item.unlockedRooms);
        } else {
            saferooms.push(2);  // 01B should always be available, since you do not visit it manually at the start of the game
        }

        if(developer) Console.Printf("Destination is %s", Dawn(players[consoleplayer].mo).destinationLevel);

        UIView rowView;
        int rowCnt = 0;
        for(int lev = 0; lev < num; lev++) {
            let i = LevelInfo.GetLevelInfo(lev);
            bool hasUnlocked = false;
            if(i.cluster != 1) continue;    // Stick to first chapter only
            if(i.flags3 & LEVEL3_SAFEROOM == 0) continue;   // Only saferooms

            // Check if we unlocked this map
            for(int x = 0; x < saferooms.size(); x++) {
                if(saferooms[x] == i.levelNum) {
                    hasUnlocked = true;
                    break;
                }
            }

            if(developer) Console.Printf("\c[GOLD]Map %d: %s  (%s)", i.levelNum, i.MapName, hasUnlocked ? "\c[GREEN]unlocked" : "\c[red]locked");

            if(!rowView || rowCnt == 3) {
                rowView = new("UIView").init((0,0), (0, 180));
                rowView.pin(UIPin.Pin_Left);
                rowView.pin(UIPin.Pin_Right);
                chapterLayout.addManaged(rowView);
                rowCnt = 0;
            }

            // Create a button for this area
            let btn = new("LevelButton2").init(i.levelNum, !hasUnlocked);
            btn.frame.pos.x = rowCnt * btn.frame.size.x;
            rowView.add(btn);
            btn.levelImage.alpha = 0.2;
            //btn.navRight = travelButton;

            if(lastBtn) {
                lastBtn.navRight = btn;
                btn.navLeft = lastBtn;
            } else firstBtn = btn;

            if(levelButtons.size() > 2) {
                levelButtons[levelButtons.size() - 3].navDown = btn;
                btn.navUp = levelButtons[levelButtons.size() - 3];
            }
            
            lastBtn = btn;
            count++;
            rowCnt++;
            levelButtons.push(btn);

            if(!hasUnlocked) {
                btn.setDisabled(true);
            }
        }

        if(firstBtn && lastBtn && firstBtn != lastBtn) {
            lastBtn.navRight = firstBtn;
            firstBtn.navLeft = lastBtn;
        }

        // Add vertical selection
        for(int x = 0; x < 3; x++) {
            for(int y = 0; y < int(ceil(levelButtons.size() / 3.0)); y++) {
                int idx = y * 3 + x;
                int idxu = (y - 1) * 3 + x;
                int idxd = (y + 2) * 3 + x;

                if(idx < levelButtons.size()) {
                    if(idxu >= 0) {
                        levelButtons[idx].navUp = levelButtons[idxu];
                        levelButtons[idxu].navDown = levelButtons[idx];
                    }

                    if(idxd < levelButtons.size()) {
                        levelButtons[idxd].navUp = levelButtons[idx];
                        levelButtons[idx].navDown = levelButtons[idxd];
                    } else {
                        idxd = x;
                        if(idxd < levelButtons.size()) {
                            levelButtons[idx].navDown = levelButtons[x];
                            levelButtons[x].navUp = levelButtons[idx];
                        }
                    }
                }
            }
        }

        if(selectFirst && firstBtn) {
            firstBtn.setSelected(true);
            navigateTo(firstBtn);
            configureForMap(firstBtn.index);
        }
    }


    void configureForMap(int levelNum) {
        let info = LevelInfo.FindLevelByNum(levelNum);
        displayTitle.setText(UIHelper.GetShortLevelName(info.LevelName));
        curLevelNum = levelNum;

        // Set button selections to match
        for(int x = 0; x < levelButtons.size(); x++) {
            let b2 = LevelButton2(levelButtons[x]);
            if(b2) b2.setSelected(b2.index == levelNum);
        }

        //levelImage.setImage(String.Format("SBLEV%d", info.levelNum));

        // Fill progress report
        ProgressInfo progressInfo;
        Stats.getProgressInfo(progressInfo, levelGroup: info.levelGroup);
        String unvisitedText = progressInfo.hasUnvisitedLevels ? "+(?)" : "";
        pSecurityCards.setText(String.Format("%s%d/%d%s", 
            progressInfo.hasUnvisitedLevels ? "\c[YELLOW]" : (progressInfo.clearanceFound == progressInfo.clearanceTotal ? "\c[GREEN]" : ""), 
            progressInfo.clearanceFound, progressInfo.clearanceTotal, 
            unvisitedText
        ));
        pDatapads.setText(String.Format("%s%d/%d%s", 
            progressInfo.hasUnvisitedLevels ? "\c[YELLOW]" : (progressInfo.datapadsFound == progressInfo.datapadsTotal ? "\c[GREEN]" : ""), 
            progressInfo.datapadsFound, progressInfo.datapadsTotal, 
            unvisitedText
        ));
        pSecrets.setText(String.Format("%s%d/%d%s", 
            progressInfo.hasUnvisitedLevels ? "\c[YELLOW]" : (progressInfo.secretsFound == progressInfo.secretsTotal ? "\c[GREEN]" : ""),
            progressInfo.secretsFound, progressInfo.secretsTotal, 
            unvisitedText
        ));
        pUpgrades.setText(String.Format("%s%d/%d%s",
            progressInfo.hasUnvisitedLevels ? "\c[YELLOW]" : (progressInfo.upgradesFound == progressInfo.upgradesTotal ? "\c[GREEN]" : ""),
            progressInfo.upgradesFound, progressInfo.upgradesTotal, 
            unvisitedText
        ));
        pCabinets.setText(String.Format("%s%d/%d%s", 
            progressInfo.hasUnvisitedLevels ? "\c[YELLOW]" : (progressInfo.cabinetsUnlocked == progressInfo.cabinetsTotal ? "\c[GREEN]" : ""),
            progressInfo.cabinetsUnlocked, progressInfo.cabinetsTotal, 
            unvisitedText
        ));

        // Disable/Enable travel button if this is our current destination already
        let d = Dawn(players[consolePlayer].mo);
        if(d) {
            travelButton.setDisabled(d.destinationLevel ~== info.MapName);
        } else {
            travelButton.setDisabled(true);
        }
        
        pSecurityCards.charLimit = 0;
        pDatapads.charLimit = 0;
        pUpgrades.charLimit = 0;
        pCabinets.charLimit = 0;
        pSecrets.charLimit = 0;
        pSecurityCards.start(50, 4);
        pDatapads.start(50, 3);
        pUpgrades.start(50, 2);
        pCabinets.start(50, 1);
        pSecrets.start(50, 0);
    }


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated) {
            if(ctrl is "LevelButton2") {
                let b = LevelButton2(ctrl);
                if(curLevelNum == b.index && !fromMouseEvent) {
                    if(closing == 0 && !travelButton.isDisabled()) {
                        MenuSound("UI/VACCONSOLE/END");
                        EventHandler.SendNetworkEvent("setTrainDest", curLevelNum);
                        animateClosed();
                    }
                } else {
                    configureForMap(b.index);
                    MenuSound("menu/cursor");
                }

                return;
            }

            if(ctrl == travelButton) {
                if(closing == 0) {
                    MenuSound("UI/VACCONSOLE/END");
                    EventHandler.SendNetworkEvent("setTrainDest", curLevelNum);
                    animateClosed();
                }
                return;
            }
        }

        if(event == UIHandler.Event_Selected && !fromMouseEvent) {
            if(ctrl is "LevelButton2") {
                let b = LevelButton2(ctrl);
                configureForMap(b.index);

                // TODO: Play sound
                levelScroll.scrollTo(ctrl, true);
            }
        }

        if(event == UIHandler.Event_Selected && fromMouseEvent) {
            if(ctrl is "LevelButton2") { MenuSound("codex/tabHover"); }
        }
    }


     override bool navigateTo(UIControl con, bool mouseSelection) {
		let ac = activeControl;
        let cc = Super.navigateTo(con, mouseSelection);
        if(cc) {
            if(ac != activeControl && !mouseSelection && ticks > 1) {
                MenuSound("menu/cursor");
            }
        }

        return cc;
	}


    override UIControl findFirstControl(int mkey) {
        switch(mkey) {
            case MKEY_Left:
            case MKEY_Right:
            case MKEY_Down:
                if(!chapterLayout || levelButtons.size() == 0) return null;
                return UIControl(levelButtons[0]);
            case MKEY_Up:
                // TODO: Get last entry from custom maps instead
                if(!chapterLayout || levelButtons.size() == 0) return null;
                return UIControl(levelButtons[levelButtons.size() - 1]);
            default:
                return null;
        }
    }


    override bool onBack() {
        if(closing == 0) {
            animateDismiss();
        }

        return true;
    }


    void animateClosed() {
        if(closing) return;

        closing = ticks;

        // Animate container out
        container.animateFrame(
            0.20,
            toPos: container.frame.pos + (0, 100),
            toAlpha: 0.0,
            ease: Ease_In
        );
    }


    void animateDismiss() {
        if(closing) return;

        closing = ticks - 4;

        // Animate container out
        container.animateFrame(
            0.10,
            toPos: container.frame.pos + (0, 100),
            toAlpha: 0.0,
            ease: Ease_In
        );

        MenuSound("menu/backup");
    }
}


class LevelButton : UIButton {
    int index;

    LevelButton init(int levelNum) {
        UIButtonState normState     = UIButtonState.Create("");
        UIButtonState hovState      = UIButtonState.CreateSlices("trainbt3", (10, 10), (19, 19), textColor: Font.CR_UNTRANSLATED);
        UIButtonState pressState    = UIButtonState.CreateSlices("trainbt1", (10, 10), (19, 19), textColor: Font.CR_UNTRANSLATED);
        UIButtonState disableState  = UIButtonState.CreateSlices("trainbt1", (10, 10), (19, 19), textColor: 0xFFAAAAAA);
        UIButtonState selectedState         = UIButtonState.CreateSlices("trainbt1", (10, 10), (19, 19), textColor: Font.CR_UNTRANSLATED);
        UIButtonState selectedHovState      = UIButtonState.CreateSlices("trainbt2", (10, 10), (19, 19), textColor: Font.CR_UNTRANSLATED);
        UIButtonState selectedPressState    = selectedState;
        
        self.index = levelNum;
        let info = LevelInfo.FindLevelByNum(levelNum);

        Super.init(
            (0,0), (136, 42),
            info.LevelName, "PDA18FONT",
            normState,
            hovState,
            pressState,
            disableState,
            selectedState,
            selectedHovState,
            selectedHovState
        );

        pin(UIPin.Pin_Left, offset: 8);
        pin(UIPin.Pin_Right, offset: -8);
        pinHeight(UIView.Size_Min);
        minSize.y = 42;

        let tpad = ceil((42 - label.fnt.getHeight()) / 2.0);
        setTextPadding(10, tpad, 10, tpad);
        label.textAlign = Align_Left | Align_Middle;


        return self;
    }
}


class LevelButton2 : UIButton {
    UIImage levelImage, lockImage;
    int index;

    LevelButton2 init(int levelNum, bool locked) {
        UIButtonState normState     = UIButtonState.CreateSlices("trainb01", (14, 14), (36, 96), textColor: Font.CR_UNTRANSLATED);
        UIButtonState hovState      = UIButtonState.CreateSlices("trainb02", (14, 14), (36, 96), textColor: Font.CR_UNTRANSLATED);
        UIButtonState pressState    = UIButtonState.CreateSlices("trainb02", (14, 14), (36, 96), textColor: Font.CR_UNTRANSLATED);
        UIButtonState disableState  = UIButtonState.CreateSlices("trainb04", (14, 14), (36, 96), textColor: 0x00010101);
        UIButtonState selectedState         = UIButtonState.CreateSlices("trainb03", (14, 14), (36, 96), textColor: Font.CR_UNTRANSLATED);
        UIButtonState selectedPressState    = selectedState;
        UIButtonState selectedHovState      = UIButtonState.CreateSlices("trainb03", (14, 14), (36, 96), textColor: Font.CR_UNTRANSLATED);

        self.index = levelNum;
        let info = LevelInfo.FindLevelByNum(levelNum);

        Super.init(
            (0,0), (310, 180),
            UIHelper.GetShortLevelName(info.LevelName), "SEL21FONT",
            normState,
            hovState,
            pressState,
            disableState,
            selectedState,
            selectedHovState,
            selectedHovState
        );

        pinWidth(310);
        pinHeight(180);

        let tpad = ceil((42 - label.fnt.getHeight()) / 2.0);
        setTextPadding(35, 15, 35, 27);
        label.textAlign = Align_BottomLeft;


        // Add level image, it will be custom drawn under the button so order is not important
        string graphic = String.Format("SBLEV%d", info.levelNum);
        TextureID texTest = TexMan.CheckForTexture(graphic);
        if(!texTest || !texTest.isValid()) graphic = "SBPLACEH";
        
        levelImage = new("UIImage").init((0,0), (1, 1), graphic);
        levelImage.pinToParent(8, 8, -8, -8);
        add(levelImage);

        if(locked) {
            lockImage = new("UIImage").init((0,0), (83,93), "trainlok");
            lockImage.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: 1.0);
            lockImage.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: 1.0);
            add(lockImage);

            levelImage.desaturation = 1.0;
            levelImage.blendColor = 0x88000000;
        }


        return self;
    }


    override void draw() {
        if(hidden) { return; }
        
        layoutIfNecessary();

        // Draw the level image first
        // Since I'm not drawing the subviews, this should not modify the clipping rectangle
        levelImage.draw();

        // Draw ourselves as a frame over levelImage
        Super.draw();
    }


    override void drawSubviews() {
        if(hidden) { return; }
        
        // Prevent levelImage from being drawn here
        levelImage.hidden = true;
        Super.drawSubviews();
        levelImage.hidden = false;
    }
}