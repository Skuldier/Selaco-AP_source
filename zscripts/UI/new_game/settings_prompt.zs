class NewGameSettingsPrompt : CustomPromptPopup {
    UIVerticalScroll settingsScroll;
    UIVerticalLayout settingsLayout, mutatorLayout;
    UIVerticalLayout skillLayout;
    UIMenu parentMenu;
    UILabel descriptionLabel, descriptionTitle;
    UIButton mutatorButt, randomizerButt;
    int chosenSkill;
    bool showDescriptions;
    bool resetOnClose;
    bool noCancel;

    UIView centerView;
    SkillMenuRadioOptionView smfButt, admiralButt;

    Array<UIView> mutatorViews;

    mixin CVARBuddy;

    const CENTER_DIVIDER = 350;
    const WINDOW_WIDTH = 450;
    const WINDOW_FULL_WIDTH = 820;

    override void init(Menu parent) {
        titleText = StringTable.Localize("$SKILL_NEWOPTIONS");

		Super.init(parent);

        parentMenu = UIMenu(parent);

        layout.firstPin(UIPin.Pin_VCenter).value = 1.0;
        //layout.frame.size.x += max(layout.frame.size.x, 600);
        layout.frame.size.x = WINDOW_WIDTH;
        
        let textIndex = layout.managedIndex(inputText) - 1;
        layout.removeManagedAt(textIndex);
        layout.removeManagedAt(textIndex);
        inputText.destroy();
        inputText = null;

        chosenSkill = skill;

        okButton.label.text = "Start Game";
        okButton.setDisabled(false);

        if(noCancel && cancelButton) {
            UIHorizontalLayout horz = UIHorizontalLayout(cancelButton.parent);
            if(horz) horz.removeManaged(cancelButton);
            cancelButton.setDisabled(true);
        }

        // Create description field =================================================
        //double leftSize = showDescriptions ? -580 : 0;

        /*if(showDescriptions) {
            descriptionTitle = new("UILabel").init((0,0), (100, 100), "Title", 'SEL21FONT');
            descriptionTitle.multiline = false;
            descriptionTitle.pin(UIPin.Pin_Right);
            descriptionTitle.pin(UIPin.Pin_Top, offset: 85);
            descriptionTitle.pinHeight(UIView.Size_Min);
            descriptionTitle.pin(UIPin.Pin_Left, UIPin.Pin_Right, offset: leftSize);
            layout.add(descriptionTitle);

            descriptionLabel = new("UILabel").init((0,0), (100, 100), "Description Text", 'PDA18FONT');
            descriptionLabel.pin(UIPin.Pin_Right);
            descriptionLabel.pin(UIPin.Pin_Top, offset: 125);
            descriptionLabel.pin(UIPin.Pin_Bottom, offset: -100);
            descriptionLabel.pin(UIPin.Pin_Left, UIPin.Pin_Right, offset: leftSize);
            layout.add(descriptionLabel);
        }*/

        centerView = new("UIView").init((0,0),(0,0));
        centerView.pin(UIPin.Pin_Left);
        centerView.pin(UIPin.Pin_Right);
        centerView.frame.size.y = 700;
        centerView.minSize.y = 700;
        layout.insertManaged(centerView, textIndex);

        // Add options  =============================================================
        skillLayout = new("UIVerticalLayout").init((0,0), (500, 100));
        skillLayout.ignoreHiddenViews = true;
        skillLayout.pin(UIPin.Pin_Left);
        skillLayout.pin(UIPin.Pin_Top, offset: -20);
        skillLayout.pin(UIPin.Pin_Bottom);
        skillLayout.pinWidth(CENTER_DIVIDER);
        centerView.add(skillLayout);


        settingsScroll = new("UIVerticalScroll").init((0,0), (500, 100), 14, 14,
            NineSlice.Create("PDABAR1", (7,9), (8,21)), null,
            UIButtonState.CreateSlices("PDABAR2", (7,9), (8,21)),
            UIButtonState.CreateSlices("PDABAR3", (7,9), (8,21)),
            UIButtonState.CreateSlices("PDABAR4", (7,9), (8,21))
        );

        settingsScroll.mLayout.ignoreHiddenViews = true;
        settingsScroll.scrollbar.rejectHoverSelection = true;
        settingsScroll.rejectHoverSelection = true;
        settingsScroll.autoHideScrollbar = true;

        //settingsLayout = new("UIVerticalLayout").init((0,0), (500, 100));
        mutatorLayout = new("UIVerticalLayout").init((0,0), (500, 100));
        mutatorLayout.layoutMode = UIViewManager.Content_SizeParent;
        mutatorLayout.pinHeight(UIView.Size_Min);
        mutatorLayout.pin(UIPin.Pin_Left);
        mutatorLayout.pin(UIPin.Pin_Right);

        settingsLayout = UIVerticalLayout(settingsScroll.mLayout);
        //settingsScroll.pin(UIPin.Pin_Left, 300);
        //settingsScroll.pin(UIPin.Pin_Right, offset: 0);
        //settingsLayout.pin(UIPin.Pin_Top, value: 60);
        //settingsScroll.minSize.y = 400;
        //settingsScroll.maxSize.y = 900;
        //settingsScroll.pinHeight(UIView.Size_Min);
        settingsScroll.pinToParent(CENTER_DIVIDER, -20, 0, 0);
        //settingsLayout.layoutMode = UIViewManager.Content_SizeParent;
        //settingsLayout.itemSpacing = 8;
        settingsLayout.clipsSubviews = false;
        //layout.insertManaged(settingsScroll, textIndex);
        centerView.add(settingsScroll);

        settingsScroll.hidden = true;


        // Create Game Mode options
        skillLayout.addManaged(createSectionHeader("Campaign", 60));
        let campaign1 = new("SkillMenuRadioOptionView").init(StringTable.Localize("$MENU_STANDARD_CAMPAIGN"),100,!g_randomizer);
        let campaign2 = new("SkillMenuRadioOptionView").init(StringTable.Localize("$MENU_RANDOMIZER_CAMPAIGN"),101,g_randomizer);
        campaign1.groupID = campaign2.groupID = 2;

        skillLayout.addManaged(campaign1);
        skillLayout.addManaged(campaign2);

        skillLayout.addSpacer(30);

        // Add randomizer settings button
        randomizerButt = new("UIButton").init((0,0), (100, 40), "Configure Randomizer", "SEL21FONT",
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999)
        );
        randomizerButt.pinWidth(UIView.Size_Min);
        randomizerButt.pin(UIPin.Pin_Left, offset: 22);
        randomizerButt.pinHeight(40);
        randomizerButt.minSize.y = 40;
        randomizerButt.setTextPadding(20, 0, 20, 0);
        skillLayout.addManaged(randomizerButt);
        

        // Create skill options
        skillLayout.addManaged(createSectionHeader("Skill", 60));
        skillLayout.addManaged(new("SkillMenuRadioOptionView").init(StringTable.Localize("$SKILL_0"),0,skill <= 0 || skill > 5));
        skillLayout.addManaged(new("SkillMenuRadioOptionView").init(StringTable.Localize("$SKILL_1"),1,skill == 1));
        skillLayout.addManaged(new("SkillMenuRadioOptionView").init(StringTable.Localize("$SKILL_2"),2,skill == 2));
        skillLayout.addManaged(new("SkillMenuRadioOptionView").init(StringTable.Localize("$SKILL_3"),3,skill == 3));

        admiralButt = new("SkillMenuRadioOptionView").init(StringTable.Localize("$SKILL_4"),4,skill == 4 || skill == 5);
        skillLayout.addManaged(admiralButt);

        smfButt = new("SkillMenuRadioOptionView").init(StringTable.Localize("$SKILL_5"),5,false);
        skillLayout.addManaged(smfButt);


        if(g_randomizer) {
            chosenSkill = min(4, chosenSkill);
            smfButt.setDisabled(true);
        } else {
            randomizerButt.hidden = true;
        }

        skillLayout.addSpacer(30);


        mutatorButt = new("UIButton").init((0,0), (100, 40), "Show Mutators", "SEL21FONT",
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999)
        );
        mutatorButt.pinWidth(UIView.Size_Min);
        mutatorButt.pin(UIPin.Pin_Left, offset: 22);
        mutatorButt.pinHeight(40);
        mutatorButt.minSize.y = 40;
        mutatorButt.setTextPadding(20, 0, 20, 0);
        skillLayout.addManaged(mutatorButt);

        
        //mutatorLayout.hidden = true;
        settingsLayout.addManaged(mutatorLayout);

        // Add a little seperator
        /*mutatorLayout.addSpacer(15);
        let spacer = new("UIView").init((0,0), (0, 2));
        spacer.pin(UIPin.Pin_Left, offset: 35);
        spacer.pin(UIPin.Pin_Right, offset: -35);
        spacer.backgroundColor = 0x66FFFFFF;
        mutatorLayout.addManaged(spacer);
        mutatorLayout.addSpacer(15);*/
        mutatorLayout.addSpacer(30);

        // Create controls for gameplay options
        let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("NewGameSettings"));
        if(menuDescriptor) {
            UIButton lastButt = null;
            for(int x = 0; x < menuDescriptor.mItems.size(); x++) {
                if(menuDescriptor.mItems[x] is 'OptionMenuItemTooltipSlider') {
                    let mi = new("SkillMenuSliderOptionView2").init(OptionMenuItemTooltipSlider(menuDescriptor.mItems[x]));
                    mi.pin(UIPin.Pin_Left, offset: 15);
                    mutatorLayout.addManaged(mi);
                    mi.buttonIndex = x + 5;

                } else if(menuDescriptor.mItems[x] is 'OptionMenuItemTooltipOption') {
                    let mi = new("SkillMenuCheckboxOptionView2").init(OptionMenuItemTooltipOption(menuDescriptor.mItems[x]));
                    mi.pin(UIPin.Pin_Left, offset: 15);
                    mutatorLayout.addManaged(mi);
                    mi.buttonIndex = x + 5;

                    let u = OptionMenuItemTooltipOptionMode(menuDescriptor.mItems[x]);
                    bool disabled = false;
                    if(u && u.unlocker != "") {
                        int v;
                        bool success;
                        [v, success] = Globals.GetInt(u.unlocker);

                        if(u.unlocker == 'staylocked' || !success || v < 1) {
                            mi.setDisabled(true);
                            disabled = true;
                        }
                    }

                    if(u && u.subMenu != "" && !disabled) {
                        mi.command = "submenu";
                        mi.controlID = x;
                        mi.cancelsSubviewRaycast = false;

                        // Add a mouse-only options button inside this control
                        let oButt = new("UIButton").init((0,0), (180, 45), "", "PDA18FONT",
                            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: Font.CR_UNTRANSLATED),
                            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
                            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
                            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
                            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13))
                        );
                        
                        oButt.pin(UIPin.Pin_Right, offset: -25);
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
                    mutatorLayout.addManaged(createSectionHeader(menuDescriptor.mItems[x].mLabel, OptionMenuItemSeparatorTitle(menuDescriptor.mItems[x]).mSize));
                }
            }
            
        } else {
            Console.Printf("\c[RED]Couldn't load menu descriptor for NewGameSettings!");
        }

        // Set up navigation order
        let firstCon = setupNavigation();

        if(firstCon) {
            navigateTo(firstCon);
        }
        else navigateTo(okButton);
        
        /*if(isUsingController() || isUsingKeyboard()) {
            navigateTo(okButton);
        }*/
    }


    UIView createSectionHeader(String text, int vSpace = 25) {
        let separator = new("UIView").init((0,0), (190, vSpace));
        separator.pin(UIPin.Pin_Left, offset: 15);
        let spacerInner = new("UIView").init((5,vSpace - 10), (190, 2));
        spacerInner.backgroundColor = 0xFFDDDDDD;
        spacerInner.alpha = 0.7;
        separator.add(spacerInner);
        let spacerText = new("UILabel").init((5,0), (190, vSpace - 13), text, "PDA13FONT", 0xFFb3adad, textAlign: UIView.Align_Bottom);
        separator.add(spacerText);
        return separator;
    }


    UIControl setupNavigation() {
        UIControl lastCon = null, firstCon = null;
        for(int x = 0; x < settingsLayout.numManaged(); x++) {
            let con = UIControl(settingsLayout.getManaged(x));
            if(con) {
                con.navDown = okButton;

                if(x > 0) {
                    if(lastCon) lastCon.navDown = con;
                    con.navUp = lastCon;
                } else {
                    con.navUp = okButton;
                }

                if(!firstCon) firstCon = con;
                lastCon = con;

                con.navRight = cancelButton;
            }
        }

        if(!mutatorLayout.hidden) {
            for(int x = 0; x < mutatorLayout.numManaged(); x++) {
                let con = UIControl(mutatorLayout.getManaged(x));
                if(con) {
                    con.navDown = okButton;

                    if(lastCon) lastCon.navDown = con;
                    con.navUp = lastCon;
    
                    if(!firstCon) firstCon = con;
                    lastCon = con;
    
                    con.navRight = cancelButton;
                }
            }
        }
        

        // ===================================================================================

        if(lastCon) {
            cancelButton.navLeft = lastCon;
        }

        okButton.navUp = lastCon;
        cancelButton.navUp = okButton.navUp;

        if(firstCon) {
            okButton.navDown = firstCon;
            cancelButton.navDown = firstCon;
        }

        return firstCon;
    }


    void setDescription(string text) {
         // Get the first line as the title
        Array<string> lines;
        text.split(lines, "\n");

        if(lines.size() > 1) {
            descriptionTitle.setText(lines[0]);

            // Hello GC, I see you over there
            let s = lines[1];
            for(int x = 2; x < lines.size(); x++) s = s .. "\n" .. lines[x];
            descriptionLabel.setText(s);
            descriptionLabel.layout();
        } else {
            descriptionTitle.setText("");
            descriptionLabel.setText(text);
            descriptionLabel.layout();
        }
    }


    override void onFirstTick() {
        Super.onFirstTick();
    }


    override UIControl findFirstControl(int mkey) {
		return okButton;
	}


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(event == UIHandler.Event_Activated) {
            let bb = SkillMenuOptionView(ctrl);
            if(bb) {
                if(bb is 'SkillMenuRadioOptionView' && !bb.isDisabledInMenu) {
                    let bb = SkillMenuRadioOptionView(bb);
                    if(!bb.checkbox.isSelected()) bb.toggle(fromMouseEvent, fromController);

                    // Toggle all radios
                    for(int x = 0; x < skillLayout.numManaged(); x++) {
                        let bb2 = SkillMenuRadioOptionView(skillLayout.getManaged(x));
                        if(bb2 && bb2 != bb && bb2.groupID == bb.groupID) {
                            bb2.checkbox.setSelected(false);
                        }
                    }

                    if(bb.groupID == 2) {
                        // Set the campaign mode
                        bool isRandomizer = bb.controlID == 101;
                        iSetCVAR('g_randomizer', isRandomizer);

                        if(isRandomizer) {
                            // Deselect SMF
                            if(smfButt.checkbox.isSelected()) {
                                smfButt.checkbox.setSelected(false);
                                admiralButt.checkbox.setSelected(true);
                            }

                            chosenSkill = min(4, chosenSkill);
                            randomizerButt.hidden = false;
                            
                            // Disable SMF
                            smfButt.setDisabled(true);
                        } else {
                            randomizerButt.hidden = true;
                            smfButt.setDisabled(false);
                        }

                        skillLayout.requiresLayout = true;
                    } else {
                        // Set the skill
                        chosenSkill = bb.controlID;
                    }
                } else {
                    bb.toggle(fromMouseEvent, fromController);
                }
                return;
            }

            if(ctrl == okButton) {
                // OK Button pressed, send info to parent
                if(parentMenu) {
                    parentMenu.MenuEvent(MKEY_MBYes, fromController);
                }
                animateClosed(true);
            } else if(ctrl == cancelButton) {
                // Reset any of the selected CVARs
                if(resetOnClose) resetSelections();

                MenuSound("menu/OSKBackspace");

                if(parentMenu) {
                    parentMenu.MenuEvent(MKEY_Abort, fromController);
                }

                animateClosed(false);
            } else if(ctrl == mutatorButt) {
                toggleMutators();
            } else if(ctrl == randomizerButt) {
                // Open Randomizer configuration
                MenuSound("menu/advance");

                let prompt = new("OptionsPrompt").initNew(self, "RandomizerSettings", enableReset: true);
                prompt.ActivateMenu();
            } else if(ctrl.command == "config") {
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
        } else if(event == UIHandler.Event_Selected && showDescriptions) {
            let bb = SkillMenuOptionView(ctrl);
            if(bb) {
                let op = OptionMenuItemTooltipOption(bb.menuItem);
                let text = op ? StringTable.Localize(op.mTooltip) : "";
                if(!op) {
                    let op = OptionMenuItemTooltipSlider(bb.menuItem);
                    if(op) {
                        text = StringTable.Localize(op.mTooltip);
                    }
                }

                setDescription(text);
            }
        }
    }


    void toggleMutators() {
        if(settingsScroll.hidden) {
            // TODO: Animate showing
            //scrollView.maxSize.y = mainView.frame.size.y - 380;
            settingsScroll.hidden = false;
            mutatorButt.label.text = "Hide Mutators";
        } else {
            // TODO: Animate hiding
            settingsScroll.hidden = true;
            mutatorButt.label.text = "Show Mutators";
        }

        let oldSize = layout.frame.size;
        let oldPos = layout.frame.pos;
        layout.frame.size.x = settingsScroll.hidden ? WINDOW_WIDTH : WINDOW_FULL_WIDTH;
        layout.layout();
        
        // Animate new settingsScroll size
        let anim = layout.animateFrame(
            0.2,
            fromPos: oldPos,
            toPos: layout.frame.pos,
            fromSize: oldSize,
            toSize: layout.frame.size, 
            //layoutSubviewsEveryFrame: true,
            ease: Ease_Out
        );
        
        layout.frame.size = oldSize;

        setupNavigation();
    }


    override bool navigateTo(UIControl con, bool mouseSelection) {
        let bb = SkillMenuOptionView(con);
        let ff = Super.navigateTo(con, mouseSelection);

        if(bb) {
            if(!mouseSelection) settingsScroll.scrollTo(bb, true, 40);
        }
        
        return ff;
	}


    override void ticker() {
        Super.ticker();
    }

     override bool onBack() {
        if(resetOnClose) resetSelections();
        MenuSound("menu/backup");
        
        if(parentMenu) {
            parentMenu.MenuEvent(MKEY_Abort, false);
        }

        animateClosed();
		return true;
	}

    void resetSelections() {
        UIHelper.ResetNewGameOptions();
    }
}