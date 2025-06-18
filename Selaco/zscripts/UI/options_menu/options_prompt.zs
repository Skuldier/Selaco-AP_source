class OptionsPrompt : SelacoOptionsMenuBase {
    String optionsGroup;
    UIMenu parentMenu;
    UIImage mainBG, bg, previewImage;
    UILabel titleLabel, valueLabel, tooltipLabel, valueTitleLabel;
    UIVerticalScroll scrollView;
    UIVerticalScroll descriptionScroll;
    UIVerticalLayout descriptionLayout;
    UIButton okButton, resetButton;

    bool enableReset, enableDescription;

    int closeTicks;
    int requiresItemLayout, requiresPresetLayout, requiresItemUpdate;

    OptionsPrompt initNew(UIMenu parent, string optionsGroup, bool enableReset = false, bool enableDescription = true) {
        self.enableDescription = enableDescription;
        self.optionsGroup = optionsGroup;
        parentMenu = parent;
        self.enableReset = enableReset;
        init(parent);

        return self;
    }



    override void init(Menu parent) {
		Super.init(parent);
        AnimatedTransition = false;
        allowDimInGameOnly();

        gamepadIndexStart = -1;
        isGamepadMenu = false;
        
        // Create main options container
        bg = new("UIImage").init((0,0), (100, 100), "TUTMBG");
        bg.pinToParent();
        bg.alpha = 0;
        mainView.add(bg);

        mainBG = new("UIImage").init(
            (0,0), (99999, 850), "",
            NineSlice.Create("PROMPTB4", (30, 70), (40, 76))
        );
        mainBG.maxSize.x = enableDescription ? min(Screen.GetWidth() - 80, 1330) : 850;
        mainBG.alpha = 0;
        mainBG.pin(UIPin.Pin_VCenter, value: 1.0);
        mainBG.pin(UIPin.Pin_HCenter, value: 1.0);

        mainView.add(mainBG);

        titleLabel = new("UILabel").init(
            (0,0), (100, 37),
            "Title",
            'SEL21FONT',
            textAlign: UIView.Align_Centered,
            fontScale: (0.95, 0.95)
        );
        titleLabel.pin(UIPin.Pin_Top, offset: 24);
        titleLabel.pin(UIPin.Pin_Left, offset: 30 + 15);
        titleLabel.pin(UIPin.Pin_Right, offset: -30 - 15);
        mainBG.add(titleLabel);

        scrollView = new("OptionsVerticalScroll").init((0,0), (0,0), 30, 24,
            NineSlice.Create("graphics/options_menu/slider_bg_vertical.png", (14, 6), (16, 24)),
            null,
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down.png", (8,8), (13,13)),
            insetA: 5, insetB: 5
        );
        scrollView.pinToParent(30, 75 - 8, enableDescription ? -(340 + 5) : -25, -100);
        scrollView.autoHideScrollbar = true;
        scrollView.scrollbar.buttonSize = 20;
        scrollView.scrollbar.rejectHoverSelection = true;
        scrollView.rejectHoverSelection = true;
        scrollView.mLayout.ignoreHiddenViews = true;
        scrollView.mLayout.layoutWithChildren = true;
        scrollView.mLayout.setPadding(25, 25, 10, 25);
        mainBG.add(scrollView);
        
        // Configure preview pane

        descriptionScroll = new("OptionsVerticalScroll").init((0,0), (0,0), 30, 24,
            NineSlice.Create("graphics/options_menu/slider_bg_vertical.png", (14, 6), (16, 24)),
            null,
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down.png", (8,8), (13,13)),
            insetA: 5, insetB: 5
        );
        descriptionScroll.pin(UIPin.Pin_Top, offset: 75);
        descriptionScroll.pin(UIPin.Pin_Right, offset: -5);
        descriptionScroll.pinWidth(350);
        descriptionScroll.pin(UIPin.Pin_Bottom, offset: -100);
        descriptionScroll.autoHideScrollbar = true;
        descriptionScroll.scrollbar.buttonSize = 20;
        descriptionScroll.scrollbar.rejectHoverSelection = true;
        descriptionScroll.rejectHoverSelection = true;
        descriptionScroll.mLayout.ignoreHiddenViews = true;
        descriptionScroll.mLayout.layoutWithChildren = true;
        descriptionScroll.mLayout.setPadding(5, 10, 0, 25);
        descriptionLayout = UIVerticalLayout(descriptionScroll.mLayout);
        
        if(enableDescription) mainBG.add(descriptionScroll);


        previewImage = new("UIImage").init((0,0), (100, 305), "", imgStyle: UIImage.Image_Aspect_Fit);
        previewImage.pin(UIPin.Pin_Left, offset: 0);
        previewImage.pin(UIPin.Pin_Right, offset: 0);
        descriptionLayout.addManaged(previewImage);


        valueTitleLabel = new("UILabel").init((0,0), (100, 40), "", "SEL21OFONT", fontScale: (0.95, 0.95));
        valueTitleLabel.multiline = true;
        valueTitleLabel.pin(UIPin.Pin_Left, offset: 25);
        valueTitleLabel.pin(UIPin.Pin_Right, offset: -25);
        valueTitleLabel.pinHeight(UIView.Size_Min);
        descriptionLayout.addManaged(valueTitleLabel);

        descriptionLayout.addSpacer(20);

        tooltipLabel = new("UILabel").init((0,0), (100, 40), "", "PDA16FONT", fontScale: (0.95, 0.95));
        tooltipLabel.multiline = true;
        tooltipLabel.pin(UIPin.Pin_Left, offset: 25);
        tooltipLabel.pin(UIPin.Pin_Right, offset: -25);
        tooltipLabel.pinHeight(UIView.Size_Min);
        descriptionLayout.addManaged(tooltipLabel);

        valueLabel = new("UILabel").init((0,0), (100, 40), "", "PDA16FONT", fontScale: (0.95, 0.95));
        valueLabel.multiline = true;
        valueLabel.pin(UIPin.Pin_Left, offset: 25);
        valueLabel.pin(UIPin.Pin_Right, offset: -25);
        valueLabel.pinHeight(UIView.Size_Min);
        descriptionLayout.addManaged(valueLabel);

        // End preview pane


        midLay = UIVerticalLayout(scrollView.mLayout);
        midLay.itemSpacing = 2.0;

        let hlayout = new("UIHorizontalLayout").init((0,0), (100, 100));
        //hlayout.pin(UIPin.Pin_Right, offset: -30 - 15);
        //hlayout.pin(UIPin.Pin_Left, offset: 30 + 15);
        hlayout.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        hlayout.pin(UIPin.Pin_Bottom, offset: -10);
        hlayout.layoutMode = UIViewManager.Content_SizeParent;
        hlayout.itemSpacing = 30;
        mainBG.add(hlayout);

        let stateNorm = UIButtonState.CreateSlices("PRMTBUT1", (16,16), (20,20), textColor: 0xFFFFFFFF);
        let stateHigh = UIButtonState.CreateSlices("PRMTBUT2", (16,16), (20,20), sound: "ui/cursor2", soundVolume: 0.45);
        let stateDown = UIButtonState.CreateSlices("PRMTBUT3", (16,16), (20,20));
        let stateSelected = UIButtonState.CreateSlices("PRMTBUT4", (16,16), (20,20), sound: "ui/cursor2", soundVolume: 0.45);
        let stateSelectedDown = stateDown;


        if(enableReset) {
            resetButton = CommonUI.MakeStandardButton(StringTable.Localize("$RESET_BUTTON"), negative: true);
            resetButton.pinWidth(UIView.Size_Min);
            resetButton.pinHeight(42);
            resetButton.pin(UIPin.Pin_VCenter, value: 1.0);
            //resetButton.pin(UIPin.Pin_HCenter, value: 1.0);
            resetButton.setTextPadding(35, 0, 37, 0);
            hlayout.addManaged(resetButton);
        }

        okButton = CommonUI.MakeStandardButton(StringTable.Localize("$DONE_BUTTON"));
        okButton.pinWidth(UIView.Size_Min);
        okButton.pinHeight(42);
        okButton.pin(UIPin.Pin_VCenter, value: 1.0);
        //okButton.pin(UIPin.Pin_HCenter, value: 1.0);
        okButton.setTextPadding(35, 0, 37, 0);
        hlayout.addManaged(okButton);

        if(resetButton) {
            okButton.navLeft = resetButton;
            resetButton.navRight = okButton;
        }

        mainView.requiresLayout = true;

        createOptionsGroup(optionsGroup != "" ? optionsGroup : "GameplayMenu");

        if(firstControl) {
            UIControl nControl = firstControl;
            for(int loopLimit = 0; loopLimit < 200 && nControl && nControl.isDisabled() && nControl.getNextControl() != firstControl; loopLimit++) {
                nControl = nControl.getNextControl();
            }
            
            if(nControl) navigateTo(nControl);
        }
    }


    override void linkOptionNavigation() {
        if(firstControl) {
            firstControl.navUp = okButton;
            okButton.navDown = firstControl;
            if(resetButton) resetButton.navDown = firstControl;
        }

        if(lastControl) {
            lastControl.navDown = okButton;
            okButton.navUp = lastControl;
            if(resetButton) resetButton.navUp = lastControl;
        }
    }


    override void collapse(Collapser dropControl) {
        Super.collapse(dropControl);
        scrollView.mLayout.requiresLayout = true;
        scrollView.layout();
    }

    override void expand(Collapser dropControl) {
        Super.expand(dropControl);
        scrollView.mLayout.requiresLayout = true;
        scrollView.layout();
    }

    
    override void createOptionsGroup(string def, UIButton sourceButton, UIScrollBarConfig dropScrollConfig) {
        Super.createOptionsGroup(def, sourceButton, dropScrollConfig);

        if(optionsDescriptor && optionsDescriptor.mTitle) {
            // Set title of options group
            titleLabel.setText(optionsDescriptor.mTitle);
        } else {
            titleLabel.setText("");
        }

        scrollView.scrollNormalized(0);
        scrollView.requiresLayout = true;
    }


    override void ticker() {
        Super.ticker();
        
        animated = true;

        // If we are on top of a parent menu, tick it first
        if(parentMenu) {
            parentMenu.ticker();
        }


        if(closeTicks > 0) {
            if(closeTicks > 4) {
                Close();
            }
            closeTicks++;
        }

        // Scroll with gamepad
        if(scrollView && scrollView.contentsCanScroll()) {
            let v = getGamepadRawLook();
            if(abs(v.y) > 0.1) {
                scrollView.scrollByPixels((v.y * CommonUI.STANDARD_SCROLL_AMOUNT), true, false, false);
            }
        }

        // Layout when required
        if(requiresItemLayout > 0) {
            if(requiresItemLayout == 1) {
                for(int x = 0; x < optionViews.size(); x++) {
                    optionViews[x].updateValue();
                    optionViews[x].requiresLayout = true;
                }
                requiresItemLayout = 0;
            } else {
                requiresItemLayout--;
            }
        }

        if(requiresItemUpdate > 0) {
            if(requiresItemUpdate == 1) {
                for(int x = 0; x < optionViews.size(); x++) {
                    optionViews[x].updateValue();
                }
                requiresItemUpdate = 0;
            } else {
                requiresItemUpdate--;
            }
        }

        if(requiresPresetLayout > 0) {
            if(requiresPresetLayout == 1) {
                for(int x = 0; x < presetViews.size(); x++) {
                    presetViews[x].updateValue();
                    presetViews[x].requiresLayout = true;
                }
                requiresPresetLayout = 0;
            } else {
                requiresPresetLayout--;
            }
        }
    }


    override void drawer() {
        // If we are on top of a parent menu, draw it first
        if(parentMenu) {
            parentMenu.drawer();
        }

        Super.drawer();
    }
    

    override void layoutChange(int screenWidth, int screenHeight) {
		mainBG.maxSize.x = enableDescription ? min(Screen.GetWidth() - 80, 1330) : 850;
        
        Super.layoutChange(screenWidth, screenHeight);
        
        mainView.layout();

        // Since this should only happen if screen size changes, or at startup let's add our animation here
        // Normally we would do this on the first tick
        bg.animateFrame(
            0.10,
            toAlpha: 0.6
        );

        mainBG.animateFrame(
            0.11,
            fromPos: mainBG.frame.pos + (0, 100),
            toPos: mainBG.frame.pos,
            toAlpha: 1.0,
            ease: Ease_Out
        );
	}


    void animateClose() {
        animator.clear();

        bg.animateFrame(
            0.10,
            toAlpha: 0.0
        );

        mainBG.animateFrame(
            0.10,
            fromPos: mainBG.frame.pos,
            toPos: mainBG.frame.pos + (0, 100),
            toAlpha: 0.0,
            ease: Ease_In
        );

        closeTicks = 1;
    }


    override bool onBack() {
        if(closeTicks == 0) {
            MenuSound('menu/backup');
            animateClose();
        }
		return true;
	}


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated && closeTicks == 0 && ctrl == okButton) {
            EventHandler.SendNetworkEvent("optionsPromptComplete");
            MenuSound("menu/advance");
            animateClose();
        } else if(event == UIHandler.Event_Activated && closeTicks == 0 && ctrl == resetButton && resetButton) {
            //MenuSound("menu/advance");
            menuSound("menu/change");
            // Find each item and reset to default when possible
            for(int x = 0; x < optionViews.size(); x++) {
                let ov = optionViews[x];
                let cv = Cvar.FindCVar(ov.menuItem.getAction());
                OptionMenuItem it = ov.menuItem;

                if(cv) {
                    if(developer) Console.Printf("Reset: %s", ov.menuItem.getAction());
                    cv.ResetToDefault();
                }

                // If this is a custom color picker, we are going to assume the default value is NOT custom
                // Because I can't be arsed to do this in another tick or after layout when everything is resolved
                if(it is 'OptionMenuItemColorPicker' && SOMOptionView(ov.navUp) && SOMOptionView(ov.navUp).menuItem is 'OptionMenuItemColorPickerDD') {
                    // Check value to see if we should hide the custom color picker
                    ov.hidden = true;
                    ov.setDisabled(true);
                }
            }

            // Everything changed, relayout everything
            requiresItemUpdate = 2;
            requiresItemLayout = 2;
        } else {
            Super.handleControl(ctrl, event, fromMouseEvent);
        }

        if(event == UIHandler.Event_ValueChanged) {
            if(ctrl is "SOMOptionView") {
                let sctrl = SOMOptionView(ctrl);

                if(ctrl == activeControl) { configPreview(sctrl); }

                // If we changed a preset, we need to layout all of the option views next tick
                if(sctrl.menuItem is "OptionMenuItemTooltipPreset") {
                    requiresItemLayout = 2;
                } else {
                    // Update preset views
                    requiresPresetLayout = 2;
                }

                // Special case, if this was an action button we need to reload our values
                if(sctrl.command == "reset") {
                    requiresPresetLayout = 2;
                    requiresItemUpdate = 2;
                    requiresItemLayout = 2;
                }

                for(int x = 0; x < optionViews.size(); x++) {
                    if(optionViews[x].requireCVar) {
                        requiresItemUpdate = 2;
                        break;
                    }
                }
            }
        }
    }


    override bool navigateTo(UIControl con, bool mouseSelection) {
		let ac = activeControl;
        let cc = Super.navigateTo(con, mouseSelection);

        if(con is "SOMOptionView") {
            SOMOptionView som = SOMOptionView(con);
            configPreview(som);
        } else {
            configPreview(null);
        }

        if(cc && ticks > 1) {
            if(!mouseSelection && con.parent == midLay) {
                scrollView.scrollTo(con, true, 40);
            }

            return true;
        }

        return false;
	}


    void configPreview(SOMOptionView opView = null) {
        if(opView && opView.menuItem is "OptionMenuItemTooltipOption") {
            let tt = OptionMenuItemTooltipOption(opView.menuItem);
            
            int selection = tt.getSelection();
            string img, fart;
            [fart, img] = tt.getValueDescription();

            // Check to make sure the texture works, otherwise set the default texture
            if(img != "" && TexMan.checkForTexture(img, TexMan.Type_Any).isValid()) {
                previewImage.hidden = false;
                previewImage.setImage(img);
            } else {
                previewImage.hidden = true;
            }

            let valueTitleText = opView.menuItem.mLabel.filter();
            valueTitleText.replace("\t", "");
            valueTitleText = StringTable.Localize(valueTitleText);

            let tooltipText = tt.mTooltip.filter();
            tooltipText.replace("\t", "");
            tooltipText = StringTable.Localize(tooltipText);
            
            valueTitleLabel.setText("\n" .. valueTitleText);
            tooltipLabel.setText(tooltipText);

            // Get all the descriptions
            string description = "";
            if(tt.mValueDescriptions) {
                for(int x = 0; x < OptionValues.GetCount(tt.mValueDescriptions); x++) {
                    if(x == selection) {
                        let valDesc = StringTable.Localize(OptionValues.GetText(tt.mValueDescriptions, x));
                        description = String.format("%s\n[ %s ]\n\n%s\n", description.filter(),
                            "\c[OMNIBLUE]" .. StringTable.Localize(OptionValues.GetText(tt.mValues, x)) .. "\c-", 
                            valDesc.filter()
                        );
                    }
                }
            } else {
                description = "";
            }

            valueLabel.setText(description);
        } else if(opView && opView.menuItem is 'OptionMenuItemTooltipSlider') { 
            let tt = OptionMenuItemTooltipSlider(opView.menuItem);

            // Check to make sure the texture works, otherwise set the default texture
            if(tt.mDefaultImage != "" && TexMan.checkForTexture(tt.mDefaultImage, TexMan.Type_Any).isValid()) {
                previewImage.hidden = false;
                previewImage.setImage(tt.mDefaultImage);
            } else {
                previewImage.hidden = true;
            }

            let valueTitleText = opView.menuItem.mLabel.filter();
            valueTitleText.replace("\t", "");
            valueTitleText = StringTable.Localize(valueTitleText);

            let tooltipText = tt.mTooltip.filter();
            tooltipText.replace("\t", "");
            tooltipText = StringTable.Localize(tooltipText);
            
            valueTitleLabel.setText("\n" .. valueTitleText);
            tooltipLabel.setText(tooltipText);
            valueLabel.setText("");
        } else if(opView && opView.menuItem is 'OptionMenuItemTooltipCommand') { 
            let tt = OptionMenuItemTooltipCommand(opView.menuItem);

            previewImage.setImage("");

            let valueTitleText = opView.menuItem.mLabel.filter();
            valueTitleText.replace("\t", "");
            valueTitleText = StringTable.Localize(valueTitleText);

            let tooltipText = tt.mTooltip.filter();
            tooltipText.replace("\t", "");
            tooltipText = StringTable.Localize(tooltipText);
            
            valueTitleLabel.setText("\n" .. valueTitleText);
            tooltipLabel.setText(tooltipText);
            valueLabel.setText("");
        } else {
            previewImage.hidden = true;
            valueTitleLabel.setText("");
            tooltipLabel.setText("");
            valueLabel.setText("");
        }

        descriptionScroll.requiresLayout = true;
    }
}