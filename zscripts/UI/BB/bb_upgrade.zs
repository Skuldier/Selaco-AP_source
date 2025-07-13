extend class BBItem {
    Array<BBUpgrade> availableUpgrades;
    Array<BBUpgrade> installedUpgrades;


    void getAvailableUpgrades() {
        int totalClasses = AllClasses.size();
		for(int x = 0; x < totalClasses; x++) {
            if(AllClasses[x] is "BBUpgrade" && AllClasses[x] != "BBUpgrade") {
                availableUpgrades.push(BBUpgrade(new(AllClasses[x])).init(self));
            }
        }
    }

    void tickUpgrades() {
        for(int x = installedUpgrades.size() - 1; x >= 0; x--) {
            installedUpgrades[x].tick();
        }
    }

    void installUpgrade(int index) {
        BBUpgrade upg = availableUpgrades[index];
        availableUpgrades.delete(index);

        installedUpgrades.push(upg);
        upg.onInstall();

        recalcAll();
    }  
}


class BBUpgrade play {
    Array<int> buildings;   // What buildings are affected by this upgrade
    BBItem item;
    double unlockTotal;     // Total burgers ever collected
    double unlockBPS;       // Unlock once X bps is reached
    double unlockActive;    // Active burgers in pool
    double cost;            // Burger cost
    Array<int> unlockBuildings;     // Which buildings need to be owned
    Array<int> unlockBuildingCount; // How many of each
    String icon, name, description;

    virtual BBUpgrade init(BBItem item) {
        self.item = item;
        return self;
    }

    virtual double calculateAdditionalBPS() {
        return 0;
    }

    virtual double calculateAdditionalBPC() {
        return 0;
    }

    virtual clearscope bool shouldUnlock() const {
        bool numbers = item.maxBurgers >= unlockTotal && item.burgers >= unlockActive && item.bps >= unlockBPS;

        if(numbers) {
            for(int x = 0; x < unlockBuildings.size(); x++) {
                if(item.buildings[unlockBuildings[x]].count >= unlockBuildingCount[x]) return true;
            }
        }

        return false;
    }

    virtual void onInstall() {

    }

    // Do maintenance every tick if required
    virtual void tick() { }
}


class BBStepCounterUpgrade : BBUpgrade {
    StatTracker tracker;
    double lastValue;

    const PCT_OF_BPC = 1.0;

    override BBUpgrade init(BBItem item) {
        Super.init(item);
        unlockBuildings.push(BBItem.Build_Flipper);
        unlockBuildingCount.push(15);
        icon = "BBFOOTST";
        self.name = "Pedometer";
        description = "Who says burgers aren't healthy?\nFlip 100% of BPF every step you take outside of the game.";
        cost = 35000;

        return self;
    }

    override void onInstall() {
        Super.onInstall();
        tracker = Stats.GetTracker(STAT_STEP_COUNTER);
        lastValue = tracker.value;
    }

    override void tick() {
        // Add burgers for every step
        item.stepCounter += (tracker.value - lastValue);
        item.burgers += (tracker.value - lastValue) * (item.bpc * PCT_OF_BPC);
        lastValue = tracker.value;
    }
}


class BBBPCUpgrade1 : BBUpgrade {
    override BBUpgrade init(BBItem item) {
        Super.init(item);
        unlockBuildings.push(BBItem.Build_Flipper);
        unlockBuildingCount.push(40);
        icon = "BBFLIP01";
        self.name = "Tungsten Spatula";
        description = "Better spatula, better flipping!\nIncrease BPF by 10% of BPS.";
        cost = 100000;

        return self;
    }

    override double calculateAdditionalBPC() {
        return item.bps * 0.1;
    }
}



class BBUpgradeButton : UIButton {
    int buildingID, upgradeID;
    BBItem burgerItem;
    UIImage iconImage;

    BBUpgradeButton init(int building, int upgrade, BBItem burgerItem) {
        UIButtonState normState     = UIButtonState.CreateSlices("BBBUTT05", (16,16), (20, 84), scaleCenter: true);
        UIButtonState hovState      = UIButtonState.CreateSlices("BBBUTT06", (16,16), (20, 84), scaleCenter: true);
        UIButtonState pressState    = UIButtonState.CreateSlices("BBBUTT07", (16,16), (20, 84), scaleCenter: true);
        UIButtonState disabledState = UIButtonState.CreateSlices("BBBUTT05", (16,16), (20, 84), scaleCenter: true);
        normState.blendColor = 0;
        hovState.blendColor = 0.0;
        pressState.blendColor = 0.0;
        disabledState.blendColor = 0x66000000;

        buildingID = building;
        upgradeID = upgrade;
        self.burgerItem = burgerItem;

        Super.init(
            (0,0), (320, 85),
            "", null,
            normState,
            hovState,
            pressState,
            disabledState,
            null,
            null,
            null
        );

        pin(UIPin.Pin_Left);
        pin(UIPin.Pin_Right);
        pinHeight(90);

        iconImage = new("UIImage").init((0,0), (100, 100), "", imgStyle: UIImage.Image_Aspect_Fit);
        iconImage.pinToParent(8,8,-8,-8);
        add(iconImage);

        update();

        return self;
    }

    double getUpgradeCost() {
        if(buildingID > -1) {
            return burgerItem.getUpgradeCost(buildingID);
        }

        return burgerItem.availableUpgrades.size() > upgradeID ? burgerItem.availableUpgrades[upgradeID].cost : 0;
    }

    void update() {
        // Update graphic
        if(buildingID > -1) {
            iconImage.setImage(String.Format("BBICO%03d", burgerItem.buildings[buildingID].mirrored ? buildingID - BBItem.Build_MirrorUniverse : buildingID));
        } else {
            if(burgerItem.availableUpgrades.size() > upgradeID && upgradeID != -1)
                iconImage.setImage(burgerItem.availableUpgrades[upgradeID].icon);
            else
                iconImage.setImage("");
        }

        iconImage.flipX = buildingID > 0 && burgerItem.buildings[buildingID].mirrored;
        

        // Set greyed out if too expensive
        if(getUpgradeCost() > burgerItem.burgers) {
            iconImage.desaturation = 1.0;
            self.desaturation = 1.0;
            iconImage.blendColor = 0;
        } else {
            iconImage.desaturation = 0;
            self.desaturation = 0;
            iconImage.blendColor = buildingID > 0 && burgerItem.buildings[buildingID].mirrored ? 0x66CA3DD4 : 0;
        }
    }

    override void onMouseEnter(Vector2 screenPos) {
        Super.onMouseEnter(screenPos);

        sendEvent(UIHandler.Event_Alternate_Activate, true, false);
    }

    override void onMouseExit(Vector2 screenPos, UIView newView) {
        Super.onMouseExit(screenPos, newView);

        sendEvent(UIHandler.Event_Deselected, true, false);
    }
}


class BBUpgradePopUp : UIImage {
    int buildingID, upgradeID;
    BBItem burgerItem;
    UILabel label, descriptionLabel, priceLabel;
    bool mouseMode;

    BBUpgradePopUp init(int building, int upgrade, BBItem burgerItem) {
        buildingID = building;
        upgradeID = upgrade;
        mouseMode = true;

        self.burgerItem = burgerItem;

        Super.init(
            (0,0), (320, 120),
            "", NineSlice.Create("BBBACK01", (20,20), (380, 380), scaleCenter: true)
        );

        maxSize.x = 450;
        pinWidth(0.5, offset: -85, isFactor: true);
        pinHeight(UIView.Size_Min);
        minSize.y = 120;
        
        label = new("UILabel").init((8+10, 8+5), (400, 400), "None"/*burgerItem.buildings[building].name*/, "PDA18FONT");
        label.textAlign = UIView.Align_TopLeft;
        label.drawShadow = true;
        add(label);

        priceLabel = new("UILabel").init((0, 8 + 10), (10, 20), "100000", "PDA16FONT", textAlign: UIView.Align_Right, fontScale: (0.85, 0.85));
        //priceLabel.monospace = true;  // Can't use monospace, since adding escape characters fucks up the width calculation >:(
        priceLabel.pin(UIPin.Pin_Right, offset: -(8 + 10));
        priceLabel.pin(UIPin.Pin_Left, offset: 0);
        priceLabel.shadowOffset = (1,1);
        priceLabel.drawShadow = true;
        priceLabel.multiline = false;
        add(priceLabel);

        let buildName = "none";//burgerItem.buildings[building].mirrored ? BBShopButton.flipWords(burgerItem.buildings[building].name) : burgerItem.buildings[building].name;
        
        descriptionLabel = new("UILabel").init((0,45), (80, 80), String.Format("%ss become 2X as effective.", buildName), "PDA16FONT", fontScale: (0.85, 0.85));
        descriptionLabel.pin(UIPin.Pin_Left, offset: 8+10);
        descriptionLabel.pin(UIPin.Pin_Right, offset: -(8 + 10));
        descriptionLabel.shadowOffset = (1,1);
        descriptionLabel.drawShadow = true;
        add(descriptionLabel);

        update();

        return self;
    }


    void update() {
        double cost = buildingID > -1 ? burgerItem.getUpgradeCost(buildingID) : burgerItem.availableUpgrades[upgradeID].cost;
        let buildName = StringTable.Localize(buildingID > -1 ? burgerItem.buildings[buildingID].name : burgerItem.availableUpgrades[upgradeID].name);
        if(buildingID > -1 && burgerItem.buildings[buildingID].mirrored) {
            buildName = BBShopButton.flipWords(buildName);
        }

        label.setText(buildName);
        priceLabel.setText(String.Format("\c[%s]%s", cost > burgerItem.burgers ? "red" : "green", BBWindow.formatTextNumber(cost, true)));
        
        if(buildingID > -1) {
            //iconImage.setImage(String.Format("BBICO%03d", buildingID));
            let desc = StringTable.Localize(String.Format("%s%d", burgerItem.buildings[buildingID].name, burgerItem.buildings[buildingID].numUpgrades % 10));
            if(burgerItem.buildings[buildingID].mirrored) {
                desc = BBShopButton.flipWords(desc);
            }
            descriptionLabel.setText(desc);
        } else {
            descriptionLabel.setText(burgerItem.availableUpgrades[upgradeID].description);
            //iconImage.setImage(burgerItem.availableUpgrades[upgradeID].icon);
        }
    }

    override Vector2 calcMinSize(Vector2 parentSize) {
        let lsize = descriptionLabel.calcMinSize((frame.size.x, 9999999));
        return (frame.size.x, lsize.y + descriptionLabel.frame.pos.y + 18);
    }

    override void layout(Vector2 parentScale, double parentAlpha, bool skipSubviews) {
        Super.layout(parentScale, parentAlpha, skipSubviews);

        let m = getMenu();
        if(m && mouseMode) {
            // Always follow mouse
            let scpy = parent.screenToRel((0,m.mouseY));
            frame.pos.y = clamp(scpy.y - 30, 0, parent.frame.size.y - frame.size.y);
        } else {
            frame.pos.y = parent.frame.size.y - frame.size.y;
        }
    }

    override void Draw() {
        let m = getMenu();
        if(m && mouseMode) {
            // Always follow mouse
            let scpy = parent.screenToRel((0,m.mouseY));
            frame.pos.y = clamp(scpy.y - 30, 0, parent.frame.size.y - frame.size.y);
        } else {
            frame.pos.y = parent.frame.size.y - frame.size.y;
        }
        
        Super.Draw();
    }
}