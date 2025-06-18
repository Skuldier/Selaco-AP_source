const WeaponStationGFXPath = "graphics/upgrade_menu/";

#include "ZScripts/UI/weaponstation/resource_view.zs"
#include "ZScripts/UI/weaponstation/upgrades.zs"
#include "ZScripts/UI/weaponstation/fast_travel.zs"

class WorkshopMenu : SelacoGamepadMenuInGame {
    enum TabID {
        Upgrades_Tab = 0,
        //Travel_Tab,
        //Mutator_Tab,
        Num_Tabs
    };

    UIHorizontalLayout tabLayout;
    UIImage footerImage, logoImage;
    UIScrollBG scrollBG;
    UIView mainViewContainer, viewContainer, tabTopView;
    WeaponStationTab tabs[Num_Tabs];
    WorkshopView views[Num_Tabs];
    ResourceView creditsView, partsView, saferoomsView;
    UIHorizontalLayout resourceLayout;
    TabID currentTab;
    int currentView;

    UILabel warningText;

    bool closing, preload, useController;
    double closeTime;

    override void init(Menu parent) {
		Super.init(parent);

        ReceiveAllInputEvents = true;
        menuActive = Menu.OnNoPause;

        useController = isUsingController() || isUsingGamepad();

        scrollBG = new("UIScrollBG").init("graphics/pda/grid1.png", NineSlice.Create("graphics/upgrade_menu/background.png", (70, 70), (572, 343)));
        scrollBG.pinToParent();
        mainView.add(scrollBG);

        tabTopView = new("UIView").init((0,0), (999, 150));
        tabTopView.pin(UIPin.Pin_Left);
        tabTopView.pin(UIPin.Pin_Right);
        tabTopView.pin(UIPin.Pin_Top);
        tabTopView.alpha = 0;
        mainView.add(tabTopView);

        let tabBackground = new("UIImage").init((0,0), (100, 100), "graphics/upgrade_menu/header.png");
        tabBackground.pinToParent();
        tabTopView.add(tabBackground);

        tabLayout = new("UIHorizontalLayout").init((0,0), (100, 150));
        tabLayout.pinHeight(150);
        tabLayout.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        tabLayout.pinWidth(1.0, isFactor: true);
        tabLayout.maxSize = (1920, 150);
        tabLayout.padding.left = 48;
        tabTopView.add(tabLayout);

        footerImage = new("UIImage").init((0,0), (100, 50), "", NineSlice.Create("graphics/upgrade_menu/footer.png", (40, 40), (125, 42)));
        footerImage.pin(UIPin.Pin_Left);
        footerImage.pin(UIPin.Pin_Right);
        footerImage.pin(UIPin.Pin_Bottom);
        footerImage.alpha = 0;
        mainView.add(footerImage);

        // Show controller LEFT icon
        /*if(useController) {
            let leftText = new("UILabel").init((0,0), (200, 40), String.Format("%c  ", 0x86), "SEL46FONT", Font.CR_UNTRANSLATED, textAlign: UIView.Align_Right | UIView.Align_Middle);
            leftText.pinHeight(1.0, isFactor: true);
            leftText.pinWidth(UIView.Size_Min);
            tabLayout.addManaged(leftText);
        }*/

        // Create tab buttons
        tabs[Upgrades_Tab] = new("WeaponStationTab").init("Weapon Upgrades");
        tabLayout.addManaged(tabs[Upgrades_Tab]);

        /*tabs[Travel_Tab] = new("WeaponStationTab").init("Fast Travel");
        tabs[Travel_Tab].setDisabled();
        tabLayout.addManaged(tabs[Travel_Tab]);

        tabs[Mutator_Tab] = new("WeaponStationTab").init("Mutators");
        tabs[Mutator_Tab].setDisabled();
        tabLayout.addManaged(tabs[Mutator_Tab]);*/

        tabs[Upgrades_Tab].setSelected(true, false);
        currentTab = Upgrades_Tab;

        /*if(useController) {
            let rightText = new("UILabel").init((0,0), (200, 40), String.Format("  %c", 0x87), "SEL46FONT", Font.CR_UNTRANSLATED, textAlign: UIView.Align_Right | UIView.Align_Middle);
            rightText.pinHeight(1.0, isFactor: true);
            rightText.pinWidth(UIView.Size_Min);
            tabLayout.addManaged(rightText);
        }*/

        // Create resource views
        creditsView = new("ResourceView").init(players[consolePlayer].mo.countInv("creditscount"), WeaponStationGFXPath .. "resourceSelver.png", 0xFFFAD364, rightAligned: true);
        creditsView.minSize.x = 125;
        creditsView.pinWidth(UIView.Size_Min);
        partsView = new("ResourceView").init(players[consolePlayer].mo.countInv("weaponparts"), WeaponStationGFXPath .. "resourceWeaponParts.png", rightAligned: true);
        partsView.minSize.x = 125;
        partsView.pinWidth(UIView.Size_Min);
        saferoomsView = new("ResourceView").init(players[consolePlayer].mo.countInv("WorkshopTierItem"), WeaponStationGFXPath .. "resourceSaferoom.png", rightAligned: true);
        saferoomsView.minSize.x = 86;
        saferoomsView.pinWidth(UIView.Size_Min);

        resourceLayout = new("UIHorizontalLayout").init((0,0), (300, 41));
        resourceLayout.pin(UIPin.Pin_Right, offset: -130);
        resourceLayout.pin(UIPin.Pin_Top, offset: 60);
        resourceLayout.pinHeight(ResourceView.FIXED_HEIGHT);
        resourceLayout.layoutMode = UIViewManager.Content_SizeParent;
        resourceLayout.itemSpacing = 15;
        resourceLayout.addManaged(creditsView);
        resourceLayout.addManaged(partsView);
        resourceLayout.addManaged(saferoomsView);
        tabLayout.add(resourceLayout);

        // Setup logo for intro animation
        logoImage = new("WorkshopLogo").init((0,0), (495, 433), "graphics/upgrade_menu/logo.png");
        logoImage.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        logoImage.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        mainView.add(logoImage);

        mainViewContainer = new("UIView").init((0,0), (1,1));
        mainViewContainer.pinToParent(50, 118 + 25, -50, -(40 + 25));
        mainViewContainer.clipsSubviews = false;
        mainView.add(mainViewContainer);

        viewContainer = new("UIView").init((0,0), (1,1));
        //viewContainer.pinToParent(50, 118 + 25, -50, -(40 + 25));
        viewContainer.pin(UIPin.Pin_Top);
        viewContainer.pin(UIPin.Pin_Bottom);
        viewContainer.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        viewContainer.pinWidth(1.0, isFactor: true);
        viewContainer.maxSize = (1820, 99999);
        viewContainer.clipsSubviews = false;
        mainViewContainer.add(viewContainer);

        // Create initial view
        views[Upgrades_Tab] = new("WorkshopUpgradeView").init(useController);
        //views[Travel_Tab] = new("FastTravelView").init();
        //views[Mutator_Tab] = new("WorkshopUpgradeView").init(useController);

        // Add temporary warning for demo
        warningText = new("UILabel").init((0,0), (100, 40), "*Upgrades do not necessarily represent the final game.", "PDA16FONT", textColor: 0xFF35536C);
        warningText.pinHeight(UIView.Size_Min);
        warningText.pinWidth(UIView.Size_Min);
        warningText.pin(UIPin.Pin_VCenter, value: 1.0, offset: 5, isFactor: true);
        warningText.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        footerImage.add(warningText);

        // Play opening sound
        MenuSound("ui/ugmopen");
    }

    override bool onBack() {
        if(!closing && ticks > 35) {
            animateClose();
        }

        return true;    // Cancel back/close commands
    }

    override void onFirstTick() {
        Super.onFirstTick();
        mainView.layoutIfNecessary();

        // Animate logo
        let anim = logoImage.animateFrame(
            0.3,
            fromSize: (495, 433),
            toSize: (495, 433) * 3,
            fromAlpha: 1,
            toAlpha: 0,
            ease: Ease_In
        );
        anim.layoutEveryFrame = true;
        anim.startTime += 0.55;
        anim.endTime += 0.55;

        // Animate tabs and footer
        anim = tabTopView.animateFrame(
            0.2,
            fromPos: tabTopView.frame.pos - (0, 100),
            toPos: tabTopView.frame.pos,
            fromAlpha: 0,
            toAlpha: 1.0,
            ease: Ease_Out
        );
        //anim.layoutEveryFrame = true;
        anim.startTime += 0.4;
        anim.endTime += 0.4;

        anim = footerImage.animateFrame(
            0.18,
            fromPos: footerImage.frame.pos + (0, 50),
            toPos: footerImage.frame.pos,
            fromAlpha: 0,
            toAlpha: 1.0,
            ease: Ease_Out
        );
        anim.startTime += 0.4;
        anim.endTime += 0.4;

        
        viewContainer.add(views[Upgrades_Tab]);
        viewContainer.layout();
        views[currentView].animate(WorkshopView.Anim_In, 0.55);
    }

    void animateClose() {
        double time = views[currentTab].animate(WorkshopView.Anim_Out, 0) * 0.8;

        // Animate tabs and footer
        let anim = tabTopView.animateFrame(
            0.2,
            toPos: tabTopView.frame.pos - (0, 100),
            toAlpha: 0.0,
            ease: Ease_In
        );
        anim.startTime += time;
        anim.endTime += time;

        anim = footerImage.animateFrame(
            0.18,
            toPos: footerImage.frame.pos + (0, 50),
            toAlpha: 0.0,
            ease: Ease_In
        );
        anim.startTime += time;
        anim.endTime += time;

        anim = mainView.animateFrame(
            0.2,
            toAlpha: 0.25,
            ease: Ease_In
        );
        anim.startTime += time;
        anim.endTime += time;

        closing = true;
        closeTime = getTime() + time + 0.2;

        MenuSound("ui/ugmdialogc");
    }

    override void ticker() {
        Super.ticker();
        Animated = true;

        // Check for change in resources
        int deltaCredits = creditsView.value;
        int deltaParts = partsView.value;
        int newCredits = players[consolePlayer].mo.countInv("creditscount");
        int newParts = players[consolePlayer].mo.countInv("weaponparts");

        if(newCredits != deltaCredits) creditsView.setValue(newCredits);
        if(newParts != deltaParts) partsView.setValue(newParts);

        if(closing && getTime() - closeTime >= 0) {
            close();
            EventHandler.SendNetworkEvent("WorkshopClosed");
        }
    }

    override void closeOnDeath() {
        Super.closeOnDeath();
        EventHandler.SendNetworkEvent("WorkshopClosed");
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(closing) return;

        if(event == UIHandler.Event_Activated) {
            for(int x = 0; x < Num_Tabs; x++) {
                if(ctrl == tabs[x]) {
                    switchTab(x);
                    return;
                }
            }
        }

        Super.handleControl(ctrl, event, fromMouseEvent);
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(closing) return true;

		switch (mkey) {
			/*case MKEY_PageUp:
                if(currentTab > 0) moveTabs(-1);
                return true;
			case MKEY_PageDown:
                if(currentTab < Num_Tabs - 1) moveTabs(1);
                return true;*/
			default:
				break;
		}

        if(views[currentTab] && views[currentTab].MenuEvent(mkey, fromcontroller)) {
            return true;
        }

		return Super.MenuEvent(mkey, fromcontroller);
	}

    override bool OnInputEvent(InputEvent ev) {
        if(closing) return true;

        if(ev.type == InputEvent.Type_KeyDown) {
            switch(ev.KeyScan) {
                case InputEvent.Key_Pad_Y:
                    return MenuEvent(MKEY_Abort, true); // TODO: Remove this, just interpret this key in the submenus
                default:
                    break;
            }
        }

        if(views[currentTab] && views[currentTab].OnInputEvent(ev)) {
            return true;
        }

        return Super.OnInputEvent(ev);
    }

    void moveTabs(int offset) {
        offset = clamp(offset, -1, 1);
        if(offset == 0) return;

        for(int x = 0; x < Num_Tabs; x++) {
            int newTabIndex = (currentTab + offset) % Num_Tabs;
            while(newTabIndex < 0) newTabIndex = Num_Tabs + newTabIndex;

            if(newTabIndex != currentTab && !tabs[newTabIndex].isDisabled()) {
                switchTab(newTabIndex);
                return;
            }
        }
    }

    void switchTab(TabID tab) {
        if(currentTab == tab) return;
        
        let oldTab = currentTab;
        currentTab = tab;

        for(int x = 0; x < Num_Tabs; x++) {
            tabs[x].setSelected(x == currentTab, false);
        }

        double time = views[oldTab].animate(WorkshopView.Anim_Out);
        
        if(views[currentTab].parent == null) {
            viewContainer.add(views[currentTab]);
        } else {
            viewContainer.moveToFront(views[currentTab]);
        }

        views[currentTab].animate(WorkshopView.Anim_In, time * 0.8);
    }

    // We are going to draw a bunch of nonsense off screen to preload the graphics and prevent a glitchy intro animation
    override void beforeFirstDraw() {
        DrawImg("graphics/upgrade_menu/background.png", (0,0), DR_SCREEN_RIGHT | DR_SCREEN_BOTTOM);
        DrawImg("graphics/upgrade_menu/footer.png", (0,0), DR_SCREEN_RIGHT | DR_SCREEN_BOTTOM);
        DrawImg("graphics/upgrade_menu/header.png", (0,0), DR_SCREEN_RIGHT | DR_SCREEN_BOTTOM);
        DrawImg("graphics/upgrade_menu/logo.png", (0,0), DR_SCREEN_RIGHT | DR_SCREEN_BOTTOM);
        DrawImg("graphics/upgrade_menu/header_selected.png", (0,0), DR_SCREEN_RIGHT | DR_SCREEN_BOTTOM);
        // Preload string
        DrawStr("SEL46FONT", "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", (0,0), DR_SCREEN_RIGHT | DR_SCREEN_BOTTOM, 0xFF5A6A87);
    }

    override void drawSubviews() {
        if(!preload) {
            preload = true;
            return;
        }

        Super.drawSubviews();
    }

    override void layoutChange(int screenWidth, int screenHeight) {
		calcScale(screenWidth, screenHeight);

        // Adjust spacing for small horizontal widths
        if(virtualScreenSize.x < 1900) {
            resourceLayout.firstPin(UIPin.Pin_Right).offset = -50;
            mainViewContainer.firstPin(UIPin.Pin_Left).offset = 10;
            mainViewContainer.firstPin(UIPin.Pin_Right).offset = -10;
            tabLayout.padding.left = 20;
        } else {
            resourceLayout.firstPin(UIPin.Pin_Right).offset = -130;
            mainViewContainer.firstPin(UIPin.Pin_Left).offset = 50;
            mainViewContainer.firstPin(UIPin.Pin_Right).offset = -50;
            tabLayout.padding.left = 48;
        }

        Super.layoutChange(screenWidth, screenHeight);
    }

    override void calcScale(int screenWidth, int screenHeight, Vector2 baselineResolution) {
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
        double minWidth = 1600;
        if(screenWidth / newScale < minWidth) {
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
}

class WeaponStationTab : UIButton {
    WeaponStationTab init(string title, bool hasNew = false) {
        UIButtonState normState     = UIButtonState.Create("", 0xFF5A6A87);
        UIButtonState hovState      = UIButtonState.Create("", 0xFF77C7FD);
        UIButtonState pressState    = UIButtonState.Create("", 0xFF2984DE);
        UIButtonState disableState  = UIButtonState.Create("", 0x33AAAAAA);
        UIButtonState selectedState         = UIButtonState.Create("graphics/upgrade_menu/header_selected.png", 0xFF77C7FD);
        UIButtonState selectedHovState      = UIButtonState.Create("graphics/upgrade_menu/header_selected.png", 0xFF77C7FD);
        UIButtonState selectedPressState    = UIButtonState.Create("graphics/upgrade_menu/header_selected.png", 0xFF77C7FD);

        Super.init(
            (0,0), (100, 150), 
            title, 'SEL46FONT',
            normState,
            hovState,
            pressState,
            disableState,
            selectedState,
            selectedHovState,
            selectedHovState
        );

        pin(UIPin.Pin_Top);
        pin(UIPin.Pin_Bottom);
        pinWidth(label.getStringWidth(title) + 50);
        setTextPadding(0, 0, 0, 50);
        label.textAlign = Align_Center | Align_Bottom;
        clipsSubviews = false;
        rejectHoverSelection = true;

        return self;
    }

    override void transitionToState(int idx, bool sound, bool mouseSelection) {
        Super.transitionToState(idx, sound, mouseSelection);

        if(currentState == State_Selected || currentState == State_SelectedHover || currentState == State_SelectedPressed) {
            label.fontScale = (1.0, 1.0);
            requiresLayout = true;
        } else {
            label.fontScale = (0.65, 0.65);
            requiresLayout = true;
        }
    }
}


class WorkshopLogo : UIImage {
    override void draw() {
        if(hidden) { return; }
        
        UIView.draw();

        UIBox b;
        boundingBoxToScreen(b);

        if(tex) {
            Vector2 pos, size;
            switch(imgStyle) {
                case Image_Absolute:
                    size = (tex.size.x * imgScale.x * cScale.x, tex.size.y * imgScale.y * cScale.y);
                    pos = b.pos;
                    break;
                case Image_Center:
                    size = (tex.size.x * imgScale.x * cScale.x, tex.size.y * imgScale.y * cScale.y);
                    pos = b.pos + (b.size / 2.0) - (size / 2.0);
                    break;
                case Image_Aspect_Fill:
                    {
                        double aspect = tex.size.x / tex.size.y;
                        double target_aspect = b.size.x / b.size.y;

                        size = aspect > target_aspect ? (b.size.y * aspect, b.size.y) : (b.size.x, b.size.x / aspect);
                        size = (size.x * imgScale.x, size.y * imgScale.y);
                        pos = b.pos + (b.size / 2.0) - (size / 2.0);
                    }
                    break;
                case Image_Aspect_Fit:
                    {
                        double aspect = tex.size.x / tex.size.y;
                        size = (tex.size.x * imgScale.x * cScale.x, tex.size.y * imgScale.y * cScale.y);

                        if(b.size.x < size.x) {
                            size *= b.size.x / size.x;
                        }

                        if(b.size.y < size.y) {
                            size *= b.size.y / size.y;
                        }
                        
                        switch(imgAnchor) {
                            case ImageAnchor_TopLeft:
                                pos = b.pos;
                                break;
                            case ImageAnchor_Top:
                                pos = b.pos + ((b.size.x / 2.0) - (size.x / 2.0), 0);
                                break;
                            case ImageAnchor_TopRight:
                                pos = b.pos + (b.size.x - size.x, 0);
                                break;
                            case ImageAnchor_Left:
                                pos = b.pos + (0, (b.size.y / 2.0) - (size.y / 2.0));
                                break;
                            case ImageAnchor_Right:
                                pos = b.pos + (b.size.x - size.x, (b.size.y / 2.0) - (size.y / 2.0));
                                break;
                            case ImageAnchor_BottomLeft:
                                pos = b.pos + (0, b.size.y - size.y);
                                break;
                            case ImageAnchor_Bottom:
                                pos = b.pos + ((b.size.x / 2.0) - (size.x / 2.0), b.size.y - size.y);
                                break;
                            case ImageAnchor_BottomRight:
                                pos = b.pos + (b.size.x - size.x, b.size.y - size.y);
                                break;
                            default:
                                pos = b.pos + (b.size / 2.0) - (size / 2.0);
                                break;
                        }
                    }
                    break;
                default:
                    pos = b.pos;
                    size = b.size;
                    break;
            }

            // Draw texture
            Screen.DrawTexture(
                tex.texID, 
                true, 
                pos.x + (size.x / 2.0),
                pos.y + (size.y / 2.0),
                DTA_DestWidthF, size.x,
                DTA_DestHeightF, size.y,
                DTA_Alpha, cAlpha,
                DTA_ColorOverlay, blendColor,
                DTA_Filtering, !noFilter,
                DTA_Desaturate, int(255.0 * desaturation),
                DTA_Rotate, (MSTime() / 1000.0) * -180.0,
                DTA_CenterOffset, true
            );
        }
    }
}


class WorkshopView : UIView {
    enum WVAnimation {
        Anim_In,
        Anim_Out
    };

    virtual bool hasCompletedAnimation(WVAnimation anim) {
        return true;
    }

    // returns the time that the animation expects to stop
    virtual double animate(WVAnimation anim, double timeDelay = 0) { return 0; }

    virtual bool MenuEvent(int mkey, bool fromcontroller) {
		return false;
	}

    virtual bool OnInputEvent(InputEvent ev) {
        return false;
    }
}