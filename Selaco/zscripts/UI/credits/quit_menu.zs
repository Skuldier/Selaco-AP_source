class BetterQuitMenu : SelacoGamepadMenu {
    TitleButton yesButt, noButt;
    UILabel descLabel;

    const BOTT_ANCHOR = -270;

    override void init(Menu parent) {
		Super.init(parent);
        allowDimInGameOnly();
        Animated = true;
        AnimatedTransition = false;

        descLabel = new("UILabel").init(
            (0,0), (500, 45),
            StringTable.Localize("$QUIT_PROMPT"),
            "SEL21FONT"
        );
        descLabel.multiline = true;
        descLabel.pinWidth(500);
        descLabel.pinHeight(UIView.Size_Min);
        descLabel.pin(UIPin.Pin_Left, offset: 140);
        descLabel.pin(UIPin.Pin_Bottom, value: 1.0, offset: BOTT_ANCHOR - 10, isFactor: true);
        mainView.add(descLabel);

        let hiState = CommonUI.barBackgroundState();
        hiState.textColor = 0xFFB4B4FF;

        yesButt = TitleButton(new("TitleButton").init(
            (0,0), (150, 40),
            StringTable.Localize("$QUIT_YES"), "SEL27OFONT",
            UIButtonState.Create("", 0xFFFFFFFF),
            hiState,
            UIButtonState.Create("", 0xFFB4B4FF),
            textAlign: UIView.Align_Left | UIView.Align_Middle
        ));

        //yesButt.pinWidth(UIView.Size_Min, offset: 20);
        //yesButt.pinHeight(UIView.Size_Min);
        yesButt.buttonIndex = 0;
        yesButt.pinHeight(42);
        yesButt.pinWidth(150);
        yesButt.label.fontScale = (0.87, 0.87);
        yesButt.originalFontScale = (0.87, 0.87);
        yesButt.pin(UIPin.Pin_Left, offset: 140);
        yesButt.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 1.0, offset: BOTT_ANCHOR, isFactor: true);

        noButt = TitleButton(new("TitleButton").init(
            (0,0), (150, 40),
            StringTable.Localize("$QUIT_NO"), "SEL27OFONT",
            UIButtonState.Create("", 0xFFFFFFFF),
            hiState,
            UIButtonState.Create("", 0xFFB4B4FF),
            textAlign: UIView.Align_Left | UIView.Align_Middle
        ));
        noButt.pinHeight(42);
        noButt.pinWidth(150);
        noButt.label.fontScale = (0.87, 0.87);
        noButt.originalFontScale = (0.87, 0.87);
        noButt.pin(UIPin.Pin_Left, offset: 140);
        noButt.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 1.0, offset: BOTT_ANCHOR + 40, isFactor: true);
        noButt.buttonIndex = 1;

        mainView.add(yesButt);
        mainView.add(noButt);

        yesButt.navDown = noButt;
        noButt.navUp = yesButt;

        navigateTo(yesButt);
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated) {
            if(ctrl == yesButt) {
                Level.QuitGame();
                //Menu.SetMenu("SharewareMenu");
                return;
            }

            if(ctrl == noButt) {
                MenuSound("ui/choose2");
                close();
            }
        }
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
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
	}


    override bool navigateTo(UIControl con, bool mouseSelection) {
		let ac = activeControl;

        let ff = Super.navigateTo(con, mouseSelection);

        if(ac != activeControl && !mouseSelection) {
            MenuSound("menu/cursor");
        }
        
        return ff;
	}
}


class QuitToTitleMenu : BetterQuitMenu {
    override void init(Menu parent) {
		Super.init(parent);
        
        descLabel.setText(StringTable.Localize("$QUIT_PROMPT_MENUS"));
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated) {
            if(ctrl == yesButt) {
                Level.ReturnToTitle();
                return;
            }

            if(ctrl == noButt) {
                MenuSound("ui/choose2");
                didReverse(!fromMouseEvent);
                close();
            }
        }
    }
}