class PDAChallengesWindow : PDAFullscreenAppWindow {
    UIVerticalScroll listScroll;
    UIView noDataView;

    const STATWIDTH = 80;

    override PDAAppWindow vInit(Vector2 pos, Vector2 size) {
        return Init(pos, size);
    }
    
    PDAChallengesWindow init(Vector2 pos, Vector2 size) {
        Super.init(pos, size);
        pinToParent();

        createStandardTitleBar("$CHALLENGES_HEADER");

        appID = PDA_APP_CHALLENGES;
        rejectHoverSelection = true;

        listScroll = new("UIVerticalScroll").init((0,0), (320,100), 14, 14,
            NineSlice.Create("PDABAR5", (10,10), (11,13)), null,
            UIButtonState.CreateSlices("PDABAR6", (10,10), (11,13)),
            UIButtonState.CreateSlices("PDABAR7", (10,10), (11,13)),
            UIButtonState.CreateSlices("PDABAR8", (10,10), (11,13)),
            insetA: 15, insetB: 15
        );
        listScroll.pinToParent();
        listScroll.autoHideScrollbar = false;
        listScroll.mLayout.padding.top = 20;
        listScroll.mLayout.padding.bottom = 20;
        listScroll.mLayout.itemSpacing = 12;
        listScroll.scrollbar.rejectHoverSelection = true;
        contentView.add(listScroll);

        noDataView = new("UILabel").init((0,0), (0,0), "$CHALLENGES_NONE", "SEL27OFONT", textAlign: UIView.Align_Centered);
        noDataView.pinToParent();
        noDataView.hidden = true;
        contentView.add(noDataView);
        
        return self;
    }


    override void onAddedToParent(UIView parentView) {
        Super.onAddedToParent(parentView);
        
        if(listScroll.mLayout.numManaged() == 0) buildList();
    }


    override void setDefaultPositionAndSize(int desktopWidth, int desktopHeight) {
        
    }



    void buildList() {
        // No challenges until 02b
        if(!(players[consolePlayer].mo && players[consolePlayer].mo.countInv("ChallengesUnlocked") > 0)) {
            noDataView.hidden = false;
            UILabel(noDataView).setText("MILESTONES NOT UNLOCKED YET");
            return;
        }

        let statItem = Stats.FindStats();
        bool useTwoRows = getMenu().mainView.frame.size.x > 1700;
        if(statItem) {
            // Go through each stat and identify challenges
            int cnt = 0;
            int row = 0;
            UIView rowView;

            for(int x = 0; x < STAT_COUNT; x++) {
                ChallengeStatTracker challenge = ChallengeStatTracker(statItem.trackers[x]);
                if(challenge) {
                    // If this is a progress only challenge, skip it
                    ProgressStatTracker ptc = ProgressStatTracker(challenge);
                    if(ptc && !ptc.isChallenge) continue;

                    // Add a line for this challenge only if it has been started
                    if(challenge.value > 0) {
                        if(!rowView) {
                            rowView = new("UIView").init((0,0), (0, 100));
                            rowView.pinHeight(100);
                            rowView.pin(UIPin.Pin_Left);
                            rowView.pin(UIPin.Pin_Right, offset: -15);
                        }

                        let v = makeLine(challenge, row % 2);
                        if(!useTwoRows) {
                            v.pin(UIPin.Pin_Left);
                            v.pin(UIPin.Pin_Right);
                        } else if(cnt % 2 == 0) {
                            v.pin(UIPin.Pin_Left);
                            v.pin(UIPin.Pin_Right, UIPin.Pin_HCenter, value: 1.0, offset: -10, isFactor: true);
                        } else {
                            v.pin(UIPin.Pin_Left, UIPin.Pin_HCenter, value: 1.0, offset: 10, isFactor: true);
                            v.pin(UIPin.Pin_Right);
                        }
                        rowView.add(v);

                        if(cnt % 2 == 1 || !useTwoRows) {
                            listScroll.mLayout.addManaged(rowView);
                            rowView = null;
                            row++;
                        }

                        cnt++;
                    }
                }
            }

            if(rowView) {
                listScroll.mLayout.addManaged(rowView);
            }

            noDataView.hidden = listScroll.mLayout.numManaged() != 0;
        } else {
            // Show noDataView
            noDataView.hidden = false;
        }
    }

    
    UIView makeLine(ChallengeStatTracker challenge, int row = 0) {
        let rowView = new("UIView").init((0,0), (1,42));
        //rowView.pin(UIPin.Pin_Left);
        //rowView.pin(UIPin.Pin_Right, offset: -15);
        rowView.pinHeight(100);

        let v = new("UIImage").init((0,0), (1,42), "", NineSlice.Create(row == 0 ? "PDASTLN2" : "PDASTLN1", (17,14), (43,23)));
        v.pinToParent();
        v.clipsSubviews = false;
        rowView.add(v);

        // Icons
        let iconBackground = new("UIImage").init((0,0), (80,80), "ACH_BG4");
        iconBackground.pin(UIPin.Pin_Left, offset: 20);
        iconBackground.pin(UIPin.Pin_Top, offset: 13);
        iconBackground.pin(UIPin.Pin_Bottom, offset: -7);
        iconBackground.blendColor = 0xFF000000;
        iconBackground.clipsSubviews = false;
        v.add(iconBackground);

        let iconBackground2 = new("UIImage").init((0,0), (80,80), "ACH_BG4");
        iconBackground2.pinToParent(0, -3, 0, -3);
        iconBackground.add(iconBackground2);

        if(challenge.medalImage != "") {
            let imgB = new("UIImage").init((0,0), (80,80), challenge.medalImage);
            imgB.pinToParent(0, 0, 0, 0);
            imgB.blendColor = 0xFF000000;
            imgB.alpha = 0.35;
            iconBackground.add(imgB);

            let img = new("UIImage").init((0,0), (80,80), challenge.medalImage);
            img.pinToParent(0, -3, 0, -3);
            iconBackground.add(img);
        }

        // Name/Title
        let titleLabel = new("UILabel").init((0,0), (100, 50), StringTable.Localize(challenge.displayName), "PDA18FONT", textColor: 0xFFB8BFD1);
        titleLabel.multiline = false;
        titleLabel.pin(UIPin.Pin_Left, offset: 120);
        titleLabel.pin(UIPin.Pin_Top, offset: 10);
        titleLabel.pin(UIPin.Pin_Right);
        titleLabel.clipText = true;
        titleLabel.autoScale = true;
        v.add(titleLabel);

        // Progress Text
        int pval = int(challenge.challengeValue - challenge.previousGoalValue);
        int nval = int(challenge.nextValue - challenge.previousGoalValue);

        let progressLabel = new("UILabel").init((0,0), (100, 30), String.Format("Progress: %d / %d", pval, nval), "PDA16FONT", textColor: 0xFFB8BFD1);
        progressLabel.multiline = false;
        progressLabel.pin(UIPin.Pin_Left, offset: 120);
        progressLabel.pin(UIPin.Pin_Top, offset: 42);
        progressLabel.pin(UIPin.Pin_Right);
        v.add(progressLabel);

        // Progress Bar
        let slider = new("UISlider").init((0,0), (200, 20), 0, 1, 1, 
            NineSlice.Create("graphics/options_menu/slider_bg.png", (7, 14), (24, 16)),
            NineSlice.Create("graphics/options_menu/slider_bg_full.png", (7, 14), (24, 16)),
            null,
            null,
            null
        );
        //slider.buttonSize = 5;
        slider.pin(UIPin.Pin_Left, offset: 120);
        slider.pin(UIPin.Pin_Bottom, offset: -5);
        slider.pinHeight(30);
        slider.pin(UIPin.Pin_Right, offset: -250);
        slider.setValue((challenge.challengeValue - challenge.previousGoalValue) / (challenge.nextValue - challenge.previousGoalValue));
        slider.raycastTarget = false;
        slider.slideButt.raycastTarget = false;
        v.add(slider);

        // Reward
        let rewardInfoLabel = new("UILabel").init((0,0), (100, 50), "Next Reward:", "PDA16FONT", textColor: 0xFFB8BFD1, textAlign: UIView.Align_Right);
        rewardInfoLabel.multiline = false;
        rewardInfoLabel.pin(UIPin.Pin_Top, offset: 10);
        rewardInfoLabel.pin(UIPin.Pin_Right, offset: -105);
        v.add(rewardInfoLabel);

        let rewardLabel = new("UILabel").init((0,0), (100, 50), String.Format("%d", challenge.calcReward(challenge.challengesCompleted + 1)), "SEL46FONT", textColor: 0xFFB8BFD1, textAlign: UIView.Align_Middle | UIView.Align_Right);
        rewardLabel.multiline = false;
        rewardLabel.pin(UIPin.Pin_Top, offset: 25);
        rewardLabel.pin(UIPin.Pin_Bottom, offset: -5);
        rewardLabel.pin(UIPin.Pin_Right, offset: -105);
        v.add(rewardLabel);

        let rewardIcon = new("UIImage").init((0,0), (70,70), "WPUNPRT");
        rewardIcon.pin(UIPin.Pin_Right, offset: -20);
        rewardIcon.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        v.add(rewardIcon);

        return rowView;
    }
    

    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        return Super.handleSubControl(ctrl, event, fromMouse, fromController);
    }

    override UIControl getActiveControl() {
        return listScroll.scrollbar;
    }

    override void onClose() {
        Super.onClose();
    }

    override void tick() {
        Super.tick();
        
        if(!listScroll.scrollbar.disabled  && PDAMenu3(getMenu()).findActiveWindow() == self) {
            let v = SelacoGamepadMenu(getMenu()).getGamepadRawLook();
            if(abs(v.y) > 0.1) {
                listScroll.scrollByPixels(v.y * CommonUI.STANDARD_SCROLL_AMOUNT, true, false, false);
            }
        }
    }
}