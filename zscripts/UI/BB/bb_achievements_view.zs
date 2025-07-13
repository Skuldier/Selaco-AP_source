class BBAchievementsView : UIView {
    UIVerticalScroll scroll;
    UIVerticalLayout mainLayout;
    BBWindow window;
    UIImage hedImage;

    BBAchievementsView init() {
        Super.init((0,0), (0,0));

        pinToParent();

        // Add header
        hedImage = new("UIImage").init((0,0), (0,0), "BBHED2", imgStyle: UIImage.Image_Aspect_Fit);
        hedImage.pin(UIPin.Pin_Left);
        hedImage.pin(UIPin.Pin_Right);
        hedImage.pinHeight(27);
        //hedImage.pin(UIPin.Pin_Top, offset: 5);

        scroll = new("UIVerticalScroll").init((0,0), (0,0), 15, 15,
            NineSlice.Create("BBBAR01", (7,8), (8,28)), null,
            UIButtonState.CreateSlices("BBBAR02", (6,6), (9,13)),
            UIButtonState.CreateSlices("BBBAR03", (6,6), (9,13)),
            UIButtonState.CreateSlices("BBBAR04", (6,6), (9,13)),
            insetA: 10,
            insetB: 10,
            scrollPadding: 10
        );
        scroll.pinToParent();
        scroll.autoHideAdjustsSize = true;
        scroll.autoHideScrollbar = true;
        scroll.scrollbar.rejectHoverSelection = true;
        scroll.rejectHoverSelection = true;
        scroll.mLayout.itemSpacing = 5;
        //scroll.scrollbar.firstPin(UIPin.Pin_Right).offset = -8;
        add(scroll);

        mainLayout = UIVerticalLayout(scroll.mLayout);
        mainLayout.addManaged(hedImage);

        refreshAchievements();        
        

        return self;
    }


    void refreshAchievements() {
        let burgerItem = BBItem.Find();
        if(!burgerItem) return;

        mainLayout.removeManaged(hedImage);
        mainLayout.clearManaged();
        mainLayout.addManaged(hedImage);

        Array<BBAchievementView> obscuredViews;
        Array<BBAchievementView> views;

        // Add the list of earned achievements
        foreach(key, a : burgerItem.achievements) {
            if(a.value > 0) {
                let v = new("BBAchievementView").init(a.type, a.subject, a.amount, false, true);

                // Sort and insert based on type and then subject
                if(views.size() == 0) {
                    views.Push(v);
                    continue;
                }
        
                for(int x = 0; x < views.size(); x++) {
                    if( views[x].type > v.type || 
                        (views[x].type == v.type && views[x].subject > v.subject) || 
                        (views[x].type == v.type && views[x].subject == v.subject && views[x].amount > v.amount) 
                    ) {
                        views.Insert(x, v);
                        break;
                    } else if(x + 1 == views.size()) {
                        views.Push(v);
                        break;
                    }
                }
            }
        }
        

        // Add next click achievement
        int achievLev = burgerItem.findAchievementLevel(BB_ACH_CLICK, 0);
        for(int y = 0; y < achievLev + 2 && y < BBItem.ACH_CLICK_ACHIEVEMENTS.size(); y++) {
            let v = new("BBAchievementView").init(BB_ACH_CLICK, 0, BBItem.ACH_CLICK_ACHIEVEMENTS[y], burgerItem.clickCounter < 1, false);
            if(v.obscured) obscuredViews.push(v);
            else views.push(v);
        }

        // Add Burger Achievement
        achievLev = burgerItem.findAchievementLevel(BB_ACH_BURGERS, 0);
        for(int y = 0; y < achievLev + 2 && y < BBItem.ACH_BURGER_ACHIEVEMENTS.size(); y++) {
            let v = new("BBAchievementView").init(BB_ACH_BURGERS, 0, BBItem.ACH_BURGER_ACHIEVEMENTS[y], burgerItem.maxBurgers < 1, false);
            if(v.obscured) obscuredViews.push(v);
            else views.push(v);
        }

        // Add bps achievements
        achievLev = burgerItem.findAchievementLevel(BB_ACH_BPS, 0);
        for(int y = 0; y < achievLev + 2 && y < BBItem.ACH_BPS_ACHIEVEMENTS.size(); y++) {
            let v = new("BBAchievementView").init(BB_ACH_BPS, 0, BBItem.ACH_BPS_ACHIEVEMENTS[y], burgerItem.bps < 1, false);
            if(v.obscured) obscuredViews.push(v);
            else views.push(v);
        }

        // Add next gold burger achievement
        achievLev = burgerItem.findAchievementLevel(BB_ACH_COOKIE, 0);
        for(int y = 0; y < achievLev + 2 && y < BBItem.ACH_COOKIE_ACHIEVEMENTS.size(); y++) {
            let v = new("BBAchievementView").init(BB_ACH_COOKIE, 0, BBItem.ACH_COOKIE_ACHIEVEMENTS[y], burgerItem.goldBurgerCounter < 1, false);
            if(v.obscured) obscuredViews.push(v);
            else views.push(v);
        }

        // Add next steps achievement
        achievLev = burgerItem.findAchievementLevel(BB_ACH_STEPS, 0);
        for(int y = 0; y < achievLev + 2 && y < BBItem.ACH_STEPS_ACHIEVEMENTS.size(); y++) {
            let v = new("BBAchievementView").init(BB_ACH_STEPS, 0, BBItem.ACH_STEPS_ACHIEVEMENTS[y], burgerItem.stepCounter < 1, false);
            if(v.obscured) obscuredViews.push(v);
            else views.push(v);
        }

        // Add next prestige achievement
        achievLev = burgerItem.findAchievementLevel(BB_ACH_PRESTIGE, 0);
        for(int y = 0; y < achievLev + 2 && y < 100; y++) {
            let v = new("BBAchievementView").init(BB_ACH_PRESTIGE, 0, y + 1, burgerItem.prestige < y - 1, false);
            if(v.obscured) obscuredViews.push(v);
            else views.push(v);
        }


        // Now show possible achievements, as we know them
        // Make sure to filter out the ones we have already achieved
        for(int x = 0; x < BBItem.Build_Count; x++) {
            bool obscured = burgerItem.buildings[x].count < 1 && x > 2;
            Array<BBAchievementView> vs;

            // Show the next 2 highest achievement only, don't show all of them
            int lev = burgerItem.findAchievementLevel(BB_ACH_BUILD, x);

            for(int y = 0; y < lev + 2 && y < BBItem.ACH_BUILDING_AND_UPGRADES; y++) {
                vs.push( new("BBAchievementView").init(BB_ACH_BUILD, x, burgerItem.buildingFormula(x, y + 1), obscured, false) );
            }

            if(obscured) {
                obscuredViews.append(vs);
            } else {
                views.append(vs);
            }
        }

        // Do the same for upgrades
        for(int x = 0; x < BBItem.Build_Count; x++) {
            bool obscured = burgerItem.buildings[x].count < 1 && x > 2;
            Array<BBAchievementView> vs;

            // Show the next 2 highest achievement only, don't show all of them
            int upgradeLev = burgerItem.findAchievementLevel(BB_ACH_UPGRADE, x);

            for(int y = 0; y < upgradeLev + 2 && y < BBItem.ACH_BUILDING_AND_UPGRADES; y++) {
                vs.push( new("BBAchievementView").init(BB_ACH_UPGRADE, x, burgerItem.upgradeFormula(x, y + 1), obscured, false) );
            }

            if(obscured) {
                obscuredViews.append(vs);
            } else {
                views.append(vs);
            }
        }

        // Add views
        foreach(v : views) {
            if(!v.achieved && burgerItem.achievements.CheckKey(v.code)) continue;
            mainLayout.addManaged(v);
        }

        // Add obscured
        // TODO: Add header first
        foreach(v : obscuredViews) {
            mainLayout.addManaged(v);
        }
    }


    override void tick() {
        Super.tick();
        
    }

    UIControl getFirstControl() {
        return null;
    }
}



class BBAchievementView : UIView {
    bool obscured, achieved;
    string code;
    int type, subject, amount;

    BBAchievementView init(int type, int subject, int amount, bool obscured, bool achieved) {
        Super.init((0,0), (0, 120));
        self.obscured = obscured;
        self.achieved = achieved;
        self.type = type;
        self.subject = subject;
        self.amount = amount;
        code = BBItem.EncodeAchievementParts(type, subject, amount);

        pin(UIPin.Pin_Left);
        pin(UIPin.Pin_Right);

        let bg = new("UIImage").init((0,0), (0,0), "", NineSlice.Create(achieved ? "BBACHBG" : "BBACHBG2", (12, 12), (20, 20)));
        bg.pinToParent();
        add(bg);

        if(obscured) {
            bg.desaturation = 1.0;
        }

        let burgerItem = BBItem.Find();
        if(!burgerItem) return self;

        string achName = "[NONE]";
        string achTitle = "";

        let vlayout = new("UIVerticalLayout").init((0,0), (0,0));
        vlayout.pin(UIPin.Pin_Left, offset: 100);
        vlayout.pin(UIPin.Pin_Right, offset: -15);
        vlayout.itemSpacing = 5;
        vlayout.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        vlayout.pinHeight(UIView.Size_Min);
        vlayout.layoutMode = UIViewManager.Content_SizeParent;
        add(vlayout);

        switch(type) {
            case BB_ACH_BUILD: {
                string subjectName = StringTable.Localize(burgerItem.buildings[subject].name);
                achTitle = StringTable.Localize(burgerItem.buildings[subject].name .. "_ACH");

                if(burgerItem.buildings[subject].mirrored) {
                    subjectName = BBShopButton.flipWords(subjectName);
                    achTitle = BBShopButton.flipWords(achTitle);
                }
                
                achName = String.Format("Build \c[gold]%s\c- %d times", subjectName, amount);
                break;
            }
            case BB_ACH_CLICK:
                achTitle = "Sore Thumbs";
                achName = String.Format("Manually flip %d times", amount);
                break;
            case BB_ACH_COOKIE:
                achTitle = "Pure Gold";
                achName = String.Format("Capture %d Golden Burgers", amount);
                break;
            case BB_ACH_UPGRADE: {
                string subjectName = StringTable.Localize(burgerItem.buildings[subject].name);
                if(burgerItem.buildings[subject].mirrored) {
                    subjectName = BBShopButton.flipWords(subjectName);

                }
                achTitle = "Hmm.. Upgrades.";
                achName = String.Format("Upgrade %s %d times", subjectName, amount);
                break;
            }
            case BB_ACH_BPS:
                achTitle = "Rate My Burgers";
                achName = String.Format("Achieve %s Burgers Per Second", BBWindow.formatTextNumber( burgerItem.burgerFormula(amount), true, true, false ));
                break;
            case BB_ACH_BURGERS:
                achTitle = "The Burger Vault";
                achName = String.Format("Accumulate %s Burgers", BBWindow.formatTextNumber( burgerItem.burgerFormula(amount), true, true, false ));
                break;
            case BB_ACH_STEPS:
                achTitle = "Running Shoes";
                achName = String.Format("Walk %d steps", amount);
                break;
            case BB_ACH_PRESTIGE:
                achTitle = "Prestigious!";
                achName = String.Format("Prestige %d times", amount);
                break;
        }

        if(achTitle != "") {
            let titleLabel = new("UILabel").init((0,0), (0,0), achTitle, "PDA18FONT", fontScale: (0.9, 0.9));
            titleLabel.pin(UIPin.Pin_Left);
            titleLabel.pin(UIPin.Pin_Right);
            titleLabel.pinHeight(UIView.Size_Min);
            titleLabel.shadowOffset = (1, 1);
            titleLabel.drawShadow = !obscured;

            if(obscured) {
                titleLabel.textColor = 0x00FFFFFF;
                titleLabel.textBackgroundColor = 0xDD333333;
            }

            vlayout.addManaged(titleLabel);
        }

        let label = new("UILabel").init((0,0), (0,0), achName, "PDA16FONT", fontScale: (0.9, 0.9));
        label.pin(UIPin.Pin_Left);
        label.pin(UIPin.Pin_Right);
        label.pinHeight(UIView.Size_Min);
        label.shadowOffset = (1, 1);
        label.drawShadow = !obscured;
        label.multiline = true;

        if(obscured) {
            label.textColor = 0x00FFFFFF;
            label.textBackgroundColor = 0xDD333333;
        } else if(achieved) {
            // Set to brighter color
        }
        vlayout.addManaged(label);

        string img;
        bool mirrorImage = false;

        switch(type) {
            case BB_ACH_BUILD:
                img = String.Format("BBICO%03d", burgerItem.buildings[subject].mirrored ? subject - BBItem.Build_MirrorUniverse : subject);
                mirrorImage = burgerItem.buildings[subject].mirrored;
                break;
            case BB_ACH_UPGRADE: 
                if(subject > -1) {
                    img = String.Format("BBICO%03d", burgerItem.buildings[subject].mirrored ? subject - BBItem.Build_MirrorUniverse : subject);
                } else {
                    let upgradeID = subject * -1;
                    if(burgerItem.availableUpgrades.size() > upgradeID)
                        img = burgerItem.availableUpgrades[upgradeID].icon;
                }
    
                mirrorImage = subject > 0 && burgerItem.buildings[subject].mirrored;
                break;
            case BB_ACH_CLICK:
                img = "BBICO000";
                break;
            case BB_ACH_COOKIE:
                img = "CCPICM";
                break;
            case BB_ACH_BPS:
                img = "BBBPS";
                break;
            case BB_ACH_BURGERS:
                img = "BBBPS";
                break;
            case BB_ACH_STEPS:
                img = "BBFOOTST";
                break;
            case BB_ACH_PRESTIGE:
                img = "BBPRESTI";
                break;
        }


        if(!obscured && achieved) {
            let bg2 = new("UIImage").init((10,0), (80,80), "BBACH1", imgStyle: UIImage.Image_Aspect_Fit);
            bg2.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
            add(bg2);
        }
        
        let iconImage = new("UIImage").init((15,0), (70, 70), img, imgStyle: UIImage.Image_Aspect_Fit);
        iconImage.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);

        if(mirrorImage) {
            iconImage.flipX = true;
            iconImage.blendColor = 0x66CA3DD4;
        }

        if(obscured) {
            iconImage.blendColor = 0xFF333333;
        } else if(!achieved) {
            // Blend with darker color
            iconImage.blendColor = 0x66013D4C;
        }

        add(iconImage);

        return self;
    }
}

