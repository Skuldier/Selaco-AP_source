class ResetControlsPrompt : CustomPromptPopup {
    mixin CVARBuddy;
    
    UIVerticalLayout settingsLayout;
    UIMenu parentMenu;
    Array<QualityRadioButton> radioButts;

    static const string opts[] = {
        "$OPTVAL_MODERN",
        "$SETTING_CONTROLS_PRO"
    };

    static const int optsv[] = {
        0,
        2
    };

    override void init(Menu parent) {
        titleText = "Reset Controls";

		Super.init(parent);

        parentMenu = UIMenu(parent);
        
        let textIndex = layout.managedIndex(inputText);
        layout.removeManagedAt(textIndex);
        inputText.destroy();
        inputText = null;

        okButton.label.text = "Reset Controls";
        okButton.setDisabled(false);


        // Add options  =============================================================
        settingsLayout = new("UIVerticalLayout").init((0,0), (300, 100));
        settingsLayout.pin(UIPin.Pin_Left);
        settingsLayout.pin(UIPin.Pin_Right);
        settingsLayout.minSize.y = 100;
        settingsLayout.layoutMode = UIViewManager.Content_SizeParent;
        settingsLayout.itemSpacing = 5;
        settingsLayout.clipsSubviews = false;
        layout.insertManaged(settingsLayout, textIndex - 1);

        // Set descriptive text
        let descLabel = new("UILabel").init((0,0), (0,0), StringTable.Localize("$DIALOG_RESETCONTROLS"), "PDA16FONT");
        descLabel.multiline = true;
        descLabel.pin(UIPin.Pin_Left);
        descLabel.pin(UIPin.Pin_Right);
        descLabel.pinHeight(UIView.Size_Min);
        settingsLayout.addManaged(descLabel);

        settingsLayout.addSpacer(15);

        // Create controls for gameplay options
        UIControl lastCon = null;
        

        for(int y = 0; y < opts.size(); y++) {
            let optionText = StringTable.Localize(opts[y]);

            let v = new("UIView").init((0,0), (1, 44));
            v.pin(UIPin.Pin_Left);
            v.pin(UIPin.Pin_Right);
            v.minSize.y = 44;
            v.pinHeight(44);

            let rb = new("QualityRadioButton").init((22,0), (35,35), iGetCVar("cl_defaultconfiguration", 0) == optsv[y]);
            rb.pin(UIPin.Pin_Left, offset: 22);
            rb.pin(UIPin.Pin_VCenter, value: 1.0);
            rb.controlID = optsv[y];
            radioButts.push(rb);
            v.add(rb);

            if(lastCon) {
                lastCon.navDown = rb;
                rb.navUp = lastCon;
            }
            lastCon = rb;

            let st = new("UILabel").init((0,0), (1, 25), optionText, "PDA16FONT", textAlign: UIView.Align_Middle);
            st.pin(UIPin.Pin_Left, offset: 22 + 35 + 15);
            st.pin(UIPin.Pin_VCenter, value: 1.0);
            st.pinHeight(34);
            st.multiline = false;
            v.add(st);

            settingsLayout.addManaged(v);
        }

        if(lastCon) {
            lastCon.navDown = okButton;
        }

        // ===================================================================================

        okButton.navUp = lastCon;
        cancelButton.navUp = lastCon;

        if(isUsingController() || isUsingKeyboard()) {
            navigateTo(okButton);
        }

        layout.layout();
    }

    override void onFirstTick() {
        Super.onFirstTick();
    }


    override UIControl findFirstControl(int mkey) {
		return okButton;
	}


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(event == UIHandler.Event_Activated) {
            let c = QualityRadioButton(ctrl);

            if(c) {
                menuSound("menu/change");

                iSetCVar("cl_defaultconfiguration", c.controlID);

                // Set radio button values
                for(int x = 0; x < radioButts.size(); x++) {
                    radioButts[x].setSelected(radioButts[x] == ctrl);
                }

                return;
            }

            if(ctrl == okButton) {
                // OK Button pressed, send info to parent
                if(parentMenu) {
                    parentMenu.MenuEvent(MKEY_MBYes, fromController);
                }
                MenuSound("menu/advance");
                animateClosed(true);
            } else {
                MenuSound("menu/OSKBackspace");
                animateClosed(false);
            }
        }
    }

    override void ticker() {
        Super.ticker();
    }

     override bool onBack() {
        MenuSound("menu/backup");
        animateClosed();
		return true;
	}
}