class BBShopView : UIView {
    UIView contentView;
    UIImage coinLogo, gemLogo;
    UILabel coinLabel, gemLabel;
    UIImage coinBG, gemBg;
    UIButton closeButton;
    BBWindow window;

    BBShopView init() {
        Super.init((0,0), (0,0));

        coinBG = new("UIImage").init((0,0), (125, 35), "", NineSlice.Create("BBSHOPBG", (18,16), (35,31)));
        gemBG = new("UIImage").init((0,0), (125, 35), "", NineSlice.Create("BBSHOPBG", (18,16), (35,31)));
        coinBG.clipsSubviews = gemBG.clipsSubviews = false;
        
        coinBG.pin(UIPin.Pin_Right, UIPin.Pin_HCenter, value: 1, offset: -20, isFactor: true);
        gemBG.pin(UIPin.Pin_Left, UIPin.Pin_HCenter, value: 1, offset: 20, isFactor: true);
        coinBG.pin(UIPin.Pin_Top, offset: 20);
        gemBG.pin(UIPin.Pin_Top, offset: 20);

        coinLogo = new("UIImage").init((0,0), (45, 45), "BBCOIN", imgStyle: UIImage.Image_Aspect_Fit);
        gemLogo = new("UIImage").init((0,0), (45, 45), "BBGEM", imgStyle: UIImage.Image_Aspect_Fit);
        coinLogo.pin(UIPin.Pin_Right, offset: -5);
        gemLogo.pin(UIPin.Pin_Right, offset: -5);
        coinLogo.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        gemLogo.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);

        // Add labels
        coinLabel = new("UILabel").init((0,0), (0, 0), String.Format("%d", players[consolePlayer].mo.countInv("creditsCount")), "SEL21FONT", textColor: Font.CR_UNTRANSLATED, textAlign: UIView.Align_Centered);
        gemLabel = new("UILabel").init((0,0), (0, 0), String.Format("%d", BBItem.Find().gems), "SEL21FONT", textColor: Font.CR_UNTRANSLATED, textAlign: UIView.Align_Centered);
        coinLabel.pinToParent(10,0,-50,-2);
        gemLabel.pinToParent(10,0,-50,-2);
        coinBG.add(coinLabel);
        gemBG.add(gemLabel);

        coinLabel.multiline = gemLabel.multiline = false;

        add(coinBG);
        add(gemBG);

        coinBG.add(coinLogo);
        gemBG.add(gemLogo);


        closeButton = new("UIButton").init((0,0), (24, 24), "", "PDA16FONT",
            UIButtonState.Create("BBCLO1"),
            UIButtonState.Create("BBCLO2"),
            UIButtonState.Create("BBCLO3"),
            onClick: closePressed,
            receiver: self
        );
        closeButton.pin(UIPin.Pin_Right, offset: -10);
        closeButton.pin(UIPin.Pin_Top, offset: 10);
        add(closeButton);


        contentView = new("UIView").init((0,0), (0,0));
        contentView.pinToParent(10, 75, -10, 0);
        add(contentView);

        let sideView = new("UIView").init((0,0), (2, 0));
        sideView.backgroundColor = 0xFF000000;
        sideView.pin(UIPin.Pin_Right);
        sideView.pin(UIPin.Pin_Top);
        sideView.pin(UIPin.Pin_Bottom);
        add(sideView);

        return self;
    }


    static bool closePressed(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = BBShopView(self);

        if(self.window) {
            self.window.hideShopView();
            Menu.MenuSound("ui/burgerflipper/tabclose");
        }

        return true;
    }

    void updateCounts() {
        coinLabel.setText(String.Format("%d", players[consolePlayer].mo.countInv("creditsCount")));
        gemLabel.setText(String.Format("%d", BBItem.Find().gems));
    }

    override void tick() {
        Super.tick();

        if(parentMenu && parentMenu.ticks % 8 == 0) {
            updateCounts();
        }
    }
}


class BBStoreView : UIView {
    UIVerticalScroll scroll;
    UIVerticalLayout mainLayout;
    BBWindow window;
    BBStoreButton premiumButton;

    static const int costs[] = {0, 999, 1599, 2299};

    BBStoreView init() {
        Super.init((0,0), (0,0));
        pinToParent();

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
        scroll.mLayout.itemSpacing = 10;
        //scroll.scrollbar.firstPin(UIPin.Pin_Right).offset = -8;
        add(scroll);

        mainLayout = UIVerticalLayout(scroll.mLayout);

        return self;
    }

    
    UIControl getFirstControl() {
        return premiumButton;
    }


    void reload() {
        mainLayout.clearManaged();

        mainLayout.addSpacer(40);

        // Add premium button
        premiumButton = new("BBStoreButton").init("", "BBPREM", "\c[SEL]1250");
        premiumButton.pin(UIPin.Pin_Left);
        premiumButton.pin(UIPin.Pin_Right);
        premiumButton.pinHeight(175);

        // Check if premium is already owned and disable button
        if(BBPremiumItem.HasPremium()) {
            premiumButton.setDisabled(true);
            premiumButton.iconView.desaturation = 1.0;
            premiumButton.costImage.desaturation = 1.0;
        } else if(players[consolePlayer].mo.countInv("creditsCount") < 1250) {
            // Not enough money, visually disable but still allow click
            premiumButton.setBuyable(false);
        }
        premiumButton.onClick = premiumPressed;
        premiumButton.receiver = self;
        premiumButton.clipsSubviews = false;
        premiumButton.iconView.firstPin(UIPin.Pin_Top).offset = -50;
        mainLayout.addManaged(premiumButton);


        // Add gem purchase buttons
        let horz = createRow(170);
        let btn1 = new("BBStoreButton").init("", "BBBUY3", "\c[SEL]2299", true);
        btn1.setBuyable(players[consolePlayer].mo.countInv("creditsCount") >= 2299);
        btn1.pinHeight(1.0, isFactor: true);
        btn1.pinWidth(1.0, isFactor: true);
        btn1.onClick = buyGemPressed;
        btn1.receiver = self;
        btn1.controlID = 3;
        horz.addManaged(btn1);
        mainLayout.addManaged(horz);

        horz = createRow();
        let btn2 = new("BBStoreButton").init("", "BBBUY2", "\c[SEL]1599", true);
        let btn3 = new("BBStoreButton").init("", "BBBUY1", "\c[SEL]999", true);
        btn2.setBuyable(players[consolePlayer].mo.countInv("creditsCount") >= 1599);
        btn3.setBuyable(players[consolePlayer].mo.countInv("creditsCount") >= 999);
        btn2.controlID = 2;
        btn3.controlID = 1;
        btn2.onClick = buyGemPressed;
        btn3.onClick = buyGemPressed;
        btn3.receiver = self;
        btn2.receiver = self;
        btn3.pinHeight(1.0, isFactor: true);
        btn3.pinWidth(1.0, isFactor: true);
        btn2.pinHeight(1.0, isFactor: true);
        btn2.pinWidth(1.0, isFactor: true);
        horz.addManaged(btn2);
        horz.addManaged(btn3);
        mainLayout.addManaged(horz);

        btn2.navRight = btn3;
        btn3.navLeft = btn2;
        btn2.navUp = btn3.navUp = btn1;
        premiumButton.navDown = btn1;
        btn1.navUp = premiumButton;
        premiumButton.navRight = btn3.navRight = btn1.navRight = window ? window.storeButton : null;
        btn1.navDown = btn2;        

        // Add Castle Burger purchase
        horz = createRow(200);
        let btn4 = new("BBStoreButton").init("", "BBBUY4", "\c[GWYNPINK]20", false);
        if(BBItem.Find().skinUnlocks[BB_SKIN_CASTLE] == 1) {
            btn4.setDisabled(true);
            btn4.iconView.desaturation = 1.0;
            btn4.costImage.desaturation = 1.0;
        } else {
            btn4.setBuyable(BBItem.Find().gems >= 20);
        }
        btn4.pinHeight(1.0, isFactor: true);
        btn4.pinWidth(1.0, isFactor: true);
        btn4.onClick = buySkinPressed;
        btn4.receiver = self;
        btn4.controlID = 4;
        horz.addManaged(btn4);
        mainLayout.addManaged(horz);

        btn4.navRight = premiumButton.navRight;
        btn4.navUp = btn2;
        btn2.navDown = btn3.navDown = btn4;
    }


    UIHorizontalLayout createRow(int height = 130) {
        let horz = new("UIHorizontalLayout").init((0,0), (0,0));
        horz.pin(UIPin.Pin_Left);
        horz.pin(UIPin.Pin_Right, offset: 0);
        horz.pinHeight(height);
        horz.itemSpacing = 10;
        horz.layoutMode = UIViewManager.Content_Stretch;

        return horz;
    }

    void animateIn(double delay = 2.0) {
        
    }

    void animateOut(double delay = 0.0) {

    }

    static bool premiumPressed(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = BBStoreView(self);

        // Make sure we have enough moneys
        if(players[consolePlayer].mo.countInv("creditsCount") < 1250) {
            Menu.MenuSound("ui/fail");
            return true;
        }

        Menu.MenuSound("ui/burgerflipper/adfree");

        // Disable button 
        let btn = BBStoreButton(btn);
        btn.setDisabled(true);
        btn.iconView.desaturation = 1.0;
        btn.costImage.desaturation = 1.0;

        // TODO: Add purchase effect
        if(self.window) {
            self.window.flash(0x66FFFFFF, 1.0);
            self.window.hideAds();
        }

        EventHandler.SendNetworkEvent("bbpremium", 1);

        BBShopView(self.window.shopView).updateCounts();

        return true;
    }


    static bool buySkinPressed(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = BBStoreView(self);

        // Make sure we have enough moneys
        if(BBItem.Find().gems < 20) {
            Menu.MenuSound("ui/fail");
            return true;
        }

        Menu.MenuSound("ui/burgerflipper/adfree");

        // Disable button 
        let btn = BBStoreButton(btn);
        btn.setDisabled(true);
        btn.iconView.desaturation = 1.0;
        btn.costImage.desaturation = 1.0;

        // TODO: Add purchase effect
        if(self.window) {
            self.window.flash(0x66FFFFFF, 1.0);
        }

        EventHandler.SendNetworkEvent("bbskinbuy", btn.controlID);

        BBShopView(self.window.shopView).updateCounts();

        return true;
    }


    static bool buyGemPressed(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = BBStoreView(self);
        let btn = BBStoreButton(btn);

        let cost = BBStoreView.costs[btn.controlID];

        // Make sure we have enough moneys
        if(players[consolePlayer].mo.countInv("creditsCount") < cost) {
            Menu.MenuSound("ui/fail");
            return true;
        }

        Menu.MenuSound("ui/burgerflipper/upgrade");

        // Send network buy event
        /*EventHandler.SendNetworkEvent("bbgem", btn.controlID);
        BBShopView(self.window.shopView).updateCounts();*/

        // Too easy to actually cheat this, since you could reload a save
        let m = new("PromptMenu").initNew(UIMenu(Menu.GetCurrentMenu()), "$BB_NOGEMS_TITLE", "$BB_NOGEMS_DESCRIPTION", "$BB_NOGEMS_OK");
        m.defaultSelection = 0;
        m.ActivateMenu();

        return true;
    }
}


class BBStoreButton : UIButton {
    UIImage iconView, costIcon, buyButtonView;
    UIImage costImage, resourceImage;
    UILabel costLabel;

    UIButtonState normState, hovState, pressState, disabledState;

    BBStoreButton init(string text = "", string icon = "", string buyText = "", bool isCredits = true) {
        normState     = UIButtonState.CreateSlices("BBBUTT05", (16,16), (20, 84), scaleCenter: true);
        hovState      = UIButtonState.CreateSlices("BBBUTT06", (16,16), (20, 84), scaleCenter: true);
        pressState    = UIButtonState.CreateSlices("BBBUTT07", (16,16), (20, 84), scaleCenter: true);
        disabledState = UIButtonState.CreateSlices("BBBUTT05", (16,16), (20, 84), scaleCenter: true);
        
        normState.desaturation = 0;
        hovState.desaturation = 0;
        pressState.desaturation = 0;
        disabledState.desaturation = 1.0;

        Super.init((0,0), (0,100), text, "PDA16FONT", normState, hovState, pressState, disabledState);

        if(icon != "") {
            iconView = new("UIImage").init((0,0), (0, 0), icon, imgStyle: UIImage.Image_Aspect_Fit);
            iconView.pinToParent();
            add(iconView);
        }

        if(buyText != "") {
            costImage = new("UIImage").init((0,0), (112, 37), "BBBUYBAK");
            costImage.pin(UIPin.Pin_HCenter, value:1.0, isFactor: true);
            costImage.pin(UIPin.Pin_Bottom, offset: -15);
            costImage.clipsSubviews = false;
            add(costImage);

            resourceImage = new("UIImage").init((0,0), (45, 45), isCredits ? "BBCOIN" : "BBGEM", imgStyle: UIImage.Image_Aspect_Fit);
            resourceImage.pin(UIPin.Pin_Left, offset: 5);
            resourceImage.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
            costImage.add(resourceImage);

            costLabel = new("UILabel").init((0,2), (100, 60), "", "PDA16FONT", Font.CR_UNTRANSLATED, UIView.Align_Middle);
            costLabel.multiline = false;
            costLabel.pixelAlign = false;
            costLabel.text = buyText;
            costLabel.pinToParent(50);
            costLabel.shadowColor = 0x80006600;
            costLabel.shadowOffset = (1,1);
            costLabel.drawShadow = true;
            costImage.add(costLabel);
            
        }
        

        return self;
    }


    void setBuyable(bool buyable) {
        if(!buyable) {
            costLabel.textColor = 0xFFFF0000;
            costImage.desaturation = 1.0;
        } else {
            costLabel.textColor = Font.CR_UNTRANSLATED;
            costImage.desaturation = 0;
        }
    }
}