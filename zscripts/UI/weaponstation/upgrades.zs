#include "ZScripts/UI/weaponstation/upgrade_button.zs"
#include "ZScripts/UI/weaponstation/upgrade_node_button.zs"
#include "ZScripts/UI/weaponstation/weapon_image.zs"
#include "ZScripts/UI/weaponstation/upgrade_line.zs"
#include "ZScripts/UI/weaponstation/upgrade_alt_fire_button.zs"
#include "ZScripts/UI/weaponstation/upgrade_stat_view.zs"
#include "ZScripts/UI/weaponstation/fake_weapons.zs"

class WorkshopUpgradeView : WorkshopView {
    mixin CVARBuddy; 

    UIViewAnimation lastAnimation;  // last finishing animation in the current animation, controls status
    WVAnimation curAnimType;

    UIView upgradeView;
    UIImage ammoImage, gamepadScrollIcon;
    UIWeaponImage weaponImage;
    UIButton installedImage, statsButton;
    UIControl forwardControl;
    UILabel secondaryFireLabel, ammoCountLabel;   
    UIVerticalScroll weaponScroll, statScroll;
    UIVerticalLayout weaponLayout, altFireLayout, statsLayout, ammoLayout;
    UIAnimatedLabel modTitleLabel, modDescriptionLabel;
    WeaponStatLine statLines[UpgradeStatView.Num_Stats];
    UpgradeStatView upgradePopup;
    
    Array<UpgradeButton> upgradeButtons;
    Array<UpgradeNodeButton> nodeButtons;
    Array<UpgradeAltFireButton> altFireButtons;
    UpgradeNodeButton buyButton;            // Button last pressed to open purchase prompt
    SelacoWeapon currentWeapon;
    readonly<SelacoWeapon> currentDefaultWeapon;

    UIVerticalLayout infoLayout;
    UIHorizontalLayout priceLayout, moduleLayout;
    UIAnimatedLabel moduleLabel1, moduleLabel2;
    UIImage moduleImage;
    ResourceView creditsView, partsView, saferoomsView;
    ResourceView creditsCostView, partsCostView, roomsCostView;


    Vector2 lastWorkshopPos;            // When switching weapons with keys we must retain the previous position and try to select the closest upgrade to that
    bool showingStats, useController, waitingForReveal, isPlaystation;
    uint ticks;
    int reloadTicks;                    // Reload stats countdown
    int ammoUpdate;                     // Reload ammo countdown
    int ammoCount, ammoCountTotal;      // Amount of ammo shown vs what the total should be
    int ammoCountMax;                   // Max ammo to show
    bool ammoAllowed;                   // Is ammo locked?
    int selectedWeapon;


    WorkshopUpgradeView init(bool useController) {
        Super.init((0,0), (100, 100));
        pinToParent();

        isPlaystation = iGetCVar("g_gamepad_use_psx") > 0;

        clipsSubviews = false;
        self.useController = useController;

        Dawn girlCaptainDown = Dawn(players[consolePlayer].mo);
        
        let workTier = girlCaptainDown.FindInventory("WorkshopTierItem");
        ammoAllowed = workTier && workTier.amount >= 2;

        forwardControl = new("UIControl").init((0,0), (100, 100));

        weaponImage = new("UIWeaponImage").init((0,0), (100, 100), WeaponStationGFXPath .. "rifle", imgStyle: UIImage.Image_Center);
        weaponImage.pinToParent(275, 0, -290);
        add(weaponImage);

        infoLayout = new("UIVerticalLayout").init((0,0), (100, 35));
        infoLayout.layoutMode = UIViewManager.Content_SizeParent;
        infoLayout.pin(UIPin.Pin_Left, offset: 275 + 50);
        infoLayout.pin(UIPin.Pin_Right, value: 0.6, isFactor: true);
        infoLayout.pin(UIPin.Pin_Bottom);
        infoLayout.ignoreHiddenViews = true;
        infoLayout.minSize.x = 700;
        infoLayout.itemSpacing = 5;
        infoLayout.alpha = 0;
        add(infoLayout);

        priceLayout = new("UIHorizontalLayout").init((0,0), (100, 41));
        priceLayout.itemSpacing = 15;
        priceLayout.pin(UIPin.Pin_Left);
        priceLayout.pin(UIPin.Pin_Right);
        priceLayout.pinHeight(41);
        priceLayout.ignoreHiddenViews = true;
        infoLayout.addManaged(priceLayout);

        creditsCostView = new("ResourceView").init(1300, WeaponStationGFXPath .. "resourceSelver.png", 0xFFFAD364);
        creditsCostView.pinWidth(UIView.Size_Min);
        partsCostView = new("ResourceView").init(300, WeaponStationGFXPath .. "resourceWeaponParts.png");
        partsCostView.pinWidth(UIView.Size_Min);
        roomsCostView = new("ResourceView").init(2, WeaponStationGFXPath .. "resourceSaferoom.png");
        roomsCostView.hidden = true;
        roomsCostView.pinWidth(UIView.Size_Min);

        priceLayout.addManaged(creditsCostView);
        priceLayout.addManaged(partsCostView);
        priceLayout.addManaged(roomsCostView);

        infoLayout.addSpacer(3);

        // Add description for when you need more Tech Modules
        moduleLayout = new("UIHorizontalLayout").init((0,0), (100, 25));
        moduleLayout.layoutMode = UIViewManager.Content_SizeParent;
        infoLayout.addManaged(moduleLayout);

        moduleLabel1 = new("UIAnimatedLabel").init((0,0), (100, 25), StringTable.Localize("$WORKSHOP_MODULES1"), "SEL21FONT", textAlign: Align_Middle);
        moduleLabel1.pinWidth(UIView.Size_Min);
        moduleLabel1.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        moduleLabel1.multiline = false;

        moduleLabel2 = new("UIAnimatedLabel").init((0,0), (100, 25), " TECH MODULE 1", "SEL21FONT", textAlign: Align_Middle);
        moduleLabel2.pinWidth(UIView.Size_Min);
        moduleLabel2.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        moduleLabel2.multiline = false;

        moduleImage = new("UIImage").init((0,0), (25, 25), WeaponStationGFXPath .. "resourceSaferoom.png");
        moduleImage.pin(UIPin.Pin_VCenter, value: 1.0, offset: 1, isFactor: true);
        moduleLayout.addManaged(moduleLabel1);
        moduleLayout.addManaged(moduleImage);
        moduleLayout.addManaged(moduleLabel2);

        infoLayout.addSpacer(5);

        modTitleLabel = new("UIAnimatedLabel").init((0,0), (100, 100), "MOD TITLE LABEL", "SEL46FONT", textAlign: Align_BottomLeft);
        modTitleLabel.scaleToHeight(30);
        modTitleLabel.pinWidth(UIView.Size_Min);
        modTitleLabel.pin(UIPin.Pin_Bottom);
        modTitleLabel.multiline = false;

        let horzLayout = new("UIHorizontalLayout").init((0,0), (100, 35));
        horzLayout.itemSpacing = 12;
        horzLayout.pin(UIPin.Pin_Left);
        horzLayout.pin(UIPin.Pin_Right);
        horzLayout.pinHeight(29);
        infoLayout.addManaged(horzLayout);
        
        installedImage = new("InstalledButton").init("Not Installed");
        installedImage.pinWidth(UIView.Size_Min);
        installedImage.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        installedImage.pinHeight(25);

        horzLayout.addManaged(modTitleLabel);
        horzLayout.addManaged(installedImage);

        modDescriptionLabel = new("UIAnimatedLabel").init((0,0), (100, 100), "Penetrating bullets are the ultimate solution for any situation that requires maximum penetration. ", "PDA18FONT");
        modDescriptionLabel.scaleToHeight(27);
        modDescriptionLabel.pin(UIPin.Pin_Left);
        modDescriptionLabel.pin(UIPin.Pin_Right);
        modDescriptionLabel.pinHeight(UIView.Size_Min);
        modDescriptionLabel.multiline = true;
        infoLayout.addManaged(modDescriptionLabel);


        let scrollConfig = UIScrollBarConfig.Create(
            18, 18,
            NineSlice.Create(WeaponStationGFXPath .. "scroll_bg.png", (8, 3), (10, 13)),
            null,
            UIButtonState.CreateSlices(WeaponStationGFXPath .. "scroll_normal.png", (8, 3), (10, 13)),
            UIButtonState.CreateSlices(WeaponStationGFXPath .. "scroll_hover.png", (8, 3), (10, 13)),
            UIButtonState.CreateSlices(WeaponStationGFXPath .. "scroll_normal.png",(8, 3), (10, 13)),
            insetA: 8,
            insetB: 8
        );


        weaponScroll = new("UIVerticalScroll").initFromConfig((0,0), (275, 100), scrollConfig);
        weaponScroll.autoHideScrollbar = true;
        weaponScroll.autoHideAdjustsSize = true;
        weaponScroll.pinWidth(275);
        weaponScroll.pin(UIPin.Pin_Left);
        weaponScroll.pin(UIPin.Pin_Top);
        weaponScroll.pin(UIPin.Pin_Bottom, offset: useController ? -60 : 0);
        weaponScroll.scrollbar.firstPin(UIPin.Pin_Right).offset = -4;
        weaponScroll.scrollbar.rejectHoverSelection = true;
        weaponScroll.rejectHoverSelection = true;
        weaponLayout = UIVerticalLayout(weaponScroll.mLayout);
        add(weaponScroll);

        // Add controller icons
        if(useController) {
            let leftText = new("UILabel").init((0,15), (1, 1), String.Format("%c", 0x86), "SEL46FONT", Font.CR_UNTRANSLATED, textAlign: UIView.Align_Left, fontScale: (0.85, 0.85));
            leftText.pinHeight(UIView.Size_Min);
            leftText.pinWidth(UIView.Size_Min);
            leftText.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, offset: 10);
            leftText.ignoresClipping = true;
            weaponScroll.add(leftText);

            // Add text
            leftText = new("UILabel").init((0,15), (1, 1), "Prev", "SEL27OFONT", Font.CR_UNTRANSLATED, textAlign: UIView.Align_Left, fontScale: (0.85, 0.85));
            leftText.pinHeight(UIView.Size_Min);
            leftText.pinWidth(UIView.Size_Min);
            leftText.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, offset: 18);
            leftText.pin(UIPin.Pin_Left, offset: 40);
            leftText.ignoresClipping = true;
            weaponScroll.add(leftText);

            let rightText = new("UILabel").init((0,15), (1, 1), String.Format("%c", 0x87), "SEL46FONT", Font.CR_UNTRANSLATED, textAlign: UIView.Align_Right, fontScale: (0.85, 0.85));
            rightText.pinHeight(UIView.Size_Min);
            rightText.pinWidth(UIView.Size_Min);
            rightText.pin(UIPin.Pin_Right);
            rightText.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, offset: 10);
            rightText.ignoresClipping = true;
            weaponScroll.add(rightText);

            rightText = new("UILabel").init((0,15), (1, 1), "Next", "SEL27OFONT", Font.CR_UNTRANSLATED, textAlign: UIView.Align_Right, fontScale: (0.85, 0.85));
            rightText.pinHeight(UIView.Size_Min);
            rightText.pinWidth(UIView.Size_Min);
            rightText.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, offset: 18);
            rightText.pin(UIPin.Pin_Right, offset: -40);
            rightText.ignoresClipping = true;
            weaponScroll.add(rightText);
        }

        weaponLayout.itemSpacing = -8;

        let bg = new("UIImage").init((0,0), (100, 100), "", NineSlice.Create(WeaponStationGFXPath .. "panel_background.png", (16,16), (36, 36)));
        bg.pinToParent(-10, -10, 10, 10);
        bg.ignoresClipping = true;
        weaponScroll.add(bg);
        weaponScroll.moveToBack(bg);

        weaponScroll.alpha = 0;     // Prepare for animation
        weaponImage.alpha = 0;

        // Get all the current weapons
        //Array<SelacoWeapon> weapons;
        Array< class<SelacoWeapon> > roWeapons;
        int numClasses = AllClasses.size();

        for(int x = 0; x < numClasses; x++) {
            if(AllClasses[x] is 'SelacoWeapon') {
                let cls = (class<SelacoWeapon>)(AllClasses[x]);
                Inventory i = girlCaptainDown.FindInventory(cls);
                
                if((i && i.amount > 0) || girlCaptainDown.hasUnlockedWeapon(cls)) {
                    // Insert into our list of weapons. Sort by weapon slot
                    readonly<SelacoWeapon> w = GetDefaultByType(cls);
                    Array< class<WeaponUpgrade> > pUpgrades;

                    if(!w.isUpgradeable && !w.alwaysShowInWorkshop) continue;
                    w.findUpgrades(pUpgrades);
                    if(!pUpgrades.size()) continue;     // If there are no upgrades for this weapon, don't show it

                    if(roWeapons.size() == 0) {
                        roWeapons.push(cls);
                    } else {
                        for(int y = 0; y <= roWeapons.size(); y++) {
                            if(y == roWeapons.size()) {
                                roWeapons.push(cls);
                                break;
                            }

                            let roWeapon = GetDefaultByType(roWeapons[y]);
                            
                            if(w.SlotNumber < roWeapon.SlotNumber || (w.SlotNumber == roWeapon.SlotNumber && w.SlotPriority > roWeapon.SlotPriority)) {
                                roWeapons.insert(y, cls);
                                break;
                            }
                        }
                    }
                }
            }
        }

        // Use the weapon list to create buttons
        bool hasSelected = false;
        selectedWeapon = -1;

        for(int x = 0; x < roWeapons.size(); x++) {
            readonly<SelacoWeapon> w = GetDefaultByType(roWeapons[x]);
            let wb = new("UpgradeButton").init(w.getTag(), WeaponStationGFXPath .. "" .. w.imagePrefix);
            wb.weapon = SelacoWeapon(girlCaptainDown.FindInventory(roWeapons[x]));
            wb.defaultWeapon = w;
            weaponLayout.addManaged(wb);

            if(!hasSelected && players[consolePlayer].ReadyWeapon && players[consolePlayer].ReadyWeapon.getClass() == roWeapons[x]) {
                selectedWeapon = x;
                if(!useController) {
                    wb.setSelected();
                    forwardControl.navLeft = wb;
                }
                hasSelected = true;
            }

            int ugs = upgradeButtons.size();
            if(ugs > 0) {
                upgradeButtons[ugs - 1].navDown = wb;
                wb.navUp = upgradeButtons[ugs - 1];
            }

            wb.navRight = forwardControl;
            upgradeButtons.push(wb);
        }

        if(!hasSelected && upgradeButtons.size() > 0) {
            selectedWeapon = 0;
            upgradeButtons[0].setSelected();
            if(!useController) forwardControl.navLeft = upgradeButtons[0];
        }

        for(int x = 0; x < upgradeButtons.size(); x++) {
            upgradeButtons[x].alpha = 0;
        }


        // Create alt fire Containers
        altFireLayout = new("UIVerticalLayout").init((0,0), (380, 400));
        altFireLayout.layoutMode = UIViewManager.Content_SizeParent;
        altFireLayout.pin(UIPin.Pin_Right);
        altFireLayout.pin(UIPin.Pin_Bottom);
        altFireLayout.minSize.y = 190;
        altFireLayout.itemSpacing = -8;
        altFireLayout.alpha = 0;
        add(altFireLayout);

        let altFireBG = new("UIImage").init((0,0), (100, 100), "", NineSlice.Create(WeaponStationGFXPath .. "panel_background.png", (16,16), (36, 36)));
        altFireBG.pinToParent(-10, -10, 10, 10);
        altFireBG.ignoresClipping = true;
        altFireLayout.add(altFireBG);

        secondaryFireLabel = new("UILabel").init((0,0), (100, 100), String.Format("\c[HI2]%s\c-", "Secondary Mode") .. (useController ? String.Format("  %c", UIHelper.ICON_PAD_X  + (isPlaystation ? 23 : 0)) : ""), "SEL46FONT", textAlign: Align_BottomLeft);
        //secondaryFireLabel.setShadow(0xAA1C1E27, (3,3));
        secondaryFireLabel.scaleToHeight(36);
        secondaryFireLabel.pinWidth(1.0, isFactor: true);
        secondaryFireLabel.pin(UIPin.Pin_Left);
        secondaryFireLabel.pin(UIPin.Pin_Bottom, UIPin.Pin_Top, offset: -17);
        secondaryFireLabel.ignoresClipping = true;
        secondaryFireLabel.multiline = false;
        altFireLayout.add(secondaryFireLabel);

        // Create ammo purchase container
        ammoLayout = new("UIVerticalLayout").init((0,0), (290, 400));
        ammoLayout.layoutMode = UIViewManager.Content_SizeParent;
        ammoLayout.pin(UIPin.Pin_Right);
        ammoLayout.pin(UIPin.Pin_VCenter, value: 1.0, offset: 40);
        ammoLayout.itemSpacing = -8;
        //ammoLayout.minSize.y = 100;
        ammoLayout.layoutWithChildren = false;
        add(ammoLayout);

        let ammoBG = new("UIImage").init((0,0), (100, 100), "", NineSlice.Create(WeaponStationGFXPath .. "panel_background.png", (16,16), (36, 36)));
        ammoBG.pinToParent(-10, -10, 10, 10);
        ammoBG.ignoresClipping = true;
        ammoLayout.add(ammoBG);

        ammoImage = new("UIImage").init((0,0), (36, 36), "WPNRIFLE", imgStyle: UIImage.Image_Scale);
        ammoImage.pinWidth(40);
        ammoImage.pinHeight(40);
        ammoImage.pin(UIPin.Pin_Left, offset: -2);
        ammoImage.pin(UIPin.Pin_Bottom, UIPin.Pin_Top, offset: -14);
        ammoImage.ignoresClipping = true;
        ammoLayout.add(ammoImage);

        let ammoLabel = new("UILabel").init((0,0), (100, 100), String.Format("\c%s%s\c-", ammoAllowed ? "[HI2]" : "[DarkGrey]", "BUY AMMO"), "SEL46FONT", textAlign: Align_BottomLeft);
        ammoLabel.scaleToHeight(36);
        ammoLabel.pinWidth(1.0, isFactor: true);
        ammoLabel.pin(UIPin.Pin_Left, offset: 36 + 8);
        ammoLabel.pin(UIPin.Pin_Bottom, UIPin.Pin_Top, offset: -17);
        ammoLabel.ignoresClipping = true;
        ammoLabel.multiline = false;
        ammoLayout.add(ammoLabel);
        ammoLayout.alpha = 0;

        ammoCountLabel = new("UILabel").init((0,0), (100, 25), "[69/420]", "SEL46FONT", textAlign: Align_BottomRight);
        ammoCountLabel.scaleToHeight(25);
        ammoCountLabel.pinWidth(UIView.Size_Min);
        ammoCountLabel.pin(UIPin.Pin_Right, offset: 0);
        ammoCountLabel.pin(UIPin.Pin_Bottom, UIPin.Pin_Top, offset: -17);
        ammoCountLabel.ignoresClipping = true;
        ammoCountLabel.multiline = false;
        ammoLayout.add(ammoCountLabel);

        if(!ammoAllowed) {
            let v = new("UIView").init((0,0), (290, 74));
            v.add(new("UIImage").init((5,5), (64,64), "AMMOLOCK"));

            let lab = new("UILabel").init((64 + 15, 5), (290 - 64 - 15, 64), String.Format(StringTable.Localize("$WORKSHOP_TIER_REQUIRED"), 2), 'SEL46FONT', textColor: 0xFF999999, textAlign: UIView.Align_Left | UIView.Align_Middle);
            lab.scaleToHeight(27);
            lab.fontScale.x -= 0.05;
            v.add(lab);
            ammoLayout.addManaged(v);
        }

        // Create stats views
        let norm = UIButtonState.Create(WeaponStationGFXPath .. "info1.png");
        let hover = UIButtonState.Create(WeaponStationGFXPath .. "info2.png");
        let down = UIButtonState.Create(WeaponStationGFXPath .. "info2.png");
        norm.blendColor = 0;
        hover.blendColor = 0;
        down.blendColor = 0x6622262E;


        // Create stats scroll window
        scrollConfig = UIScrollBarConfig.Create(
            14, 14,
            NineSlice.Create(WeaponStationGFXPath .. "scroll_bg.png", (8, 3), (10, 13)),
            null,
            UIButtonState.CreateSlices(WeaponStationGFXPath .. "scroll_normal.png", (8, 3), (10, 13)),
            UIButtonState.CreateSlices(WeaponStationGFXPath .. "scroll_hover.png", (8, 3), (10, 13)),
            UIButtonState.CreateSlices(WeaponStationGFXPath .. "scroll_normal.png",(8, 3), (10, 13)),
            insetA: 8,
            insetB: 8
        );

        statScroll = new("UIVerticalScroll").initFromConfig((0,0), (290, 400), scrollConfig);
        statScroll.autoHideScrollbar = true;
        statScroll.autoHideAdjustsSize = true;
        statScroll.pinWidth(290);
        statScroll.pinHeight(UIView.Size_Min);
        statScroll.pin(UIPin.Pin_Right);
        statScroll.pin(UIPin.Pin_Top);
        statScroll.scrollbar.ignoresClipping = true;
        statScroll.scrollbar.firstPin(UIPin.Pin_Right).offset = -2;
        statScroll.scrollbar.rejectHoverSelection = true;
        statScroll.rejectHoverSelection = true;
        statsLayout = UIVerticalLayout(statScroll.mLayout);
        add(statScroll);

        
        statsLayout.itemSpacing = 15;
        statsLayout.minSize.y = 190;
        statsLayout.ignoreHiddenViews = true;
        statsLayout.layoutMode = UIViewManager.Content_SizeParent;
        statsLayout.setPadding(25, 25, 25, 25);

        let statsBG = new("UIImage").init((0,0), (100, 100), "", NineSlice.Create(WeaponStationGFXPath .. "panel_background5.png", (16,16), (36, 36)));
        statsBG.pinToParent(-10, -10, 10, 10);
        statsBG.ignoresClipping = true;
        statScroll.add(statsBG);
        statScroll.moveToBack(statsBG);


        statsButton = new("UIButton").init(
            (0,0), (60, 59),
            "", null,
            norm,   // normal
            hover,  // hover
            down,   // pressed
            norm    // disabled
        );
        statsButton.pin(UIPin.Pin_Right);
        statsButton.pin(UIPin.Pin_Top);
        statsButton.alpha = 0;
        add(statsButton);

        // Scroll icon for gamepads
        gamepadScrollIcon = new("UIImage").init((0,0), (58, 78), "PDARTICO");
        gamepadScrollIcon.pin(UIPin.Pin_Top, offset: 70);
        gamepadScrollIcon.pin(UIPin.Pin_Right, UIPin.Pin_Left, offset: -20);
        gamepadScrollIcon.ignoresClipping = true;
        statScroll.add(gamepadScrollIcon);
        gamepadScrollIcon.hidden = true;

        // Add a button indicator for the info icon
        if(useController) {
            let statButtText = new("UILabel").init((0,0), (200, 40), String.Format("%c", UIHelper.ICON_PAD_Y + (isPlaystation ? 23 : 0)), "SEL46FONT", Font.CR_UNTRANSLATED, textAlign: UIView.Align_Right);
            statButtText.scaleToHeight(36);
            statButtText.ignoresClipping = true;
            statButtText.pin(UIPin.Pin_Right, UIPin.Pin_Left, offset: -10);
            statButtText.pin(UIPin.Pin_Bottom);
            statButtText.pinHeight(UIView.Size_Min);
            statButtText.pinWidth(100);
            statsButton.add(statButtText);
        }

        for(int x = 0; x < UpgradeStatView.Num_Stats; x++) {
            statLines[x] = new("WeaponStatLine").init();
            statsLayout.addManaged(statLines[x]);
        }

        showingStats = iGetCVar("workshop_show_stats") > 0;
        statScroll.alpha = 0;

        upgradePopup = new("UpgradeStatView").init();
        upgradePopup.hidden = true;
        add(upgradePopup);

        lastWorkshopPos = (-9999, -9999);


        return self;
    }

    

    override bool hasCompletedAnimation(WVAnimation anim) {
        if(lastAnimation && lastAnimation.checkValid(lastAnimation.getTime())) {
            return false;
        }
        return true;
    }

    override double animate(WVAnimation anim, double delay) {
        let animator = getAnimator();
        if(!animator) return 0;
        animator.clear(weaponScroll);

        switch(anim) {
            case Anim_In: {
                let animator = getAnimator();
                let time = getTime();

                animator.finish(weaponScroll, time + delay);
                animator.finish(altFireLayout, time + delay + 0.05);
                animator.finish(statsButton, time + delay + 0.15);
                animator.finish(statScroll, time + delay + 0.15);

                let anim = weaponScroll.animateFrame(
                    0.3,
                    fromPos: (-190, weaponScroll.frame.pos.y),
                    toPos: (0, weaponScroll.frame.pos.y),
                    fromAlpha: 0,
                    toAlpha: 1,
                    ease: Ease_Out
                );
                anim.startTime += delay;
                anim.endTime += delay;
                lastAnimation = anim;

                for(int x = 0; x < upgradeButtons.size(); x++) {
                    upgradeButtons[x].alpha = 0;

                    let toff = (x * 0.03);
                    let anim = upgradeButtons[x].animateFrame(
                        0.18,
                        fromAlpha: 0,
                        toAlpha: 1,
                        ease: Ease_Out
                    );
                    anim.startTime += delay + 0.1 + toff;
                    anim.endTime += delay + 0.1 + toff;
                }

                // Set the selected weapon
                weaponImage.alpha = 0;
                /*if(useController) {
                    for(int x = 0; x < upgradeButtons.size(); x++) {
                        if(upgradeButtons[x].isSelected()) {
                            buildWeapon(upgradeButtons[x].defaultWeapon, upgradeButtons[x].weapon, animDelay: delay + 0.23);
                            getMenu().navigateTo(upgradeButtons[x]);
                            weaponScroll.scrollTo(upgradeButtons[x], false, 136 / 2);
                            break;
                        }
                    }
                } else {
                    selectWeaponIndex(selectedWeapon);
                }*/
                selectWeaponIndex(selectedWeapon, scroll: true, animDelay: delay + 0.23);
                

                

                // Show stats
                if(showingStats) {
                    let anim = statScroll.animateFrame(
                        0.2,
                        fromPos: (frame.size.x + 50, statScroll.frame.pos.y),
                        toPos: (frame.size.x - statScroll.frame.size.x, statScroll.frame.pos.y),
                        toAlpha: 1,
                        ease: Ease_Out
                    );
                    anim.startTime += delay + 0.15;
                    anim.endTime += delay + 0.15;

                    // Move button as well
                    anim = statsButton.animateFrame(
                        0.2,
                        fromPos: (frame.size.x + 50 - 80, statsButton.frame.pos.y),
                        toPos: (frame.size.x - statScroll.frame.size.x - 80, statsButton.frame.pos.y),
                        toAlpha: 1,
                        ease: Ease_Out
                    );
                    anim.startTime += delay + 0.15;
                    anim.endTime += delay + 0.15;
                } else {
                    anim = statsButton.animateFrame(
                        0.2,
                        toAlpha: 1.0,
                        ease: Ease_Out
                    );
                    anim.startTime += delay + 0.15;
                    anim.endTime += delay + 0.15;
                }

                // Show secondary fire panel
                anim = altFireLayout.animateFrame(
                    0.2,
                    fromPos: (frame.size.x + 50, altFireLayout.frame.pos.y),
                    toPos: (frame.size.x - altFireLayout.frame.size.x, altFireLayout.frame.pos.y),
                    toAlpha: 1,
                    ease: Ease_Out
                );
                anim.startTime += delay + 0.05;
                anim.endTime += delay + 0.05;

                // Show ammo purchase panel
                anim = ammoLayout.animateFrame(
                    0.2,
                    fromPos: (frame.size.x + 50, ammoLayout.frame.pos.y),
                    toPos: (frame.size.x - ammoLayout.frame.size.x, ammoLayout.frame.pos.y),
                    toAlpha: 1,
                    ease: Ease_Out
                );
                anim.startTime += delay + 0.1;
                anim.endTime += delay + 0.1;
                
                return 0.3;
            }
            case Anim_Out: {
                let animator = getAnimator();
                let time = getTime();

                animator.finish(weaponScroll, time + delay);
                animator.finish(weaponImage, time + delay + 0.1);
                animator.finish(altFireLayout, time + delay + 0.05);
                animator.finish(statsButton, time + delay + 0.1);
                animator.finish(statScroll, time + delay + 0.1);

                let anim = weaponScroll.animateFrame(
                    0.18,
                    fromPos: weaponScroll.frame.pos,
                    toPos: (-190, weaponScroll.frame.pos.y),
                    toAlpha: 0,
                    ease: Ease_In
                );
                anim.startTime += delay;
                anim.endTime += delay;
                lastAnimation = anim;

                anim = weaponImage.animateFrame(
                    0.2,
                    toAlpha: 0,
                    ease: Ease_In
                );
                anim.startTime += delay + 0.1;
                anim.endTime += delay + 0.1;

                for(int x = 0; x < nodeButtons.size(); x++) {
                    animator.finish(nodeButtons[x], time + delay + 0.049);

                    anim = nodeButtons[x].animateFrame(
                        frandom(0.15, 0.2),
                        toAlpha: 0,
                        ease: Ease_Out
                    );
                    let dlay = frandom(0.05, 0.15) + delay;
                    anim.startTime += dlay;
                    anim.endTime += dlay;
                }


                // Hide stats
                if(showingStats) {
                    let anim = statScroll.animateFrame(
                        0.2,
                        toPos: (frame.size.x + 50, statScroll.frame.pos.y),
                        toAlpha: 0,
                        ease: Ease_In
                    );
                    anim.startTime += delay + 0.1;
                    anim.endTime += delay + 0.1;

                    anim = statsButton.animateFrame(
                        0.2,
                        toPos: (frame.size.x + 50 - 80, statsButton.frame.pos.y),
                        toAlpha: 0,
                        ease: Ease_In
                    );
                    anim.startTime += delay + 0.1;
                    anim.endTime += delay + 0.1;
                } else {
                    anim = statsButton.animateFrame(
                        0.2,
                        toAlpha: 0,
                        ease: Ease_In
                    );
                    anim.startTime += delay + 0.1;
                    anim.endTime += delay + 0.1;
                }

                // Hide alt fires
                anim = altFireLayout.animateFrame(
                    0.2,
                    toPos: (frame.size.x + 50, altFireLayout.frame.pos.y),
                    toAlpha: 0,
                    ease: Ease_In
                );
                anim.startTime += delay + 0.05;
                anim.endTime += delay + 0.05;

                // Hide ammo window
                anim = ammoLayout.animateFrame(
                    0.2,
                    toPos: (frame.size.x + 50, ammoLayout.frame.pos.y),
                    toAlpha: 0,
                    ease: Ease_In
                );
                anim.startTime += delay + 0.1;
                anim.endTime += delay + 0.1;

                upgradePopup.hidden = true;

                return 0.2;
            }
            default:
                lastAnimation = null;
                break;
        }

        return 0;
    }

    
    override void layoutSubviews() {
        let m = getMenu();
        if(m) {
            if(m.virtualScreenSize.x < 1900) {
                let wscale = min(1.0, m.virtualScreenSize.x / 2000.0);
                weaponImage.setScale((wscale, wscale));
            } else {
                if(m.virtualScreenSize.y < 1000) {
                    weaponImage.setScale((1,1) * (m.virtualScreenSize.y / 1080.0));
                } else {
                    weaponImage.setScale((1,1));
                }
            }
        }

        Super.layoutSubviews();

        layoutPanels();
    }

    // Move right-side panels to fit the vertical space
    // We will shrink the stats panel if there is not enough space for everything
    void layoutPanels() {
        // Only move things around if the default layout does not fit
        if( !ammoLayout.hidden && 
            (statScroll.frame.pos.y + statScroll.frame.size.y > ammoLayout.frame.pos.y - 80) || 
            (ammoLayout.frame.pos.y + ammoLayout.frame.size.y > altFireLayout.frame.pos.y - 80)
        ) {
            ammoLayout.frame.pos.y = altFireLayout.frame.pos.y - 80 - ammoLayout.frame.size.y;

            if(statScroll.frame.pos.y + statScroll.frame.size.y > ammoLayout.frame.pos.y - 80) {
                statScroll.maxSize.y =  ammoLayout.frame.pos.y - 80 - statScroll.frame.pos.y;
                statScroll.layout();
            }
        }

        // Add scroll icon for gamepads if necessary
        gamepadScrollIcon.hidden = !(useController && !statScroll.hidden && statScroll.contentsCanScroll());
    }

    
    void selectWeaponIndex(int index, bool scroll = false, double animDelay = 0) {
        selectedWeapon = index;

        for(int x = 0; x < upgradeButtons.size(); x++) {
            upgradeButtons[x].setSelected(upgradeButtons[index] == upgradeButtons[x]);
        }

        if(scroll) weaponScroll.scrollTo(upgradeButtons[index], true, 136 / 2);
        if(!useController) forwardControl.navLeft = upgradeButtons[index];

        buildWeapon(upgradeButtons[index].defaultWeapon, upgradeButtons[index].weapon, animDelay: animDelay);

        let menu = getMenu();
        if(useController && menu) {
            let btn = findNavigatableButtonByPos(lastWorkshopPos);
            if(btn) menu.navigateTo(btn);

            if(ticks < 5) {
                waitingForReveal = true;
            }
        }
    }


    void cycleWeapon(int dir) {
        // Find index of current weapon
        int curIndex = 0;
        for(int x = 0; x < upgradeButtons.size(); x++) {
            if(upgradeButtons[x].weapon == currentWeapon) {
                curIndex = x;
                break;
            }
        }

        curIndex = (curIndex + dir) % upgradeButtons.size();
        if(curIndex < 0) curIndex = upgradeButtons.size() + curIndex;

        /*for(int x = 0; x < upgradeButtons.size(); x++) {
            upgradeButtons[x].setSelected(upgradeButtons[curIndex] == upgradeButtons[x]);
        }

        forwardControl.navLeft = upgradeButtons[curIndex];
        buildWeapon(upgradeButtons[curIndex].defaultWeapon, upgradeButtons[curIndex].weapon);

        weaponScroll.scrollTo(upgradeButtons[curIndex], true, 136 / 2);*/
        selectWeaponIndex(curIndex, scroll: true);

        playSound("ui/ugmweaponsel", 0.75);
    }


    void loadStats(SelacoWeapon weapon, WeaponUpgrade upgrade = null) {
        for(int x = 0; x < UpgradeStatView.Num_Stats; x++) {
            statLines[x].setValues(weapon, upgrade, x);
        }
        
        //statsLayout.requiresLayout = true;
        statScroll.requiresLayout = true;
    }

    void loadDefaultStats(readonly<SelacoWeapon> defaultWeapon) {
        for(int x = 0; x < UpgradeStatView.Num_Stats; x++) {
            statLines[x].setDefaultValues(defaultWeapon, x);
        }
    }

    void buildWeapon(readonly<SelacoWeapon> defaultWeapon, SelacoWeapon weapon, bool animate = true, double animDelay = 0) {
        currentWeapon = weapon;
        currentDefaultWeapon = defaultWeapon;

        // Remove old nodes
        for(int x = 0; x < nodeButtons.size(); x++) nodeButtons[x].removeFromSuperview();
        nodeButtons.clear();

        // Set background image
        weaponImage.setImage(WeaponStationGFXPath .. defaultWeapon.imagePrefix);

        let wscale = 1.0;
        let m = getMenu();
        if(m) wscale = min(1.0, m.virtualScreenSize.x / 1920.0);

        // Add upgrade nodes
        Array< class<WeaponUpgrade> > upgrades;
        defaultWeapon.findUpgrades(upgrades);
        
        weaponImage.layout();

        double eachUGDelay = 0.27 / double(upgrades.size());
        for(int x = 0; x < upgrades.size(); x++) {
            UpgradeNodeButton b = new("UpgradeNodeButton").init(GetDefaultByType(upgrades[x]), weaponImage, x);
            nodeButtons.push(b);
            self.add(b);
            b.alpha = 0;
            b.setScale((wscale, wscale));
            b.animateIn(0.095 + animDelay + (x * eachUGDelay));
            b.layout();
        }

        // Create navigation order
        for(int x = 0; x < nodeButtons.size(); x++) {
            nodeButtons[x].navLeft = findNavigatableButton(nodeButtons[x], Left);
            nodeButtons[x].navUp = findNavigatableButton(nodeButtons[x], Up);
            nodeButtons[x].navDown = findNavigatableButton(nodeButtons[x], Down);
            nodeButtons[x].navRight = findNavigatableButton(nodeButtons[x], Right);
        }

        // Setup navigation back to left panel
        double minX = 9999999;
        for(int x = 0; x < nodeButtons.size(); x++) {
            readonly< WeaponUpgrade > upg = GetDefaultByType(nodeButtons[x].upgrade);
            if(upg.workshopPosX < minX && nodeButtons[x].navLeft == null) {
                minX = upg.workshopPosX;
                forwardControl.forwardSelection = nodeButtons[x];
                nodeButtons[x].navLeft = forwardControl.navLeft;
            }

            if(nodeButtons[x].navLeft == null) nodeButtons[x].navLeft = forwardControl.navLeft;
        }

        // Create ammo shop buttons
        if(ammoAllowed) {
            ammoLayout.clearManaged();
        }

        if(defaultWeapon.AmmoType1 is 'SelacoAmmo') {
            class<SelacoAmmo> ammo1 = (class<SelacoAmmo>)(defaultWeapon.AmmoType1);
            let inv = players[consolePlayer].mo.FindInventory(ammo1);
            int numAmmo = inv ? inv.amount : 0;
            int maxAmmo = inv ? inv.MaxAmount : GetDefaultByType(ammo1).MaxAmount;

            ammoLayout.hidden = false;
            ammoImage.setImage(TexMan.GetName(defaultWeapon.Icon));

            if(ammoAllowed) {
                if(GetDefaultByType(ammo1).shopPrice > 0 && maxAmmo > 0) {
                    let btn = new('UpgradeAmmoButton').init(ammo1, 0, useController);
                    ammoLayout.addManaged(btn);
                    let btn2 = new('UpgradeAmmoButton').init(ammo1, 1, useController);
                    ammoLayout.addManaged(btn2);

                    btn.navDown = btn2;
                    btn2.navUp = btn;
                }
            }

            ammoCount = numAmmo;
            ammoCountTotal = numAmmo;
            ammoCountMax = maxAmmo;
            ammoCountLabel.setText(maxAmmo > 0 ? String.Format("[%d/%d]", ammoCount, maxAmmo) : "");
        } else {
            ammoLayout.hidden = true;
        }

        // Create alt fire list
        Array<WeaponAltFire> altFires;
        Array< class<WeaponAltFire> > altFireClasses;
		defaultWeapon.findAltFires(altFireClasses);   // We only need this for the total count

        defaultWeapon.findOwnedAltFires(players[consolePlayer].mo, altFires);
        altFireLayout.clearManaged();
        altFireButtons.clear();

        for(int x = 0; x < altFires.size(); x++) {
            let afb = new("UpgradeAltFireButton").init(altFires[x]);
            
            if(x > 0) {
                let prevCon = UIControl(altFireLayout.getManaged(altFireLayout.numManaged() - 1));
                afb.navUp = prevCon;
                prevCon.navDown = afb;
            }

            altFireLayout.addManaged(afb);
            altFireButtons.push(afb);
        }

        secondaryFireLabel.setText( String.Format("\c[HI2]%s\c-", StringTable.Localize(defaultWeapon.altFireLabel)) .. (useController && altFires.size() > 1 ? String.Format("  %c", UIHelper.ICON_PAD_X + (isPlaystation ? 23 : 0)) : "") );
        
        // Add fake buttons to show missing alt fires
        for(int x = 0; x < altFireClasses.size(); x++) {
            bool found = false;
            for(int y = 0; y < altFires.size(); y++) {
                if(altFires[y] is altFireClasses[x]) {
                    found = true;
                    break;
                }
            }

            if(found || !GetDefaultByType(altFireClasses[x]).bWorkshopPreview) continue;
            
            let afb = new("UpgradeFakeAltFireButton").init(altFireClasses[x]);
            afb.setDisabled();

            altFireLayout.addManaged(afb);
        }

        altFireLayout.layout();
        altFireLayout.hidden = altFires.size() == 0 && altFireClasses.size() == 0;

        // Setup navigation left/up from alt fire list
        if(!useController) {
            if(altFireLayout.numManaged() > 0) {
                double maxX = -99999999;
                for(int x = 0; x < nodeButtons.size(); x++) {
                    readonly< WeaponUpgrade > upg = GetDefaultByType(nodeButtons[x].upgrade);
                    if(upg.workshopPosX > maxX && nodeButtons[x].navRight == null) {
                        maxX = upg.workshopPosX;
                        for(int y = 0; y < altFireLayout.numManaged(); y++) {
                            UIControl(altFireLayout.getManaged(y)).navLeft = nodeButtons[x];
                        }
                        if(ammoAllowed) {
                            for(int y = 0; y < ammoLayout.numManaged(); y++) {
                                UIControl(ammoLayout.getManaged(y)).navLeft = nodeButtons[x];
                            }
                        }
                        nodeButtons[x].navRight = UIControl(altFireLayout.getManaged(0));
                    }

                    if(nodeButtons[x].navRight == null) nodeButtons[x].navRight = UIControl(altFireLayout.getManaged(0));
                }
            }
        }

        // Navigate between alt-fires and ammo shop
        if(altFireLayout.numManaged() > 0 && ammoAllowed && ammoLayout.numManaged()) {
            UIControl(altFireLayout.getManaged(0)).navUp = UIControl(ammoLayout.getManaged(ammoLayout.numManaged() - 1));
            let uc = UIControl(ammoLayout.getManaged(ammoLayout.numManaged() - 1));
            if(uc) uc.navDown = UIControl(altFireLayout.getManaged(0));
        }

        // Animate appearance
        let animator = getAnimator();
        if(animate && animator) {
            animator.clear(infoLayout);
            infoLayout.alpha = 0;

            let anim = weaponImage.animateFrame(
                0.18,
                fromAlpha: 0,
                toAlpha: 1,
                ease: Ease_Out
            );
            anim.startTime += animDelay;
            anim.endTime += animDelay;

            let anim2 = weaponImage.animateImage(
                0.18,
                fromScale: (1.1, 1.1),
                toScale: (1.0, 1.0),
                ease: Ease_Out
            );
            anim2.startTime += animDelay;
            anim2.endTime += animDelay;
            anim2.layoutEveryFrame = true;
            weaponImage.startAnim(animDelay);
        }

        statScroll.maxSize.y = 999999;

        if(currentWeapon) loadStats(currentWeapon);
        else loadDefaultStats(defaultWeapon);
        statScroll.layout();


        if(!ammoLayout.hidden) ammoLayout.layout();
        layoutPanels();
    }


    enum ButtonDir { Left = 0, Up, Right, Down }
    UpgradeNodeButton findNavigatableButton(UpgradeNodeButton source, ButtonDir dir) {
        UpgradeNodeButton candidate;
        double candidateScore = 0;
        readonly< WeaponUpgrade > upg = GetDefaultByType(source.upgrade);
        Vector2 center = upg.workshopPosX != 999999 ? (upg.workshopPosX, upg.workshopPosY) : (source.frame.pos + (source.frame.size / 2.0));

        for(int y = 0; y < nodeButtons.size(); y++) {
            UpgradeNodeButton can = nodeButtons[y];            
            readonly< WeaponUpgrade > upg2 = GetDefaultByType(can.upgrade);
            Vector2 canCenter = upg2.workshopPosX != 999999 ? (upg2.workshopPosX, upg2.workshopPosY) : (can.frame.pos + (can.frame.size / 2.0));
            Vector2 diff = canCenter - center;

            if(can == source) continue;

            double score = 99999999;

            switch(dir) {
                case Left:
                    if(diff.x > 0 || abs(diff.x) < source.frame.size.x / 2.0) continue;
                    score = abs(diff.x) + (MAX(0, abs(diff.y) - (source.frame.size.y * 2)) * 10);
                    break;
                case Right:
                    if(diff.x < 0 || abs(diff.x) < source.frame.size.x / 2.0) continue;
                    score = abs(diff.x) + (MAX(0, abs(diff.y) - (source.frame.size.y * 2)) * 10);
                    break;
                case Up:
                    if(diff.y > 0 || abs(diff.y) < source.frame.size.y / 2.0) continue;
                    score = abs(diff.y) + (MAX(0, abs(diff.x) - (source.frame.size.x * 2)) * 10);
                    break;
                case Down:
                    if(diff.y < 0 || abs(diff.y) < source.frame.size.y / 2.0) continue;
                    score = abs(diff.y) + (MAX(0, abs(diff.x) - (source.frame.size.x * 2)) * 10);
                    break;
            }

            if(score < candidateScore || candidate == null) {
                candidate = can;
                candidateScore = score;
            }
        }

        return candidate;
    }

    // Note: Pos is an workshopPos, not a screen pos
    UpgradeNodeButton findNavigatableButtonByPos(Vector2 pos = (0,0)) {
        UpgradeNodeButton candidate;
        double candidateScore = 0;
        Vector2 center = pos;

        for(int y = 0; y < nodeButtons.size(); y++) {
            UpgradeNodeButton can = nodeButtons[y];            
            readonly< WeaponUpgrade > upg2 = GetDefaultByType(can.upgrade);
            Vector2 canCenter = upg2.workshopPosX != 999999 ? (upg2.workshopPosX, upg2.workshopPosY) : (can.frame.pos + (can.frame.size / 2.0));
            Vector2 diff = canCenter - center;

            double score = diff.length();

            if(score < candidateScore || candidate == null) {
                candidate = can;
                candidateScore = score;
            }
        }

        return candidate;
    }


    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        if(ctrl is 'UpgradeButton' && event == UIHandler.Event_Activated) {
            int weaponIndex = 0;
            let b = UpgradeButton(ctrl);
            if(currentWeapon == b.weapon && currentDefaultWeapon == b.defaultWeapon) return true;

            for(int x = 0; x < upgradeButtons.size(); x++) {
                if(upgradeButtons[x] == ctrl) weaponIndex = x;
                upgradeButtons[x].setSelected(ctrl == upgradeButtons[x]);
            }

            selectWeaponIndex(weaponIndex, scroll: !fromMouse);

            playSound("ui/ugmweaponsel", 0.75);
            return true;
        } else if(ctrl is 'UpgradeButton' && event == UIHandler.Event_Selected) {
            playSound("ui/ugmhover2");

            return true;
        } else if(ctrl is 'UpgradeNodeButton' && event == UIHandler.Event_Selected) {
            let btn = UpgradeNodeButton(ctrl);
            
            if(ticks > 30) showInfo(btn);

            playSound("ui/ugmhover1");

            return true;
        } else if((ctrl is 'UpgradeNodeButton' || ctrl is 'UpgradeAltFireButton') && event == UIHandler.Event_Deselected) {
            let animator = getAnimator();
            if(animator) {
                animator.clear(infoLayout);
                infoLayout.animateFrame(
                    3,
                    toAlpha: 0,
                    ease: Ease_In
                );
            }
            upgradePopup.hidden = true;
            return true;
        } else if(ctrl is 'UpgradeNodeButton' && event == UIHandler.Event_Activated) {
            // TODO: Check if owned. If owned toggle the upgrade on/off instead of buying it
            buyButton = UpgradeNodeButton(ctrl);
            readonly< WeaponUpgrade > upgrade = GetDefaultByType(buyButton.upgrade);
            WeaponUpgrade ug = WeaponUpgrade(players[consolePlayer].mo.FindInventory(upgrade.getClassName()));

            if(ug) {
                bool newState = !ug.isEnabled();
                
                // Toggle
                EventHandler.SendNetworkEvent("upg:" .. ug.getClassName(), newState);

                // Set button to correct state
                buyButton.setUpgradeEnabled(newState, ug.Amount > 0);
                showInfo(buyButton, false);
                reloadTicks = 2;
                buyButton = null;

                // Play sound if we equipped or unequipped
                if(newState) playSound("ui/ugmbuyammo");
                else playSound("ui/ugmdialogc");

                return true;
            }

            // Make sure we have prerequisites
            if( players[consolePlayer].mo.countInv("weaponParts") < upgrade.cost ||
                players[consolePlayer].mo.countInv("creditsCount") < upgrade.creditsCost ||
                players[consolePlayer].mo.countInv("WorkshopTierItem") < upgrade.requiredSaferooms
            ) {
                playSound("ui/buy/error");
                return true;
            }

            playSound("ui/ugmdialogo");

            // TODO: Fancy purchase menu
            let desc = StringTable.Localize(upgrade.upgradeDescription);
            desc.stripRight();

            let m = new("PromptMenu").initNew(
                getMenu(), 
                "PURCHASE UPGRADE", 
                String.Format("%s\n\n\cc%s\n\nBuy for %d Weapon Parts?", StringTable.Localize(upgrade.upgradenameShort), desc, upgrade.cost),
                "$CANCEL_BUTTON", 
                "Buy", 
                defaultSelection: 0,
                image: WeaponStationGFXPath .. "upgradeBackground.png"
            );
            
            if(m.imageView) {
                let iv = new("UIImage").init((0,0), (0,0), upgrade.upgradeImage);
                iv.pinWidth(UIView.Size_Min);
                iv.pinHeight(UIView.Size_Min);
                iv.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
                iv.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
                iv.imgScale = (0.9, 0.9);
                m.imageView.blendColor = 0x44000000;
                m.imageView.add(iv);
            }

            if(fromMouse) {
                upgradePopup.hidden = true;
                getMenu().clearNavigation();
            }

            m.mainBG.frame.size.x = 600;
            m.ActivateMenu();

            return true;
        } else if(ctrl == statsButton && event == UIHandler.Event_Activated) {
            showStats(!showingStats);
            iSetCVar("workshop_show_stats", showingStats ? 1 : 0);
            playSound("ui/choose2");
            return true;
        } else if(ctrl is 'UpgradeAltFireButton' && event == UIHandler.Event_Activated) {
             // TODO: Check if owned. If owned toggle the upgrade on/off instead of buying it
            UpgradeAltFireButton btn = UpgradeAltFireButton(ctrl);

            if(btn.altFire.isEnabled()) {
                playSound("ui/buy/error");
                return true;
            }

            playSound("ui/ugmAltOpn");

            // Toggle
            EventHandler.SendNetworkEvent("alf:" .. btn.altFire.getClassName(), 1);
            reloadTicks = 2;
            buyButton = null;

            for(int x = 0; x < altFireLayout.numManaged(); x++) {
                let b = UpgradeAltFireButton(altFireLayout.getManaged(x));
                if(b) b.setSelected(b == btn);
            }

            return true;
        } else if(ctrl is 'UpgradeAltFireButton' && event == UIHandler.Event_Selected) {
            let btn = UpgradeAltFireButton(ctrl);

            showAltFireInfo(btn.altFire);
        } else if(ctrl is 'UpgradeAmmoButton' && event == UIHandler.Event_Activated) {
            let btn = UpgradeAmmoButton(ctrl);

            // Buy ammo
            EventHandler.SendNetworkEvent((btn.type == 0 ? "ammo1:" : "ammo2:") .. btn.ammo1.getClassName(), 0);

            // Play sound
            playSound("ui/ugmbuyammo");

            // Update Buttons
            for(int x = 0; x < ammoLayout.numManaged(); x++) {
                let b = UpgradeAmmoButton(ammoLayout.getManaged(x));
                if(b) {
                    b.needsUpdate = 2;
                }
            }

            ammoUpdate = 2;
            // Make a little effect appear
            let show = new('AmmoShowyOffyThing').init(ammoCountLabel.frame.pos - (0, 25), (100, 25), String.Format("+%d", btn.ammoAmount), 'SEL46FONT', textAlign: UIView.Align_BottomLeft);
            show.scaleToHeight(25);
            show.ignoresClipping = true;
            show.alpha = 0.75;
            ammoCountLabel.parent.add(show);

            return true;
        }

        return Super.handleSubControl(ctrl, event, fromMouse, fromController);
    }

    void showInfo(UpgradeNodeButton btn, bool animated = true) {
        let plr = players[consolePlayer].mo;

        let animator = getAnimator();
        if(animator) animator.clear(infoLayout);
        readonly< WeaponUpgrade > upgrade = GetDefaultByType(btn.upgrade);
        modTitleLabel.setText(StringTable.Localize(upgrade.upgradeNameShort));
        let desc = StringTable.Localize(upgrade.upgradeDescription);
        desc.stripRight();
        modDescriptionLabel.setText(desc);
        infoLayout.setAlpha(1);
        if(animated) modDescriptionLabel.start(400);
        else modDescriptionLabel.end();

        if(upgrade.workshopPosX < 9999) lastWorkshopPos = (upgrade.workshopPosX, upgrade.workshopPosY);
        else lastWorkshopPos = (-99999, -99999);

        if(btn.iHaveIt) {
            moduleLayout.hidden = true;
            installedImage.hidden = false;
            creditsCostView.hidden = true;
            partsCostView.hidden = true;
            roomsCostView.hidden = true;
            installedImage.label.setText(btn.upgradeEnabled ? "INSTALLED" : "NOT INSTALLED");
            installedImage.setAlpha(btn.upgradeEnabled ? 1 : 0.5);
        } else {
            moduleLayout.hidden = plr.countInv("WorkshopTierItem") >= upgrade.requiredSaferooms;
            if(!moduleLayout.hidden) {
                moduleLabel2.setText(String.Format("%s %d", StringTable.Localize("$WORKSHOP_MODULES2"), upgrade.requiredSaferooms));
            }
            installedImage.hidden = true;
            creditsCostView.setValue(upgrade.creditsCost, animated: false);
            creditsCostView.setValid(upgrade.creditsCost <= players[consolePlayer].mo.countInv("creditsCount"));
            creditsCostView.hidden = upgrade.creditsCost <= 0;
            partsCostView.setValue(upgrade.cost, animated: false);
            partsCostView.hidden = upgrade.cost <= 0;
            partsCostView.setValid(upgrade.cost <= players[consolePlayer].mo.countInv("weaponParts"));
            //roomsCostView.setValue(upgrade.requiredSaferooms, animated: false);
            //roomsCostView.hidden = false;
            //roomsCostView.setValid(upgrade.requiredSaferooms <= players[consolePlayer].mo.countInv("WorkshopTierItem"));
        }

        infoLayout.layout();

        moveToFront(upgradePopup);
        upgradePopup.hidden = false;
        upgradePopup.configure(upgrade, currentWeapon);
        upgradePopup.layout();

        // Show pop up on the opposite side of the pointer
        bool right = upgrade.workshopPointerPosX - upgrade.workshopPosX >= 0;
        bool top = upgrade.workshopPointerPosY - upgrade.workshopPosY >= 0;
        upgradePopup.frame.pos = btn.frame.pos + (right ? btn.frame.size.x + 10 : -(upgradePopup.frame.size.x + 10), top ? 0 : btn.frame.size.y - upgradePopup.frame.size.y);
    }


    void showAltFireInfo(WeaponAltFire altFire) {
        let animator = getAnimator();
        if(animator) animator.clear(infoLayout);

        
        modTitleLabel.setText(StringTable.Localize(altFire.upgradeNameShort));
        modDescriptionLabel.setText(StringTable.Localize(altFire.upgradeDescription));
        infoLayout.setAlpha(1);
        modDescriptionLabel.start(400);

        moduleLayout.hidden = true;
        installedImage.hidden = true;
        creditsCostView.hidden = true;
        partsCostView.hidden = true;
        roomsCostView.hidden = true;
    }


    void showStats(bool show) {
        if(showingStats && !show) {
            let anim = statScroll.animateFrame(
                0.2,
                toPos: (frame.size.x + 50, statScroll.frame.pos.y),
                toAlpha: 0,
                ease: Ease_In
            );

            anim = statsButton.animateFrame(
                0.2,
                toPos: (frame.size.x - statsButton.frame.size.x, statsButton.frame.pos.y),
                ease: Ease_In
            );
        } else if(!showingStats && show) {
            let anim = statScroll.animateFrame(
                0.2,
                fromPos: statScroll.alpha ~== 0 ? (frame.size.x + 50, statScroll.frame.pos.y) : statScroll.frame.pos,
                toPos: (frame.size.x - statScroll.frame.size.x, statScroll.frame.pos.y),
                toAlpha: 1,
                ease: Ease_Out
            );

            anim = statsButton.animateFrame(
                0.2,
                toPos: (frame.size.x - statScroll.frame.size.x - 80, statsButton.frame.pos.y),
                ease: Ease_Out
            );
        }

        showingStats = show;
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
		switch (mkey) {
            case Menu.MKEY_Clear:
                // Move to next alt fire if available
                if(altFireButtons.size() > 1) {
                    for(int x = 0; x < altFireButtons.size(); x++) {
                        if(altFireButtons[x].isSelected()) {
                            // Select the next button
                            altFireButtons[x < altFireButtons.size() - 1 ? x + 1 : 0].sendEvent(UIHandler.Event_Activated, false, fromController);
                            showAltFireInfo(altFireButtons[x < altFireButtons.size() - 1 ? x + 1 : 0].altFire);
                            break;
                        }
                    }
                }
                break;
            case Menu.MKEY_Abort:
                // Toggle info pane
                showStats(!showingStats);
                iSetCVar("workshop_show_stats", showingStats ? 1 : 0);
                break;
            case Menu.MKEY_PageUp:
                cycleWeapon(-1);
                return true;
			case Menu.MKEY_PageDown:
                cycleWeapon(1);
                return true;
			default:
                if(mkey >= Menu.MKEY_MBYes) {
                    // We received a response from a prompt
                    int res = mkey - Menu.MKEY_MBYes;
                    if(res == 1 && buyButton) {
                        // Purchase the upgrade
                        EventHandler.SendNetworkEvent("buy:" .. buyButton.upgrade.getClassName());
                        playSound("ui/ugmbuyupgrade");
                        ammoUpdate = 2;
                    } else {
                        buyButton = null;
                    }
                    return true;
                }
				break;
		}

		return Super.MenuEvent(mkey, fromcontroller);
	}


    override bool OnInputEvent(InputEvent ev) {
        if(ev.type == InputEvent.Type_KeyDown) {
            switch(ev.KeyScan) {
                case InputEvent.Key_Pad_LTrigger:
                    if(ammoAllowed && ammoLayout.numManaged() > 0 && !UIControl(ammoLayout.getManaged(0)).isDisabled()) {
                        let btn = UIButton(ammoLayout.getManaged(0));
                        if(btn) btn.onActivate(false, true);
                    }
                    return true;
                case InputEvent.Key_Pad_RTrigger:
                    if(ammoAllowed && ammoLayout.numManaged() > 0 && !UIControl(ammoLayout.getManaged(1)).isDisabled()) {
                        let btn = UIButton(ammoLayout.getManaged(1));
                        if(btn) btn.onActivate(false, true);
                    }
                    return true;
                default:
                    break;
            }
        }

        return false;
    }


    override void tick() {
        Super.tick();

        if(reloadTicks) {
            reloadTicks--;

            if(reloadTicks == 0) {
                if(currentWeapon) loadStats(currentWeapon);
                else loadDefaultStats(currentDefaultWeapon);
            }
        }

        // Update ammo counter
        bool updateAmmoCount = false;
        if(ammoCount < ammoCountTotal) {
            ammoCount += max(1, (ammoCountTotal - ammoCount) / 2);
            updateAmmoCount = true;
        } else if(ammoCount > ammoCountTotal) { 
            ammoCount = ammoCountTotal;
        }

        if(--ammoUpdate == 0 && currentDefaultWeapon && currentDefaultWeapon.AmmoType1 is 'SelacoAmmo') {
            class<SelacoAmmo> ammo1 = (class<SelacoAmmo>)(currentDefaultWeapon.AmmoType1);
            let inv = players[consolePlayer].mo.FindInventory(ammo1);
            int numAmmo = inv ? inv.amount : 0;
            int maxAmmo = inv ? inv.MaxAmount : GetDefaultByType(ammo1).MaxAmount;
            int oldAT = ammoCountTotal;
            int oldMax = ammoCountMax;
            ammoCountTotal = numAmmo;
            ammoCountMax = maxAmmo;
            updateAmmoCount = true;

            // Animate label
            if(ammoCountTotal != oldAT || ammoCountMax != oldMax) {
                double scale1 = ammoCountLabel.getScaleForHeight(30);
                double scale2 = ammoCountLabel.getScaleForHeight(25);
                ammoCountLabel.animateLabel(
                    0.3,
                    fromScale: (scale1, scale1),
                    toScale: (scale2, scale2),
                    ease: Ease_Out
                );
            }
        }

        if(updateAmmoCount) {
            ammoCountLabel.setText(String.Format("[%d/%d]", ammoCount, ammoCountMax));
        }

        // We are waiting on this value to clear, or the item to be purchased
        if(buyButton) {
            readonly< WeaponUpgrade > upgrade = GetDefaultByType(buyButton.upgrade);
            WeaponUpgrade ug = WeaponUpgrade(players[consolePlayer].mo.FindInventory(upgrade.getClassName()));

            // The item is now in our inventory, so reset the button
            if(ug && ug.Amount > 0) {
                buyButton.refresh();
                
                if(getMenu().activeControl == buyButton) {
                    showInfo(buyButton, false);
                }
                
                if(currentWeapon) loadStats(currentWeapon);
                else loadDefaultStats(currentDefaultWeapon);

                // Update all other buttons in case our money or availability situation has changed
                for(int x = 0; x < nodeButtons.size(); x++) {
                    if(nodeButtons[x] == buyButton) continue;
                    nodeButtons[x].refresh();
                }

                buyButton = null;
            }
        }

        // Scroll with gamepad
        if(statScroll.contentsCanScroll() && showingStats) {
            let v = SelacoGamepadMenu(getMenu()).getGamepadRawLook();
            if(abs(v.y) > 0.1) {
                statScroll.scrollByPixels((v.y * CommonUI.STANDARD_SCROLL_AMOUNT), true, false, false);
            }
        }

        // Check for initial reveal to show info for the selected upgrade
        if(ticks > 5 && waitingForReveal && weaponImage.revealValue() >= 0.9) {
            waitingForReveal = false;

            let ctrl = UpgradeNodeButton(getMenu().activeControl);
            if(ctrl) {
                showInfo(ctrl);
            }
        }

        ticks++;
    }
}


class AmmoShowyOffyThing : UILabel {
    override void tick() {
        Super.tick();

        frame.pos.y -= 2;
        alpha -= 0.05;
        cAlpha = alpha;

        if(alpha <= 0) {
            removeFromSuperview();
            Destroy();
            return;
        }
    }
}