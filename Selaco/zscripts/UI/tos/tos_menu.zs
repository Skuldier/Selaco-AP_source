#include "ZScripts/UI/tos/quality_menu.zs"

class StartupMenu : SelacoGamepadMenu {

}

class TOSEventHandler : StaticEventHandler {
    bool shouldRun;
    uint ticks;

    const introTicks = 494;

    override void OnRegister() {
        shouldRun = IntroHandler.needsTOS();

        SetOrder(99997);
    }

    override void WorldTick () {
        shouldRun = IntroHandler.needsTOS() || IntroHandler.needsVisibility();

        if(!shouldRun) {
            //Level.SetFrozen(false);
            if (!bDESTROYED) Destroy(); // Destruct after first use
            return;
        }

        if(ticks == 0) {
            //Level.SetFrozen(true);
            //Menu.SetMenu("TOSMenu");
            if(IntroHandler.needsTOS()) Menu.SetMenu("QualityMenu");
            else Menu.SetMenu("VisibilityMenu");
        }

        ticks++;
    }

    /*override void NetworkProcess(ConsoleEvent e) {
        if(e.name == "VISIBILITY_SET") {
            IntroHandler.clearNeedsVisibility();
        }
        
        if(e.name == "ACCEPT_TOS" && !e.isManual) {
            shouldRun = false;
            IntroHandler.clearNeedsTOS();

            Level.SetFrozen(false);
        }
    }*/
}

class TOSHandler : UIHandler {
    TOSMenu mMenu;
    bool hasAlreadyClickedContinue; // Stop spamming the button you jerks

    override void handleEvent(int type, UIControl con, bool fromMouseEvent, bool fromcontrollerEvent) {
        if(type == Event_ValueChanged && con == mMenu.scrollView) {
            if(mMenu.scrollView.scrollbar.getNormalizedValue() >= 0.8) {
                // Notify menu that it is safe to display checkbox
                mMenu.hasScrolledFully(fromMouseEvent);
            }
        }

        if(type == Event_Activated) {
            if(con == mMenu.checkbox) {
                mMenu.checkbox.setSelected(!mMenu.checkbox.selected);
                mMenu.checkboxToggle(fromMouseEvent);
            }

            if(!hasAlreadyClickedContinue && con == mMenu.continueButton && !mMenu.continueButton.isDisabled()) {
                hasAlreadyClickedContinue = true;
                mMenu.menuSound("ui/closeTutorialBig");
                mMenu.animateClose();
            }
        }
    }
}

class TOSMenu : StartupMenu {
    UILabel tosLabel, tosTitleLabel, checkboxLabel;
    UIButton continueButton;
    UIImage background;
    UIVerticalScroll scrollView;
    TOSCheckbox checkbox;
    TOSHandler handler;
    UIView acceptView;
    UIViewAnimation closeAnimation;

    bool alreadyDidTOS;

    Array<SOMOptionView> optionViews, presetViews;
    Array<int> backKeys, rawBackKeys;

    double dimStart;
    int countdown;

    override void init(Menu parent) {
        Super.init(parent);

        menuActive = Menu.On;
        DontDim = true;
        DontBlur = true;
        AnimatedTransition = false;
        Animated = true;

        alreadyDidTOS = !IntroHandler.needsTOS();

        Array<int> tempKeybinds;
        Bindings.GetAllKeysForCommand(rawBackKeys, "+use");
        Bindings.GetAllKeysForCommand(tempKeybinds, "+usereload");
        rawBackKeys.append(tempKeybinds);
        
        for(int x =0; x < rawBackKeys.size(); x++) {
            backKeys.push(UIHelper.GetUIKey(rawBackKeys[x]));
        }

        handler = new("TOSHandler");
        handler.mMenu = self;

        menuSound("ui/openTutorialBig");

        background = new("UIImage").init((0, 0), (760, 600), "", NineSlice.Create("graphics/options_menu/op_bbar2.png", (9,9), (14,14)));
        background.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        background.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        background.pinHeight(0.75, isFactor: true);
        mainView.add(background);

        scrollView = new("UIVerticalScroll").init((0,0), (0,0), 30, 24,
            NineSlice.Create("graphics/options_menu/slider_bg_vertical.png", (14, 6), (16, 24)),
            null,
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down.png", (8,8), (13,13)),
            null,
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_selected.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_selected.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down_selected.png", (8,8), (13,13))
        );
        scrollView.scrollbar.selectButtonOnFocus = true;
        scrollView.scrollbar.buttonSize = 20;
        scrollView.pinToParent(10, 10, -5, -10);
        scrollView.handler = handler;
        scrollView.autoHideScrollbar = true;

        background.add(scrollView);

        tosTitleLabel = new("UILabel").init((0,0), (100,100), StringTable.Localize("$TOS_TITLE") .. "\n\n", "SEL21FONT", textAlign: UIView.Align_Centered);
        tosTitleLabel.multiline = true;
        tosTitleLabel.pin(UIPin.Pin_Left);
        tosTitleLabel.pin(UIPin.Pin_Right);
        tosTitleLabel.pinHeight(UIView.Size_Min);

        tosLabel = new("UILabel").init((0,0), (100,100), StringTable.Localize("$TOS"), "PDA16FONT");
        tosLabel.multiline = true;
        tosLabel.pin(UIPin.Pin_Left, offset: 10);
        tosLabel.pin(UIPin.Pin_Right, offset: -10);
        tosLabel.pinHeight(UIView.Size_Min);

        scrollView.mLayout.addManaged(tosTitleLabel);
        scrollView.mLayout.addManaged(tosLabel);

        acceptView = new("UIView").init((0,0), (760, 40));
        acceptView.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        acceptView.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 0.875, offset: 10, isFactor: true);
        acceptView.clipsSubviews = false;
        //acceptView.backgroundColor = 0xFF00FF00;
        mainView.add(acceptView);
        

        checkbox = new("TOSCheckbox").init((0,0), (30, 30), false);
        checkbox.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        checkbox.handler = handler;
        acceptView.add(checkbox);

        continueButton = new("UIButton").init((0,0), (100, 40), "Continue", "SEL16FONT",
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999)
        );
        continueButton.pinWidth(UIView.Size_Min);
        continueButton.pin(UIPin.Pin_Right);
        continueButton.setDisabled(true);
        continueButton.setTextPadding(15, 0, 15, 0);
        continueButton.alpha = 0.5;
        continueButton.handler = handler;

        // Setup nav
        continueButton.navLeft = checkbox;
        checkbox.navRight = continueButton;

        acceptView.add(continueButton);
        
        checkboxLabel = new("UILabel").init((45,0), (600, 40), StringTable.Localize("$TOS_ACCEPT"), "PDA16FONT", textAlign: UIView.Align_Middle);
        acceptView.add(checkboxLabel);
        
        acceptView.hidden = true;
        acceptView.alpha = 0;

        navigateTo(scrollView.scrollbar);

        countdown = 105;
        dimStart = getTime();
        background.alpha = 0;
    }


    override void layoutChange(int screenWidth, int screenHeight) {
		Super.layoutChange(screenWidth, screenHeight);

        if(!scrollView.contentsCanScroll()) {
            if(acceptView.hidden) {
                acceptView.hidden = false;
            
                // Animate to visible
                acceptView.animateFrame(
                    0.6,
                    fromAlpha: 0.0,
                    toAlpha: 1
                );

                navigateTo(checkbox);
            }
        }
	}


    override void beforeFirstDraw() {
        // We are guaranteed to have layed out once here
        // Check if the scroll view is actually scrollable, if not move the default selection
        if(!scrollView.contentsCanScroll()) {
            acceptView.hidden = false;
            
            // Animate to visible
            acceptView.animateFrame(
                0.6,
                fromAlpha: 0.0,
                toAlpha: 1
            );

            navigateTo(checkbox);
        }
    }

    override void ticker() {
        Super.ticker();

        countdown--;

        // In case the TOS doesn't take up the full amount of space, after 3 seconds enable the scroll
        if(countdown == 0 && scrollView.scrollbar.hidden) {
            hasScrolledFully(false);
        }

        if(countdown == 100) {
            background.animateFrame(
                0.35,
                fromPos: background.frame.pos + (0, 400),
                toPos: background.frame.pos,
                fromAlpha: 0.0,
                toAlpha: 1,
                ease: Ease_Out
            );
        } else if(closeAnimation && !closeAnimation.checkValid(getTime())) {
            if(alreadyDidTOS) {
                close();
            } else {
                alreadyDidTOS = true;
                Menu.SetMenu("QualityMenu");
            }
        }

        if(!scrollView.scrollbar.isDisabled()) {
            let v = getGamepadRawLook();
            if(abs(v.y) > 0.1) {
                scrollView.scrollByPixels((v.y * CommonUI.STANDARD_SCROLL_AMOUNT), true, false, false);
            }
        }
    }

    void animateClose() {
        if(!closeAnimation) {
            acceptView.setAlpha(0);

            closeAnimation = background.animateFrame(
                0.35,
                fromPos: background.frame.pos,
                toPos: background.frame.pos + (0, 400),
                fromAlpha: 1.0,
                toAlpha: 0,
                ease: Ease_In
            );
        }
    }

    void hasScrolledFully(bool fromMouse) {
        if(acceptView.hidden) {
            acceptView.hidden = false;

            // Animate to visible
            acceptView.animateFrame(
                0.2,
                fromAlpha: 0.0,
                toAlpha: 1
            );

            // Select the checkbox for keyboard input
            if(!fromMouse) {
                navigateTo(checkbox);
            }

            menuSound("item/iconshow");
        }
    }

    void checkboxToggle(bool fromMouse) {
        if(checkbox.selected) {
            continueButton.setDisabled(false);
            continueButton.animateFrame(
                0.2,
                fromAlpha: continueButton.alpha,
                toAlpha: 1
            );

            if(!fromMouse) {
                navigateTo(continueButton);
            }
        } else {
            continueButton.setDisabled(true);
            continueButton.animateFrame(
                0.2,
                fromAlpha: continueButton.alpha,
                toAlpha: 0.5
            );
        }
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(mkey == MKEY_Back) {
            // TODO: Play error sound
            return true;
        }

        if(mkey == MKEY_Up) {
            if(activeControl != scrollView.scrollbar && !scrollView.scrollbar.isDisabled()) {
                navigateTo(scrollView.scrollbar);
                return true;
            }
        } else if(mkey == MKEY_Down) {
            if(activeControl == scrollView.scrollbar && (scrollView.scrollbar.getNormalizedValue() > 0.99 || scrollView.scrollbar.isDisabled()) && acceptView.hidden == false) {
                if(checkbox.selected && !continueButton.isDisabled()) {
                    navigateTo(continueButton);
                } else {
                    navigateTo(checkbox);
                }
            }
        }

        return Super.MenuEvent(mkey, fromcontroller);
    }

    // Check for use key. Needed for gamepad input
    // This doesn't actually work yet, no gamepad input makes it to the menus unless the game is running
    /*override bool onUIEvent(UIEvent ev) {
        if(ev.type == UIEvent.Type_KeyDown) {
            if(!closeAnimation) {
                for(int x = 0; x < backKeys.size(); x++) {
                    Console.Printf("Checking key: %d against %d", ev.KeyChar, backKeys[x]);
                    if(ev.KeyChar == backKeys[x]) {
                        animateClose();
                        return true;
                    }
                }
            }
        }

        return Super.onUIEvent(ev);
    }

    override bool OnInputEvent(InputEvent ev) { 
		if(ev.type == InputEvent.Type_KeyDown && !closeAnimation) {
            for(int x = 0; x < rawBackKeys.size(); x++) {
                if(ev.KeyScan == rawBackKeys[x]) {
                    animateClose();
                    return true;
                }
            }
        }

        return Super.OnInputEvent(ev);
	}*/

    override void drawSubviews() {
        double time = getTime();
        if(time - dimStart > 0) {
            double dim = MIN((time - dimStart) / 0.25, 1.0) * 0.8;
            Screen.dim(0xFF020202, dim, 0, 0, lastScreenSize.x, lastScreenSize.y);
        }

        Super.drawSubviews();
    }
}

class TOSCheckbox : StandardCheckbox {
    TOSCheckbox Init(Vector2 pos, Vector2 size, bool isChecked = false) {
        Super.Init(pos, size, true);
        setSelected(isChecked, false);
        return self;
    }
    /*TOSCheckbox Init(Vector2 pos, Vector2 size, bool isChecked = false) {
        Super.init(pos, size, "", null, 
            UIButtonState.Create("graphics/options_menu/checkbox.png"),
            UIButtonState.Create("graphics/options_menu/checkbox_high.png", sound: "menu/cursor", soundVolume: 0.45),
            UIButtonState.Create("graphics/options_menu/checkbox_down.png"),
            UIButtonState.Create("graphics/options_menu/checkbox_disabled.png"),
            UIButtonState.Create("graphics/options_menu/checkbox_filled.png"),
            UIButtonState.Create("graphics/options_menu/checkbox_filled_high.png", sound: "menu/cursor", soundVolume: 0.45),
            UIButtonState.Create("graphics/options_menu/checkbox_filled_down.png")
        );

        setSelected(isChecked, false);

        return self;
    }*/
}