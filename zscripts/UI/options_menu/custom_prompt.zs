class CustomPromptPopup : SelacoGamepadMenu {
    UIVerticalLayout layout;
    UIInputText inputText;
    UIButton okButton, cancelButton;
    UIControl sourceControl;
    bool useController;
    string startingText, titleText, descriptionText;

    UIViewAnimation openAnim, closeAnim;

    double dimStart;
    const dimTime = 0.3;

    static CustomPromptPopup present(String titleText, String descriptionText, String startingText, UIControl sourceControl, bool fromController = false) {
        let te = new("CustomPromptPopup");
        te.useController = fromController;
        te.startingText = startingText;
        te.titleText = StringTable.Localize(titleText);
        te.descriptionText = StringTable.Localize(descriptionText);
        te.sourceControl = sourceControl;
        te.Init(Menu.GetCurrentMenu());
        te.ActivateMenu();
		return te;
    }

    override void init(Menu parent) {
		Super.init(parent);

        DontBlur = parent.DontBlur;
        DontDim = parent.DontDim;
        BlurAmount = parent.BlurAmount;

        dimStart = getTime();

        layout = new("UIVerticalLayout").init((0,0), (600, 100));
        layout.layoutMode = UIViewManager.Content_SizeParent;
        layout.clipsSubviews = false;
        layout.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        layout.pin(UIPin.Pin_VCenter, value: 0.8, isFactor: true);
        layout.alpha = 0;
        mainView.add(layout);

        // Add a background, use the dialog bg for now
        let mainBG = new("UIImage").init(
            (0,0), (450, 300), "",
            NineSlice.Create("PROMPTB3", (30, 70), (40, 76))
        );
        mainBG.pinToParent(-(21 + 25), -21, 21 + 25, 21);
        layout.add(mainBG);
        
        let titleText = new("UILabel").init((0,0), (100, 46), titleText, 'SEL21FONT', textAlign: UIView.Align_Centered);
        titleText.pinWidth(1.0, isFactor: true);
        titleText.pinHeight(46);
        layout.addManaged(titleText);
        layout.addSpacer(15);

        let infoText = new("UILabel").init((0,0), (100, 46), descriptionText, 'PDA16FONT');
        infoText.pinWidth(1.0, isFactor: true);
        infoText.pinHeight(UIView.Size_Min);
        layout.addManaged(infoText);
        layout.addSpacer(10);

        // Create text field, text field will open its own text menu once focused
        // Focus the text menu on the first tick, because we don't want to open two menus at once
        inputText = new("UIInputText").init(
            (0,0), (600, 35), 
            startingText, 
            "PDA18FONT"
        );
        inputText.inputFont = "PDA18FONT";
        inputText.pinWidth(1.0, isFactor: true);
        inputText.pinHeight(UIView.Size_Min);
        inputText.requireValue = true;
        //inputText.backgroundColor = 0xFFFF0000;
        inputText.setTextPadding(10, 7, 10, 7);
        inputText.setBackgroundSlices("", NineSlice.Create("TXTINPUT", (9, 9), (13, 13)));
        inputText.rejectHoverSelection = true;
        UIPadding pad;
        pad.set(-5,-5,-5,-5);
        inputText.setHighlightSlices("", NineSlice.Create("TXTINHIG", (12,12), (20, 20)), pad);
        layout.addManaged(inputText);
        layout.addSpacer(25);

        inputText.oskTemplate = CommonUI.MakeDefaultOSKTemplate();

        // Add button layout
        let horz = new("UIHorizontalLayout").init((0,0), (100, 80));
        horz.pinHeight(80);
        horz.layoutMode = UIViewManager.Content_SizeParent;
        horz.itemSpacing = 15;
        horz.pin(UIPin.Pin_Right, value: -30);
        layout.addManaged(horz);

        // Add buttons
        let stateNorm = UIButtonState.CreateSlices("PRMTBUT1", (16,16), (20,20), textColor: 0xFFFFFFFF);
        let stateHigh = UIButtonState.CreateSlices("PRMTBUT2", (16,16), (20,20), sound: "ui/cursor2", mouseSound: "ui/cursor2", mouseSoundVolume: 0.45);
        let stateDown = UIButtonState.CreateSlices("PRMTBUT3", (16,16), (20,20));
        let stateSelected = UIButtonState.CreateSlices("PRMTBUT4", (16,16), (20,20), sound: "ui/cursor2", mouseSound: "ui/cursor2", mouseSoundVolume: 0.45);
        let stateSelectedDown = stateDown;
        let stateDisabled = UIButtonState.CreateSlices("PRMTBUT5", (16,16), (20,20), textColor: 0x66FFFFFF);

        cancelButton = new("UIButton").init((0,0), (100, 54),  StringTable.Localize("$CANCEL_BUTTON"), "PDA16FONT",
            stateNorm, stateHigh, stateDown, stateDisabled, stateSelected, stateHigh, stateSelectedDown
        );
        cancelButton.pinWidth(UIView.Size_Min);
        cancelButton.pin(UIPin.Pin_VCenter, value: 1.0);
        cancelButton.setTextPadding(25, 0, 27, 0);
        cancelButton.rejectHoverSelection = true;
        horz.addManaged(cancelButton);

        okButton = new("UIButton").init((0,0), (100, 54), StringTable.Localize("$SAVE_BUTTON"), "PDA16FONT",
            stateNorm, stateHigh, stateDown, stateDisabled, stateSelected, stateHigh, stateSelectedDown
        );
        okButton.pinWidth(UIView.Size_Min);
        okButton.pin(UIPin.Pin_VCenter, value: 1.0);
        okButton.setTextPadding(25, 0, 27, 0);
        okButton.rejectHoverSelection = true;
        horz.addManaged(okButton);

        if(startingText == "") {
            okButton.setDisabled();
        }

        inputText.navDown = okButton;
        cancelButton.navUp = inputText;
        okButton.navUp = inputText;
        cancelButton.navRight = okButton;
        okButton.navLeft = cancelButton;
        okButton.navDown = inputText;
    }

    override void onFirstTick() {
        Super.onFirstTick();

        if(inputText) {
            navigateTo(inputText);
            inputText.onActivate(false, useController);
        }

        layout.layout();
        animateOpen();
    }

    override void drawSubviews() {
        double time = getTime();
        if(time - dimStart > 0 && !closeAnim) {
            double dim = MIN((time - dimStart) / dimTime, 1.0) * 0.7;
            Screen.dim(0xFF020202, dim, 0, 0, lastScreenSize.x, lastScreenSize.y);
        } else if(closeAnim && time - closeAnim.startTime > 0) {
            double dim = (1.0 - MIN((time - closeAnim.startTime) / (closeAnim.endTime - closeAnim.startTime), 1.0)) * 0.7;
            Screen.dim(0xFF020202, dim, 0, 0, lastScreenSize.x, lastScreenSize.y);
        }

        Super.drawSubviews();
    }

    override void drawer() {
        if(uiParentMenu) uiParentMenu.drawer();

		Super.drawer();
	}

    override void ticker() {
        if(uiParentMenu) uiParentMenu.ticker();
        Super.ticker();

        if(closeAnim && !closeAnim.checkValid(getTime())) {
            Close();
        }
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
		if(closeAnim) return true;

        if(mkey == MKEY_Input) {
            okButton.onActivate(false, fromController);
            return true;
        } else if(mkey == MKEY_Abort) {
            cancelButton.onActivate(false, fromController);
            return true;
        } 

        return Super.MenuEvent(mkey, fromcontroller);
	}

    override bool onBack() {
        if(uiParentMenu) uiParentMenu.MenuEvent(MKEY_Abort, false);

        return false;
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(closeAnim) return;

        if(event == UIHandler.Event_Activated) {
            if(ctrl == okButton) {
                // TODO: Validation, I wish we had function pointers
                if(inputText.label.text.length() > 0) {
                    // Proceed with save
                    saveAndClose();
                    if(!fromController) {
                        MenuSound("menu/OSKSave");
                    }
                } else {
                    MenuSound("ui/buy/error");
                }
                return;
            } else if(ctrl == cancelButton) {
                animateClosed();
                return;
            }
        } else if(event == UIInputText.StoppedEditing) {
            // We stopped editing, if this was due to keyboard command (esc, back button) assume we want to cancel completely
            if(!fromMouseEvent) {
                animateClosed();
                return;
            }
        } else if(event == UIInputText.OpenedVirtualKeyboard) {
            okButton.setAlpha(0.25);
            cancelButton.setAlpha(0.25);
        } else if(event == UIInputText.ClosedVirtualKeyboard) {
            okButton.setAlpha(1);
            cancelButton.setAlpha(1);
        } else if(event == UIHandler.Event_ValueChanged) {
            if(ctrl == inputText) {
                if(inputText.label.text.length() == 0 && !okButton.isDisabled()) okButton.setDisabled();
                if(inputText.label.text.length() > 0 && okButton.isDisabled()) okButton.setDisabled(false);
            }
        }

        Super.handleControl(ctrl, event, fromMouseEvent, fromController);
    }

    virtual void saveAndClose() {
        let parentMenu = uiParentMenu;

        inputText.deactivate();

        if(parentMenu) parentMenu.MenuEvent(MKEY_Input, false);
        
        
        animateClosed();
    }

    void animateClosed(bool saved = false) {
        if(!closeAnim) {
            animator.clear();
            /*closeAnim = layout.animateFrame(
                0.17,
                fromPos: layout.frame.pos,
                toPos: layout.frame.pos - (0, saved ? -150 : 150),
                fromAlpha: layout.alpha,
                toAlpha: 0,
                ease: Ease_In
            );*/
            closeAnim = new("UIViewPinAnimation").initComponents(
                layout, 
                0.17, 
                fromAlpha: layout.alpha,
                toAlpha: 0,
                ease: Ease_In
            );
            UIViewPinAnimation(closeAnim).addValues(UIPin.Pin_VCenter, startOffset: 0, endOffset: saved ? 150 : -150);
            animator.add(closeAnim);
        }
    }

    void animateOpen() {
        if(!openAnim) {
            /*openAnim = layout.animateFrame(
                0.17,
                fromPos: layout.frame.pos - (0, 150),
                toPos: layout.frame.pos,
                fromAlpha: 0,
                toAlpha: 1.0,
                ease: Ease_Out
            );*/

            openAnim = new("UIViewPinAnimation").initComponents(
                layout, 0.17, 
                fromAlpha: 0,
                toAlpha: 1.0,
                ease: Ease_Out
            );
            UIViewPinAnimation(openAnim).addValues(UIPin.Pin_VCenter, startOffset: -150, endOffset: 0);
            animator.add(openAnim);
        }
    }
}


class ResolutionPrompt : CustomPromptPopup {
    int width, height;
    UIInputText inputText2;

    static ResolutionPrompt present(String titleText, String descriptionText, int defaultWidth, int defaultHeight,  UIControl sourceControl, bool fromController = false) {
        let te = new("ResolutionPrompt");
        te.useController = fromController;
        te.width = defaultWidth;
        te.height = defaultHeight;
        te.titleText = StringTable.Localize(titleText);
        te.descriptionText = StringTable.Localize(descriptionText);
        te.sourceControl = sourceControl;
        te.Init(Menu.GetCurrentMenu());
        te.ActivateMenu();
		return te;
    }


    override void init(Menu parent) {
		Super.init(parent);

        layout.frame.size.x = 400;
        
        inputText.pinWidth(130);
        inputText.setText(String.Format("%d", width));

        let textIndex = layout.managedIndex(inputText);
        layout.removeManagedAt(textIndex);

        inputText.frame.pos.y = 20;
        
        // Add horizontal layout for text boxes
        let horz = new("UIHorizontalLayout").init((0,0), (100, 80));
        horz.pinHeight(80);
        horz.layoutMode = UIViewManager.Content_SizeParent;
        horz.itemSpacing = 15;
        horz.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        layout.insertManaged(horz, textIndex);

        inputText2 = new("UIInputText").init(
            (0,20), (600, 35), 
            startingText, 
            "PDA18FONT"
        );
        inputText2.inputFont = "PDA18FONT";
        inputText2.pinWidth(130);
        inputText2.pinHeight(UIView.Size_Min);
        inputText2.requireValue = true;
        //inputText.backgroundColor = 0xFFFF0000;
        inputText2.setTextPadding(10, 7, 10, 7);
        inputText2.setBackgroundSlices("", NineSlice.Create("TXTINPUT", (9, 9), (13, 13)));
        UIPadding pad;
        pad.set(-5,-5,-5,-5);
        inputText2.setHighlightSlices("", NineSlice.Create("TXTINHIG", (12,12), (20, 20)), pad);
        inputText2.setText(String.Format("%d", height));

        let xLabel = new("UILabel").init((0,20), (40, 40), "X", "PDA18FONT", textAlign: UIView.Align_Centered);

        horz.addManaged(inputText);
        horz.addManaged(xLabel);
        horz.addManaged(inputText2);

        inputText.numeric = true;
        inputText.charLimit = 4;
        inputText2.numeric = true;
        inputText2.charLimit = 4;

        inputText.navRight = inputText2;
        inputText2.navLeft = inputText;
        inputText.navDown = okButton;
        inputText2.navDown = okButton;
        cancelButton.navUp = inputText2;
        okButton.navUp = inputText2;
        okButton.navDown = inputText;

        cancelButton.navRight = okButton;
        okButton.navLeft = cancelButton;

        inputText.rejectHoverSelection = true;
        inputText2.rejectHoverSelection = true;

        if(width >= 800 && height >= 600 && okButton.isDisabled()) okButton.setDisabled(false);
    }


    override void saveAndClose() {
        // Set width and height based on input values
        width = inputText.getText().toInt();
        height = inputText2.getText().toInt();

        if(width < 800 || height < 600) {
            width = Screen.GetWindowWidth();
            height = Screen.GetWindowHeight();
        } else {
            // Assume the resolution has changed, and lay out the window accordingly
            layoutChange(width, height);
            lastUIScale = uiScale;
        }

        inputText2.deactivate();

        Super.saveAndClose();
    }


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(closeAnim) return;

        if(event == UIHandler.Event_ValueChanged) {
            if(ctrl == inputText) {
                width = inputText.getText().toInt();
                if(width < 800 && !okButton.isDisabled()) okButton.setDisabled();
                if(width >= 800 && height >= 600 && okButton.isDisabled()) okButton.setDisabled(false);
            } else if(ctrl == inputText2) {
                height = inputText2.getText().toInt();
                if(height < 600 && !okButton.isDisabled()) okButton.setDisabled();
                if(width >= 800 && height >= 600 && okButton.isDisabled()) okButton.setDisabled(false);
            }

            return;
        } else if(event == InputText.StartedEditing) {
            if(activeControl != ctrl) navigateTo(ctrl);

            if(ctrl == inputText) {
                inputText2.deactivate();
                return;
            } else if(ctrl == inputText2) {
                inputText.deactivate();
                return;
            }
        } else if(event == UIInputText.StoppedEditing) {
            if(!fromController) {
                saveAndClose();
                return;
            }

            /*if(ctrl == inputText) {
                navigateTo(inputText2);
                inputText2.onActivate(false, fromController);
            }*/

            return;
        }

        Super.handleControl(ctrl, event, fromMouseEvent, fromController);
    }


    
}


class MaxFPSPrompt : CustomPromptPopup {
    int fps;

    static MaxFPSPrompt present(String titleText, String descriptionText, int defaultFPS,  UIControl sourceControl, bool fromController = false) {
        let te = new("MaxFPSPrompt");
        te.useController = fromController;
        te.fps = defaultFPS;
        te.titleText = StringTable.Localize(titleText);
        te.descriptionText = StringTable.Localize(descriptionText);
        te.sourceControl = sourceControl;
        te.Init(Menu.GetCurrentMenu());
        te.ActivateMenu();
		return te;
    }


    override void init(Menu parent) {
		Super.init(parent);

        layout.frame.size.x = 400;
        
        inputText.pinWidth(130);
        inputText.setText(String.Format("%d", fps));

        inputText.numeric = true;
        inputText.charLimit = 4;
        
        inputText.rejectHoverSelection = true;

        if(fps >= 0) okButton.setDisabled(false);
    }


    override void saveAndClose() {
        // Set width and height based on input values
        fps = inputText.getText().toInt();

        Super.saveAndClose();
    }


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(closeAnim) return;

        if(event == UIHandler.Event_ValueChanged) {
            if(ctrl == inputText) {
                fps = inputText.getText().toInt();
                if(fps < 0 && !okButton.isDisabled()) okButton.setDisabled();
                if(fps >= 0 && okButton.isDisabled()) okButton.setDisabled(false);
            }
            
            return;
        } else if(event == InputText.StartedEditing) {
            if(activeControl != ctrl) navigateTo(ctrl);
            return;
        } else if(event == UIInputText.StoppedEditing) {
            if(!fromController) {
                saveAndClose();
                return;
            }
            return;
        }

        Super.handleControl(ctrl, event, fromMouseEvent, fromController);
    }


    
}