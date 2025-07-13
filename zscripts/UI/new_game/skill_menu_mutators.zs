class SkillMenuMutators : SkillMenuSub {
    SkillMenuButton startButton;

    override void init(Menu parent) {
        Super.init(parent);

        // Create controls for gameplay options
        let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("NewGameSettings"));
        if(menuDescriptor) {
            UIButton lastButt = null;
            for(int x = 0; x < menuDescriptor.mItems.size(); x++) {
                if(menuDescriptor.mItems[x] is 'OptionMenuItemTooltipSlider') {
                    let tts = OptionMenuItemTooltipSlider(menuDescriptor.mItems[x]);
                    let mi = new("SkillMenuSliderOptionView").init(tts);
                    mi.pin(UIPin.Pin_Left);
                    mi.pin(UIPin.Pin_Right);
                    mainLayout.addManaged(mi);
                    mi.buttonIndex = x + 1;
                    if(tts.GetAction() == 'g_randomizer') {
                        mi.setDisabled(true);   // Disable randomizer for now
                    }
                } else if(menuDescriptor.mItems[x] is 'OptionMenuItemTooltipOptionText') {
                    let txt = OptionMenuItemTooltipOptionText(menuDescriptor.mItems[x]);
                    let txtText = new("UILabel").init((0,0), (10, 10), menuDescriptor.mItems[x].mLabel, "PDA13FONT", 0xFFb3adad);
                    txtText.pin(UIPin.Pin_Left, offset: 10 + txt.spaceLeft);
                    txtText.pin(UIPin.Pin_Right, offset: -15 + txt.spaceRight);
                    txtText.pinHeight(UIView.Size_Min);

                    if(txt.spaceTop > 0) mainLayout.addSpacer(txt.spaceTop);
                    mainLayout.addManaged(txtText);
                    if(txt.spaceBottom > 0) mainLayout.addSpacer(txt.spaceBottom);

                } else if(menuDescriptor.mItems[x] is 'OptionMenuItemTooltipOption') {
                    let mode = OptionMenuItemTooltipOptionMode(menuDescriptor.mItems[x]);
                    let mi = new("SkillMenuCheckboxOptionView").init(mode);
                    mi.pin(UIPin.Pin_Left);
                    mi.pin(UIPin.Pin_Right);
                    mainLayout.addManaged(mi);
                    mi.buttonIndex = x + 1;

                    bool disabled = false;
                    let u = OptionMenuItemTooltipOptionMode(menuDescriptor.mItems[x]);
                    if(u && u.unlocker != "") {
                        int v;
                        bool success;
                        [v, success] = Globals.GetInt(u.unlocker);

                        if(!success || v < 1) {
                            mi.setDisabled(true);
                            disabled = true;
                        }
                    }

                    if(mode.subMenu != "" && !disabled) {
                        mi.command = "submenu";
                        mi.controlID = x;
                        mi.cancelsSubviewRaycast = false;

                        // No longer putting the options inline. Instead we add a Options button that pops up
                        // an options prompt

                        //mi.navRight = optionsButton;

                        // Add a mouse-only options button inside this control
                        // This is necessary because it's awkward as fuck hovering over the control and then clicking Options
                        // in the description section
                        let oButt = new("UIButton").init((0,0), (180, 45), "", "PDA18FONT",
                            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: Font.CR_UNTRANSLATED),
                            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
                            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
                            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
                            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13))
                        );
                        
                        oButt.pin(UIPin.Pin_Right, offset: -15);
                        oButt.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
                        oButt.pinWidth(45);
                        oButt.pinHeight(45);
                        oButt.alpha = 0;
                        //oButt.setTextPadding(15,6,15,6);
                        oButt.label.multiline = false;
                        oButt.forwardSelection = mi;
                        oButt.controlID = x;
                        oButt.command = "config";
                        mi.add(oButt);
                        mi.extraButtons.push(oButt);

                        // Add image to button
                        let img = new("UIImage").init((0,0), (45, 45), "SETGEARS");
                        img.pinToParent(2, 2, -2, -2);
                        oButt.add(img);
                    }

                } else if(menuDescriptor.mItems[x] is 'OptionMenuItemSeparatorTitle') {
                    let vSpace = OptionMenuItemSeparatorTitle(menuDescriptor.mItems[x]).mSize;
                    let separator = new("SkillSeperator").init((0,0), (190, vSpace));
                    separator.pin(UIPin.Pin_Left);
                    let spacerInner = new("UIView").init((5,vSpace - 10), (190, 2));
                    spacerInner.backgroundColor = 0xFFDDDDDD;
                    spacerInner.alpha = 0.7;
                    separator.add(spacerInner);
                    let spacerText = new("UILabel").init((5,0), (190, vSpace - 13), menuDescriptor.mItems[x].mLabel, "PDA13FONT", 0xFFb3adad, textAlign: UIView.Align_Bottom);
                    separator.add(spacerText);
                    mainLayout.addManaged(separator);
                    
                    separator.alpha = 0;
                }
            }
        } else {
            Console.Printf("\c[RED]Couldn't load menu descriptor for NewGameSettings!");
        }

        mainLayout.addSpacer(50);
        startButton = new("SkillMenuButton").init("Apply", "", -1);
        startButton.firstPin(UIPin.Pin_Left).offset = 20 + 150;
        startButton.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, offset: 15);
        startButton.ignoresClipping = true;
        mainScroll.add(startButton);

        calculateNavigation();
    }
    

    override void calculateNavigation() {
        UIControl lastCon = null;
        UIControl firstCon = null;
        for(int x = 0; x < mainLayout.numManaged(); x++) {
            let con = UIControl(mainLayout.getManaged(x));
            if(con) {
                if(x > 0) {
                    if(lastCon) lastCon.navDown = con;
                    con.navUp = lastCon;
                }

                if(!firstCon) firstCon = con;
                lastCon = con;
            }
        }

        if(lastCon) {
            lastCon.navDown = startButton;
            startButton.navUp = lastCon;
        }

        if(firstCon && firstCon != lastCon) {
            firstCon.navUp = startButton;
            startButton.navDown = firstCon;
        }
    }


    override void onFirstTick() {
        Super.onFirstTick();
        
        for(int x = 0; x < mainLayout.numManaged(); x++) {
            let con = UIControl(mainLayout.getManaged(x));
            if(con) {
                navigateTo(con);
                break;
            }
        }
        if(!activeControl) {
            navigateTo(startButton);
        }
    }


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(animatingClosed || animatingNext) return;

        if(event == UIHandler.Event_ValueChanged) {
            let bb = SkillMenuCheckboxOptionView(ctrl);
            if(bb) {
                if(bb.controlView) {
                    bb.controlView.hidden = !bb.checkbox.isSelected();
                    mainLayout.layout();
                    calculateNavigation();
                    return;
                }


                // If this control has a submenu, open it when using controller or keyboard
                // Disabled by request of mr Nexxtic.
                /*if(bb.command == "submenu" && !fromMouseEvent && bb.checkbox.isSelected()) {
                    // Open config menu for specific control
                    let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("NewGameSettings"));
                    if(menuDescriptor) {
                        let mode = OptionMenuItemTooltipOptionMode(menuDescriptor.mItems[ctrl.controlID]);
                        if(mode && mode.subMenu != "") {
                            let prompt = new("OptionsPrompt").initNew(self, mode.subMenu);
                            prompt.ActivateMenu();
                            return;
                        }
                    }
                }*/
            }
        }


        if(event == UIHandler.Event_Activated) {
            if(ctrl == startButton) {
                MenuSound("menu/advance");
                animateOut();
                animatingClosed = true;
                return;
            }

            let bb = SkillMenuOptionView(ctrl);
            if(bb) {
                if(bb.isDisabledInMenu) {
                    MenuSound("ui/buy/error");
                    return;
                }

                bb.toggle(fromMouseEvent, fromController);
                return;
            }


            if(ctrl.command == "config") {
                // Open config menu for specific control
                let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("NewGameSettings"));
                if(menuDescriptor) {
                    let mode = OptionMenuItemTooltipOptionMode(menuDescriptor.mItems[ctrl.controlID]);
                    if(mode && mode.subMenu != "") {
                        let prompt = new("OptionsPrompt").initNew(self, mode.subMenu, true, enableDescription: false);
                        prompt.ActivateMenu();
                    }
                }
            }
        }
    }


    override void animateIn() {
        Super.animateIn();

        if(masterMenu) {
            masterMenu.animateHeaderLabel(StringTable.Localize("$SKILL_TITLE_MUTATORS"));
        }
    }

    override void animateOut() {
        Super.animateOut();

        if(masterMenu) {
            masterMenu.background.removeGamepadFooterKey(InputEvent.Key_Pad_X);
        }
    }

    override bool onBack() {
        if(!Super.onBack()) {
            if(masterMenu)  masterMenu.background.removeGamepadFooterKey(InputEvent.Key_Pad_X);
            return false;
        }

        return true;
    }


    override bool navigateTo(UIControl con, bool mouseSelection) {
        let ff = Super.navigateTo(con, mouseSelection);

        let bb = SkillMenuOptionView(con);
        if(bb) {
            optionSelected(bb);
            if(!mouseSelection) mainScroll.scrollTo(bb, true, 40);
        } else if(con == startButton) {
            // Hide description container if it's shown
            if(descriptionContainer.alpha ~== 1.0) {
                animator.clear(descriptionContainer);

                descriptionContainer.animateFrame(
                    0.12,
                    fromAlpha: descriptionContainer.alpha,
                    toAlpha: 0,
                    ease: Ease_In
                );
                
                let a = new("UIViewPinAnimation").initComponents(descriptionContainer, 0.12, ease: Ease_In);
                a.addValues(UIPin.Pin_Left, startOffset: descriptionContainer.firstPin(UIPin.Pin_Left).offset, endOffset: (mainView.frame.size.x > 1800 ? 550 : 400) + 150);
                animator.add(a);
            }
        }
        
        return ff;
	}


    void optionSelected(SkillMenuOptionView optionView) {
        let op = OptionMenuItemTooltipOption(optionView.menuItem);
        let opm = OptionMenuItemTooltipOptionMode(optionView.menuItem);
        let text = op ? StringTable.Localize(op.mTooltip) : "";

        if(!op) {
            let op = OptionMenuItemTooltipSlider(optionView.menuItem);
            if(op) {
                text = StringTable.Localize(op.mTooltip);
            }
        }
        
        // Get the first line as the title
        Array<string> lines;
        text.split(lines, "\n");

        if(lines.size() > 1) {
            let u = OptionMenuItemTooltipOptionMode(optionView.menuItem);
            if(u && u.unlocker) {
                 int v;
                bool success;
                [v, success] = Globals.GetInt(u.unlocker);

                if(!success || v < 1) {
                    lines[0] = String.Format("\c[DARKGRAY]%s %s\c-", lines[0], StringTable.Localize("$LOCKED_MODE"));
                }
            }
            descriptionTitleLabel.setText(lines[0]);

            // Hello GC, I see you over there
            let s = lines[1];
            for(int x = 2; x < lines.size(); x++) s = s .. "\n" .. lines[x];
            descriptionLabel.setText(s);
        } else {
            descriptionTitleLabel.setText("");
            descriptionLabel.setText(text);
        }


        // Show settings container if it's hidden
        if(descriptionContainer.alpha < 1) {
            animator.clear(descriptionContainer);
            
            descriptionContainer.animateFrame(
                0.12,
                toAlpha: 1,
                ease: Ease_Out
            );

            let a = new("UIViewPinAnimation").initComponents(descriptionContainer, 0.12, ease: Ease_Out);
            a.addValues(UIPin.Pin_Left, startOffset: descriptionContainer.firstPin(UIPin.Pin_Left).offset, endOffset: (mainView.frame.size.x > 1800 ? 550 : 400));
            animator.add(a);
        }


        // Update the gamepad tooltips if necessary
        if(masterMenu) {
            masterMenu.background.removeGamepadFooterKey(InputEvent.Key_Pad_X);

            if(!animatingClosed) {
                SkillMenuCheckboxOptionView cb = SkillMenuCheckboxOptionView(optionView);
                if(JoystickConfig.NumJoysticks() && cb && !cb.isDisabledInMenu && opm.subMenu != "" ) {
                    masterMenu.background.addGamepadFooter(InputEvent.Key_Pad_X, "Configure Mutator");
                }
            }
        }
    }


    /*int buildSubOptions(UIVerticalLayout parentview, string menuSet, int indexStart = 0) {
        int lcount = 0;

        let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor(menuSet));
        if(menuDescriptor) {
            for(int x = 0; x < menuDescriptor.mItems.size(); x++) {
                if(menuDescriptor.mItems[x] is 'OptionMenuItemTooltipSlider') {
                    let tts = OptionMenuItemTooltipSlider(menuDescriptor.mItems[x]);
                    let mi = new("SkillMenuSliderOptionView").init(tts);
                    mi.pin(UIPin.Pin_Left);
                    mi.pin(UIPin.Pin_Right);
                    mi.alpha = 1;
                    parentview.addManaged(mi);
                    mi.buttonIndex = indexStart + lcount + 1;
                    lcount++;

                } else if(menuDescriptor.mItems[x] is 'OptionMenuItemTooltipOptionText') {
                    let txt = OptionMenuItemTooltipOptionText(menuDescriptor.mItems[x]);
                    let txtText = new("UILabel").init((0,0), (10, 10), menuDescriptor.mItems[x].mLabel, "PDA13FONT", 0xFFb3adad);
                    txtText.pin(UIPin.Pin_Left, offset: 10 + txt.spaceLeft);
                    txtText.pin(UIPin.Pin_Right, offset: -15 + txt.spaceRight);
                    txtText.pinHeight(UIView.Size_Min);

                    if(txt.spaceTop > 0) parentview.addSpacer(txt.spaceTop);
                    parentview.addManaged(txtText);
                    if(txt.spaceBottom > 0) parentview.addSpacer(txt.spaceBottom);

                } else if(menuDescriptor.mItems[x] is 'OptionMenuItemTooltipOption') {
                    let mi = new("SkillMenuCheckboxOptionView").init(OptionMenuItemTooltipOption(menuDescriptor.mItems[x]));
                    mi.pin(UIPin.Pin_Left);
                    mi.pin(UIPin.Pin_Right);
                    mi.alpha = 1;
                    parentview.addManaged(mi);
                    mi.buttonIndex = indexStart + lcount + 1;
                    lcount++;

                    let u = OptionMenuItemTooltipOptionMode(menuDescriptor.mItems[x]);
                    if(u && u.unlocker != "") {
                        int v;
                        bool success;
                        [v, success] = Globals.GetInt(u.unlocker);

                        if(!success || v < 1) {
                            mi.setDisabled(true);
                        }
                    }
                } else if(menuDescriptor.mItems[x] is 'OptionMenuItemSeparatorTitle') {
                    let vSpace = OptionMenuItemSeparatorTitle(menuDescriptor.mItems[x]).mSize;
                    let separator = new("UIView").init((0,0), (190, vSpace));
                    separator.pin(UIPin.Pin_Left);
                    let spacerInner = new("UIView").init((5,vSpace - 10), (190, 2));
                    spacerInner.backgroundColor = 0xFFDDDDDD;
                    spacerInner.alpha = 0.7;
                    separator.add(spacerInner);
                    let spacerText = new("UILabel").init((5,0), (190, vSpace - 13), menuDescriptor.mItems[x].mLabel, "PDA13FONT", 0xFFb3adad, textAlign: UIView.Align_Bottom);
                    separator.add(spacerText);
                    parentview.addManaged(separator);
                }
            }
        } else {
            Console.Printf("\c[RED]Couldn't load menu descriptor for %s!", menuSet);
        }

        return lcount;
    }*/


    override bool MenuEvent(int mkey, bool fromcontroller) {
		switch (mkey) {
            case Menu.MKEY_Clear:
            {
                if(fromcontroller) {
                    SkillMenuCheckboxOptionView cb = SkillMenuCheckboxOptionView(activeControl);
                    if(cb && !cb.isDisabledInMenu) {
                        // Open the submenu
                        let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("NewGameSettings"));
                        if(menuDescriptor) {
                            let mode = OptionMenuItemTooltipOptionMode(menuDescriptor.mItems[cb.controlID]);
                            if(mode && mode.subMenu != "") {
                                let prompt = new("OptionsPrompt").initNew(self, mode.subMenu, enableDescription: false);
                                prompt.ActivateMenu();
                            }
                        }
                    }
                }
            }
			default:
				break;
		}

		return Super.MenuEvent(mkey, fromcontroller);
	}
}


