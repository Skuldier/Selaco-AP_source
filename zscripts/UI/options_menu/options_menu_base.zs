class SelacoOptionsMenuBase : SelacoGamepadMenu {
    OptionMenuDescriptor optionsDescriptor;
    Array<SOMOptionView> optionViews, presetViews;
    UIVerticalLayout midLay;
    UIControl firstControl, lastControl;

    UIButton linkButt;                               // Reference to the mouse sensitivity link button

    // Gamepad special vars
    int gamepadCount;
    int gamepadIndexStart, gamepadOptionIndexStart;          // First item in generated gamepad settings
    bool isGamepadMenu;                                     // is this a partially generated gamepad menu?

    Array<UIControl> collapsedControlsThatRequireEnabling;  // List of controls that were collapsed and need to be enabled when expanded

    virtual void collapse(Collapser dropControl) {
        if(ticks > 0) {
            dropControl.collapseButton.animateFrame(
                0.25,
                toAngle: 0,
                ease: Ease_Out
            );
        } else {
            dropControl.collapseButton.angle = 0;
        }

        dropControl.isCollapsed = true;

        for(int x = dropControl.startPos + 1; x <= dropControl.endPos; x++) {
            UIView obj = midLay.getManaged(x);
            if(obj) {
                obj.hidden = true;
                if(obj is 'UIControl') {
                    if(!UIControl(obj).isDisabled()) {
                        collapsedControlsThatRequireEnabling.push(UIControl(obj));
                        UIControl(obj).setDisabled(true);
                    }
                }
            }
        }
    }

    virtual void expand(Collapser dropControl) {
        if(ticks > 0) {
            dropControl.collapseButton.animateFrame(
                0.25,
                toAngle: -90,
                ease: Ease_Out
            );
        } else {
            dropControl.collapseButton.angle = -90;
        }

        dropControl.isCollapsed = false;

        for(int x = dropControl.startPos + 1; x <= dropControl.endPos; x++) {
            UIView obj = midLay.getManaged(x);
            if(obj) {
                obj.hidden = false;
                
                if(collapsedControlsThatRequireEnabling.find(UIControl(obj)) < collapsedControlsThatRequireEnabling.size()) {
                    UIControl(obj).setDisabled(false);
                }
            }
        }
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated && ((ctrl.parent && ctrl.parent is 'Collapser') || (ctrl is 'Collapser'))) {
            MenuSound("menu/change");
            let c = Collapser(ctrl.parent);
            if(!c) c = Collapser(ctrl);
            if(c.isCollapsed) {
                expand(c);
            } else {
                collapse(c);
            }

            return;
        }

        Super.handleControl(ctrl, event, fromMouseEvent);
    }


    virtual void linkOptionNavigation() {
        if(firstControl) {
            firstControl.navUp = lastControl;
        }

        if(lastControl) {
            lastControl.navDown = firstControl;
        }
    }


    virtual void createOptionsGroup(string def, UIButton sourceButton = null, UIScrollBarConfig dropScrollConfig = null) {
        // Kill current contents
        isGamepadMenu = false;
        gamepadIndexStart = -1;
        gamepadOptionIndexStart = -1;

        midLay.clearManaged(true);
        optionViews.clear();
        presetViews.clear();

        firstControl = lastControl = null;

        // Get menu description, this will likely be populated with submenus so we will have to get those two into one big list
        optionsDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor(def));
        if(!optionsDescriptor) {
            Console.Printf("\c[red]Failed to read options menu descriptor \"%s\" while building options list.", def);
            return;
        }

        addOptions(optionsDescriptor, sourceButton, null, dropScrollConfig);

        linkOptionNavigation();
    }


    virtual void addOptions(OptionMenuDescriptor desc, UIButton sourceButton = null, UIControl lastCon = null, UIScrollBarConfig dropScrollConfig = null) {
        UIButtonState btnState = UIButtonState.CreateSlices("MODESELC", (8,8), (18, 18), textColor: 0xFFFFFFFF);
        linkButt = null;

        if(dropScrollConfig == null) dropScrollConfig = CommonUI.makeDropScrollConfig();

        OptionMenuItemRequire requireItem = null;
        OptionMenuItemRequireNone requireNoneItem = null;
        OptionMenuItemMustNotHave mustNotHave = null;
        OptionMenuItemMustHave mustHave = null;
        bool shouldDisable = false;
        bool shouldSkip = false;

        for(int x = 0; x < desc.mItems.size(); x++) {
            OptionMenuItem it = OptionMenuItem(desc.mItems[x]);
            if(!it) continue;

            if(it.GetClass() == "OptionMenuItemSubmenu") {
                let o = OptionMenuDescriptor(MenuDescriptor.GetDescriptor(it.GetAction()));
                if(o) {
                    if(OptionMenuItemSubmenu(it).mParam == 1) {
                        // Create a control to handle the collapse/expand
                        let dropControl = addCollapser(it.mLabel);
                        if(!firstControl) { firstControl = dropControl; }
                        if(lastCon) { 
                            lastCon.navDown = dropControl;
                            dropControl.navUp = lastCon;
                        }
                        lastCon = dropControl;

                        // Index the position where collapse will start
                        dropControl.startPos = midLay.numManaged() - 1;
                        addOptions(o, sourceButton, lastCon, dropScrollConfig);
                        dropControl.endPos = midLay.numManaged() - 1;

                        collapse(dropControl);
                    } else {
                        // Just add it to the list
                        // TODO: add spacer?
                        addOptionTitle(StringTable.Localize(it.mLabel));
                        addOptions(o, sourceButton, lastCon, dropScrollConfig);
                    }
                }
                if(lastControl) lastCon = lastControl;
            } else if(it is "OptionMenuItemDisable") {
                shouldDisable = true;
                continue;
            } else if(it is "OptionMenuItemDisableInGame") {
                if(!(level.mapName ~== "TITLEMAP")) {
                    shouldDisable = true;
                    continue;
                }
            } else if(it is "OptionMenuItemOnlyInGame") {
                if(level.mapName ~== "TITLEMAP") {     
                    shouldSkip = true;
                    continue;
                }
            } else if(it is "OptionMenuItemRequireNone") {
                requireNoneItem = OptionMenuItemRequireNone(it);
                continue;
            } else if(it is "OptionMenuItemRequire") {
                requireItem = OptionMenuItemRequire(it);
                continue;
            } else if(it is "OptionMenuItemMustNotHave") {
                mustNotHave = OptionMenuItemMustNotHave(it);
                continue;
            } else if(it is "OptionMenuItemMustHave") {
                mustHave = OptionMenuItemMustHave(it);
                continue;
            } else if(shouldSkip) {
                // Do nothing            
            } else if(it is "OptionMenuItemSeparator") {
                addSeparator(OptionMenuItemSeparator(it).mSize);
            } else if(it is "OptionMenuItemSpace") {
                addSpace(OptionMenuItemSpace(it).mSize);
            } else if(it is "OptionMenuItemSubtext") {
                addOptionTitle(it.mLabel, OptionMenuItemSubtext(it).mColor, OptionMenuItemSubtext(it).mFont, -1, vSpaceAdd: 2);
            } else if(it is "OptionMenuItemStaticText") {
                addOptionTitle(it.mLabel, OptionMenuItemStaticText(it).mColor, 'SEL46FONT', scale: (0.567, 0.567), vSpaceAdd: 2);
            }  else if(it is "OptionMenuItemStaticTextSwitchable") {
                addOptionTitle(it.mLabel, OptionMenuItemStaticTextSwitchable(it).mColor, vSpaceAdd: 2);
            } else if(it is "OptionMenuItemModHeader") {
                let item = OptionMenuItemModHeader(it);
                
                if(midLay.numManaged() > 0) {
                    midLay.addSpacer(40);
                }
                
                // Create a header for the mod
                let v = new("UIVerticalLayout").init((0,0), (1, 280));
                v.pin(UIPin.Pin_Left);
                v.pin(UIPin.Pin_Right);
                //v.pinHeight(UIView.Size_Min);
                v.layoutMode = UIViewManager.Content_SizeParent;

                let imv = new("UIImage").init((0,0), (1, 200), item.mBanner, imgStyle: UIImage.Image_Aspect_Fill);
                imv.backgroundColor = 0x66AAAAAA;
                imv.pin(UIPin.Pin_Left);
                imv.pin(UIPin.Pin_Right);
                v.addManaged(imv);


                // If no valid image could be loaded for the banner, add a text banner as a placeholder
                if(!imv.tex || !imv.tex.isValid()) {
                    let etext = new("UILabel").init((20, 0), (1, 40), StringTable.Localize(item.mName), "SEL52FONT", textAlign: UIView.Align_Centered);
                    etext.pinHeight(UIView.Size_Min);
                    etext.alpha = 0.65;
                    etext.pin(UIPin.Pin_Left, offset: 20);
                    etext.pin(UIPin.Pin_Right, offset: -20);
                    etext.pin(UIPin.Pin_VCenter, UIPin.Pin_VCenter, value: 1.0, offset: -5, isFactor: true);
                    imv.add(etext);
                }

                v.addSpacer(20);

                let tview = new("UIView").init((0,0), (100, 45));
                let ttext = new("UILabel").init((20, 0), (1, 40), StringTable.Localize(item.mName), "SEL46FONT");
                ttext.scaleToHeight(40);
                ttext.pinHeight(UIView.Size_Min);
                ttext.pin(UIPin.Pin_Left);
                ttext.pin(UIPin.Pin_Right);
                tview.add(ttext);

                // Readme Button
                let btn = new("UIButton").init((0,0), (180, 45), "View README", "PDA18FONT",
                    UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: Font.CR_UNTRANSLATED),
                    UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
                    UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
                    UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
                    UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                    UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                    UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13))
                );
                btn.pin(UIPin.Pin_Right);
                btn.pinWidth(UIView.Size_Min);
                btn.setTextPadding(15,4,15,4);
                btn.label.multiline = true;
                btn.rejectHoverSelection = true;
                tview.add(btn);

                tview.pin(UIPin.Pin_Left);
                tview.pin(UIPin.Pin_Right);
                v.addManaged(tview);

                let stext = new("UILabel").init((0, 0), (1, 40), String.Format("\c[DARKGRAY]by \c[HI]%s", StringTable.Localize(item.mAuthor)), "PDA16FONT");
                stext.pin(UIPin.Pin_Left);
                stext.pin(UIPin.Pin_Right);
                stext.pinHeight(UIView.Size_Min);
                v.addManaged(stext);

                if(item.mDescription != "") {
                    v.addSpacer(15);

                    stext = new("UILabel").init((0, 0), (1, 40), String.Format("\c[GREY]%s", StringTable.Localize(item.mDescription)), "PDA16FONT", fontScale: (0.75, 0.75));
                    stext.pin(UIPin.Pin_Left);
                    stext.pin(UIPin.Pin_Right, offset: -20);
                    stext.pinHeight(UIView.Size_Min);
                    v.addManaged(stext);
                }

                 v.addSpacer(10);
                
                midLay.addManaged(v);

                // Setup navigation for readme button
                if(!firstControl) { firstControl = btn; }
                if(lastCon) { 
                    lastCon.navDown = btn;
                    btn.navUp = lastCon;
                }
                lastCon = btn;
            } else {
                if( (mustHave && mustHave.mCvar.getInt() <= 0) || 
                    (mustNotHave && mustNotHave.mCvar.getInt() > 0)) {

                    // Do nothing
                } else {
                    let labelText = it.mLabel.filter();
                    let ov = new("SOMOptionView").init(labelText, it, dropScrollConfig);
                    ov.heightPin = UIPin.Create(0,0,UIView.Size_Min);
                    ov.pin(UIPin.Pin_Right);
                    ov.pin(UIPin.Pin_Left);
                    ov.navUp = lastCon;
                    midLay.addManaged(ov);

                    if(requireItem) {
                        ov.requireCVar = requireItem.mCvar;
                        requireItem = null;
                    } 

                    if(requireNoneItem) {
                        ov.requireNoneCVar = requireNoneItem.mCvar;
                        requireNoneItem = null;
                    }

                    if(!firstControl) { firstControl = ov; }
                    if(lastCon) { lastCon.navDown = ov; }
                    lastCon = ov;

                    optionViews.push(ov);
                    ov.index = optionViews.size() - 1;

                    // Special case: If this is the YAxis mouse sensitivity view, add a link/unlink button
                    if(ov.menuItem.getAction() == 'm_sensitivity_x') {
                        linkButt = new("UIButton").init(
                            (0,0), (30, 30), "", null,
                            UIButtonState.Create("op_link4"),
                            UIButtonState.Create("op_link3"),
                            UIButtonState.Create("op_link6"),
                            null,
                            UIButtonState.Create("op_link1"),
                            UIButtonState.Create("op_link2"),
                            UIButtonState.Create("op_link5")
                        );

                        linkButt.command = "linksens";
                        linkButt.setSelected(iGetCVar('m_sensitivity_linked'));
                        linkButt.pin(UIPin.Pin_Right, value: 0.6, offset: -40, isFactor: true);
                        linkButt.pin(UIPin.Pin_VCenter, UIPin.Pin_VCenter, value: 1.0, offset: 0, isFactor: true);
                        ov.add(linkButt);
                        ov.clipsSubviews = false;
                    } else if(ov.menuItem.getAction() == 'm_sensitivity_y' && iGetCVar('m_sensitivity_linked')) {
                        ov.setDisabled(true);
                    } else if(ov.requireCVar && ov.requireCVar.GetInt() <= 0) {
                        ov.setDisabled(true);
                    }

                    if(it is "OptionMenuItemTooltipPreset") {
                        presetViews.push(ov);
                    }

                    // Special case: If this is a color slider, and the previous item is a color dropdown
                    // we assume they are linked
                    if(it is 'OptionMenuItemColorPicker' && SOMOptionView(ov.navUp) && SOMOptionView(ov.navUp).menuItem is 'OptionMenuItemColorPickerDD') {
                        // Check value to see if we should hide the custom color picker
                        ov.hidden = OptionMenuItemColorPickerDD(SOMOptionView(ov.navUp).menuItem).getSelection() > 0;
                        ov.setDisabled(ov.hidden);
                    }

                    if(shouldDisable) {
                        ov.setDisabled(true);
                        Console.Printf("\c[red]Disabling option %s because of previous item.", ov.menuItem.mLabel);
                    }
                }

                mustHave = null;
                mustNotHave = null;
            }

            shouldDisable = false;
            shouldSkip = false;
        }

        lastControl = lastCon;

        // Special case, if this is the Gamepad Options menu, add additional items
        if(desc.mMenuName == "GamepadOptions") {
            // Save the index of the first gamepad option so we know where to reload from if gamepads change
            isGamepadMenu = true;
            gamepadIndexStart = midLay.numManaged();
            gamepadOptionIndexStart = optionViews.size();

            addGamepadOptions(dropScrollConfig);
        }

        // Special case, if this is the Mods options menu, add additional items
        if(desc.mMenuName == "ModOptionsMenu") {
            addModOptions(desc);
        }
    }


    virtual void addOptionTitle(string title, int color = 0xFFFFFFFF, Font fnt = "SEL21FONT", int height = 50, Vector2 scale = (1,1), int vSpaceAdd = 0) {
        UIView v;

        if(height > 0) {
            v = new("UIView").init((0,0), (0,2));
            v.heightPin = UIPin.Create(UIPin.Pin_Static, UIPin.Pin_Static, height);
            v.pin(UIPin.Pin_Left);
            v.pin(UIPin.Pin_Right);
        }

        UILabel lab = new("UILabel").init((0,0), (0, 50), StringTable.Localize(title), fnt, textColor: color, textAlign: UIView.Align_Left | UIView.Align_Bottom, scale);
        //lab.heightPin = UIPin.Create(UIPin.Pin_Static, UIPin.Pin_Static, height);
        lab.pin(UIPin.Pin_Left);
        lab.pin(UIPin.Pin_Right);
        
        if(v) {
            lab.pin(UIPin.Pin_Top);
            lab.pin(UIPin.Pin_Bottom, offset: -5);
            v.add(lab);
            midLay.addManaged(v);
        } else {
            lab.pinHeight(UIView.Size_Min);
            midLay.addManaged(lab);

            if(vSpaceAdd > 0) {
                let v = new("UIView").init((0,0), (0,2));
                v.pinHeight(vSpaceAdd);
                v.pin(UIPin.Pin_Left);
                v.pin(UIPin.Pin_Right);
                midLay.addManaged(v);
            }
        }
    }


    virtual void addSeparator(int height = 2) {
        UIView v = new("UIView").init((0,0), (0,height));
        v.backgroundColor = 0x33666666;
        v.pin(UIPin.Pin_Left);
        v.pin(UIPin.Pin_Right);
        midLay.addManaged(v);
    }


    virtual void addSpace(int height) {
        midLay.addManaged(new("UIView").init((0,0), (0, height)));
    }
    

    SOMOptionView addOptionView(OptionMenuItem it, UIScrollBarConfig dropScrollConfig) {
        let labelText = it.mLabel.filter();
        let ov = new("SOMOptionView").init(labelText, it, dropScrollConfig);
        ov.heightPin = UIPin.Create(0,0,UIView.Size_Min);
        ov.pin(UIPin.Pin_Right);
        ov.pin(UIPin.Pin_Left);
        ov.navUp = lastControl;
        midLay.addManaged(ov);

        if(!firstControl) { firstControl = ov; }
        if(lastControl) { lastControl.navDown = ov; }
        lastControl = ov;

        optionViews.push(ov);

        return ov;
    }


    Collapser addCollapser(string label) {
        Collapser dropControl = Collapser(new("Collapser").init(label));
        dropControl.pin(UIPin.Pin_Left);
        dropControl.pin(UIPin.Pin_Right);
        //dropControl.backgroundColor = 0x7700FF00;

        /*UILabel lab = new("UILabel").init((0,0), (0, 50), StringTable.Localize(label), "SEL21FONT", textAlign: UIView.Align_Left | UIView.Align_VCenter);
        lab.pinToParent(0,0,-80, 0);
        dropControl.add(lab);*/
        
        midLay.addManaged(dropControl);

        return dropControl;
    }


    virtual void addGamepadOptions(UIScrollBarConfig dropScrollConfig) {
        int numJoys = JoystickConfig.NumJoysticks();
        
        if(numJoys <= 0) {
            addOptionTitle(String.Format("\c[GOLD]%s", StringTable.Localize("$GAMEPAD_NONEFOUND")));
            return;
        }
        
        for(int x = 0; x < numJoys; x++) {
            let j = JoystickConfig.GetJoystick(x);

            addOptionTitle(String.format("\c[HI]%s", j.getName()));

            // Add overall sensitivity
            OptionMenuItem item = new("OptionMenuSliderGamepadSensitivity").init(
                "$SETTING_GAMEPAD_OVERALLSENS",
                "$DESCRIPTION_GAMEPAD_OVERALLSENS",
                "",
                0, 2, 0.025, 3, j
            );
            addOptionView(item, dropScrollConfig);

            // Reset to defaults
            item = new("OptionMenuGamepadResetDefaults").init(
                "$SETTING_GAMEPAD_DEFAULTS",
                "$DESCRIPTION_GAMEPAD_DEFAULTS",
                "",
                j
            );
            let ov = addOptionView(item, dropScrollConfig);
            if(ov != null) ov.command = "reset";

            // Add each axis
            for(int y = 0; y < j.getNumAxes(); y++) {
                item = new("OptionMenuItemGamepadMap").init(
                    j.getAxisName(y),
                    "$DESCRIPTION_GAMEPAD_AXISFUNC",
                    "",
                    y, "JoyAxisMapNames", false, j
                );
                addOptionView(item, dropScrollConfig);

                if(iGetCVar("g_gamepad_advanced")) {
                    // Sensitivity scale
                    item = new("OptionMenuSliderGamepadScale").init(
                        "\t$SETTING_GAMEPAD_SENSSCALE",
                        "$DESCRIPTION_GAMEPAD_SENSSCALE",
                        "",
                        y, 0, 4, 0.025, 3, j
                    );
                    addOptionView(item, dropScrollConfig);

                    // Invert Axis
                    item = new("OptionMenuItemGamepadInverter").init(
                        "\t$SETTING_GAMEPAD_INVERTAXIS",
                        "$DESCRIPTION_GAMEPAD_INVERTAXIS",
                        "",
                        y, false, j
                    );
                    addOptionView(item, dropScrollConfig);

                    // Acceleration - Only in advanced
                    item = new("OptionMenuSliderGamepadAcceleration").init(
                        "\t$SETTING_GAMEPAD_ACCEL",
                        "$DESCRIPTION_GAMEPAD_ACCEL",
                        "",
                        y, 0, 1.0, 0.025, 3, j
                    );
                    addOptionView(item, dropScrollConfig);

                    // Deadzone - Only show in advanced mode
                    item = new("OptionMenuSliderGamepadDeadZone").init(
                        "\t$SETTING_GAMEPAD_DEADZONE",
                        "$DESCRIPTION_GAMEPAD_DEADZONE",
                        "",
                        y, 0, 0.9, 0.025, 3, j
                    );
                    addOptionView(item, dropScrollConfig);
                }
            }

            addSpace(50);
        }
    }


    virtual void reloadGamepads(UIScrollBarConfig dropScrollConfig = null) {
        if(!isGamepadMenu || gamepadIndexStart < 0) return;

        int activeControlIndex = -1;
        lastActiveControl = null;

        // If the current active control inside the gamepad section, get the index
        if(activeControl && activeControl is "SOMOptionView") {
            for(int x = 0; x < optionViews.size(); x++) {
                if(activeControl == UIView(optionViews[x])) {
                    activeControlIndex = x;
                    break;
                }
            }
        }

        if(gamepadOptionIndexStart >= 0) {
            optionViews.delete(gamepadOptionIndexStart, optionViews.size() - gamepadOptionIndexStart);
        }

        midLay.removeManagedAt(gamepadIndexStart, midLay.numManaged() - gamepadIndexStart);

        // Find the new "last" usable control in the list by searching upwards
        lastControl = null;
        for(int x = midLay.numManaged() - 1; x >= 0; x--) {
            let obj = midLay.getManaged(x);
            if(obj is "SOMOptionView") {
                lastControl = SOMOptionView(obj);
                break;
            }
        }

        addGamepadOptions(dropScrollConfig);

        // Fix the active control, since we were inside the dynamic section
        if(activeControlIndex >= 0 && activeControlIndex >= gamepadOptionIndexStart) {
            if(activeControlIndex < optionViews.size()) {
                navigateTo(optionViews[activeControlIndex]);
            } else {
                navigateTo(optionViews[optionViews.size() - 1]);
            }
        }

        // Relink the loop
        linkOptionNavigation();
    }


    void addModOptions(OptionMenuDescriptor desc) {
        if(desc.mItems.size() == 0) {
            // No mod options yet
            addOptionTitle("No mods installed with options.\nTo install mods manually, move the PK3 into the MODS folder in the game directory.", Font.CR_RED, 'PDA16FONT');
        }

        // Display a list of added wadfiles in /mods/ folder
        int numWads = Wads.GetNumWads();
        bool firstWadFound = false;
        let wi = Wads.GetLumpWadNum(Z_CONTAINER);
        for(int x = wi + 1; x < numWads; x++) {
            string wadName = Wads.GetWadName(x);
            int modFolder = wadName.makeLower().rightIndexOf("/");
            if(modFolder < int(wadName.length())) wadName = wadName.mid(modFolder + 1);

            if(modFolder > -1) {
                if(!firstWadFound) {
                    firstWadFound = true;
                    addSpace(20);
                    addOptionTitle("Installed mods:");
                }

                addOptionTitle(wadName, fnt:'PDA16FONT', height:25, scale: (0.75, 0.75));
            }
        }
    }
}


class Collapser : UIButton {
    int startPos, endPos;
    bool isCollapsed;
    UIButton collapseButton;

    Collapser init(string label) {
        Super.init((0,0), (0, 50),
            label, "SEL21FONT",
            UIButtonState.CreateSlices("graphics/options_menu/op_bg2.png", (11,11), (19,19)),
            UIButtonState.CreateSlices("graphics/options_menu/op_bg.png", (11,11), (19,19)),
            UIButtonState.CreateSlices("graphics/options_menu/op_bg.png", (11,11), (19,19))
        );

        setTextPadding(15, 0, 80, 0);
        self.label.textAlign = UIView.Align_Left | UIView.Align_VCenter;

        // Add button to collapse/expand the section
        collapseButton = new("UIButton").init((0,0), (32,32), "", null,
            UIButtonState.Create("graphics/options_menu/arrow_right.png"),
            UIButtonState.Create("graphics/options_menu/arrow_right_high.png", sound: "ui/cursor2", soundVolume: 0.45),
            UIButtonState.Create("graphics/options_menu/arrow_right_down.png"),
            UIButtonState.Create("graphics/options_menu/arrow_right.png")
        );
        collapseButton.command = "collapse";
        collapseButton.pin(UIPin.Pin_Right, offset: -20);
        collapseButton.pin(UIPin.Pin_VCenter, value: 1.0);
        collapseButton.rejectHoverSelection = true;
        collapseButton.forwardSelection = self;
        add(collapseButton);

        return self;
    }
    

    override bool menuEvent(int key, bool fromcontroller) {
        let m = getMenu();
        let mo = SelacoOptionsMenuBase(m);

        if(key == Menu.MKEY_Left) {
            if(!isCollapsed && mo) {
                playSound("menu/change");
                mo.collapse(self);
                return true;
            }
        } else if(key == Menu.MKEY_Right) {
            if(isCollapsed && mo) {
                playSound("menu/change");
                mo.expand(self);
                return true;
            }
        }

        return false;
    }
}