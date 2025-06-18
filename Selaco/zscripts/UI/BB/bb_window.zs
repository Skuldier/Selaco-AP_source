class BBWindow : PDAAppWindow {
    BBButton burgerButt;
    FlippersGFX flippers;
    UILabel burgerCounter, bpsCounter, prestigeLabel;
    BBItem burgerItem;
    UIVerticalScroll storeScroll, upgradesScroll;
    UIVerticalLayout storeLayout, upgradesLayout;
    BBStorePopup storePopup;
    UIScrollBG sauceGraphic, burgerScroller, burgerScroller2;
    UIView mainView, leftView;    // lazy conversion from Menu
    UIView burgerButtPromptView, settingsButtonPrompt;
    UIImage burgerBackground, adImage;
    BBUpgradePopUp upgradePopup;
    BBShopButton lastShopButton;
    BBUpgradeButton lastUpgradeButton;
    BBSettingsPopUp settingsPop;

    UIButton storeButton, progressButton, achievementsButton, prestigeButton, cloudButton, inventoryButton, settingsButton;
    BBShopView shopView;
    BBStoreView storeView;          // Actual store, inside shopview
    BBProgressView progressView;    // inside shopview
    BBInventoryView inventoryView;    // Show inventory and burger skins
    BBAchievementsView achievementsView;

    UIControl tabRedirect;          // Used to redirect navigation from tabs

    Array<UIButton> tabButtons;
    int bannerAdCounter;            // Increase whenever a new ad is shown

    uint needsUpdate, ticks;
    double upgrades;
    bool lastActionWasGamepad, shopViewOpen;

    const SHOP_WIDTH = 400;
    const MAX_BANNER_ADS = 2;
    
    override PDAAppWindow vInit(Vector2 pos, Vector2 size) {
        return Init(pos, size);
    }

    BBWindow init(Vector2 pos, Vector2 size) {
        bool usingGP = InputHandler.Instance().isUsingGamepad;

        Super.init(pos, size,
            "Burger Flipper v0.03", "SEL16FONT",
            NineSlice.Create("BBWIND", (30, 60), (74, 82)),
            dragHeight: 46,
            sizerWidth: 17,
            46, 17, 17, 18,
            showDragBar: false,
            titleHeight: 41,
            titleOffset: 5,
            titleOffsetX: 0
        );

        closeButton.buttStates[UIButton.State_Normal].tex = UITexture.Get("BBCLO1");
        closeButton.buttStates[UIButton.State_Hover].tex = UITexture.Get("BBCLO2");
        closeButton.buttStates[UIButton.State_Pressed].tex = UITexture.Get("BBCLO3");
        mainView = contentView;
        bannerAdCounter = random(0,100); 

        appID = PDA_APP_BORGIR;
        minSize = (1200, 600);

        burgerItem = BBItem.Find();

        // Can't run game without the item
        if(!burgerItem) {
            Console.Printf("\c[RED]No BBItem found!");
            return null;
        }

        updateUpgrades();

        leftView = new("UIView").init((0,0), (100, 100));
        leftView.pinToParent(0,0,-410,0);
        mainView.add(leftView);

        burgerBackground = new("UIImage").init((0,0), (1,1), "BBBACK03", imgStyle: UIImage.Image_Repeat);
        burgerBackground.pinToParent();
        leftView.add(burgerBackground);

        let burgerBackground2 = new("UIImage").init((0,0), (1,1), "BBBACK04");
        burgerBackground2.pinToParent();
        burgerBackground.add(burgerBackground2);


        burgerScroller2 = new("UIScrollBG").init("CCPIC18", null);
        burgerScroller2.force = (0, -0.2);
        burgerScroller2.edgeOffset = (0,0);
        burgerScroller2.ignoreMouse = true;
        burgerScroller2.filter = true;
        leftView.add(burgerScroller2);
        burgerScroller2.hidden = burgerItem.bps < 1000000;

        burgerScroller = new("UIScrollBG").init("CCPIC19", null);
        burgerScroller.force = (0, -0.4);
        burgerScroller.edgeOffset = (0,0);
        burgerScroller.ignoreMouse = true;
        burgerScroller.filter = true;
        leftView.add(burgerScroller);
        burgerScroller.hidden = burgerItem.bps < 100;


        sauceGraphic = new("UIScrollBG").init("BBSAUCE1", null);
        sauceGraphic.clearPins();
        sauceGraphic.pin(UIPin.Pin_Left);
        sauceGraphic.pin(UIPin.Pin_Right);
        sauceGraphic.pin(UIPin.Pin_Bottom);
        sauceGraphic.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 1.0 - (upgrades * 0.3) - 0.1, isFactor: true);
        sauceGraphic.force = (-0.2, 0);
        sauceGraphic.edgeOffset = (0,0);
        sauceGraphic.ignoreMouse = true;
        sauceGraphic.filter = true;
        sauceGraphic.scrollScale = (2,2);
        leftView.add(sauceGraphic);


        flippers = new("FlippersGFX").init();
        flippers.numFlippers = burgerItem.buildings[BBItem.Build_Flipper].count;
        flippers.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        flippers.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        leftView.add(flippers);


        burgerButt = new("BBButton").init(
            (420, 420), burgerItem.skin
        );
        burgerButt.rejectHoverSelection = true;
        leftView.add(burgerButt);


        let counterBack = new("UIView").init((0,0), (100, 80));
        counterBack.backgroundColor = 0x66000000;
        counterBack.pin(UIPin.Pin_Top, offset: 50);
        counterBack.pin(UIPin.Pin_Left);
        counterBack.pin(UIPin.Pin_Right);
        leftView.add(counterBack);

        burgerCounter = new("UILabel").init(
            (0,0), (100, 80),
            "0 Burgers Flipped", "PDA18FONT",
            textAlign: UIView.Align_Centered,
            fontScale: (0.87, 1.0)
        );
        
        burgerCounter.pinToParent(0,0,0,-15);
        burgerCounter.monospace = true;
        burgerCounter.clipsSubviews = false;
        counterBack.add(burgerCounter);

        bpsCounter = new("UILabel").init(
            (0,0), (100, 20),
            "per second: 0", "PDA16FONT",
            textAlign: UIView.Align_Centered,
            fontScale: (0.87, 1.0)
        );
        bpsCounter.pin(UIPin.Pin_Left);
        bpsCounter.pin(UIPin.Pin_Right);
        bpsCounter.pin(UIPin.Pin_VCenter, value: 1.0, offset: 28, isFactor: true);
        burgerCounter.add(bpsCounter);


        prestigeLabel = new("UILabel").init(
            (0,0), (100, 80),
            String.Format("Prestige: %d", burgerItem.prestige), "PDA18FONT",
            textAlign: UIView.Align_Right,
            fontScale: (0.87, 1.0)
        );
        prestigeLabel.pinHeight(UIView.Size_Min);
        prestigeLabel.pinWidth(200);
        prestigeLabel.pin(UIPin.Pin_Right, offset: -15);
        prestigeLabel.pin(UIPin.Pin_Bottom, offset: -15);
        prestigeLabel.hidden = burgerItem.prestige < 1;
        prestigeLabel.drawShadow = true;
        prestigeLabel.shadowOffset = (2,2);
        leftView.add(prestigeLabel);


        storeScroll = new("UIVerticalScroll").init((0,0), (0,0), 15, 15,
            NineSlice.Create("BBBAR01", (7,8), (8,28)), null,
            UIButtonState.CreateSlices("BBBAR02", (6,6), (9,13)),
            UIButtonState.CreateSlices("BBBAR03", (6,6), (9,13)),
            UIButtonState.CreateSlices("BBBAR04", (6,6), (9,13)),
            insetA: 10,
            insetB: 10,
            scrollPadding: 5
        );
        storeScroll.scrollbar.firstPin(UIPin.Pin_Right).offset = -7;
        storeScroll.pin(UIPin.Pin_Right);
        storeScroll.pin(UIPin.Pin_Top);
        storeScroll.pin(UIPin.Pin_Bottom, offset: -80);
        storeScroll.pinWidth(400);
        storeScroll.autoHideAdjustsSize = true;
        storeScroll.autoHideScrollbar = true;
        storeScroll.scrollbar.rejectHoverSelection = true;
        storeScroll.rejectHoverSelection = true;
        storeScroll.mLayout.setPadding(10,10,10,10);
        storeScroll.mLayout.itemSpacing = 5;

        storeLayout = UIVerticalLayout(storeScroll.mLayout);
        storeLayout.ignoreHiddenViews = true;
        mainView.add(storeScroll);

        adImage = new("UIImage").init((0,0), (400,80), "BBAD", imgStyle: UIImage.Image_Scale);
        adImage.pin(UIPin.Pin_Right);
        adImage.pin(UIPin.Pin_Bottom);
        mainView.add(adImage);

        // Scroll background
        let storeScrollBack = new("UIImage").init((0,0), (1,1), "BBBACK02", imgStyle: UIImage.Image_Repeat);
        storeScrollBack.pinToParent();
        storeScroll.add(storeScrollBack);
        storeScroll.moveToBack(storeScrollBack);

        let storeScrollBack2 = new("UIImage").init((0,0), (1,1), "BBBACK05");
        storeScrollBack2.pinToParent();
        storeScroll.add(storeScrollBack2);
        storeScroll.moveInfront(storeScrollBack2, storeScrollBack);

        // Scroll border
        let storeBorder = new("UIView").init((0,0), (10, 1));
        storeBorder.backgroundColor = 0xFF006179;
        storeBorder.pin(UIPin.Pin_Top);
        storeBorder.pin(UIPin.Pin_Bottom);
        storeBorder.pin(UIPin.Pin_Right, offset: -400);
        mainView.add(storeBorder);


        upgradesScroll = new("UIVerticalScroll").init((0,0), (380,100), 14, 14,
            NineSlice.Create("PDAVBAR1", (6,6), (8,26)), null,
            UIButtonState.CreateSlices("PDAVBAR2", (6,6), (8,26)),
            UIButtonState.CreateSlices("PDAVBAR3", (6,6), (8,26)),
            UIButtonState.CreateSlices("PDAVBAR4", (6,6), (8,26)),
            insetA: 0,
            insetB: 0
        );
        upgradesScroll.pin(UIPin.Pin_Right, offset: -415);
        upgradesScroll.pin(UIPin.Pin_Top);
        upgradesScroll.pin(UIPin.Pin_Bottom);
        upgradesScroll.pinWidth(90);
        upgradesScroll.autoHideAdjustsSize = true;
        upgradesScroll.autoHideScrollbar = true;
        upgradesScroll.raycastTarget = false;
        upgradesScroll.scrollbar.rejectHoverSelection = true;
        upgradesScroll.rejectHoverSelection = true;
        upgradesScroll.mLayout.itemSpacing = 5;
        upgradesScroll.mLayout.setPadding(0,10,0,10);

        upgradesLayout = UIVerticalLayout(upgradesScroll.mLayout);
        upgradesLayout.ignoreHiddenViews = true;
        mainView.add(upgradesScroll);


        // Add all the store buttons at once, we'll hide the unused ones
        // Flipper button
        
        // Worker button
        
        // Various buildings
        BBShopButton lastBtn = null;
        for(int x = 0; x < BBItem.Build_Count; x++) {
            BBShopButton btn = new("BBShopButton").init(x, burgerItem);
            btn.navLeft = upgradesScroll;
            btn.navUp = lastBtn;
            if(lastBtn) lastBtn.navDown = btn;
            lastBtn = btn;
            storeLayout.addManaged(btn);
        }


        storePopup = new("BBStorePopup").init(0, burgerItem);
        storePopup.mouseMode = !usingGP;
        mainView.add(storePopup);
        storePopup.hidden = true;

        upgradePopup = new("BBUpgradePopUp").init(0, -1, burgerItem);
        upgradePopup.mouseMode = !usingGP;
        mainView.add(upgradePopup);
        upgradePopup.hidden = true;


        burgerButtPromptView = new("UIView").init((0,0), (400, 40));
        burgerButtPromptView.pin(UIPin.Pin_Left);
        burgerButtPromptView.pin(UIPin.Pin_Right);
        burgerButtPromptView.pin(UIPin.Pin_Top, value: 1.0, isFactor: true);
        //burgerButtPromptView.pin(UIPin.Pin_VCenter, UIPin.Pin_VCenter, value: 1.0, offset: -210, isFactor: true);
        burgerButtPromptView.pinHeight(50);
        burgerButtPromptView.pinWidth(400);
        burgerButtPromptView.raycastTarget = false;
        leftView.add(burgerButtPromptView);

        let bbtxt = new("UILabel").init(
            (0,0), (100, 80),
            String.Format("%s Flip Burger", UIHelper.GetGamepadString(InputEvent.KEY_PAD_X)), "PDA18FONT",
            textAlign: UIView.Align_Centered,
            fontScale: (1, 1)
        );
        bbtxt.backgroundColor = 0x55000000;
        bbtxt.pinToParent();
        burgerButtPromptView.add(bbtxt);
        burgerButtPromptView.hidden = !usingGP;


        // Prestige button, not added to view immediately
        prestigeButton = new("UIButton").init((0,0), (180, 80), "", "PDA16FONT",
            UIButtonState.CreateSlices("BBBUTT05", (16,16), (20, 84), scaleCenter: true),
            UIButtonState.CreateSlices("BBBUTT06", (16,16), (20, 84), scaleCenter: true),
            UIButtonState.CreateSlices("BBBUTT07", (16,16), (20, 84), scaleCenter: true)
        );
        prestigeButton.pin(UIPin.Pin_Left);
        prestigeButton.pin(UIPin.Pin_Right);
        let pbg = new("UIImage").init((0,0), (1,1), "BBPRESTI", imgStyle: UIImage.Image_Aspect_Fit);
        pbg.pinToParent();
        prestigeButton.add(pbg);

        prestigeButton.command = "Prestige";


        // Cloud button, only used when we need to update the save file and the user selected NO when the prompt came up
        cloudButton = new("UIButton").init((0,0), (64, 55), "", NULL, 
            UIButtonState.Create("BBCLOUD2"),
            UIButtonState.Create("BBCLOUD3"),
            UIButtonState.Create("BBCLOUD4")
        );
        cloudButton.imgStyle = UIImage.Image_Aspect_Fit;
        cloudButton.hidden = burgerItem.isGlobalGame;
        cloudButton.onClick = cloudButtonPressed;
        cloudButton.receiver = self;
        cloudButton.pin(UIPin.Pin_Left, offset: 15);
        cloudButton.pin(UIPin.Pin_Top, offset: 15);
        leftView.add(cloudButton);


        tabRedirect = new("UIControl").init((0,0), (0,0));
        tabRedirect.forwardSelection = null;
        tabRedirect.navUp = tabRedirect.navDown = tabRedirect.navLeft = tabRedirect.navRight = storeScroll;

        settingsButton = new("UIButton").init((0,0), (60, 60), "", NULL, 
            UIButtonState.Create("BBSETT1"),
            UIButtonState.Create("BBSETT2"),
            UIButtonState.Create("BBSETT3")
        );
        settingsButton.imgStyle = UIImage.Image_Aspect_Fit;
        settingsButton.hidden = !burgerItem.isGlobalGame;
        settingsButton.onClick = settingsButtonPressed;
        settingsButton.receiver = self;
        settingsButton.navLeft = tabRedirect;
        settingsButton.pin(UIPin.Pin_Left, offset: 15);
        settingsButton.pin(UIPin.Pin_Top, offset: 15);
        leftView.add(settingsButton);

        settingsButtonPrompt = new("UILabel").init(
            (0,0), (100, 80),
            String.Format("%s", UIHelper.GetGamepadString(InputEvent.Key_Pad_LThumb)), "PDA18FONT",
            textAlign: UIView.Align_Centered,
            fontScale: (1, 1)
        );
        settingsButtonPrompt.pinWidth(UIView.Size_Min);
        settingsButtonPrompt.pinHeight(UIView.Size_Min);
        settingsButtonPrompt.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, offset: -5);
        settingsButtonPrompt.pin(UIPin.Pin_Left, UIPin.Pin_Right, offset: -5);
        settingsButton.clipsSubviews = false;
        settingsButton.add(settingsButtonPrompt);
        settingsButtonPrompt.hidden = !usingGP;


        // Store Button/Area
        storeButton = new("UIButton").init((0,0), (180, 45), "Store", "PDA16FONT",
            UIButtonState.CreateSlices("BBSBUTT1", (8,8), (24, 24), textColor: Font.CR_UNTRANSLATED),
            UIButtonState.CreateSlices("BBSBUTT2", (8,8), (24, 24), textColor: Font.CR_UNTRANSLATED),
            UIButtonState.CreateSlices("BBSBUTT3", (8,8), (24, 24), textColor: Font.CR_UNTRANSLATED)
        );
        storeButton.pin(UIPin.Pin_Left);
        storeButton.pin(UIPin.Pin_Bottom, offset: -15);
        storeButton.label.textAlign = UIView.Align_Left | UIView.Align_Middle;
        storeButton.setTextPadding(10, 0, 12, 0);
        storeButton.pinWidth(UIView.Size_Min);
        storeButton.command = "Store";
        storeButton.navRight = upgradesScroll;
        storeButton.navLeft = tabRedirect;
        mainView.add(storeButton);
        tabButtons.push(storeButton);


        // Level Up interface
        progressButton = new("UIButton").init((0,0), (180, 45), "Rewards", "PDA16FONT",
            UIButtonState.CreateSlices("BBSBUTT1", (8,8), (24, 24), textColor: Font.CR_UNTRANSLATED),
            UIButtonState.CreateSlices("BBSBUTT2", (8,8), (24, 24), textColor: Font.CR_UNTRANSLATED),
            UIButtonState.CreateSlices("BBSBUTT3", (8,8), (24, 24), textColor: Font.CR_UNTRANSLATED)
        );
        progressButton.pin(UIPin.Pin_Left);
        progressButton.pin(UIPin.Pin_Bottom, offset: -(15 + 45));
        progressButton.label.textAlign = UIView.Align_Left | UIView.Align_Middle;
        progressButton.setTextPadding(10, 0, 12, 0);
        progressButton.pinWidth(UIView.Size_Min);
        progressButton.command = "Progress";
        progressButton.navRight = upgradesScroll;
        progressButton.navLeft = tabRedirect;
        mainView.add(progressButton);
        tabButtons.push(progressButton);

        // Achievements button
        achievementsButton = new("UIButton").init((0,0), (180, 45), "Achievements", "PDA16FONT",
            UIButtonState.CreateSlices("BBSBUTT1", (8,8), (24, 24), textColor: Font.CR_UNTRANSLATED),
            UIButtonState.CreateSlices("BBSBUTT2", (8,8), (24, 24), textColor: Font.CR_UNTRANSLATED),
            UIButtonState.CreateSlices("BBSBUTT3", (8,8), (24, 24), textColor: Font.CR_UNTRANSLATED)
        );
        achievementsButton.pin(UIPin.Pin_Left);
        achievementsButton.pin(UIPin.Pin_Bottom, offset: -(15 + 45 * 2));
        achievementsButton.label.textAlign = UIView.Align_Left | UIView.Align_Middle;
        achievementsButton.setTextPadding(10, 0, 12, 0);
        achievementsButton.pinWidth(UIView.Size_Min);
        achievementsButton.command = "Achievements";
        achievementsButton.navRight = upgradesScroll;
        achievementsButton.navLeft = tabRedirect;
        mainView.add(achievementsButton);
        tabButtons.push(achievementsButton);

        // Inventory button
        inventoryButton = new("UIButton").init((0,0), (180, 45), "Inventory", "PDA16FONT",
            UIButtonState.CreateSlices("BBSBUTT1", (8,8), (24, 24), textColor: Font.CR_UNTRANSLATED),
            UIButtonState.CreateSlices("BBSBUTT2", (8,8), (24, 24), textColor: Font.CR_UNTRANSLATED),
            UIButtonState.CreateSlices("BBSBUTT3", (8,8), (24, 24), textColor: Font.CR_UNTRANSLATED)
        );
        inventoryButton.pin(UIPin.Pin_Left);
        inventoryButton.pin(UIPin.Pin_Bottom, offset: -(15 + 45 * 3));
        inventoryButton.label.textAlign = UIView.Align_Left | UIView.Align_Middle;
        inventoryButton.setTextPadding(10, 0, 12, 0);
        inventoryButton.pinWidth(UIView.Size_Min);
        inventoryButton.navRight = upgradesScroll;
        inventoryButton.navLeft = tabRedirect;
        inventoryButton.command = "Inventory";
        mainView.add(inventoryButton);
        tabButtons.push(inventoryButton);


        shopView = new("BBShopView").init();
        shopView.backgroundColor = 0xFF006179;
        shopView.pin(UIPin.Pin_Right, UIPin.Pin_Left, value: 1.0, isFactor: true);
        shopView.pinWidth(SHOP_WIDTH);
        shopView.pin(UIPin.Pin_Top);
        shopView.pin(UIPin.Pin_Bottom);
        shopView.alpha = 0;
        shopView.raycastTarget = false;
        shopView.window = self;
        mainView.add(shopView);


        storeView = new("BBStoreView").init();
        storeView.window = self;
        progressView = new("BBProgressView").init();
        progressView.window = self;
        achievementsView = new("BBAchievementsView").init();
        achievementsView.window = self;
        inventoryView = new("BBInventoryView").init();
        inventoryView.window = self;

        inventoryButton.navDown = achievementsButton;
        achievementsButton.navDown = progressButton;
        progressButton.navDown = storeButton;
        storeButton.navUp = progressButton;
        progressButton.navUp = achievementsButton;
        achievementsButton.navUp = inventoryButton;

        //shopView.contentView.add(storeView);

        if(BBPremiumItem.HasPremium()) {
            hideAds();
        }

        lastActionWasGamepad = usingGP;

        return self;
    }


    // Callbacks ====================

    static ui bool achievementReceived(UIView self, int arg1, int arg2, int arg3, bool isManual) {
        BBWindow self = BBWindow(self);
        if(self) {
            self.achievementsView.refreshAchievements();
            self.progressView.updateSegments();
            self.popUpAchievement(arg1, arg2, arg3);
        }
        return false;
    }

    static ui bool achievementsChanged(UIView self, int arg1, int arg2, int arg3, bool isManual) {
        BBWindow self = BBWindow(self);
        if(self) {
            self.achievementsView.refreshAchievements();
            self.progressView.updateSegments();
        }
        return false;
    }

    static ui bool rewardsChanged(UIView self, int arg1, int arg2, int arg3, bool isManual) {
        BBWindow self = BBWindow(self);
        if(self) {
            self.progressView.updateSegments();
            self.shopView.updateCounts();
        }
        return false;
    }

    // End Callbacks ================


    const DEFAULT_WIDTH = 1200;
    override void setDefaultPositionAndSize(int desktopWidth, int desktopHeight) {
        if(minSize.x > desktopWidth) minSize.x = desktopWidth;
        if(minSize.y > desktopHeight) minSize.y = desktopHeight;

        double desiredWidth = lastActionWasGamepad ? max(DEFAULT_WIDTH, desktopWidth - 40) : DEFAULT_WIDTH;

        frame.pos = ((desktopWidth / 2) - (DEFAULT_WIDTH / 2), 25);
        frame.size = (DEFAULT_WIDTH, desktopHeight - 50);

        if(frame.size.x >= desktopWidth) {
            frame.size.x = desktopWidth;
            frame.pos.x = 0;
        }
    }

    override bool restorePos() {
        if(parent) {
            let sz = parent.frame.size;
            if(minSize.x > sz.x) minSize.x = sz.x;
            if(minSize.y > sz.y) minSize.y = sz.y;
        }
        
        let res = Super.restorePos();

        // Format for gamepad, ignore restored size
        if(lastActionWasGamepad && parent) {
            let desktopWidth = parent.frame.size.x;
            let desiredWidth = desktopWidth - 40;
            let desktopHeight = parent.frame.size.y;
            frame.pos = ((desktopWidth / 2) - (desiredWidth / 2), 25);
            frame.size = (desiredWidth, desktopHeight - 50);

            if(frame.size.x >= desktopWidth) {
                frame.size.x = desktopWidth;
                frame.pos.x = 0;
            }
        }

        return res;
    }


    static String formatTextNumber(double num, bool whole = false, bool trunc = true, bool short = false) {
        String res;
        double val = num;
        if(whole || (trunc && num >= 1000.0)) val = floor(val);

        if(num < 10000) {
            res = whole ? String.Format("%.0f", num) : String.Format("%.2f", num);
        } else if(num < 1000000.0) {
            val = num / 1000.0;
        } else if(num < 1000000000.0) {
            val = num / 1000000.0;
        } else if(num < 1000000000000.0) {
            val = num / 1000000000.0;
        } else if(num < 1000000000000000.0) {
            val = num / 1000000000000.0;
        } else if(num < 1E+15) {
            val = num / 1000000000000000.0;
        } else if(num < 1E+18) {
            val = num / 1E+15;
        } else if(num < 1E+21) {
            val = num / 1E+18;
        } else {
            val = num / 1E+21;
        }

        if(num >= 10000) res = String.Format("%.3f", val);

        // Remove trailing zeros
        if(trunc) {
            int rid = res.RightIndexOf(".");
            if(rid > 0) {
                int sub = 0;
                for(int x = res.length() - 1; x >= rid; x--) {
                    int b = res.byteAt(x);
                    if(b == 48 || b == 46) sub++;
                    else break;
                }
                res.remove(res.length() - sub, sub);
            }
        }


        if(num >= 10000) {
            if(num < 1000000) {
                res = res .. (short ? "K" : " thousand");
            } else if(num < 1000000000) {
                res = res .. (short ? "M" : " million");
            } else if(num < 1e+12) {
                res = res .. (short ? "B" : " billion");
            } else if(num < 1e+15) {
                res = res .. (short ? "T" : " trillion");
            } else if(num < 1e+18) {
                res = res .. (short ? "Q" : " quadrillion");
            } else if(num < 1e+21) {
                res = res .. (short ? "QI" : " quintillion");
            } else {
                res = res .. (short ? "SX" : " sextillion");
            }
        }

        return res;
    }


    // Store and Progress
    void showStoreView() {
        if(storeView.parent == null) {
            progressView.removeFromSuperview();
            achievementsView.removeFromSuperview();
            inventoryView.removeFromSuperview();
            shopView.contentView.add(storeView);
            storeView.requiresLayout = true;
            storeView.reload();
            storeView.animateIn();
        }

        tabRedirect.forwardSelection = storeView.getFirstControl();

        animateInShop();
    }


    void showInventoryView() {
        if(inventoryView.parent == null) {
            progressView.removeFromSuperview();
            achievementsView.removeFromSuperview();
            storeView.removeFromSuperview();
            shopView.contentView.add(inventoryView);
            
            inventoryView.reload();
            inventoryView.animateIn();
        }

        tabRedirect.forwardSelection = inventoryView.getFirstControl();

        animateInShop();
    }

    void animateInShop() {
        shopViewOpen = true;

        // Don't animate if we are already in the desired location
        if(shopView.firstPin(UIPin.Pin_Right).offset == SHOP_WIDTH) return;

        getAnimator().clear(shopView, false);

        shopView.alpha = 1;
        let anim = new("UIViewPinAnimation").initComponents(
            shopView, 
            0.35,
            //toAlpha: 1.0,
            ease: Ease_Out
        );
        anim.addValues(UIPin.Pin_Right, endOffset: SHOP_WIDTH);
        getAnimator().add(anim);

        foreach(butt : tabButtons) {
            anim = new("UIViewPinAnimation").initComponents(
                butt, 
                0.35,
                ease: Ease_Out
            );
            anim.addValues(UIPin.Pin_Left, endOffset: SHOP_WIDTH - 2);
            getAnimator().add(anim);
        }
    }


    void hideshopView() {
        shopViewOpen = false;
        tabRedirect.forwardSelection = null;

        getAnimator().clear(shopView, false);

        let anim = new("UIViewPinAnimation").initComponents(
            shopView, 
            0.35,
            //toAlpha: 0.0,
            ease: Ease_In
        );
        anim.addValues(UIPin.Pin_Right, endOffset: 0);
        getAnimator().add(anim);

        foreach(butt : tabButtons) {
            anim = new("UIViewPinAnimation").initComponents(
                butt, 
                0.35,
                ease: Ease_In
            );
            anim.addValues(UIPin.Pin_Left, endOffset: -2);
            getAnimator().add(anim);
        }
    }

    void showProgressView() {
        storeView.removeFromSuperview();
        achievementsView.removeFromSuperview();
        inventoryView.removeFromSuperview();
        progressView.requiresLayout = true;
        shopView.contentView.add(progressView);

        tabRedirect.forwardSelection = progressView.getFirstControl();

        animateInShop();
    }

    void showAchievementsView() {
        storeView.removeFromSuperview();
        progressView.removeFromSuperview();
        inventoryView.removeFromSuperview();
        achievementsView.refreshAchievements();
        achievementsView.requiresLayout = true;
        shopView.contentView.add(achievementsView);

        tabRedirect.forwardSelection = achievementsView.getFirstControl();

        animateInShop();
    }

    void hideProgressView(bool animate = true) {
        hideshopView();
    }


    void hideAds() {
        adImage.hidden = true;
        storeScroll.firstPin(UIPin.Pin_Bottom).offset = 0;
        storeScroll.requiresLayout = true;

        // TODO: If any pop up ads are showing somehow, remove them
    }


    override bool onInputEvent(InputEvent ev) {
        if(ev.type == InputEvent.Type_KeyDown && ev.KeyScan == InputEvent.Key_Pad_LThumb) {
            // Open settings menu
            if(settingsPop) {
                settingsPop.removeFromSuperview();
                settingsPop = null;
                if(lastControlBeforeSettings) {
                    getMenu().navigateTo(lastControlBeforeSettings, false, true);
                    lastControlBeforeSettings = null;
                }
            } else {
                if(settingsButton && !settingsButton.hidden) {
                    settingsButton.onActivate(false, true);
                }
            }
        }

        return false;
    }

    override bool menuEvent(int key, bool fromcontroller) {
        UIMenu m = getMenu();
        if(!m) { return false; }    // How the hell could this even happen?

        if(fromController || (key == Menu.MKEY_Left || key == Menu.MKEY_Right || key == Menu.MKEY_Up || key == Menu.MKEY_Down || key == Menu.MKEY_Enter)) {
            lastActionWasGamepad = true;
            if(upgradePopup) upgradePopup.mouseMode = false;
            if(storePopup) storePopup.mouseMode = false;
            burgerButtPromptView.hidden = false;
            settingsButtonPrompt.hidden = false;
        }

        if(m.activeControl == null && (key == Menu.MKEY_Left || key == Menu.MKEY_Right || key == Menu.MKEY_Up || key == Menu.MKEY_Down || key == Menu.MKEY_Enter)) {
            m.navigateTo(getActiveControl());
        }

        if(key == Menu.MKEY_Clear) {
            // Check for golden burgers, click those first
            foreach(b : goldBurgerButtons) {
                if(b && !b.hidden && !b.leaving) {
                    b.onActivate(false, true);
                    return true;
                }
            }

            burgerButt.onActivate(false, true);
            return true;
        }

        return Super.menuEvent(key, fromcontroller);
    }


    override void navigateToFirstControl(bool atOpen, bool gamepad) {
        if(atOpen && !gamepad) return;
        Super.navigateToFirstControl(atOpen, gamepad);
    }

    override UIControl getActiveControl() {
        if(lastShopButton && !lastShopButton.isDisabled() && !lastShopButton.hidden) return lastShopButton;

        let m = getMenu();
        if(!m.activeControl) {
            // Find a control to select
            for(int x = 0; x < storeLayout.numManaged(); x++) {
                let b = BBShopButton(storeLayout.getManaged(x));
                if(b && !b.isDisabled() && !b.hidden) {
                    return b;
                }
            }
        }

        if(!m.activeControl) {
            // Find a control to select
            for(int x = 0; x < upgradesLayout.numManaged(); x++) {
                let b = BBUpgradeButton(upgradesLayout.getManaged(x));
                if(b && !b.isDisabled() && !b.hidden) {
                    return b;
                }
            }
        }

        return BBShopButton(storeLayout.getManaged(0));
    }


    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        if(fromMouse && !fromController && (event == UIHandler.Event_Alternate_Activate || event == UIHandler.Event_Selected || event == UIHandler.Event_Activated)) {
            lastActionWasGamepad = false;
            if(upgradePopup) upgradePopup.mouseMode = true;
            if(storePopup) storePopup.mouseMode = true;
            burgerButtPromptView.hidden = true;
        } else if(fromController) {
            lastActionWasGamepad = true;
            if(upgradePopup) upgradePopup.mouseMode = false;
            if(storePopup) storePopup.mouseMode = false;
            burgerButtPromptView.hidden = false;
        }

        if(ctrl == burgerButt && event == UIHandler.Event_Activated) {
            // Animate bouncy button
            let anim = burgerButt.animateFrame(
                0.07,
                fromSize: (420, 420),
                toSize: (368, 368),
                ease: Ease_Out
            );
            anim.layoutEveryFrame = true;

            let anim2 = burgerButt.animateFrame(
                0.1,
                fromSize: (368, 368),
                toSize: (420, 420),
                ease: Ease_In
            );
            anim2.startTime += 0.07;
            anim2.endTime += 0.07;
            anim2.layoutEveryFrame = true;

            EventHandler.SendNetworkEvent("bgflip", 1);
            updateBurgers();

            let menu = GetMenu();
            let ppos = (fromMouse ? mainView.screenToRel((menu.mouseX, menu.mouseY) - (0, 30)) : burgerButt.frame.pos + (burgerButt.frame.size / 2.0)) + (frandom(-15, 15), frandom(-5, 5));
            let num = new("FlipNumber").init(ppos, burgerItem.bpc);
            mainView.add(num);

            S_StartSound("ui/burgerflipper/flip", CHAN_VOICE, CHANF_UI, snd_menuvolume * 1.0);

            return true;
        }

        if(ctrl is "BBShopButton" && event == UIHandler.Event_Activated) {
            let btn = BBShopButton(ctrl);
            double cost = burgerItem.getBuildingCost(btn.buildingID);
            if(cost <= burgerItem.burgers && burgerItem.prestige >= btn.buildingID - BBItem.Build_MirrorUniverse) {
                EventHandler.SendNetworkEvent("bgbuild", btn.buildingID, 1);
                needsUpdate = ticks;
                
                S_StartSound("ui/burgerflipper/buy", CHAN_VOICE, CHANF_UI, snd_menuvolume * 1.0);
            } else if(burgerItem.prestige <= btn.buildingID - BBItem.Build_MirrorUniverse) {
                S_StartSound("ui/fail", CHAN_VOICE, CHANF_UI, snd_menuvolume * 1.0);
            }

            return true;
        }

        if(ctrl is "BBUpgradeButton" && event == UIHandler.Event_Activated) {
            let btn = BBUpgradeButton(ctrl);
            double cost = btn.getUpgradeCost();
            if(cost <= burgerItem.burgers) {
                if(btn.buildingID > -1) {
                    EventHandler.SendNetworkEvent("bgupgrade", btn.buildingID);
                } else {
                    EventHandler.SendNetworkEvent("bgupgradei", btn.upgradeID);
                }
                needsUpdate = ticks;
                upgradePopup.hidden = true;

                S_StartSound("ui/burgerflipper/upgrade", CHAN_VOICE, CHANF_UI, snd_menuvolume * 1.0);
            }

            return true;
        }


        // Handle golden burger pressed
        if(ctrl is 'BBGoldButton' && event == UIHandler.Event_Activated) {
            let bb = BBGoldButton(ctrl);
            if(bb.leaving) {
                return true;
            }

            S_StartSound("ui/burgerflipper/gold", CHAN_VOICE, CHANF_UI, snd_menuvolume, pitch: frandom(0.9, 1.1));
            EventHandler.SendNetworkEvent("bggold", bb.index);

            let menu = GetMenu();
            let ppos = (fromMouse ? mainView.screenToRel((menu.mouseX, menu.mouseY) - (0, 30)) : bb.frame.pos + (bb.frame.size / 2.0)) + (frandom(-15, 15), frandom(-5, 5));
            let num = new("FlipNumber").init(ppos, bb.value);
            mainView.add(num);
            bb.animateClickOut();
            bb.raycastTarget = false;   // Don't click me

            return true;
        }


        if(ctrl is "BBShopButton" && (event == UIHandler.Event_Alternate_Activate || event == UIHandler.Event_Selected)) {
            lastShopButton = BBShopButton(ctrl);
            showStorePopup(BBShopButton(ctrl), fromMouse);
            if(!fromMouse && ticks > 5) storeScroll.scrollTo(ctrl, ticks != 0);
            if(shopViewOpen && !fromMouse) {
                hideShopView();
                Menu.MenuSound("ui/burgerflipper/tabclose");
            }
            return true;
        } else if(ctrl is "BBShopButton" && event == UIHandler.Event_Deselected) {
            storePopup.hidden = true;
            return true;
        }

        if(ctrl is "BBUpgradeButton" && (event == UIHandler.Event_Alternate_Activate || event == UIHandler.Event_Selected)) {
            lastUpgradeButton = BBUpgradeButton(ctrl);
            showUpgradePopUp(BBUpgradeButton(ctrl), fromMouse);
            if(!fromMouse && ticks > 5) upgradesScroll.scrollTo(ctrl, ticks != 0);
            if(shopViewOpen && !fromMouse) {
                hideShopView();
                Menu.MenuSound("ui/burgerflipper/tabclose");
            }
            return true;
        } else if(ctrl is "BBUpgradeButton" && event == UIHandler.Event_Deselected) {
            upgradePopup.hidden = true;
            return true;
        }


        if(ctrl == prestigeButton && event == UIHandler.Event_Selected) {
            if(!fromMouse && ticks > 5) upgradesScroll.scrollTo(ctrl, ticks != 0);
            if(shopViewOpen && !fromMouse) {
                hideShopView();
                Menu.MenuSound("ui/burgerflipper/tabclose");
            }
            return true;
        }


        // If we selected a tab button from the controller, hide the shop window
        static const string tabButtonNames[] = {"Store", "Progress", "Achievements", "Inventory"};
        Function<ui void(BBWindow)> tabButtonFuncs[] = { 
            showStoreView,
            showProgressView,
            showAchievementsView,
            showInventoryView
        };

        if(!fromMouse && (event == UIHandler.Event_Alternate_Activate || event == UIHandler.Event_Selected)) {
            for(int x = 0; x < tabButtonNames.size(); x++) {
                let s = tabButtonNames[x];
                if(ctrl.command ~== s) {
                    if(tabButtonFuncs[x]) tabButtonFuncs[x].call(self);
                    Menu.MenuSound("ui/burgerflipper/tab");
                    return false;
                }
            }
        }

        if(event == UIHandler.Event_Activated) {
            if(ctrl.command == "Store") {
                if(shopViewOpen && storeView.parent) {
                    hideShopView();
                    Menu.MenuSound("ui/burgerflipper/tabclose");
                } else {
                    showStoreView();
                    if(fromController) {
                        let con = storeView.getFirstControl();
                        if(con) getMenu().navigateTo(con, controllerSelection: fromController);
                    }
                    Menu.MenuSound("ui/burgerflipper/tab");
                }
            } else if(ctrl.command == "Progress") {
                if(shopViewOpen && progressView.parent) {
                    hideShopView();
                    Menu.MenuSound("ui/burgerflipper/tabclose");
                } else {
                    showProgressView();
                    if(fromController) {
                        let con = progressView.getFirstControl();
                        if(con) getMenu().navigateTo(con, controllerSelection: fromController);
                    }
                    Menu.MenuSound("ui/burgerflipper/tab");
                }
            } else if(ctrl.command == "Achievements") {
                if(shopViewOpen && achievementsView.parent) {
                    hideShopView();
                    Menu.MenuSound("ui/burgerflipper/tabclose");
                } else { 
                    showAchievementsView();
                    if(fromController) {
                        let con = achievementsView.getFirstControl();
                        if(con) getMenu().navigateTo(con, controllerSelection: fromController);
                    }
                    Menu.MenuSound("ui/burgerflipper/tab");
                }
            } else if(ctrl.command == "Inventory") {
                if(shopViewOpen && inventoryView.parent) {
                    hideShopView();
                    Menu.MenuSound("ui/burgerflipper/tabclose");
                } else {
                    showInventoryView();
                    if(fromController) {
                        let con = inventoryView.getFirstControl();
                        if(con) getMenu().navigateTo(con, controllerSelection: fromController);
                    }
                    Menu.MenuSound("ui/burgerflipper/tab");
                }
            } else if(ctrl.command == "Prestige") {
                let m = new("PromptMenu").initNew(getMenu(), "$BB_PRESTIGE_TITLE", "$BB_PRESTIGE_DESCRIPTION", "$BB_PRESTIGE_YES", "$BB_PRESTIGE_NO");
                m.onClosed = prestigePromptClosed;
                m.receiver = self;
                m.defaultSelection = 1;
                m.ActivateMenu();
            }
        }

        return Super.handleSubControl(ctrl, event, fromMouse, fromController);
    }


    Array<BBGoldButton> goldBurgerButtons;
    void updateGoldenBurgers() {
        foreach(b : burgerItem.goldBurgers) {
            bool found = false;

            // Find the associated button
            for(int x = goldBurgerButtons.size() - 1; x >= 0; x--) {
                let bb = goldBurgerButtons[x];
                if(bb.index == b.index) {
                    if(b.endTime <= level.totalTIme && bb.leaving == 0) {
                        getAnimator().clear(bb);
                        bb.removeFromSuperview();
                        goldBurgerButtons.delete(x);
                        found = true;
                        break;
                    }

                    found = true;
                    break;
                }
            }

            if(!found && b.endTime > level.totalTime + 5) {
                // Create the button
                let bb = new("BBGoldButton").init(b.index, b.value, b.spawnTime, b.endTime, b.scaler);
                leftView.add(bb);
                bb.animateIn();

                goldBurgerButtons.push(bb);
            }
        }

        for(int x = goldBurgerButtons.size() - 1; x >= 0; x--) {
            if(goldBurgerButtons[x].leaving) {
                goldBurgerButtons.delete(x);
            } else if(!burgerItem.goldBurgers.checkKey(goldBurgerButtons[x].index)) {
                goldBurgerButtons[x].animateClickOut();
                goldBurgerButtons.delete(x);
            }
        }
    }


    void updateBurgers() {
        burgerCounter.setText(String.Format("%s Burgers Flipped", formatTextNumber(burgerItem.burgers, true, false)));
        
        if(burgerItem.prestige > 0) {
            bpsCounter.setText(String.Format("per second: %s + (%s)", formatTextNumber(burgerItem.bpscRaw), formatTextNumber(burgerItem.bpsc - burgerItem.bpscRaw)));
        } else {
            bpsCounter.setText(String.Format("per second: %s", formatTextNumber(burgerItem.bpsc)));
        }
        
        prestigeLabel.setText(String.Format("Prestige: %d", burgerItem.prestige));
        prestigeLabel.hidden = burgerItem.prestige < 1;

        storeScroll.forwardSelection = lastShopButton ? lastShopButton : BBShopButton(storeLayout.getManaged(0));

        bool needsUpdate = false;
        for(int x = 0; x < storeLayout.numManaged(); x++) {
            let b = BBShopButton(storeLayout.getManaged(x));
            if(b) {
                if(b.update()) needsUpdate = true;
            }
        }

        for(int x = 0; x < upgradesLayout.numManaged(); x++) {
            let b = BBUpgradeButton(upgradesLayout.getManaged(x));
            if(b) {
                b.update();
            }
        }

        updateUpgrades();

        if(needsUpdate || ticks == 0) {
            storeScroll.layout();
            storeScroll.updateScrollbar();
        }

        sauceGraphic.force = (-0.45 * upgrades - 0.05, 0);

        if(burgerItem.bps >= 100) {
            if(burgerScroller.hidden) {
                burgerScroller.hidden = false;
                burgerScroller.alpha = 0;
                burgerScroller.animateFrame(
                    2.25,
                    fromAlpha: 0,
                    toAlpha: 1,
                    ease: Ease_In
                );
            }

            burgerScroller.force = (0, -clamp(burgerItem.bps / 1000000.0, 0.5, 1.5));
            burgerScroller2.force = burgerScroller.force * 0.65;

            if(burgerItem.bps >= 1000000 && burgerScroller2.hidden) {
                burgerScroller2.hidden = false;
                burgerScroller2.alpha = 0;
                burgerScroller2.animateFrame(
                    2.25,
                    fromAlpha: 0,
                    toAlpha: 1,
                    ease: Ease_In
                );
            }
        } else {
            if(!burgerScroller.hidden) {
                burgerScroller.hidden = true;
            }

            if(!burgerScroller2.hidden) {
                burgerScroller2.hidden = true;
            }
        }
    }

    void updateUpgrades() {
        upgrades = clamp(double(burgerItem.countUpgrades()) / 50.0, 0.0, 1.0);
    }

    static void convertPromptClosed(Object receiver, int result) {
        let self = BBWindow(receiver);
        if(result == 0) {
            self.needsUpdate = self.ticks;
            self.flash(0xFFFFFFFF, 1.0);
            EventHandler.SendNetworkEvent("bbconvert");
        }
    }


    static void wipePromptClosed(Object receiver, int result) {
        let self = BBWindow(receiver);
        if(result == 0) {
            if(self.settingsPop) {
                self.settingsPop.removeFromSuperview();
                self.settingsPop = null;
            }
            self.needsUpdate = self.ticks;
            self.flash(0xFFFFFFFF, 2.0);
            EventHandler.SendNetworkEvent("bbwipe");
        }
    }

    static void uninstallPromptClosed(Object receiver, int result) {
        let self = BBWindow(receiver);
        if(result == 0) {
            if(self.settingsPop) {
                self.settingsPop.removeFromSuperview();
                self.settingsPop = null;
            }

            EventHandler.SendNetworkEvent("bbuninstall");
            PDAMenu3 m = PDAMenu3(self.getMenu());
            if(m) {
                m.removeBurgerFlipper();
            }
            self.close();
        }
    }

    static void prestigePromptClosed(Object receiver, int result) {
        let self = BBWindow(receiver);
        if(result == 0) {
            self.needsUpdate = self.ticks;
            self.flash(0xFFFFFFFF, 1.0);
            EventHandler.SendNetworkEvent("bbprestige");
        }
    }

    static bool cloudButtonPressed(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = BBWindow(self);
        self.promptGlobalSave();
        return true;
    }


    UIControl lastControlBeforeSettings;
    static bool settingsButtonPressed(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = BBWindow(self);
        
        self.lastControlBeforeSettings = self.getMenu().activeControl;

        // Create settings menu
        self.settingsPop = new("BBSettingsPopUp").init();
        self.settingsPop.window = self;
        self.mainView.add(self.settingsPop);

        if(gamepad) self.getMenu().navigateTo(self.settingsPop.doneButton);

        return true;
    }

    void promptGlobalSave() {
        String desc = StringTable.Localize("$BB_CONVERT_DESCRIPTION");
            
        // Add more info if we are starting from scratch
        if(Globals.GetInt("BBHasSave") < 1) {
            desc = desc .. StringTable.Localize("$BB_CONVERT_DESCRIPTION2");
        }

        let m = new("PromptMenu").initNew(getMenu(), "$BB_CONVERT_TITLE", desc, "$BB_CONVERT_YES", "$BB_CONVERT_NO");
        m.onClosed = convertPromptClosed;
        m.receiver = self;
        m.destructiveIndex = 0;
        m.defaultSelection = 1;
        m.ActivateMenu();
    }


    void flash(Color clr, double time, bool sound = true) {
        let v = new("UIView").init((0,0), frame.size);
        v.pinToParent();
        v.backgroundColor = clr;
        v.raycastTarget = false;
        mainView.add(v);

        let anim = v.animateFrame(
            time,
            toAlpha: 0,
            ease: Ease_Out
        );
        anim.selfDestruct = true;

        if(sound) Menu.MenuSound("ui/burgerflipper/flash");
    }

    override void tick() {
        if(!burgerItem) {
            Super.tick();
            close();
            return;
        }

        if(ticks == 1) {
            getMenu().registerViewInterfaceCallback("bbach", self, achievementReceived);
            getMenu().registerViewInterfaceCallback("bbachupdate", self, achievementsChanged);
            getMenu().registerViewInterfaceCallback("bbrewardchanged", self, rewardsChanged);
        }

        // If we have a burger item with no progress, automatically convert that to a global save and reload
        if(ticks == 2 && !burgerItem.isGlobalGame && burgerItem.isUnused()) {
            needsUpdate = ticks;
            EventHandler.SendNetworkEvent("bgstartnew");
        } else if(ticks == 35 && !burgerItem.isUnused() && !burgerItem.isGlobalGame && !burgerItem.hasPromptedUser) {
            // Prompt the user to convert to a global save
            Menu.MenuSound("ui/message");
            
            promptGlobalSave();

            burgerItem.hasPromptedUser = true;
        }

        flippers.numFlippers = burgerItem.buildings[BBItem.Build_Flipper].count;

        if(ticks == 0 || ticks - needsUpdate == 1) {
            cloudButton.hidden = burgerItem.isGlobalGame;
            settingsButton.hidden = !burgerItem.isGlobalGame;
            calculateUpgrades();
            if(!storePopup.hidden) {
                storePopup.configure();
                storePopup.layout();

                // Find button and line it up
                for(int x = 0; x < storeLayout.numManaged(); x++) {
                    let btn = BBShopButton(storeLayout.getManaged(x));
                    if(btn && btn.buildingID == storePopup.buildingID) {
                        storePopup.frame.pos.x = storeScroll.frame.pos.x - storePopup.frame.size.x - 5;
                        //storePopup.frame.pos.y = min(btn.frame.pos.y, mainView.frame.size.y - storePopup.frame.size.y - 5);
                        break;
                    }
                }
            }
            storeScroll.updateScrollbar();
            upgradesScroll.updateScrollbar();
        }

        updateBurgers();
        updateGoldenBurgers();

        // Make sure we have the right skin for the button
        if(burgerButt.skin != burgerItem.skin) {
            burgerButt.changeSkin(burgerItem.skin);
        }

        
        let v = SelacoGamepadMenu(getMenu()).getGamepadRawLook();
        if(abs(v.y) > 0.1) {
            UIVerticalScroll scrollView = storeScroll;

            if(shopViewOpen) {
                // Find scrollbar in shopview
                if(storeView.parent) {
                    scrollView = storeView.scroll;
                } else if(inventoryView.parent) {
                    scrollView = inventoryView.scroll;
                } else if(progressView.parent) {
                    scrollView = progressView.scroll;
                } else if(achievementsView.parent) {
                    scrollView = achievementsView.scroll;
                }
            }

            if(scrollView && !scrollView.scrollbar.disabled) scrollView.scrollByPixels(v.y * CommonUI.STANDARD_SCROLL_AMOUNT, true, false, false);
        }

        Super.tick();
        ticks++;
    }


    void calculateUpgrades() {
        Array<int> upgrades;

        int numUsedUpgrades = 0;
        int lastBuildingID = -1, lastUpgradeID = -1;

        // Determine if one of the upgrade buttons is selected
        let ac = getMenu().activeControl;
        if(ac is 'BBUpgradeButton') {
            lastBuildingID = BBUpgradeButton(ac).buildingID;
            lastUpgradeID = BBUpgradeButton(ac).upgradeID;
        }
        UIControl moveToControl = null;

        // Determine which upgrades should be available for purchase
        for(int x = 0; x < BBItem.Build_Count; x++) {
            if(burgerItem.buildings[x].count > 0 && burgerItem.buildings[x].count >= burgerItem.buildings[x].numUpgrades * 10) 
                upgrades.push(x);
        }

        numUsedUpgrades = upgrades.size();

        // Set up upgrade buttons to match the list
        for(int x = 0; x < upgrades.size(); x++) {
            let btn = upgradesLayout.numManaged() > x ? BBUpgradeButton(upgradesLayout.getManaged(x)) : null;
            if(!btn) {
                btn = new("BBUpgradeButton").init(upgrades[x], -1, burgerItem);
                btn.navLeft = inventoryButton;
                upgradesLayout.addManaged(btn);
            } else {
                btn.buildingID = upgrades[x];
                btn.upgradeID = -1;
                btn.update();

                if(btn.mouseInside) {
                    showUpgradePopUp(btn, true);
                }
            }
        }

        // Add unlocked upgrade buttons
        for(int x = 0; x < burgerItem.availableUpgrades.size(); x++) {
            if(burgerItem.availableUpgrades[x].shouldUnlock()) {
                let btn = upgradesLayout.numManaged() > numUsedUpgrades ? BBUpgradeButton(upgradesLayout.getManaged(numUsedUpgrades)) : null;
                if(!btn) {
                    btn = new("BBUpgradeButton").init(-1, x, burgerItem);
                    btn.navLeft = inventoryButton;
                    upgradesLayout.addManaged(btn);
                } else {
                    btn.buildingID = -1;
                    btn.upgradeID = x;
                    btn.update();
                }
                numUsedUpgrades++;
            }
        }

        upgradesLayout.removeManaged(prestigeButton);

        // Destroy unused
        for(int x = upgradesLayout.numManaged() - 1; x >= numUsedUpgrades; x--) {
            let ctrl = upgradesLayout.getManaged(x);
            ctrl.removeFromSuperview();
            ctrl.destroy();

            if(BBUpgradeButton(ctrl) == lastUpgradeButton) {
                lastUpgradeButton = null;
            }

            // If we are deleting the last selected button...
            if(BBUpgradeButton(ctrl) == ac) {
                if(numUsedUpgrades > 0) {
                    // Navigate to the last item in the list
                    moveToControl = UIControl(upgradesLayout.getManaged(numUsedUpgrades - 1));
                } else {
                    // Navigate to buildings
                    moveToControl = storeScroll;
                }
            }
        }

        // If we have the latest prestige building, add the prestige button
        if(burgerItem.buildings[min(BBItem.Build_Count - 1, BBItem.Build_MirrorUniverse + burgerItem.prestige)].count > 0) {
            upgradesLayout.addManaged(prestigeButton);
        }

        // Re-link upgrade navigation
        UIControl lastCtrl = null;
        for(int x = 0; x < upgradesLayout.numManaged(); x++) {
            let ctrl = BBUpgradeButton(upgradesLayout.getManaged(x));
            if(ctrl) {
                if(lastCtrl) lastCtrl.navDown = ctrl;
                ctrl.navUp = lastCtrl;
                ctrl.navDown = null;
                ctrl.navRight = storeScroll;
                lastCtrl = ctrl;

                if(ctrl.buildingID == lastBuildingID && ctrl.upgradeID == lastUpgradeID && lastBuildingID >= 0 && lastUpgradeID >= 0) {
                    moveToControl = ctrl;
                    // This could potentially select things when no selection was desired
                }
            }
        }

        if(prestigeButton.parent) {
            prestigeButton.navUp = lastCtrl;
            if(lastCtrl) lastCtrl.navDown = prestigeButton;
            prestigeButton.navRight = storeScroll;
            prestigeButton.navLeft = inventoryButton;
        }

        upgradesScroll.navLeft = inventoryButton;
        upgradesScroll.navRight = storeScroll;

        // Forward selection setup
        if(numUsedUpgrades > 0 || prestigeButton.parent) {
            upgradesScroll.forwardSelection = lastUpgradeButton ? UIControl(lastUpgradeButton) : UIControl(upgradesLayout.getManaged(0));
            upgradesScroll.setDisabled(false);
        } else {
            upgradesScroll.forwardSelection = null;
            upgradesScroll.setDisabled(true);
        }

        if(moveToControl && lastActionWasGamepad) {
            getMenu().navigateTo(moveToControl);
            Console.Printf("Movetocontrol");
            if(moveToControl is 'BBUpgradeButton') {
                showUpgradePopUp(BBUpgradeButton(moveToControl), false);
            }
        } else if(getMenu().activeControl is 'BBUpgradeButton') {
            showUpgradePopUp(BBUpgradeButton(getMenu().activeControl), !lastActionWasGamepad);
        }

        upgradesScroll.layout();
    }


    void showStorePopup(BBShopButton btn, bool mouse) {
        int building = btn.buildingID;
        Vector2 btnPos = mainView.screenToRel(btn.relToScreen((0,0)));

        storePopup.hidden = false;
        storePopup.buildingID = building;
        storePopup.mouseMode = mouse;
        storePopup.configure();
        storePopup.layout();
        storePopup.frame.pos.x = storeScroll.frame.pos.x - storePopup.frame.size.x - 5;

        if(!mouse) {
            storePopup.frame.pos.y = mainView.frame.size.y - storePopup.frame.size.y - 5;
        }
        //storePopup.frame.pos.y = min(btnPos.y, mainView.frame.size.y - storePopup.frame.size.y - 5);
    }


    void showUpgradePopUp(BBUpgradeButton btn, bool mouse) {
        Vector2 btnPos = mainView.screenToRel(btn.relToScreen((0,0)));

        upgradePopup.hidden = false;
        upgradePopup.buildingID = btn.buildingID;
        upgradePopup.upgradeID = btn.upgradeID;
        upgradePopup.mouseMode = mouse;
        upgradePopup.update();
        upgradePopup.layout();
        upgradePopup.frame.pos.x = upgradesScroll.frame.pos.x - upgradePopup.frame.size.x - 5;

        if(!mouse) {
            upgradePopup.frame.pos.y = mainView.frame.size.y - upgradePopup.frame.size.y - 5;
        }
    }


    void popUpAchievement(int type, int subject, int value) {
        BBAchievementView achView = new("BBAchievementView").init(type, subject, value, false, true);
        achView.clearPins();
        
        if(lastActionWasGamepad) {
            achView.pin(UIPin.Pin_Left, offset: 15);
            achView.pin(UIPin.Pin_Bottom, value: 1.0, offset: -(150 + 90), isFactor: true);
        } else {
            achView.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
            achView.pin(UIPin.Pin_VCenter, UIPin.Pin_Bottom, value: 1.0, offset: -(150 / 2 + 15), isFactor: true);
        }
        
        achView.pinWidth(360);
        achView.pinHeight(150);
        leftView.add(achView);


        let anim = new("UIViewPinAnimation").initComponents(
            achView, 
            0.21,
            fromScale: (1.4, 1.4),
            toScale: (1.0, 1.0),
            ease: Ease_Out
        );
        getAnimator().add(anim);

        achView.animateFrame(
            0.21,
            fromAlpha: 0,
            toAlpha: 1,
            ease: Ease_In
        );

        let anim2 = new("UIViewPinAnimation").initComponents(
            achView, 
            0.5,
            fromScale: (1.0, 1.0),
            toScale: (0.87, 0.87),
            fromAlpha: 1,
            toAlpha: 0,
            ease: Ease_In
        );
        anim2.startTime += 5.0;
        anim2.endTime += 5.0;
        anim2.selfDestruct = true;
        getAnimator().add(anim2);


        Menu.MenuSound("ui/burgerflipper/achievement");
    }


    double lastRenderTime;
    override void draw() {
        if(hidden) { return; }
        let time = getMenu().getRenderTime();

        if(lastRenderTime != 0) {
            let te = time - lastRenderTime;
            let pin = sauceGraphic.firstPin(UIPin.Pin_Top);
            pin.value += ((1.0 - (upgrades * 0.3) - 0.1) - pin.value) * te;
            sauceGraphic.layout();
        }

        lastRenderTime = time;
        

        Super.draw();
    }
}