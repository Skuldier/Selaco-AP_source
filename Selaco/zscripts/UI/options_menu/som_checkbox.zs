class SOMCheckbox : UIButton {

    SOMCheckbox Init(Vector2 pos, Vector2 size, bool isChecked = false) {
        Super.init(pos, size, "", null, 
            UIButtonState.Create("graphics/options_menu/checkbox.png"),
            UIButtonState.Create("graphics/options_menu/checkbox_high.png", sound: "menu/cursor", soundVolume: 0.45),
            UIButtonState.Create("graphics/options_menu/checkbox_down.png"),
            UIButtonState.Create("graphics/options_menu/checkbox_disabled.png"),
            UIButtonState.Create("graphics/options_menu/checkbox_filled.png"),
            UIButtonState.Create("graphics/options_menu/checkbox_filled_high.png", sound: "menu/cursor", soundVolume: 0.45),
            UIButtonState.Create("graphics/options_menu/checkbox_filled_down.png")
        );

        setSelected(isChecked, false);

        return self;
    }
}