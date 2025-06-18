class VisibilityMenu : StartupMenu {
    mixin UIInputHandlerAccess;

    UILabel titleLabel, descLabel;
    UIButton continueButton;
    UIImage background;
    UIVerticalScroll scrollView;
    UIVerticalLayout layoutView;
    UIViewAnimation closeAnimation;

    OptionMenuItemOption menuItem;
    Array<QualityRadioButton> radioButts;
    Array<OptionMenuItem> checkItems;

    float targetMusicVolume, curMusicVolume, musicVolumeSteps;
    bool madeGraphicsSelection;

    override void init(Menu parent) {
        Super.init(parent);
        menuActive = Menu.On;
        DontDim = true;
        DontBlur = true;
        AnimatedTransition = false;
        Animated = true;

        curMusicVolume = Level.MusicVolume;
        targetMusicVolume = 0;
        musicVolumeSteps = (Level.MusicVolume - targetMusicVolume) / 10.0;

        menuSound("ui/openTutorialBig");

        scrollView = new("OptionsVerticalScroll").init((0,0), (760, 100), 30, 24,
            NineSlice.Create("graphics/options_menu/slider_bg_vertical.png", (14, 6), (16, 24)),
            null,
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down.png", (8,8), (13,13))
        );
        scrollView.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        scrollView.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        scrollView.pinHeight(UIView.Size_Min);
        scrollView.pinWidth(760);
        scrollView.maxSize.y = mainView.frame.size.y - 380;
        scrollView.minSize.y = 200;
        scrollView.autoHideScrollbar = true;
        scrollView.scrollbar.buttonSize = 20;
        scrollView.scrollbar.rejectHoverSelection = true;
        scrollView.rejectHoverSelection = true;
        scrollView.mLayout.ignoreHiddenViews = true;
        layoutView = UIVerticalLayout(scrollView.mLayout);
        layoutView.itemSpacing = 5;
        mainView.add(scrollView);

        background = new("UIImage").init((0, 0), (760, 300), "", NineSlice.Create("graphics/options_menu/op_bbar2.png", (9,9), (14,14)));
        background.pinToParent(-10, -10, 10, 10);
        background.ignoresClipping = true;
        scrollView.add(background);
        scrollView.moveToBack(background);

        titleLabel = new("UILabel").init((0,0), (100,100), StringTable.Localize("$VISIBILITY_TITLE"), "SEL46FONT", textAlign: UIView.Align_Bottom | UIView.Align_HCenter);
        titleLabel.multiline = false;
        titleLabel.pin(UIPin.Pin_Left, offset: 20);
        titleLabel.pin(UIPin.Pin_Right, offset: -20);
        titleLabel.pin(UIPin.Pin_Bottom, UIPin.Pin_Top, offset: -90);
        titleLabel.pinHeight(UIView.Size_Min);
        titleLabel.ignoresClipping = true;
        scrollView.add(titleLabel);

        descLabel = new("UILabel").init((0,0), (100,100), StringTable.Localize("$VISIBILITY_DESCRIPTION"), "PDA16FONT", textColor: 0xFFCCCCCC, textAlign: UIView.Align_HCenter);
        descLabel.multiline = true;
        descLabel.pinWidth(800);
        descLabel.pinHeight(UIView.Size_Min);
        descLabel.pin(UIPin.Pin_Top, offset: -85);
        descLabel.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        //descLabel.pin(UIPin.Pin_Left, offset: 10);
        //descLabel.pin(UIPin.Pin_Right, offset: -10);
        descLabel.ignoresClipping = true;
        scrollView.add(descLabel);

        let noteLabel = new("UILabel").init((0,0), (100,100), StringTable.Localize("$VISIBILITY_NOTE"), "PDA16FONT");
        noteLabel.multiline = true;
        noteLabel.pinWidth(760);
        noteLabel.pinHeight(UIView.Size_Min);
        noteLabel.pin(UIPin.Pin_Left, offset: 22);
        noteLabel.pin(UIPin.Pin_Right, offset: -22);

        continueButton = new("UIButton").init((0,0), (100, 55), "Continue", "SEL21FONT",
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999)
        );
        continueButton.pinWidth(UIView.Size_Min);
        continueButton.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, offset: 52);
        continueButton.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        continueButton.setTextPadding(25, 0, 25, 0);
        continueButton.ignoresClipping = true;
        scrollView.add(continueButton);

        layoutView.addSpacer(22);

        let lastControl = buildQualityOptions();
        layoutView.addSpacer(30);

        if(lastControl) lastControl.navDown = continueButton;
        continueButton.navUp = lastControl;

        layoutView.addSpacer(12);
        layoutView.addManaged(noteLabel);

        layoutView.addSpacer(22);

        continueButton.navLeft = lastControl;
        
        scrollView.alpha = 0;
    }
    

    UIControl buildQualityOptions() {
        UIControl firstControl, lastControl, selectedControl;
        let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("VisibilitySelector"));

        if(menuDescriptor) {
            for(int x = 0; x < menuDescriptor.mItems.size(); x++) {
                OptionMenuItem it = OptionMenuItem(menuDescriptor.mItems[x]);
                let io = OptionMenuItemOption(it);

                if(!io) continue;

                menuItem = io;

                int selectedItem = io is 'OptionMenuItemTooltipPreset' ? OptionMenuItemTooltipPreset(io).findSelection() : io.GetSelection();

                if(UIHelper.TestForSteamDeck()) {
                    // Select SteamDeck: Quality
                    selectedItem = clamp(6, 0, OptionValues.GetCount(io.mValues) - 1);
                } else {
                    if(selectedItem < 0) {
                        selectedItem = clamp(2, 0, OptionValues.GetCount(io.mValues) - 1);
                    }
                }

                // Make some radio buttons
                for(int y = OptionValues.GetCount(io.mValues) - 1; y >= 0 ; y--) {
                    let optionText = OptionValues.GetText(io.mValues, y);

                    if(optionText != "") {
                        let v = new("UIView").init((0,0), (1, 44));
                        v.pin(UIPin.Pin_Left);
                        v.pin(UIPin.Pin_Right);
                        v.minSize.y = 44;

                        let rb = new("QualityRadioButton").init((22,0), (40,40), y == selectedItem);
                        rb.pin(UIPin.Pin_Left, offset: 22);
                        rb.pin(UIPin.Pin_VCenter, value: 1.0);
                        rb.controlID = y;
                        radioButts.push(rb);
                        v.add(rb);

                        if(!firstControl) {
                            firstControl = rb;
                            rb.navUp = continueButton;
                        }

                        if(lastControl) {
                            lastControl.navDown = rb;
                            rb.navUp = lastControl;
                        }
                        lastControl = rb;

                        let st = new("UILabel").init((0,0), (1, 25), optionText, "PDA18FONT", textAlign: UIView.Align_Middle);//, fontScale: (0.8125, 0.8125));
                        st.pin(UIPin.Pin_Left, offset: 22 + 40 + 15);
                        st.pin(UIPin.Pin_VCenter, value: 1.0);
                        st.pinHeight(34);
                        st.multiline = false;
                        v.add(st);

                        if(y == selectedItem) {
                            selectedControl = rb;
                        }

                        layoutView.addManaged(v);
                    } else {
                        // Add separator
                        let v = new("UIView").init((0,0), (1, 33));
                        v.pin(UIPin.Pin_Left, offset: 22);
                        v.pin(UIPin.Pin_Right, offset: -22);
                        let vv = new("UIView").init((0,0), (1, 2));
                        vv.pin(UIPin.Pin_Left);
                        vv.pin(UIPin.Pin_Right);
                        vv.pin(UIPin.Pin_VCenter, value: 1.0);
                        v.add(vv);

                        v.minSize.y = 33;

                        layoutView.addManaged(v);
                    }
                }
            }
        }

        if(lastControl) {
            lastControl.navDown = continueButton;
            continueButton.navUp = lastControl;
        }

        navigateTo(selectedControl);

        return lastControl;
    }

    
    override void layoutChange(int screenWidth, int screenHeight) {
		Super.layoutChange(screenWidth, screenHeight);
        animator.clear();

        scrollView.maxSize.y = mainView.frame.size.y - 380;
        scrollView.layout();
        scrollView.updateScrollbar();
	}


    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(mkey == MKEY_Back) {
            // TODO: Play error sound
            return true;
        }

        if(mkey == MKEY_Up) {
            if(activeControl == null) {
                navigateTo(continueButton);
                return true;
            }
        } else if(mkey == MKEY_Down) {
            if(activeControl == null) {
                navigateTo(radioButts[0]);
                return true;
            }
        }

        return Super.MenuEvent(mkey, fromcontroller);
    }


    override void ticker() {
        Super.ticker();

        if(ticks == 1) {
            scrollView.animateFrame(
                0.35,
                fromPos: scrollView.frame.pos + (0, 400),
                toPos: scrollView.frame.pos,
                fromAlpha: 0.0,
                toAlpha: 1,
                ease: Ease_Out
            );
        } else if(closeAnimation && !closeAnimation.checkValid(getTime())) {
            SetMusicVolume(Level.MusicVolume);
            close();
        } else if(closeAnimation) {
            curMusicVolume = MAX(targetMusicVolume, curMusicVolume - musicVolumeSteps);
            SetMusicVolume(curMusicVolume);
        } else {
            // Scroll with gamepad
            if(scrollView && scrollView.contentsCanScroll()) {
                let v = getGamepadRawLook();
                if(abs(v.y) > 0.1) {
                    scrollView.scrollByPixels((v.y * CommonUI.STANDARD_SCROLL_AMOUNT), true, false, false);
                }
            }
        }
    }

    override void drawSubviews() {
        double time = getTime();
        double dim = 0.8;
        Screen.dim(0xFF020202, dim, 0, 0, lastScreenSize.x, lastScreenSize.y);
        Super.drawSubviews();
    }

    void animateClose() {
        if(!closeAnimation) {
            closeAnimation = scrollView.animateFrame(
                0.35,
                fromPos: scrollView.frame.pos,
                toPos: scrollView.frame.pos + (0, 400),
                fromAlpha: 1.0,
                toAlpha: 0,
                ease: Ease_In
            );
        }
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(ctrl == continueButton && event == UIHandler.Event_Activated) {
            IntroHandler.clearNeedsVisibility();
            animateClose();
            menuSound("ui/closeTutorialBig");
            return;
        }

        if(event == UIHandler.Event_Activated) {
            let c = QualityRadioButton(ctrl);

            if(c) {
                menuSound("menu/change");

                // Activate the menu item
                menuItem.setSelection(ctrl.controlID);

                // Set radio button values
                for(int x = 0; x < radioButts.size(); x++) {
                    radioButts[x].setSelected(radioButts[x] == ctrl);
                }

                madeGraphicsSelection = true;

                return;

                // Apply warning if necessary, on second hand no let's allow the Options menu to display this warning. 
                /*if(menuItem && menuItem.getSelection() == 4) {
                    MenuSound("ui/message");
                    let m = new("PromptMenu").initNew(self, "$MENU_TITLE_RIDICULOUS", "$MENU_TEXT_RIDICULOUS", "$MENU_BTN_RIDICULOUS");
                    m.ActivateMenu();
                }*/
            }
        } else if(event == UIHandler.Event_Selected) {
            if(!fromMouseEvent && ctrl is 'UIButton' && continueButton != ctrl) {
                scrollView.scrollTo(ctrl, true, 40);
            }
        }

        Super.handleControl(ctrl, event, fromMouseEvent);
    }
}