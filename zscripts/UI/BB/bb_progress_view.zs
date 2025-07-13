class BBProgressView : UIView {
    UIVerticalScroll scroll;
    UIVerticalLayout mainLayout;
    UIImage verticalBarBG, verticalBar;
    UILabel liveCounter;
    UIPin verticalBarPin;
    BBWindow window;

    int numAchievements;

    Array<BBProgressSegment> segments;

    const EACH_SEGMENT = 200;


    BBProgressView init() {
        Super.init((0,0), (0,0));

        pinToParent();

        let burgerItem = BBItem.Find();
        numAchievements = burgerItem.countAchievements();

        // Add header
        let hedImage = new("UIImage").init((0,0), (0,0), "BBHED1", imgStyle: UIImage.Image_Aspect_Fit);
        hedImage.pin(UIPin.Pin_Left);
        hedImage.pin(UIPin.Pin_Right);
        hedImage.pinHeight(27);
        hedImage.pin(UIPin.Pin_Top, offset: 5);
        add(hedImage);

        scroll = new("UIVerticalScroll").init((0,0), (0,0), 15, 15,
            NineSlice.Create("BBBAR01", (7,8), (8,28)), null,
            UIButtonState.CreateSlices("BBBAR02", (6,6), (9,13)),
            UIButtonState.CreateSlices("BBBAR03", (6,6), (9,13)),
            UIButtonState.CreateSlices("BBBAR04", (6,6), (9,13)),
            insetA: 10,
            insetB: 10,
            scrollPadding: 10
        );
        scroll.pinToParent(0, 40);
        scroll.autoHideAdjustsSize = true;
        scroll.autoHideScrollbar = true;
        scroll.scrollbar.rejectHoverSelection = true;
        scroll.rejectHoverSelection = true;
        scroll.mLayout.itemSpacing = 0;
        scroll.scrollbarPadding = 5;
        //scroll.scrollbar.firstPin(UIPin.Pin_Right).offset = -8;
        add(scroll);

        mainLayout = UIVerticalLayout(scroll.mLayout);

        // Add vertical bar images
        verticalBarBG = new("UIImage").init((0,0), (26, 0), "", NineSlice.Create("BBPROG1", (11, 13), (15, 61)));
        verticalBar = new("UIImage").init((0,0), (26, 0), "", NineSlice.Create("BBPROG2", (11, 13), (15, 61)));

        verticalBarBG.pin(UIPin.Pin_Left, offset: 15);
        verticalBarBG.pin(UIPin.Pin_Top);
        verticalBarBG.pin(UIPin.Pin_Bottom);

        verticalBar.pin(UIPin.Pin_Left, offset: 15);
        verticalBar.pin(UIPin.Pin_Top);
        verticalBarPin = verticalBar.pin(UIPin.Pin_Bottom, value: min(1.0, numAchievements / double((BBItem.Rewards.size() / 2) * 5)), offset: -(EACH_SEGMENT * 0.5), isFactor: true);
        verticalBar.minSize.y = 40;
        
        mainLayout.add(verticalBarBG);
        mainLayout.add(verticalBar);

        // Add segments
        for(int x = 0; x < BBItem.Rewards.size() / 2; x++) {
            int valueNum = (x+1) * 5;
            bool claimed = burgerItem.claimedRewards.checkKey(x);

            let v = BBProgressSegment(new("BBProgressSegment").init((0,0), (0, EACH_SEGMENT)));
            v.pin(UIPin.Pin_Left);
            v.pin(UIPin.Pin_Right);
            v.segCount = x;

            let bg = new("UIImage").init((0,0), (300, 200), "BBBACK07");
            bg.pin(UIPin.Pin_Right, offset: -30);
            bg.pin(UIPin.Pin_Top);
            v.add(bg);

            // Add progress indicator
            // Use greyed version if not unlocked
            v.segBG = new("UIImage").init((0,0), (46, 46), numAchievements >= valueNum ? "BBPROG3" : "BBPROG4");
            v.segBG.pin(UIPin.Pin_Left, offset: 5);
            v.segBG.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
            v.add(v.segBG);

            // Add number indicator
            v.segLabel = new("UILabel").init((0,0), (100, 46), String.Format("%d", (x + 1) * 5), "SEL21FONT", textAlign: UIView.Align_Centered);
            v.segLabel.shadowColor = 0xCC000000;
            v.segLabel.shadowOffset = (2,2);
            v.segLabel.drawShadow = true;
            v.segLabel.pinToParent(0, 0, -2, -2);
            v.segLabel.multiline = false;
            v.segBG.add(v.segLabel);
            

            // Add reward image
            let rewardType = BBItem.Rewards[x * 2];
            let reward = BBItem.Rewards[x * 2 + 1];

            if(rewardType == BB_GEM) {
                v.rewardImage = new("UIImage").init((0,0), (200, 100), String.Format("BBGEM%d", reward), imgStyle: UIImage.Image_Aspect_Fit);
            } else {
                v.rewardImage = new("UIImage").init((0,0), (200, 100), String.Format("CCPIC%d", reward), imgStyle: UIImage.Image_Aspect_Fit);
            }

            v.rewardImage.pinToParent(80, 0, -60, 0);
            v.add(v.rewardImage);
            v.rewardImage.blendColor = numAchievements >= valueNum ? 0 : 0xFF013D4C;

            // Add lock image
            v.lockImage = new("UIImage").init((0,0), (32, 32), "BBLOCK", imgStyle: UIImage.Image_Aspect_Fit);
            v.lockImage.pin(UIPin.Pin_Left, offset: 95);
            v.lockImage.pin(UIPin.Pin_Top, offset: 15);
            v.add(v.lockImage);
            v.lockImage.hidden = true;//numAchievements >= valueNum;

            // Add claim button
            v.claimButton = new("UIButton").init(
                (0,0), (185, 75), 
                "Claim\nReward!", "SEL21FONT", 
                UIButtonState.CreateSlices("BBBUTT05", (16,16), (20, 84), scaleCenter: true),
                UIButtonState.CreateSlices("BBBUTT06", (16,16), (20, 84), scaleCenter: true),
                UIButtonState.CreateSlices("BBBUTT07", (16,16), (20, 84), scaleCenter: true)
            );
            v.claimButton.pin(UIPin.Pin_Bottom, offset: -5);
            v.claimButton.pin(UIPin.Pin_HCenter, value: 1.0, offset: 10, isFactor: true);
            v.claimButton.hidden = claimed || numAchievements < valueNum;
            v.claimButton.setDisabled(v.claimButton.hidden);
            v.claimButton.command = "ClaimReward";
            v.claimButton.label.drawShadow = true;
            v.claimButton.label.shadowOffset = (3,3);
            v.claimButton.label.verticalSpacing = -2;
            v.claimButton.setTextPadding(20, 0, 20, 7);
            v.claimButton.controlID = x;
            v.claimButton.receiver = self;
            v.claimButton.onClick = claimRewardPressed;
            v.add(v.claimButton);

            mainLayout.addManaged(v);
            segments.push(v);
        }

        // Add current achievement counter
        liveCounter = new("UILabel").init((0,0), (100, 46), String.Format("%d", numAchievements), "SEL21FONT", textAlign: UIView.Align_Centered);
        liveCounter.shadowColor = 0xCC000000;
        liveCounter.shadowOffset = (2,2);
        liveCounter.drawShadow = true;
        liveCounter.pin(UIPin.Pin_Bottom);
        liveCounter.pin(UIPin.Pin_HCenter, value: 1.0, offset: -2, isFactor: true);
        liveCounter.multiline = false;
        
        updateLiveCounter();

        verticalBar.clipsSubviews = false;
        verticalBar.add(liveCounter);

        UIControl lastControl = null;
        foreach(v : segments) {
            v.claimButton.navUp = lastControl;
            if(lastControl) lastControl.navDown = v.claimButton;
            v.claimButton.navRight = window ? window.progressButton : null;
            lastControl = v.claimButton;
        }

        return self;
    }


    UIControl getFirstControl() {
        // Find a claim button to select. If none exist, do nothing
        foreach(v : segments) {
            let v = BBProgressSegment(v);
            if(v && v.claimButton && !v.claimButton.hidden) {
                return v.claimButton;
            }
        }

        return null;
    }


    static bool claimRewardPressed(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = BBStoreView(self);
        
        EventHandler.SendNetworkEvent("bbclaim", btn.controlID);
        Menu.MenuSound("ui/burgerflipper/buyskin");

        return true;
    }


    void updateLiveCounter() {
        liveCounter.setText(String.Format("%d", numAchievements));
        liveCounter.hidden = false;

        let na = numAchievements % 5;
        if( na == 4 ) {
            liveCounter.firstPin(UIPin.Pin_Bottom).offset = -8;
        } else if( numAchievements > 5 && na == 1 ) {
            liveCounter.firstPin(UIPin.Pin_Bottom).offset = 8;
        } else if( numAchievements >= 5 && na == 0) {
            liveCounter.hidden = true;
        } else {
            liveCounter.firstPin(UIPin.Pin_Bottom).offset = 0;
        }
    }


    void updateSegments() {
        let burgerItem = BBItem.Find();
        bool updateSelection = false;

        foreach(seg : segments) {
            int valueNum = (seg.segCount+1) * 5;
            bool claimed = burgerItem.claimedRewards.checkKey(seg.segCount);

            seg.segBG.setImage(numAchievements >= valueNum ? "BBPROG3" : "BBPROG4");

            // Reveal or hide the reward image
            if(seg.rewardImage) {
                seg.rewardImage.blendColor = numAchievements >= valueNum ? 0 : 0xFF013D4C;
            }

            // TODO: Add animation when changing state!
            seg.lockImage.hidden = true;//numAchievements >= valueNum;
            seg.claimButton.hidden = claimed || numAchievements < valueNum;
            seg.claimButton.setDisabled(seg.claimButton.hidden);

            let m = getMenu();
            let ctrl = m ? getMenu().activeControl : null;
            if(ctrl == seg.claimButton && seg.claimButton.hidden) {
                updateSelection = true;
            }
        }

        verticalBarPin.value = min(1.0, numAchievements / double((BBItem.Rewards.size() / 2) * 5));
        verticalBarPin.offset = -(EACH_SEGMENT * 0.5);
        
        updateLiveCounter();

        verticalBar.layout();

        if(updateSelection) {
            let ct = getFirstControl();
            if(!ct) ct = window ? window.progressButton : null;
            getMenu().navigateTo(ct);
        }
    }


    override void tick() {
        Super.tick();

        let b = BBItem.Find();
        if(b) {
            let ach = b.countAchievements();
            if(ach != numAchievements) {
                numAchievements = ach;
                updateSegments();

                // TODO: Add a little animation if we just unlocked something!
            }
        }

        // Output a debug message
        
    }


    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        if(event == UIHandler.Event_Selected && ctrl is 'UIButton' && !fromMouse) {
            // TODO: Play sound
            scroll.scrollTo(ctrl, true);
            return false;
        }

        return false;
    }
}


class BBProgressSegment : UIView {
    int segCount;

    UIImage segBG, rewardImage, lockImage;
    UILabel segLabel;
    UIButton claimButton;
}