class WeaponPartPrompt : PromptMenu {
    String weaponImage;
    class<WeaponUpgrade> upgradeClass, currentClass;
    bool forceClose;

    override void init(Menu parent) {
		UIMenu.init(parent);

        parentMenu = UIMenu(parent);

        AnimatedTransition = false;
        Animated = true;
        DontBlur = parent && parent.DontBlur;
        BlurAmount = parent ? parent.BlurAmount : 0;
        if(parent) DontDim = parent.DontDim;
        else allowDimInTitlemapOnly();
        
        // We will pause the game after a second or so
        menuActive = Menu.OnNoPause;

        let pinstance = PromptHandler.Instance();
        upgradeClass = pinstance.upgradeClass;
        
        class<SelacoWeapon> sw = GetDefaultByType(upgradeClass).weapon;
        let curWeapon = players[consolePlayer].mo ? SelacoWeapon(players[consolePlayer].mo.FindInventory(sw)) : null;
        if(curWeapon) {
            let cur = curWeapon.getActiveAltFire();
            if(cur) {
                currentClass = cur.getClass();
            }
        }
        
        destructiveIndex = -1;

        if(!upgradeClass) {
            Console.Printf("\c[RED]WeaponPartPrompt found no upgrade class! Aborting.");
            forceClose = true;
            return;
        }


        bg = new("UIImage").init((0,0), (100, 100), "TUTMBG");
        bg.pinToParent();
        mainView.add(bg);
        

        mainBG = new("UIImage").init(
            (0,0), (750, 650), "",
            NineSlice.Create("PROMPTB3", (30, 70), (40, 76))
        );
        mainBG.pin(UIPin.Pin_VCenter, value: 1.0);
        mainBG.pin(UIPin.Pin_HCenter, value: 1.0);
        mainView.add(mainBG);

        let titleLabel = new("UILabel").init(
            (0,0), (100, 37),
            "Behavior Modifier Found!",
            'SEL21FONT',
            textAlign: UIView.Align_Left | UIView.Align_Middle,
            fontScale: (0.857, 0.857) // 18pt
        );
        titleLabel.pin(UIPin.Pin_Top, offset: 24);
        titleLabel.pin(UIPin.Pin_Left, offset: 30 + 15);
        titleLabel.pin(UIPin.Pin_Right, offset: -30 - 15);
        mainBG.add(titleLabel);

        // Add image view with max sizes
        let shadowImage = new("UIImage").init(
            (0,0), (200, 200), GetDefaultByType(upgradeClass).upgradeImage,
            imgStyle: UIImage.Image_Aspect_Fill, 
            imgAnchor: UIImage.ImageAnchor_Middle
        );
        shadowImage.maxSize = (200, 200);
        shadowImage.pin(UIPin.Pin_Top, offset: 95);
        shadowImage.pin(UIPin.Pin_Left, offset: 30 + 15 + 5);
        shadowImage.alpha = 0.2;
        shadowImage.blendColor = 0xFF000000;
        mainBG.add(shadowImage);

        let mainImage = new("UIImage").init(
            (0,0), (200, 200), GetDefaultByType(upgradeClass).upgradeImage, 
            imgStyle: UIImage.Image_Aspect_Fill, 
            imgAnchor: UIImage.ImageAnchor_Middle
        );
        mainImage.maxSize = (200, 200);
        mainImage.pin(UIPin.Pin_Top, offset: 90);
        mainImage.pin(UIPin.Pin_Left, offset: 30 + 15);
        mainBG.add(mainImage);
        
        // Add text label to the right of image view
        // Some special cases baked in here so as not to confuse the player. These classes don't "replace" the zoom.
        string labelText;
        if(!currentClass || upgradeClass == 'AltFireRifleBurst' || upgradeClass == 'AltFireRifleBurst' || upgradeClass == 'AltFireShotgunSlugShell') {
            labelText = String.Format(StringTable.Localize("$UPGRADE_WEAPONKIT_NOTIFICATION"), 
                        StringTable.Localize(GetDefaultByType(GetDefaultByType(upgradeClass).weapon).getTag()),
                        StringTable.Localize(GetDefaultByType(upgradeClass).upgradeNameLong), 
                        StringTable.Localize(GetDefaultByType(upgradeClass).upgradeDescription));
        } else {
            labelText = String.Format(StringTable.Localize("$UPGRADE_WEAPONKIT_NOTIFICATION2"), 
                StringTable.Localize(GetDefaultByType(GetDefaultByType(upgradeClass).weapon).getTag()),
                StringTable.Localize(GetDefaultByType(upgradeClass).upgradeNameLong), 
                StringTable.Localize(GetDefaultByType(currentClass).upgradeNameLong), 
                StringTable.Localize(GetDefaultByType(upgradeClass).upgradeDescription));
        }

        textLabel = new("UILabel").init(
            (0,0), (100, 100),
            labelText,
            'PDA16FONT',
            textAlign: UIView.Align_Left | UIView.Align_Middle
        );
        textLabel.multiline = true;
        textLabel.pin(UIPin.Pin_Top, offset: 90);
        textLabel.pin(UIPin.Pin_Bottom, offset: -120);
        textLabel.pin(UIPin.Pin_Right, offset: -30 - 15);
        textLabel.pin(UIPin.Pin_Left, offset: 30 + 15 + 200 + 25);
        textLabel.pinHeight(UIView.Size_Min);
        mainBG.add(textLabel);

        // Horizontal layout to center buttons
        hlayout = new("UIHorizontalLayout").init((0,0), (100, 100));
        hlayout.layoutMode = UIViewManager.Content_SizeParent;
        hlayout.itemSpacing = 15;
        //hlayout.pin(UIPin.Pin_HCenter, value: 1.0);
        hlayout.pin(UIPin.Pin_Right, offset: -30 - 15);
        hlayout.pin(UIPin.Pin_Bottom, offset: -10);
        mainBG.add(hlayout);

        createButtons();

        if(isUsingController() || isUsingKeyboard()) {
            navigateTo(butts[defaultSelection < butts.size() ? defaultSelection : 0]);
        }
    }


    override void layoutChange(int screenWidth, int screenHeight) {
        if(forceClose) {
            Close();
            return;
        }

		UIMenu.layoutChange(screenWidth, screenHeight);

        // We are going to layout twice to get the sizes we need
        // It's such a simple view setup that this shouldn't be slow
        let textLabelMinSize = textLabel.calcMinSize((textLabel.parent.frame.size.x, 999999));
        mainBG.frame.size.y = MAX(200, textLabelMinSize.y) + 120 + 90;
        
        mainView.layout();

        // Since this should only happen if screen size changes, or at startup let's add our animation here
        // Normally we would do this on the first tick
        bg.animateFrame(
            0.10,
            fromAlpha: 0.0,
            toAlpha: initFromNew ? 0.6 : 1.0
        );

        mainBG.animateFrame(
            0.11,
            fromSize: (mainBG.frame.size.x, 100),
            toSize: (mainBG.frame.size.x, mainBG.frame.size.y),
            fromAlpha: 0.0,
            toAlpha: 1.0,
            layoutSubviewsEveryFrame: true,
            ease: Ease_Out
        );

        mainView.animateFrame(
            0.18,
            layoutSubviewsEveryFrame: true
        );  // Adding this because we need to force a layout of everything
	}


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated) {
           
            menuActive = Menu.OnNoPause;
            
            if(ctrl.controlID == 0) {
                // Actually equip the upgrade
                MenuSound("item/weaponkit");
                HUD.ShowWeaponInfo();
                EventHandler.SendNetworkEvent("alf:" .. upgradeClass.getClassName(), 1);
            } else {
                MenuSound("menu/OSKBackspace");
            }

            animateClose();
        }
    }

    override void ticker() {
        if(forceClose) {
            Close();
            return;
        }
        
        Super.ticker();

        if(ticks == 15) {
            menuActive = Menu.On;
        }

        if(players[consolePlayer].mo && players[consolePlayer].mo.health <= 0) 
            Close();
    }
}