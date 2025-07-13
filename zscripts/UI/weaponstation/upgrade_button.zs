class UpgradeButton : UIButton {
    UIImage img;
    string imgBase;
    SelacoWeapon weapon;
    readonly<SelacoWeapon> defaultWeapon;

    UpgradeButton init(string title, string imgBase, bool hasNew = false) {
        UIButtonState normState     = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background2.png", (16, 16), (36, 36));
        UIButtonState hovState      = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background3.png", (14, 14), (38, 116));
        UIButtonState pressState    = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background4.png", (14, 14), (38, 116));
        UIButtonState disableState  = UIButtonState.Create("");
        UIButtonState selectedState         = UIButtonState.CreateSlices(WeaponStationGFXPath .. "panel_background4.png", (14, 14), (38, 116));
        UIButtonState selectedHovState      = hovState;
        UIButtonState selectedPressState    = hovState;

        Super.init(
            (0,0), (110, 136), 
            title, 'SEL14FONT',
            normState,
            hovState,
            pressState,
            disableState,
            selectedState,
            selectedHovState,
            selectedHovState
        );

        self.imgBase = imgBase;

        pinHeight(110 + 16);
        pin(UIPin.Pin_Left);
        pin(UIPin.Pin_Right);
        setTextPadding(14 + 8, 8 + 8, 14 + 8, 8);

        label.textAlign = Align_Left | Align_Top;
        label.fontScale = (0.7, 0.7);
        label.textColor = 0xFF596A86;

        img = new("UIImage").init((0,0), (1, 1), imgBase .. ".png", imgStyle: UIImage.Image_Center);
        img.pinToParent(tOffset: 5);
        add(img);

        return self;
    }

    override void transitionToState(int idx, bool sound, bool mouseSelection) {
        Super.transitionToState(idx, sound, mouseSelection);

        if(img) {
            if(currentState == State_Selected || currentState == State_SelectedHover || currentState == State_SelectedPressed) {
                img.setImage(imgBase .. "S.png");
            } else {
                img.setImage(imgBase .. ".png");
            }
        }
    }

    override Vector2 calcMinSize(Vector2 parentSize) {
        return (110, 110 + 16);
    }

    override void onSelected(bool mouseSelection) {
        Super.onSelected(mouseSelection);

        if(!mouseSelection) {
            sendEvent(UIHandler.Event_Activated, false);
        }
    }
}