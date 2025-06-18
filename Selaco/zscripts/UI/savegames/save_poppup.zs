class SaveTextPop : SelacoGamepadMenu {
    UIVerticalLayout layout;
    UIInputText inputText;
    UIButton okButton, cancelButton;
    bool useController;
    string startingText;

    UIViewAnimation openAnim, closeAnim;

    double dimStart;
    const dimTime = 0.3;

    static SaveTextPop present(String startingText, bool fromController = false) {
        let te = new("SaveTextPop");
        te.useController = fromController;
        te.startingText = startingText;
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
        
        let titleText = new("UILabel").init((0,0), (100, 46), StringTable.Localize("$TITLE_SAVE_GAME"), 'SEL21FONT', textAlign: UIView.Align_Centered);
        titleText.pinWidth(1.0, isFactor: true);
        titleText.pinHeight(46);
        layout.addManaged(titleText);
        layout.addSpacer(15);

        let infoText = new("UILabel").init((0,0), (100, 46), StringTable.Localize("$SAVE_TITLE_PROMPT"), 'PDA16FONT');
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
    }

    override void onFirstTick() {
        Super.onFirstTick();
        navigateTo(inputText);
        inputText.onActivate(false, useController);

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

    void saveAndClose() {
        let parentMenu = uiParentMenu;
        if(parentMenu is 'SaveSelacoMenu') {
            SaveSelacoMenu pm = SaveSelacoMenu(parentMenu);
            pm.incomingSaveName = inputText.label.text; // TODO: Use a getter
        }
        animateClosed(true);
        if(parentMenu) parentMenu.MenuEvent(MKEY_Input, false);
    }

    void animateClosed(bool saved = false) {
        if(!closeAnim) {
            closeAnim = layout.animateFrame(
                0.17,
                fromPos: layout.frame.pos,
                toPos: layout.frame.pos - (0, saved ? -150 : 150),
                fromAlpha: layout.alpha,
                toAlpha: 0,
                ease: Ease_In
            );
        }
    }

    void animateOpen() {
        if(!openAnim) {
            openAnim = layout.animateFrame(
                0.17,
                fromPos: layout.frame.pos - (0, 150),
                toPos: layout.frame.pos,
                fromAlpha: 0,
                toAlpha: 1.0,
                ease: Ease_Out
            );
        }
    }
}