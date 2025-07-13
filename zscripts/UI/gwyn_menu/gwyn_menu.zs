#include "ZScripts/UI/gwyn_menu/gwyn_handler.zs"


class GwynMenu : SelacoGamepadMenuInGame {
    UILabel cashLabel, infoLabel;
    UIImage cashImage;
    UIView cashView;

    Array<GwynCard> cards;
    int backKey1, backKey2;

    int closingTicks;           // Delay ticks for close animation
    int credits, shownCredits;
    int saveCountdown;          // Delay to run save

    bool hasSaved, hasPurchased, hasConfidence;
    double dimStart;

    override void init(Menu parent) {
        Super.init(parent);
        BlurAmount = 1.0;
        //AnimatedTransition = true;
        Animated = true;
        menuActive = Menu.OnNoPause;    // This prevents the game from pausing when we open the menu
        DontDim = true;

        saveCountdown = -1;

        [backKey1, backKey2] = Bindings.GetKeysForCommand("+back");
        backKey1 = UIHelper.GetUIKey(backKey1);
        backKey2 = UIHelper.GetUIKey(backKey2);

        let hndlr = GWYNHandler(StaticEventHandler.Find("GWYNHandler"));
        let creditsInv = players[consolePlayer].mo.FindInventory("CreditsCount");
        credits = creditsInv ? creditsInv.Amount : 0;
        shownCredits = credits;

        bool isHardcore = false;

        let hcm = players[consolePlayer].mo.FindInventory("HardcoreMode");
        if(hcm && hcm.Amount > 0) isHardcore =  true;

        // Create Cash View
        cashView = new("UIView").init((0,0), (120, 50));
        cashView.clipsSubviews = false;
        cashView.pin(UIPin.Pin_HCenter, UIPin.Pin_HCenter, value: 1.0, offset: 0, isFactor: true);
        cashView.pin(UIPin.Pin_VCenter, UIPin.Pin_VCenter, value: 1.0, offset: 405, isFactor: true);
        mainView.add(cashView);

        cashLabel = new("UILabel").init((48 + 15, 0), (100, 45), String.Format("%d", credits), "K32FONT", 0xFFFDD14D, UIView.Align_Left | UIView.Align_Middle, fontScale: (0.75, 0.75));
        cashLabel.multiline = false;
        cashLabel.pin(UIPin.Pin_VCenter, UIPin.Pin_VCenter, value: 1.0, offset: -3, isFactor: true);
        cashLabel.setShadow(0xFF241C00, (1,3)); //0xFF241C00;
        cashView.add(cashLabel);

        cashImage = new("UIImage").init((0,0), (48,48), "GWNCASH");
        cashImage.pin(UIPin.Pin_VCenter, UIPin.Pin_VCenter, value: 1.0, offset: -10);
        cashView.add(cashImage);


        //infoLabel = new("UILabel").init((0,0), (800, 45), "", "K32FONT", textAlign: UIView.Align_Centered, fontScale: (1, 1));
        infoLabel = new("UILabel").init((0,0), (800, 45), "", "K32OFONT", textAlign: UIView.Align_Centered, fontScale: (1, 1));
        
        infoLabel.multiline = false;
        infoLabel.pin(UIPin.Pin_HCenter, UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        infoLabel.pin(UIPin.Pin_Bottom, UIPin.Pin_VCenter, value: 1.0, offset: -320, isFactor: true);
        //infoLabel.pinWidth(UIView.Size_Min);
        infoLabel.alpha = 0;
        infoLabel.shadowColor = 0xFF00213F;
        infoLabel.shadowStencil = true;     // Draw shadow as a flat color
        //infoLabel.shadowOffset = (3, 5);
        infoLabel.shadowOffset = (3, 7);
        infoLabel.drawShadow = true;
        mainView.add(infoLabel);

        // Gather a list of the cards we will actually be using from the config
        Array<int> cardIndexes;
        for(int x = 0; x < 4; x++) {
            // Skip invalid IDs
            if(hndlr.slotItems[x] < 0) { continue; }

            // Skip savegame slot if this is not hardcore
            if(hndlr.slotItems[x] == GWYN_SHOP_SAVEGAME && !isHardcore) { continue; }

            cardIndexes.push(x);
        }

        // Create cards
        int cnt = cardIndexes.size();
        double spacing = isTightScreen ? 20 : 40;
        double totalWidth = (cnt * 365) + ((cnt - 1) * spacing);
        double half = totalWidth / 2.0;
        for(int x = 0; x < cardIndexes.size(); x++) {
            int item = hndlr.slotItems[cardIndexes[x]];

            let c = new("GwynCard").init(item, -half + (365 * x) + (spacing * x) + 182);
            c.controlID = cardIndexes[x];
            cards.push(c);
            mainView.add(c);

            c.updateStatus(hndlr.HasEnoughMoney(c.shopItem) && (item != GWYN_SHOP_CONFIDENCE || hndlr.CanBuyMore(c.shopItem)));
        }

        // Configure selection chain
        for(int x = 0; x < cards.size(); x++) {
            cards[x].navLeft = x > 0 ? cards[x - 1] : cards[cards.size() - 1];
            cards[x].navRight = x < cards.size() - 1 ? cards[x + 1] : cards[0];
        }

        // Start animations
        for(int x = 0; x < cards.size(); x++) {
            let c = cards[x];
            let a = new("UIViewPinAnimation").initComponents( c, 0.25 + (x * 0.08),
                fromScale: (0.75, 0.75), toScale: (0.95, 0.95),
                fromAlpha: 0, toAlpha: 1,
                ease: Ease_Out
            );

            a.startTime += x * 0.08;
            
            a.addValues(UIPin.Pin_VCenter,
                startVal: 2.0,
                endVal: 1.0
            );
            a.prepare();

            animator.add(a);
        }

        let a = new("UIViewPinAnimation").initComponents(cashView, 0.25,
            fromScale: (0.7, 0.7), toScale: (1, 1),
            fromAlpha: 0, toAlpha: 1,
            ease: Ease_In
        );

        a.addValues(UIPin.Pin_VCenter,
            startVal: 1.05,
            endVal: 1.0
        );
        a.startTime += 0.15;
        a.endTime += 0.15;
        a.prepare();
        animator.add(a);

        // If we are using the keyboard or gamepad primarily, select the first card by default
        if(isMenuPrimarilyUsingKeyboard() || isPrimarilyUsingGamepad()) {
            navigateTo(cards[0]);
        }

        dimStart = getRenderTime();
    }


    override void calcScale(int screenWidth, int screenHeight, Vector2 baselineResolution) {
		bool isHardcore = false;
        let hcm = players[consolePlayer].mo.FindInventory("HardcoreMode");
        if(hcm && hcm.Amount > 0) isHardcore =  true;
        
        let size = (screenWidth, screenHeight);
		let uscale = ui_scaling && !ignoreUIScaling ? ui_scaling.getFloat() : 1.0;
		lastUIScale = uscale;
		if(uscale <= 0.001) uscale = 1.0;

        let newScale = uscale * CLAMP(size.y / baselineResolution.y, 0.5, 2.0);
		
		// If we are close enough to 1.0.. 
		if(abs(newScale - 1.0) < 0.08) {
			newScale = 1.0;
		} else if(abs(newScale - 2.0) < 0.08) {
			newScale = 2.0;
		}

        // Limit scale to fit
        double minWidth = isHardcore ? 1600 : 1400;
        if(isHardcore && screenWidth / newScale < minWidth) {
            newScale = screenWidth / minWidth;
        }

		mainView.frame.size = (screenWidth / newScale, screenHeight / newScale);
        mainView.scale = (newScale, newScale);

		// For UIDrawer
		screenSize = (screenWidth, screenHeight);
		virtualScreenSize = screenSize / newScale;
        calcTightScreen();
        calcUltrawide();
	}


    void updateCashLabel(int subCost = 0) {
        let creditsInv = players[consolePlayer].mo.FindInventory("CreditsCount");
        credits = (creditsInv ? creditsInv.Amount : 0) - subCost;
        //cashLabel.text = String.Format("%d", (credits ? credits.amount : 0) - subCost);
    }

    override bool menuEvent(int key, bool fromcontroller) {
        if(ticks <= 8) return true;     // Eat inputs before we are allowed, since it could create an infinite loop over the fully disabled cards

        switch (key) {
            case MKEY_Right:
                if(activeControl == null && lastActiveControl != null) {
                    navigateTo(lastActiveControl);
                    return logController(key, fromController);
                } else if(activeControl == null) {
                    navigateTo(cards[0]);
                    return logController(key, fromController);
                }
                break;
            case MKEY_Left:
                if(activeControl == null && lastActiveControl != null) {
                    navigateTo(lastActiveControl);
                    return logController(key, fromController);
                } else if(activeControl == null) {
                    navigateTo(cards[cards.size() - 1]);
                    return logController(key, fromController);
                }
                break;
            default:
                break;
        }

        return Super.MenuEvent(key, fromcontroller);
    }


    override bool onUIEvent(UIEvent ev) {
         if(ev.type == UIEvent.Type_KeyDown && (ev.KeyChar == backKey1 || ev.KeyChar == backKey2)) {
            if(ticks > 20) {
                if(closingTicks == 0) {
                    animateClose(false);
                }
            } else {
                close();
            }
            return true;
        }

        return Super.OnUIEvent(ev);
    }

    void createHardcoreSave() {
        // Brute force create a new save
        let manager = SavegameManager.GetManager();
        manager.ReadSaveStrings();
        int saveIndex = 0;
        let cv = CVar.FindCVar("g_saveindex");
        int num = cv.GetInt() + 1;
        cv.SetInt(num);
        manager.InsertNewSaveNode();
        manager.DoSave(saveIndex, String.Format("Save #%d (Hardcore)", num));
        manager.RemoveNewSaveNode();
        HUD.SaveCompleted();

        saveCountdown = -1;

        EventHandler.SendNetworkEvent("gwynReset"); // Required to notify that we are no longer at the machine
        close();                                    // Not required, but here for safety reasons in case the save fails to close the current menu
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated) {
            let c = GwynCard(ctrl);

            if(c) {
                int cost = GWYNHandler.itemCosts[c.shopItem];
                let player = players[consolePlayer].mo;
                let i = player.FindInventory("CreditsCount");
                let cash = i ? i.amount : 0;

                // Special case for save game, we only save once
                if(c.shopItem == GWYN_SHOP_SAVEGAME && hasSaved) {
                    c.updateStatus(false); 
                    MenuSound("ui/fail");
                    return;
                }

                // Most of the server side stuff has to be replicated client side so we don't show the player the wrong information
                let hndlr = GWYNHandler(StaticEventHandler.Find("GWYNHandler"));

                if(hndlr) {
                    if(hndlr.HasEnoughMoney(c.shopItem)) {
                        if(hndlr.CanBuyMore(c.shopItem)) {
                            hasPurchased = true;

                            if(c.shopItem == GWYN_SHOP_SAVEGAME) {
                                hasSaved = true;
                                c.updateStatus(false);
                                c.animateDeselect();

                                // Countdown to save, it has to be after the save is purchased for validation reasons
                                saveCountdown = 2;
                                HUD.SaveStarted();
                            } else if(c.shopItem == GWYN_SHOP_CONFIDENCE) {
                                hasConfidence = true;
                                c.updateStatus(false);
                                c.animateDeselect();
                            }
                            
                            // Update cards first with has-enough-money status
                            // Provide a 2x multiplier because we can't guarantee that the net event has been processed
                            // and that our actual money count has changed yet
                            for(int x = 0; x < cards.size(); x++) {
                                let c2 = cards[x];

                                c2.updateStatus(cash - cost >= GWYNHandler.itemCosts[c2.shopItem] && (c2.shopItem != GWYN_SHOP_SAVEGAME || !hasSaved) && (c2.shopItem != GWYN_SHOP_CONFIDENCE || (!hasConfidence && hndlr.CanBuyMore(c2.shopItem))));
                            }

                            updateCashLabel(cost);
                            EventHandler.SendNetworkEvent("gwynBuy", c.controlID);
                            
                            // TODO: Play buy sound?

                            switch(c.shopItem) {
                                case GWYN_SHOP_SAVEGAME:
                                    animateMessage("Game Saved");
                                    MenuSound("ui/savegame");
                                    break;
                                
                                case GWYN_SHOP_MEDKIT:
                                    animateMessage(String.Format("\c[SOFTBLUE]%s", StringTable.Localize("$GWYN_MENU_MEDKIT_ADDED")));
                                    MenuSound("pickup/medkit");
                                    break;
                                
                                case GWYN_SHOP_CONFIDENCE:
                                    animateMessage(String.Format("\c[SOFTBLUE]%s", StringTable.Localize("$GWYN_MENU_CONFIDENCE_ADDED")));
                                    MenuSound("ui/purchase");
                                    break;

                                case GWYN_SHOP_QUICKFIX:
                                    animateMessage(String.Format("\c[SOFTBLUE]%s", StringTable.Localize("$GWYN_MENU_STIMMED")));
                                    MenuSound("item/healpickuplarge");
                                    break;

                                default:
                                    break;
                            }
                        } else {
                            MenuSound("ui/fail");

                            // Full of this item
                            if(c.shopItem == GWYN_SHOP_QUICKFIX) {
                                animateMessage(String.Format("\c[GWYNPINK]%s", StringTable.Localize("$GWYN_MENU_HEALTH_GREEDY")));
                            } else {
                                animateMessage(String.Format("\c[GWYNPINK]%s", StringTable.Localize("$GWYN_MENU_FULL_UP")));
                            }
                        }
                    } else {
                        MenuSound("ui/fail");

                        // Not enough money text
                        animateMessage(String.Format("\c[GWYNPINK]%s", StringTable.Localize("$GWYN_MENU_POOR")));
                    }
                }
            }
        }
    }

    override void ticker() {
        Animated = true;
        Super.ticker();

        // Cards start disabled, enable them after animation is over/almost over
        if(ticks == 8) {
            for(int x = 0; x < cards.size(); x++) {
                cards[x].setDisabled(false);
            }
        }

        if(closingTicks > 0 && ticks - closingTicks > 15) {
            EventHandler.SendNetworkEvent("gwynReset");
            close();
        }

        // Update credits count
        if(shownCredits != credits) {
            if(abs(credits - shownCredits) < 5) {
                shownCredits = credits;
            } else {
                shownCredits += (credits - shownCredits) / 4;
            }
        }

        if(saveCountdown > 0 && --saveCountdown == 0) {
            createHardcoreSave();
        }

        cashLabel.setText(String.Format("%d", shownCredits));
    }

    
    override void closeOnDeath() {
        EventHandler.SendNetworkEvent("gwynReset");
        Super.closeOnDeath();
    }

    override bool onBack() {
        if(closingTicks == 0) {
            animateClose(false);
        }

        return true;
    }

    const dimTime = 0.16;

    void animateMessage(string msg) {
        msg = msg.MakeUpper();
        animator.clear(infoLabel);

        infoLabel.setText(msg);

        let a = new("UIViewPinAnimation").initComponents(infoLabel, 0.18,
            fromScale: (1.04, 1),
            toScale: (1, 1),
            fromAlpha: 0, toAlpha: 1,
            ease: Ease_Out
        );
        //a.addValues(UIPin.Pin_Bottom, startVal: 1.04, endVal: 1.0);
        animator.add(a);

        // Fade out message
        a = new("UIViewPinAnimation").initComponents(infoLabel, 0.18,
            fromAlpha: 1,
            toAlpha: 0,
            ease: Ease_In
        );
        a.startTime += 2;
        a.endTime += 2;
        animator.add(a);
    }

    void animateClose(bool boughtSomething)  {
        closingTicks = ticks;
        dimStart = getRenderTime() + dimTime;

        if(!boughtSomething) {
            MenuSound("ui/gwyn/leave");
        }

        // Start animations
        animator.clear();
        for(int x = 0; x < cards.size(); x++) {
            let c = cards[x];
            let a = new("UIViewPinAnimation").initComponents( c, 0.18 + (x * 0.08),
                toScale: (0.75, 0.75),
                fromAlpha: 1, toAlpha: 0,
                ease: Ease_In
            );

            a.startTime += x * 0.08;
            
            a.addValues(UIPin.Pin_VCenter,
                endVal: 2.0
            );
            a.prepare();

            animator.add(a);
        }

        let a = new("UIViewPinAnimation").initComponents(cashView, 0.05,
            toScale: (0.9, 0.9),
            toAlpha: 0,
            ease: Ease_In
        );
        animator.add(a);
    }

    

    override void drawSubviews() {
        double time = getRenderTime();
        double dim = closingTicks == 0 ? MIN((time - dimStart) / dimTime, 1.0) * 0.7  : MAX((dimStart - time) / dimTime, 0.0) * 0.7;
        Screen.dim(0xFF020202, dim, 0, 0, lastScreenSize.x, lastScreenSize.y);
        
        Super.drawSubviews();
    }
}


class GwynShadow : UIImage {
    override void draw() {
        // Set an artificial clip rect to keep the shadow in the bounds of the card frame
        UIBox clipRect, b;
        b.pos = (14 - frame.pos.x, 17);
        b.size = frame.size - (28, 34);
        boxToScreenClipped(clipRect, b);

        Screen.setClipRect(int(clipRect.pos.x), int(clipRect.pos.y), int(clipRect.size.x), int(clipRect.size.y));

        Super.draw();
    }
}


class GwynCard : UIButton {
    int shopItem;           // Which shop item we are buying
    //Vector2 targetCenter;   // Where the center of the card should appear on screen at idle
    Vector2 targetSize;     // Default size of the card when not being transformed
    bool hasEnoughMoney;

    UIImage /*descriptionLabel, */costImage;
    UIImage gwynImage, gwynShadow;
    UILabel headerLabel, costLabel, descriptionLabel;

    int loCol, hiCol;

    static const string gfxSuffix[] = {
        "MDKT",     // GWYN_SHOP_MEDKIT
        "BSTR",     // GWYN_SHOP_CONFIDENCE
        "SAVE",     // GWYN_SHOP_SAVEGAME
        "QFIX"      // GWYN_SHIP_QUICKFIX
    };

    GwynCard init(int item, double offsetX) {
        targetSize = (365, 620);
        shopItem = item;

        setScale((0.95,0.95));

        Super.init(
            (0,0), targetSize, "", null,
            UIButtonState.Create("GWNCARD1"),
            hover: UIButtonState.Create("GWNCARD2"),
            pressed: UIButtonState.Create("GWNCARD3"),
            selectedPressed: UIButtonState.Create("GWNCARD3")
        );

        loCol = Font.FindFontColor("GWYNPINK");
        hiCol = Font.FindFontColor("GWYNBLUE");

        

        self.clipsSubviews = false;

        // Add various important layers
        gwynShadow = new("GwynShadow").init((0,0), (365, 365), String.Format("GWN%s%d", gfxSuffix[shopItem], 1));
        gwynShadow.pin(UIPin.Pin_HCenter, value:1.0, offset: 23, isFactor: true);
        gwynShadow.pin(UIPin.Pin_VCenter, UIPin.Pin_Bottom, value:0.3, offset: 19, isFactor: true);
        add(gwynShadow);

        gwynImage = new("UIImage").init((0,0), (365, 365), String.Format("GWN%s%d", gfxSuffix[shopItem], 3));
        gwynImage.pin(UIPin.Pin_HCenter, value:1.0, isFactor: true);
        gwynImage.pin(UIPin.Pin_VCenter, UIPin.Pin_Bottom, value:0.3, isFactor: true);
        add(gwynImage);

        int maxHP = players[consolePlayer].mo.getMaxHealth() + GWYNHandler.MAX_BONUS_HEALTH;

        /*descriptionLabel = new("UIImage").init((0,0), (365, 75), String.Format("GWN%s%d", gfxSuffix[shopItem], 5));
        descriptionLabel.pin(UIPin.Pin_HCenter, value:1.0, isFactor: true);
        descriptionLabel.pin(UIPin.Pin_VCenter, UIPin.Pin_Bottom, value:0.81, isFactor: true);
        add(descriptionLabel);*/

        string itemDesc = StringTable.Localize(GWYNHandler.itemFullDescriptions[item]);
        itemDesc = itemDesc.filter();
        itemDesc.replace("^hp", String.Format("%d", maxHP));

        descriptionLabel = new("UILabel").init((0,0), (315, 75), itemDesc, "K32FONT", Font.FindFontColor("GWYNBLU2"), UIView.Align_Centered, fontScale: (0.38, 0.4));
        descriptionLabel.pin(UIPin.Pin_HCenter, value:1.0, isFactor: true);
        descriptionLabel.pin(UIPin.Pin_VCenter, UIPin.Pin_Bottom, value:0.81, isFactor: true);
        add(descriptionLabel);

        
        itemDesc = StringTable.Localize(GWYNHandler.itemDescriptions[item]);
        itemDesc = itemDesc.filter();
        itemDesc.replace("^hp", String.Format("%d", maxHP));

        headerLabel = new("UILabel").init((0,0), (336, 135), itemDesc, "K32OFONT", loCol, UIView.Align_Centered, fontScale: (1, 1));
        headerLabel.multiline = true;
        headerLabel.pin(UIPin.Pin_HCenter, value:1.0, offset: -4, isFactor: true);
        headerLabel.pin(UIPin.Pin_VCenter, UIPin.Pin_Bottom, value:0.68, offset: -15, isFactor: true);
        headerLabel.shadowColor = 0xFF00213F;
        headerLabel.shadowStencil = true;     // Draw shadow as a flat color
        headerLabel.shadowOffset = (2, 6);
        headerLabel.drawShadow = true;
        add(headerLabel);

        costImage = new("UIImage").init((0,0), (155, 60), "GWNBUTT0");
        costImage.pin(UIPin.Pin_HCenter, value:1.0, isFactor: true);
        costImage.pin(UIPin.Pin_VCenter, UIPin.Pin_Bottom, value:0.91, isFactor: true);
        costImage.setScale((0.9, 0.9));
        add(costImage);

        costLabel = new("UILabel").init((0,2), (100, 60), "", "K22FONT", 0xFF002240, UIView.Align_Centered, fontScale: (0.91, 0.91));
        costLabel.multiline = false;
        costLabel.pixelAlign = false;
        costLabel.text = String.Format("%d", GWYNHandler.itemCosts[item]);
        costLabel.pin(UIPin.Pin_Left, UIPin.Pin_Right, value: 0.432, isFactor: true);
        costLabel.pin(UIPin.Pin_Right, value: 0.916, isFactor: true);
        costImage.add(costLabel);

        //headerImage = new("UIImage").init((0,0), (365, 150), String.Format("GWN%s%d", gfxSuffix[shopItem], 0));
        //headerImage.pin(UIPin.Pin_HCenter, value:1.0, isFactor: true);
        //headerImage.pin(UIPin.Pin_VCenter, UIPin.Pin_Bottom, value:0.68, isFactor: true);
        //add(headerImage);

        pin(UIPin.Pin_VCenter, value: 1.0, offset: 40, isFactor: true);
        pin(UIPin.Pin_HCenter, value: 1.0, offset: offsetX, isFactor: true);

        disabled = true;



        return self;
    }

    void updateStatus(bool hasEnoughMoney = true) {
        bool hadMoney = self.hasEnoughMoney;
        self.hasEnoughMoney = hasEnoughMoney;
        
        int fadeCol = 0x88000000;
        blendColor = hasEnoughMoney ? 0 : fadeCol;

        headerLabel.blendColor = hasEnoughMoney ? 0 : fadeCol;
        gwynImage.blendColor = hasEnoughMoney ? 0 : fadeCol;
        gwynShadow.blendColor = hasEnoughMoney ? 0 : fadeCol;

        desaturation = hasEnoughMoney ? 0 : 0.2;
        headerLabel.desaturation = hasEnoughMoney ? 0 : 0.4;
        gwynImage.desaturation = hasEnoughMoney ? 0 : 0.2;
        gwynShadow.desaturation = hasEnoughMoney ? 0 : 0.2;
        descriptionLabel.desaturation = hasEnoughMoney ? 0 : 0.2;

        descriptionLabel.textColor = Font.FindFontColor(hasEnoughMoney ? "GWYNBLU2" : "GWYNBLU3");

        costImage.setImage(hasEnoughMoney ? "GWNBUTT0" : "GWNBUTT1");

    }

    override void onSelected(bool mouseSelection) {
        Super.onSelected(mouseSelection);

        if(disabled) {
            return;
        }

        // Set image
        //headerImage.setImage(String.Format("GWN%s%d", gfxSuffix[shopItem], 9));
        gwynImage.setImage(String.Format("GWN%s%d", gfxSuffix[shopItem], hasEnoughMoney ? 4 : 3));
        gwynShadow.setImage(String.Format("GWN%s%d", gfxSuffix[shopItem], hasEnoughMoney ? 2 : 1));
        //descriptionLabel.setImage(String.Format("GWN%s%d", gfxSuffix[shopItem], 6));

        headerLabel.textColor = hiCol;

        // Animate!
        let animator = getAnimator();
        if(animator && hasEnoughMoney) {
            animator.clear(self);
            animator.clear(gwynImage);

            UIViewPinAnimation a;

            if(hasEnoughMoney) {
                a = new("UIViewPinAnimation").initComponents( gwynImage, 0.2,
                    toScale: (1.1,1.1),
                    ease: Ease_Out
                );
                a.finishOnCancel = false;
                a.prepare();

                animator.add(a);

                a = new("UIViewPinAnimation").initComponents(costImage, 0.15,
                    toScale: (1,1),
                    ease: Ease_Out
                );
                a.finishOnCancel = false;
                a.prepare();
                animator.add(a);
            }            

            // Animate Entire View
            a = new("UIViewPinAnimation").initComponents( self, 0.14,
                toScale: hasEnoughMoney ? (1,1) : (0.955, 0.955),
                ease: Ease_Out
            );
            a.addValues(UIPin.Pin_VCenter, endVal: hasEnoughMoney ? 0.94 : 0.99);
            a.finishOnCancel = false;
            a.prepare();

            animator.add(a);
        }
    }

    override void onDeselected() {
        Super.onDeselected();

        //headerImage.setImage(String.Format("GWN%s%d", gfxSuffix[shopItem], 0));
        gwynImage.setImage(String.Format("GWN%s%d", gfxSuffix[shopItem], 3));
        gwynShadow.setImage(String.Format("GWN%s%d", gfxSuffix[shopItem], 1));
        //descriptionLabel.setImage(String.Format("GWN%s%d", gfxSuffix[shopItem], 5));

        headerLabel.textColor = loCol;

        // Animate!
        animateDeselect();
    }

    void animateDeselect() {
        let animator = getAnimator();
        if(animator) {
            animator.clear(self);
            animator.clear(gwynImage);

            let a = new("UIViewPinAnimation").initComponents( gwynImage, 0.2,
                toScale: (1,1),
                ease: Ease_In
            );
            a.finishOnCancel = false;
            a.prepare();
            animator.add(a);

            a = new("UIViewPinAnimation").initComponents(costImage, 0.15,
                toScale: (0.9,0.9),
                ease: Ease_In
            );
            a.finishOnCancel = false;
            a.prepare();
            animator.add(a);

            // Entire view
            a = new("UIViewPinAnimation").initComponents( self, 0.14,
                toScale: (0.95, 0.95),
                ease: Ease_In
            );
            a.addValues(UIPin.Pin_VCenter, endVal: 1);
            a.finishOnCancel = false;
            a.prepare();

            animator.add(a);
        }
    }

    override void transitionToState(int idx, bool sound) {
        bool isChanging = idx != currentState;
        int prevState = currentState;
        UIViewAnimator animator = getAnimator();

        Super.transitionToState(idx, sound);
        
        // Let's add our animations here
        if(isChanging && animator) {
            switch(idx) {
                case State_Pressed:
                case State_SelectedPressed:
                    if(hasEnoughMoney) {
                         animator.clear(self);
                        let a = new("UIViewPinAnimation").initComponents( self, 0.03,
                            toScale: (0.96,0.96),
                            ease: Ease_In
                        );
                        a.finishOnCancel = false;
                        a.prepare();
                        animator.add(a);
                    }
                    break;
                case State_Hover:
                case State_SelectedHover:
                    if(hasEnoughMoney && prevState == State_Pressed || prevState == State_SelectedPressed) {
                        animator.clear(self);
                        let a = new("UIViewPinAnimation").initComponents( self, 0.15,
                            toScale: (1,1),
                            ease: Ease_In
                        );
                        a.finishOnCancel = false;
                        a.prepare();
                        animator.add(a);
                    }

                    // Play hover sound only when hovering, not coming back from a press
                    if(prevState != State_Pressed && prevState != State_SelectedPressed) {
                        playSound(hasEnoughMoney ? "ui/gwyn/hover1" : "ui/gwyn/hover2");
                    }
                    break;
                default:
                    break;
            }
        }
    }

    override void onMouseExit(Vector2 screenPos, UIView newView) {
        Super.onMouseExit(screenPos, newView);

        // Remove navigation
        let m = getMenu();
        if(m && m.activeControl == self) {
            m.clearNavigation();
        }
    }
}
