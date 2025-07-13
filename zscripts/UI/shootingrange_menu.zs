class ShootingRangeMenu : SelacoGamepadMenu {
    UIVerticalLayout layout;
    UIButton startButton, cancelButton;
    RangeOptionView timeOptionView, rateOptionView;

    override void init(Menu parent) {
		Super.init(parent);

        menuActive = Menu.OnNoPause;

        let range = ShootingRangeHandler(EventHandler.Find("ShootingRangeHandler"));

        if(!range) {
            Close();
            return;
        }

        let dropScrollConfig = CommonUI.makeDropScrollConfig();

        layout = new("UIVerticalLayout").init((0,0), (100, 100));
        layout.layoutMode = UIViewManager.Content_SizeParent;
        layout.pin(UIPin.Pin_Right, offset: -150);
        layout.pin(UIPin.Pin_Top, offset: 200);
        layout.pinWidth(610);
        layout.minSize.y = 200;
        layout.itemSpacing = 5;
        layout.setPadding(50, 68, 50, 35);
        layout.ignoreHiddenViews = true;
        mainView.add(layout);

        // Add background to layout
        let bgImage = new("UIImage").init((0,0), (10, 10), "", NineSlice.Create("PDAWIND1", (147,96), (204,150)));
        bgImage.pinToParent();
        layout.add(bgImage);

        // Add title
        let titleText = new("UILabel").init((24,19), (10, 37), "Shooting Range Setup", 'PDA16FONT', textAlign: UIView.Align_Centered);
        titleText.pin(UIPin.Pin_Left, offset: 24);
        titleText.pin(UIPin.Pin_Right, offset: -24);
        bgImage.add(titleText);

        let o = new("OptionMenuItemTooltipOptionIntercept").Init("Game Mode", "", "", 'shootingrangeMode', 'ShootingRangeModes');
        o.setSelection(range.gameModeID);

        let ov = new("RangeOptionView").init("Game Mode", o, dropScrollConfig, noBackground: true);
        ov.heightPin = UIPin.Create(0,0,UIView.Size_Min);
        ov.pin(UIPin.Pin_Right);
        ov.pin(UIPin.Pin_Left);
        ov.minsize.y = 45;
        ov.index = 0;
        layout.addManaged(ov);

        o = new("OptionMenuItemTooltipOptionIntercept").Init("Time Limit", "", "", 'shootingRangeTimeLimit', 'ShootingRangeTimes');
        o.setSelection(range.timerSetting);

        ov = new("RangeOptionView").init("Time Limit", o, dropScrollConfig, noBackground: true);
        ov.heightPin = UIPin.Create(0,0,UIView.Size_Min);
        ov.pin(UIPin.Pin_Right);
        ov.pin(UIPin.Pin_Left);
        ov.minsize.y = 45;
        ov.index = 1;
        timeOptionView = ov;
        ov.setDisabled(range.gameModeID != 0);
        ov.hidden = range.gameModeID != 0;
        layout.addManaged(ov);

        o = new("OptionMenuItemTooltipOptionIntercept").Init("Target Distance", "", "", 'shootingRangeDistance', 'ShootingRangeDistances');
        o.setSelection(range.targetModeID);

        ov = new("RangeOptionView").init("Target Distance", o, dropScrollConfig, noBackground: true);
        ov.heightPin = UIPin.Create(0,0,UIView.Size_Min);
        ov.pin(UIPin.Pin_Right);
        ov.pin(UIPin.Pin_Left);
        ov.minsize.y = 45;
        ov.index = 2;
        layout.addManaged(ov);

        o = new("OptionMenuItemTooltipOptionIntercept").Init("Moving Targets", "", "", 'shootingRangeMovingTargets', 'ShootingRangeMovement');
        o.setSelection(range.movementSetting);

        ov = new("RangeOptionView").init("Moving Targets", o, dropScrollConfig, noBackground: true);
        ov.heightPin = UIPin.Create(0,0,UIView.Size_Min);
        ov.pin(UIPin.Pin_Right);
        ov.pin(UIPin.Pin_Left);
        ov.minsize.y = 45;
        ov.index = 3;
        layout.addManaged(ov);

        o = new("OptionMenuItemTooltipOptionIntercept").Init("Spawn Rate", "", "", 'shootingRangeSpawnRate', 'ShootingRangeSpawnRates');
        o.setSelection(range.spawnRateSetting);

        ov = new("RangeOptionView").init("Spawn Rate", o, dropScrollConfig, noBackground: true);
        ov.heightPin = UIPin.Create(0,0,UIView.Size_Min);
        ov.pin(UIPin.Pin_Right);
        ov.pin(UIPin.Pin_Left);
        ov.minsize.y = 45;
        ov.index = 4;
        ov.setDisabled(range.gameModeID != 1);
        ov.hidden = range.gameModeID != 1;
        rateOptionView = ov;
        layout.addManaged(ov);


        // Setup nav chain
        for(int x = 0; x < layout.numManaged(); x++) {
            if(x > 0) {
                UIControl(layout.getManaged(x)).navUp = UIControl(layout.getManaged(x - 1));
            }

            if(x < layout.numManaged() - 1) {
                UIControl(layout.getManaged(x)).navDown = UIControl(layout.getManaged(x + 1));
            }
        }


        layout.addSpacer(20);

        let v = new("UIView").init((0,0), (500, 30));
        v.pin(UIPin.Pin_Right);
        v.pin(UIPin.Pin_Left);
        v.pinHeight(50);


        startButton = new("UIButton").init((0,5), (200, 40), "Begin", "PDA16FONT",
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: Font.CR_UNTRANSLATED),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "menu/cursor", mouseSound: "ui/cursor2", mouseSoundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13))
        );
        ov.navDown = startButton;
        startButton.navUp = ov;
        startButton.pin(UIPin.Pin_Left);
        startButton.pin(UIPin.Pin_Right, UIPin.Pin_HCenter, value: 1.0, offset: -10, isFactor: true);
        v.add(startButton);

        cancelButton = new("UIButton").init((0,5), (200, 40), "Cancel", "PDA16FONT",
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: UIHelper.DestructiveColor),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), textColor: 0xFFFFFFFF, sound: "menu/cursor", mouseSound: "ui/cursor2", mouseSoundVolume: 0.45),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13), textColor: 0xFFFFFFFF)
        );
        cancelButton.navUp = ov;
        cancelButton.pin(UIPin.Pin_Right);
        cancelButton.pin(UIPin.Pin_Left, UIPin.Pin_HCenter, value: 1.0, offset: 10, isFactor: true);
        cancelButton.blendColor = UIHelper.DestructiveColor;
        //cancelButton.desaturation = 1.0;

        v.add(cancelButton);
        
        startButton.navRight = cancelButton;
        cancelButton.navLeft = startButton;
        layout.addManaged(v);
    }

    override void onFirstTick() {
        Super.onFirstTick();

        // Update all values
        for(int x = 0; x < layout.numManaged(); x++) {
            let v = SOMOptionView(layout.getManaged(x));
            if(v) {
                v.updateValue();
            }
        }

        if(isUsingGamepad() || isUsingKeyboard()) {
            navigateTo(UIControl(layout.getManaged(0)));
        }
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_ValueChanged) {
            let ov = SOMOptionView(ctrl);
            if(ov) {
                EventHandler.SendNetworkEvent("srange", ov.index, OptionMenuItemTooltipOption(ov.menuItem).getSelection());
            
                if(ov.index == 0) {
                    timeOptionView.setDisabled(OptionMenuItemTooltipOption(ov.menuItem).getSelection() != 0);
                    timeOptionView.hidden = OptionMenuItemTooltipOption(ov.menuItem).getSelection() != 0;
                    rateOptionView.setDisabled(OptionMenuItemTooltipOption(ov.menuItem).getSelection() != 1);
                    rateOptionView.hidden = OptionMenuItemTooltipOption(ov.menuItem).getSelection() != 1;
                    layout.requiresLayout = true;
                }
            }
        }

        if(event == UIHandler.Event_Activated) {
            if(ctrl == startButton) {
                MenuSound("menu/advance");
                EventHandler.SendNetworkEvent("srangeStart");
                Close();
            } else if(ctrl == cancelButton) {
                MenuSound("menu/backup");
                Close();
            }
        }
    }


    override bool MenuEvent(int mkey, bool fromcontroller) {
        switch (mkey) {
            case MKEY_Left:
            case MKEY_Right:
            case MKEY_Down:
                if(!activeControl) {
                    navigateTo(UIControl(layout.getManaged(0)));
                    return true;
                }
                break;
            case MKEY_Up:
                if(!activeControl) {
                    navigateTo(startButton);
                    return true;
                }
                break;
            default:
                break;
        }

		return Super.MenuEvent(mkey, fromcontroller);
	}
}


class RangeOptionView : SOMOptionView {
    UIImage background;
    NineSlice bgNorm, bgHigh;

    RangeOptionView init(String nam, OptionMenuItem item, UIScrollBarConfig scrollConfig, bool noBackground = false) {
        Super.init(nam, item, scrollConfig, noBackground);

        // Adjust title offset
        label.firstPin(UIPin.Pin_Left).offset = 0;

        bgNorm = NineSlice.Create("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13));
        bgHigh = NineSlice.Create("graphics/options_menu/op_dropdown_high.png", (9,9), (13,13));

        // Adjust backgrounds for dropdown
        control.firstPin(UIPin.Pin_Left).offset = -40;
        //control.backgroundColor = 0xEE586685;
        background = new("UIImage").init((0,0), (1,1), "", bgNorm);
        background.pinToParent();
        control.add(background);
        control.moveToBack(background);
        control.minSize.y = 40;

        let cv = SOMChoiceView(control);
        cv.leftButton.forwardSelection = self;
        cv.rightButton.forwardSelection = self;
    


        return self;
    }

    override void onSelected(bool mouseSelection) {
        Super.onSelected(mouseSelection);

        // Set highlight for option background
        //control.backgroundColor = 0xFF99ACD6;
        background.setSlices(bgHigh);
    }

    override void onDeselected() {
        Super.onDeselected();
        
        // Clear highlight for option background
        //control.backgroundColor = 0xEE586685;
        background.setSlices(bgNorm);
    }

    override void setDisabled(bool disabled) {
        Super.setDisabled(disabled);

        let cv = SOMChoiceView(control);
        cv.setDisabled(disabled);
        cv.leftButton.setDisabled(disabled);
        cv.rightButton.setDisabled(disabled);

        cv.setAlpha(disabled ? 0.5 : 1);
    }
}


class OptionMenuItemTooltipOptionIntercept : OptionMenuItemTooltipOption {
    override int findSelection() {
        switch(mAction) {
            case 'shootingrangeMode':
                mSelection = ShootingRangeHandler.Instance().gameModeID;
                break;
            case 'shootingRangeTimeLimit':
                mSelection = ShootingRangeHandler.Instance().timerSetting;
                break;
            case 'shootingRangeDistance':
                mSelection = ShootingRangeHandler.Instance().targetModeID;
                break;
            case 'shootingRangeMovingTargets':
                mSelection = ShootingRangeHandler.Instance().movementSetting;
                break;
            case 'shootingRangeSpawnRate':
                mSelection = ShootingRangeHandler.Instance().spawnRateSetting;
                break;
            default:
                return Super.findSelection();
        }
        return mSelection;
    }
}