class ChangeSkillMenu : SelacoGamepadMenu {
    TitleButton skillButtons[5];
    UIVerticalLayout layout;
    UILabel descLabel, descLabel2;

    bool closing;
    double dimStart;

    const BOTT_ANCHOR = -80;

    override void init(Menu parent) {
		Super.init(parent);
        allowDimInGameOnly();
        Animated = true;
        AnimatedTransition = false;

        layout = new("UIVerticalLayout").init((0,0), (500, 500));
        layout.layoutMode = UIViewManager.Content_SizeParent;
        layout.pin(UIPin.Pin_Bottom, UIPin.Pin_Bottom, value: 1.0, offset: BOTT_ANCHOR + 10, isFactor: true);
        layout.pin(UIPin.Pin_Left, offset: 140);
        layout.clipsSubviews = false;

        descLabel = new("UILabel").init(
            (0,0), (500, 45),
            StringTable.Localize("$SKILL_CHANGE_PROMPT"),
            "SEL46FONT",
            fontScale: (0.65, 0.65)
        );
        descLabel.multiline = true;
        descLabel.pinWidth(500);
        descLabel.pinHeight(UIView.Size_Min);
        //descLabel.pin(UIPin.Pin_Left, offset: 140);
        //descLabel.pin(UIPin.Pin_Bottom, value: 1.0, offset: BOTT_ANCHOR - 10, isFactor: true);
        layout.addManaged(descLabel);

        layout.addSpacer(15);

        descLabel2 = new("UILabel").init(
            (0,0), (500, 45),
            StringTable.Localize("$SKILL_CHANGE_PROMPT_DESCRIPTION"),
            "PDA35OFONT"
        );
        descLabel2.scaleToHeight(25);
        descLabel2.multiline = true;
        descLabel2.pinWidth(550);
        descLabel2.pinHeight(UIView.Size_Min);
        descLabel2.alpha = 0.8;
        layout.addManaged(descLabel2);
        
        layout.addSpacer(25);

        skillButtons[0] = new("SkillMenuButton").init(StringTable.Localize("$SKILL_0"), StringTable.Localize("$DIFF_ENSIGN"), 0);
        skillButtons[1] = new("SkillMenuButton").init(StringTable.Localize("$SKILL_1"), StringTable.Localize("$DIFF_LIEUTENANT"), 1);
        skillButtons[2] = new("SkillMenuButton").init(StringTable.Localize("$SKILL_2"), StringTable.Localize("$DIFF_COMMANDER"), 2);
        skillButtons[3] = new("SkillMenuButton").init(StringTable.Localize("$SKILL_3"), StringTable.Localize("$DIFF_CAPTAIN"), 3);
        skillButtons[4] = new("SkillMenuButton").init(StringTable.Localize("$SKILL_4"), StringTable.Localize("$DIFF_ADMIRAL"), 4);

        for(int x = 0; x < 5; x++) {
            if(x > 0) skillButtons[x].navUp = skillButtons[x - 1];
            if(x < 4) skillButtons[x].navDown = skillButtons[x + 1];

            skillButtons[x].buttonIndex = x;
            skillButtons[x].buttStates[UIButton.State_Disabled] = UIButtonState.Create("", textColor: Font.CR_DARKGRAY);
            layout.addManaged(skillButtons[x]);
        }

        mainView.add(layout);

        

        if(skill >= 0 && skill < 5) {
            if(skill != 0) {
                navigateTo(skillButtons[clamp(skill - 1, 0, 4)]);
            } else {
                navigateTo(skillButtons[clamp(skill + 1, 0, 4)]);
            }
            skillButtons[skill].setDisabled(true);
        } else {
            navigateTo(skillButtons[clamp(skill, 0, 4)]);
        }

        dimStart = MSTime() / 1000.0;
    }


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated && !closing) {
            if(ctrl is 'SkillMenuButton') {
                EventHandler.SendNetworkEvent("change_skill", SkillMenuButton(ctrl).skill);
                MenuSound("menu/choose");
                
                // TODO: Some sort of animation
                animateClosed();
            }
        }
    }


    void animateClosed() {
        closing = true;
        dimStart = MSTime() / 1000.0;

        // Disable buttons
        /*for(int x = 0; x < skillButtons.size(); x++) {
            skillButtons[x].setDisabled(true);
        }*/
    }

    void fullClose() {
        UIMenu m = self;
        while(m) {
            m.Close();
            m = m.uiParentMenu;
        }
    }

    override void ticker() {
        Super.ticker();
        animated = true;

        double time = MSTime() / 1000.0;
        if(closing && 1.0 - MIN((time - dimStart) / 0.2, 1.0) <= 0.0001) {
            fullClose();
        }
    }


    /*override bool MenuEvent(int mkey, bool fromcontroller) {
        switch (mkey) {
            case MKEY_Down:
                if(activeControl == null && lastActiveControl != null) {
                    navigateTo(lastActiveControl);
                    didNavigate(fromController);
                    return logController(mkey, fromController);
                } else if(activeControl == null) {
                    navigateTo(noButt);
                    didNavigate(fromController);
                    return logController(mkey, fromController);
                }
                break;
            case MKEY_Up:
                if(activeControl == null && lastActiveControl != null) {
                    navigateTo(lastActiveControl);
                    didNavigate(fromController);
                    return logController(mkey, fromController);
                } else if(activeControl == null) {
                    navigateTo(yesButt);
                    didNavigate(fromController);
                    return logController(mkey, fromController);
                }
                break;
            default:
                break;
        }

		return Super.MenuEvent(mkey, fromcontroller);
	}*/


    override bool navigateTo(UIControl con, bool mouseSelection) {
		let ac = activeControl;

        let ff = Super.navigateTo(con, mouseSelection);

        if(ac != activeControl && !mouseSelection) {
            MenuSound("menu/cursor");
        }
        
        return ff;
	}

    override void drawer() {
        double time = MSTime() / 1000.0;
        if(time - dimStart > 0 && !closing) {
            Screen.dim(0xFF020202, MIN((time - dimStart) / 0.15, 1.0) * 0.75, 0, 0, Screen.GetWidth(), Screen.GetHeight());
            BlurAmount =  MIN((time - dimStart) / 0.1, 1.0);
        } else if(time - dimStart > 0 && closing) {
            Screen.dim(0xFF020202, (1.0 - MIN((time - dimStart) / 0.2, 1.0)) * 0.75, 0, 0, Screen.GetWidth(), Screen.GetHeight());
            BlurAmount = min(BlurAmount, 1.0 - MIN((time - dimStart) / 0.1, 1.0));
        }
        
        Super.drawer();
    }
}