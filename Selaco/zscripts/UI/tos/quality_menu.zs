class QualityMenu : StartupMenu {
    mixin UIInputHandlerAccess;

    UILabel titleLabel, descLabel;
    UIButton continueButton, accButt;
    UIImage background;
    UIVerticalScroll scrollView;
    UIVerticalLayout layoutView, accLayout;
    UIViewAnimation closeAnimation;

    OptionMenuItemOption menuItem;
    Array<QualityRadioButton> radioButts;
    Array<UIControl> checkViews;
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

        titleLabel = new("UILabel").init((0,0), (100,100), StringTable.Localize("$QUALITY_TITLE"), "SEL46FONT", textAlign: UIView.Align_Bottom | UIView.Align_HCenter);
        titleLabel.multiline = false;
        titleLabel.pin(UIPin.Pin_Left, offset: 20);
        titleLabel.pin(UIPin.Pin_Right, offset: -20);
        titleLabel.pin(UIPin.Pin_Bottom, UIPin.Pin_Top, offset: -90);
        titleLabel.pinHeight(UIView.Size_Min);
        titleLabel.ignoresClipping = true;
        scrollView.add(titleLabel);

        descLabel = new("UILabel").init((0,0), (100,100), StringTable.Localize("$QUALITY_DESCRIPTION"), "PDA16FONT", textColor: 0xFFCCCCCC, textAlign: UIView.Align_HCenter);
        descLabel.multiline = true;
        descLabel.pinWidth(800);
        descLabel.pinHeight(UIView.Size_Min);
        descLabel.pin(UIPin.Pin_Top, offset: -85);
        descLabel.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        //descLabel.pin(UIPin.Pin_Left, offset: 10);
        //descLabel.pin(UIPin.Pin_Right, offset: -10);
        descLabel.ignoresClipping = true;
        scrollView.add(descLabel);

        let noteLabel = new("UILabel").init((0,0), (100,100), StringTable.Localize("$QUALITY_NOTE"), "PDA16FONT");
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

        let lastControl = buildGraphicsOptions();
        layoutView.addSpacer(30);

        accButt = new("UIButton").init((0,0), (100, 40), "Show Accessibility Options", "SEL21FONT",
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999)
        );
        accButt.pinWidth(UIView.Size_Min);
        accButt.pin(UIPin.Pin_Left, offset: 22);
        accButt.pinHeight(40);
        accButt.minSize.y = 40;
        accButt.setTextPadding(20, 0, 20, 0);
        layoutView.addManaged(accButt);

        if(lastControl) lastControl.navDown = accButt;
        accButt.navUp = lastControl;

        lastControl = buildACOptions(accButt);

        layoutView.addSpacer(12);
        layoutView.addManaged(noteLabel);

        layoutView.addSpacer(22);
        //layoutView.addManaged(continueButton);

        continueButton.navLeft = lastControl;
        
        scrollView.alpha = 0;
    }
    

    UIControl buildGraphicsOptions() {
        UIControl firstControl, lastControl, selectedControl;
        let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("GraphicsSelector"));

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


    UIControl buildACOptions(UIControl lastControl) {
        UIControl firstControl;
        let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("FirstRunAccessibility"));

        accLayout = new("UIVerticalLayout").init((0,0), (0,0));
        accLayout.pinHeight(UIView.Size_Min);
        accLayout.itemSpacing = 5;
        accLayout.pin(UIPin.Pin_Left);
        accLayout.pin(UIPin.Pin_Right);
        accLayout.hidden = true;
        layoutView.addManaged(accLayout);

        accLayout.addSpacer(30);
    
        if(menuDescriptor) {
            for(int x = 0; x < menuDescriptor.mItems.size(); x++) {
                OptionMenuItem it = OptionMenuItem(menuDescriptor.mItems[x]);
                let io = OptionMenuItemOption(it);
            
                if(it is 'OptionMenuItemStaticText') {
                    let s = OptionMenuItemStaticText(it);

                    UILabel lab = new("UILabel").init((0,0), (0, 20), s.mLabel, 'SEL16FONT', textAlign: UIView.Align_Left | UIView.Align_Bottom);
                    lab.pin(UIPin.Pin_Left, offset: 17);
                    lab.pin(UIPin.Pin_Right, offset: -80);
                    lab.multiline = true;
                    lab.pinHeight(20);
                    lab.minSize.y = 20;

                    accLayout.addManaged(lab);
                    continue;
                } else if(it is 'OptionMenuItemSpace') {
                    let s = OptionMenuItemSpace(it);
                    accLayout.addSpacer(s.mSize);
                    continue;
                }

                if(!io) continue;

                checkItems.push(it);

                let v = new("UIView").init((0,0), (1, 44));
                v.pin(UIPin.Pin_Left);
                v.pin(UIPin.Pin_Right);
                v.minSize.y = 44;
                accLayout.addManaged(v);

                // Checkbox
                let checkbox = new("StandardCheckbox").init((0,0), (40, 40));
                checkbox.pin(UIPin.Pin_Left, offset: 22);
                checkbox.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
                checkbox.setSelected(io.getSelection() > 0);
                checkbox.setDisabled(true); // Disabled to start, since we are hidden
                v.add(checkbox);
                checkViews.push(checkbox);
                checkbox.controlID = checkItems.size() - 1;

                // Text
                let st = new("UILabel").init((0,0), (1, 25), io.mLabel, "PDA18FONT", textAlign: UIView.Align_Middle);
                st.pin(UIPin.Pin_Left, offset: 22 + 40 + 15);
                st.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
                st.pinHeight(34);
                st.multiline = false;
                v.add(st);

                if(lastControl) {
                    lastControl.navDown = checkbox;
                    checkbox.navUp = lastControl;
                }
                lastControl = checkbox;
            }
        }

        if(lastControl) {
            lastControl.navDown = continueButton;
            continueButton.navUp = lastControl;
        }

        return lastControl;
    }

    
    override void layoutChange(int screenWidth, int screenHeight) {
		Super.layoutChange(screenWidth, screenHeight);
        animator.clear();

        scrollView.maxSize.y = mainView.frame.size.y - 380;
        scrollView.layout();
        scrollView.updateScrollbar();

        // Update selected values
        for(int x = 0; x < checkItems.size(); x++) {
            let o = OptionMenuItemTooltipOption(checkItems[x]);
            if(o) {
                o.mSelection = -1;  // Invalidate cache
                UIButton(checkViews[x]).setSelected(o.getSelection() > 0);
            }
        }
	}


    void toggleAccessibility() {
        if(accLayout.hidden) {
            // TODO: Animate showing
            scrollView.maxSize.y = mainView.frame.size.y - 380;
            accLayout.hidden = false;
            accButt.label.text = "Hide Accessibility Options";
        } else {
            // TODO: Animate hiding
            accLayout.hidden = true;
            accButt.label.text = "Show Accessibility Options";
        }

        let oldSize = scrollView.frame.size;
        let oldPos = scrollView.frame.pos;
        scrollView.layout();

        // Animate new scrollview size
        let anim = scrollView.animateFrame(
            0.25,
            fromPos: oldPos,
            toPos: scrollView.frame.pos,
            fromSize: oldSize,
            toSize: scrollView.frame.size, 
            layoutSubviewsEveryFrame: true,
            ease: Ease_Out
        );
        //anim.layoutEveryFrame = true;
        scrollView.frame.size = oldSize;

        // Toggle buttons
        for(int x = 0; x < checkViews.size(); x++) {
            if(accLayout.hidden && checkViews[x] == activeControl) {
                activeControl = accButt;
            }

            checkViews[x].setDisabled(accLayout.hidden);

            if(!accLayout.hidden) {
                let o = OptionMenuItemTooltipOption(checkItems[checkViews[x].controlID]);
                if(o) {
                    o.mSelection = -1;  // Invalidate cache
                    UIButton(checkViews[x]).setSelected(o.getSelection() > 0);
                }
            }
        }
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
            // Assume we came from the TOS and set the value
            IntroHandler.clearNeedsTOS();
            
            if(IntroHandler.needsVisibility()) {
                Menu.SetMenu("VisibilityMenu");
            } else {
                SetMusicVolume(Level.MusicVolume);
                close();
            }
        } else if(closeAnimation && !IntroHandler.needsVisibility()) {
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
            if(!madeGraphicsSelection) {
                let io = (menuItem);
                if(io) {
                    io.setSelection(UIHelper.TestForSteamDeck() ? 6 : 2); // Force the default selection of HIGH
                }
            }
            animateClose();
            menuSound("ui/closeTutorialBig");
            hideCursor(); // Hide cursor again since we came from TOS

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
            } else if(ctrl == accButt) {
                toggleAccessibility();
            } else if(ctrl is 'UIButton') {
                // Check checkboxes
                for(int x = 0; x < checkViews.size(); x++) {
                    if(checkViews[x] == ctrl) {
                        UIButton btn = UIButton(checkViews[x]);
                        OptionMenuItemOption o = OptionMenuItemOption(checkItems[btn.controlID]);
                        // Toggle the view
                        btn.setSelected(!btn.isSelected());

                        // Set value
                        if(o) o.setSelection(btn.isSelected() ? 1 : 0);
                    }
                }
            }
        } else if(event == UIHandler.Event_Selected) {
            if(!fromMouseEvent && ctrl is 'UIButton' && continueButton != ctrl) {
                scrollView.scrollTo(ctrl, true, 40);
            }
        }

        Super.handleControl(ctrl, event, fromMouseEvent);
    }
}


class QualityRadioButton : UIButton {

    QualityRadioButton Init(Vector2 pos, Vector2 size, bool isChecked = false) {
        Super.init(pos, size, "", null, 
            UIButtonState.Create("graphics/options_menu/radio.png"),
            UIButtonState.Create("graphics/options_menu/radio_high.png", sound: "menu/cursor", soundVolume: 0.45),
            UIButtonState.Create("graphics/options_menu/radio_down.png"),
            UIButtonState.Create("graphics/options_menu/radio_disabled.png"),
            UIButtonState.Create("graphics/options_menu/radio_filled.png"),
            UIButtonState.Create("graphics/options_menu/radio_filled_high.png", sound: "menu/cursor", soundVolume: 0.45),
            UIButtonState.Create("graphics/options_menu/radio_filled_down.png")
        );

        setSelected(isChecked, false);

        return self;
    }
}