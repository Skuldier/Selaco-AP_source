class SkillMenuButton : TitleButton {
    string description;
    int skill;
    bool isDisabledInMenu;

    SkillMenuButton init(string name, string description, int skill) {
        self.skill = skill;
        self.description = description;

        int col = 0xFFFFFFFF, highCol = 0xFFB0B0F5;
        if(skill == SKILL_SMF) { 
            // SMF Color
            highCol = 0xFF905EC7;
        } else if (skill == 6) {
            // Narrative Color
            highCol = 0xF37CCCA5;
        }

        let hiState = CommonUI.barBackgroundState();
        hiState.textColor = highCol;

        Super.init((0,0), (300, 40), name, "SEL27OFONT",
            UIButtonState.Create("", textColor: col),
            hiState,
            UIButtonState.Create("", 0xFFB4B4FF),
            textAlign: UIView.Align_Left | UIView.Align_Middle
        );

        pin(UIPin.Pin_Left);
        pin(UIPin.Pin_Right);
        pinHeight(42);
        setTextPadding(0, 5, 0, 5);

        label.fontScale = (0.87, 0.87);
        originalFontScale = (0.87, 0.87);

        return self;
    }

    override void onSelected(bool mouseSelection, bool controllerSelection) {
        Super.onSelected(mouseSelection);

        sendEvent(UIHandler.Event_Alternate_Activate, mouseSelection, controllerSelection);
    }
}


class SkillMenuLevelButton : SkillMenuButton {
    SkillMenuLevelButton init(string name, string description, int skill) {
        Super.init(name, description, -1);
        self.skill = skill;
        return self;
    }
}


class SkillMenuOptionView : TitleButton {
    OptionMenuItem menuItem;
    UIImage newBG;
    UILabel newText;
    UIView controlView;
    double newTextPos;
    bool isDisabledInMenu;

    virtual void toggle(bool mouseSelection, bool controllerSelection) { }

    override void transitionToState(int idx, bool sound) {
        label.multiline = false;
        label.autoScale = true;

        let oidx = currentState;
        Super.transitionToState(idx, sound);

        //if(oidx != currentState) hideNewImage();
        //if(oidx != idx) Console.Printf("%s[%d] Transition from: %d  to   %d   (%d)", getClassName(), buttonIndex, oidx, idx, Level.totalTime);
    }

    virtual void addNewImage() {
        if(!newBG) {
            newBG = new("UIImage").init((0,0), (10, 10), "", NineSlice.Create("ddnew", (9,9), (11, 11)));
            newBG.pinToParent(-10, -1, 10, 4);
        }

        if(!newText) {
            newText = new("UILabel").init(
                (0,0), (150, 15),
                StringTable.Localize("$NEW"),
                "SEL16FONT",
                textColor: 0xFF03101D,
                fontScale: (1.0, 0.9)
            );
            newText.multiline = false;
            //newText.pin(UIPin.Pin_Left, UIPin.Pin_Right, offset: 10);
            Vector2 ms = label.calcMinSize((1000000, 900));
            newTextPos = ms.x + label.firstPin(UIPin.Pin_Left).offset + 20;
            newText.pin(UIPin.Pin_Left, offset: newTextPos);
            newText.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
            newText.pinHeight(UIView.Size_Min);
            newText.pinWidth(UIView.Size_Min);
            newText.clipsSubviews = false;
            newText.drawSubviewsFirst = true;
            
            newText.add(newBG);
            //label.clipsSubviews = false;
            add(newText);
            //label.removePins(UIPin.Pin_Right);
            //label.pinWidth(UIView.Size_Min, offset: 20);
        }
    }

    virtual void hideNewImage() {
        if(newText) {
            let animator = getAnimator(); 
            if(animator) animator.clear(newText);

            newText.animateFrame(
                0.06,
                toPos: ((label.fnt.GetCharWidth("0") * originalFontScale.x * 0.5 * (slide > 0 ? slide : 1.0)) + textPadding.left + (label.getStringWidth(label.text) * originalFontScale.x * (magnify > 0 ? magnify : 1.15)) + 20, 
                        newText.frame.pos.y),
                toAlpha: 0.5,
                ease: Ease_Out
            );
        }
    }

    virtual void showNewImage() {
        if(newText) {
            let animator = getAnimator(); 
            if(animator) animator.clear(newText);
            
            newText.animateFrame(
                0.08,
                toPos: (newTextPos, newText.frame.pos.y),
                toAlpha: 1,
                ease: Ease_Out
            );
        }
    }

    override void animateToNormal() {
        Super.animateToNormal();
        
        showNewImage();
    }

    override void animateToHover() {
        Super.animateToHover();

        hideNewImage();
    }
}

// Checkbox =============================================
// ======================================================
mixin class SkillMenuCheckboxOptionMix {
    UIButton checkbox;
    Array<UIButton> extraButtons;

    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        if(ctrl == checkbox && event == UIHandler.Event_Activated) {
            checkbox.setSelected(!checkbox.isSelected());

            let item = OptionMenuItemOptionBase(menuItem);
            if(item) {
                item.setSelection(checkbox.isSelected() ? 1 : 0);
            }

            if(checkbox.isSelected()) playSound("ui/playstyle/click");//"menu/change");
            else playSound("ui/playstyle/PSCHECK");

            sendEvent(UIHandler.Event_ValueChanged, fromMouse, fromController);

            return true;
        }

        return Super.handleSubControl(ctrl, event, fromMouse, fromController);
    }


    override void toggle(bool mouseSelection, bool controllerSelection) {
        checkbox.onActivate(mouseSelection, controllerSelection);
    }

    override void transitionToState(int idx, bool sound) {
        let oldState = currentState;
        Super.transitionToState(idx, sound);

        if(idx == State_Hover) {
            // Fade in any extra buttons
            for(int x = 0; x < extraButtons.size(); x++) {
                extraButtons[x].animateFrame(
                    0.15,
                    toAlpha: 1,
                    ease: Ease_Out
                );
            }
        } else if(idx == State_Normal) {
            let a = getAnimator();
            // Fade out any extra buttons
            for(int x = 0; x < extraButtons.size(); x++) {
                if(a) a.clear(extraButtons[x]);
                extraButtons[x].setAlpha(0);
            }
        }
    }
}


class SkillMenuCheckboxOptionView : SkillMenuOptionView {
    mixin SkillMenuCheckboxOptionMix;

    override void onAddedToParent(UIView parentView) {
        UIButton.onAddedToParent(parentView);
        label.pixelAlign = false;
    }

    SkillMenuCheckboxOptionView init(OptionMenuItem menuItem) {
        self.menuItem = menuItem;

        let hiState = CommonUI.barBackgroundState();
        hiState.textColor = 0xFFB4B4FF;
        hiState.blendColor = 0;
        
        let pressState = CommonUI.barBackgroundState();
        pressState.textColor = 0xFFB4B4FF;
        pressState.blendColor = 0x88B4B4FF;

        let disableState = UIButtonState.Create("", 0xAA999999);
        disableState.blendColor = 0;

        let defaultState = UIButtonState.Create("", 0xFFFFFFFF);
        defaultState.blendColor = 0;


        super.init(
            (0,0), (350, 44),
            menuItem ? StringTable.Localize(menuItem.mLabel) : "[Unkown Option]", "SEL46FONT",
            UIButtonState.Create("", 0xFFFFFFFF),
            hiState,
            pressState,
            textAlign: UIView.Align_Left | UIView.Align_Middle
        );
        setTextPadding(65, 5, 0, 5);
        label.scaleToHeight(30);
        originalFontScale = label.fontScale;
        maxSize.x = 500;
        pinHeight(52);
        pinWidth(1.0, isFactor: true);
        buttonIndex = 0;
        hasAnimated = true;     // Don't trigger animation as soon as we appear, it happens manually

        alpha = 0;

        checkbox = new("StandardCheckbox").init((15,0), (40, 40));
        checkbox.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        checkbox.forwardSelection = self;
        
        add(checkbox);

        if(menuItem) {
            let o = OptionMenuItemOption(menuItem);
            let o2 = OptionMenuItemTooltipOptionMode(menuItem);
            let cv = CVar.FindCVar(menuItem.getAction());
            // Trust menu item over the CVAR since the cvar often latches
            checkbox.setSelected((o && o.getSelection() > 0) || (!o && cv && cv.getInt() > 0), false);

            if(o2 && o2.isNew) addNewImage();
        }

        return self;
    }


    override void setDisabled(bool disable) {
        //Super.setDisabled(disable);
        if(checkbox) checkbox.setDisabled(disable);
        
        // Cheating
        if(disable) {
            buttStates[State_Normal].textColor = 0xAA999999;
            buttStates[State_Hover].textColor = 0xAA999999;
            label.textColor = 0xAA999999;
        }
        isDisabledInMenu = disable;
    }
}


class SkillMenuCheckboxOptionView2 : SkillMenuOptionView {
    mixin SkillMenuCheckboxOptionMix;

    UIImage checkboxHighlight;

    override void onAddedToParent(UIView parentView) {
        UIButton.onAddedToParent(parentView);
        label.pixelAlign = false;
    }

    SkillMenuCheckboxOptionView2 init(OptionMenuItem menuItem) {
        self.menuItem = menuItem;
        slide = 0.00000001; // I hate myself
        magnify = 1.0;
        
        let hiState = UIButtonState.Create("", 0xFFB4B4FF);
        hiState.blendColor = 0;
        
        let pressState = UIButtonState.Create("", 0xFFB4B4FF);
        pressState.blendColor = 0x88B4B4FF;

        let defaultState = UIButtonState.Create("", 0xFFFFFFFF);
        defaultState.blendColor = 0;

        Super.init(
            (0,0), (350, 44),
            menuItem ? StringTable.Localize(menuItem.mLabel) : "[Unkown Option]", "SEL27OFONT",
            UIButtonState.Create("", 0xFFFFFFFF),
            hiState,
            pressState,
            textAlign: UIView.Align_Left | UIView.Align_Middle
        );
        setTextPadding(50, 4, 0, 5);
        label.scaleToHeight(29);
        originalFontScale = label.fontScale;
        maxSize.x = 500;
        pinHeight(52);
        pinWidth(1.0, isFactor: true);
        buttonIndex = 0;
        hasAnimated = true;     // Don't trigger animation as soon as we appear, it happens manually
        clipsSubviews = false;

        alpha = 1;

        checkbox = new("StandardCheckbox").init((0,0), (40, 40));
        checkbox.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        checkbox.forwardSelection = self;
        checkbox.clipsSubviews = false;
        
        add(checkbox);

        if(menuItem) {
            let o = OptionMenuItemOption(menuItem);
            let o2 = OptionMenuItemTooltipOptionMode(menuItem);
            let cv = CVar.FindCVar(menuItem.getAction());
            // Trust menu item over the CVAR since the cvar often latches
            checkbox.setSelected((o && o.getSelection() > 0) || (!o && cv && cv.getInt() > 0), false);

            if(o2 && o2.isNew) addNewImage();
        }

        return self;
    }


    override void onSelected(bool mouseSelection) {
        Super.onSelected(mouseSelection);
        checkbox.onSelected(mouseSelection);
    }

    override void onDeselected() {
        Super.onDeselected();
        checkbox.onDeselected();
    }
}


// Slider ===============================================
// ======================================================
mixin class SkillMenuSliderOptionMix {
    UIButton checkbox;
    UISlider slider;
    double lastValue;
    double textLeft;

    override void onAddedToParent(UIView parentView) {
        UIButton.onAddedToParent(parentView);
        label.pixelAlign = false;
    }

    override bool menuEvent(int key, bool fromcontroller) {
        let m = getMenu();
        if(key == Menu.MKEY_Left) {
            slider.decrease();

            let item = OptionMenuItemTooltipSlider(menuItem);
            if(item) item.setSliderValue(slider.value);

            return true;
        } else if(key == Menu.MKEY_Right) {
            slider.increase();

            let item = OptionMenuItemTooltipSlider(menuItem);
            if(item) item.setSliderValue(slider.value);

            return true;
        }

        return super.menuEvent(key, fromController);
    }


    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        let item = OptionMenuItemTooltipSlider(menuItem);

        if(ctrl == checkbox && event == UIHandler.Event_Activated) {
            checkbox.setSelected(!checkbox.isSelected());

            double value = lastValue;
            
            if(checkbox.isSelected()) {
                playSound("ui/playstyle/click");

                heightPin.value = 84;
                requiresLayout = true;
                slider.hidden = false;
                setTextPadding(textLeft, 5, 0, 42);

                if(item) {
                    value = lastValue > 0 ? lastValue : item.mStep;
                    item.setSliderValue(value);
                }

                slider.setValue(value, true, true);
            } else {
                playSound("ui/playstyle/PSCHECK");

                heightPin.value = 52;
                requiresLayout = true;
                slider.hidden = true;

                if(item) value = item.getSlidervalue();
                else value = slider.value;

                lastValue = value;

                setTextPadding(textLeft, 5, 0, 5);
            }

            sendEvent(UIHandler.Event_ValueChanged, fromMouse, fromController);

            return true;
        }

        if(ctrl == slider && event == UIHandler.Event_ValueChanged) {
            if(item) {
                item.setSliderValue(slider.value);
            }
        }

        return Super.handleSubControl(ctrl, event, fromMouse, fromController);
    }


    override void toggle(bool mouseSelection, bool controllerSelection) {
        if(!checkbox.isDisabled()) checkbox.onActivate(mouseSelection, controllerSelection);
    }

    override void transitionToState(int idx, bool sound) {
        let oldState = currentState;
        Super.transitionToState(idx, sound);

        if(idx == State_Disabled) {
            if(checkbox) checkbox.setDisabled(true);
            if(slider) slider.setDisabled(true);
        } else {
            if(checkbox && checkbox.currentState == State_Disabled && oldState == State_Disabled) {
                checkbox.setDisabled(false);
            }

            if(slider) {
                if(slider.isDisabled()  && oldState == State_Disabled) {
                    slider.setDisabled(false);
                }
            }
        }
    }

    override void setDisabled(bool disable) {
        //Super.setDisabled(disable);
        if(checkbox) checkbox.setDisabled(disable);
        if(slider) slider.setDisabled(disable);

        // Cheating
        if(disable) {
            buttStates[State_Normal].textColor = 0xAA999999;
            buttStates[State_Hover].textColor = 0xAA999999;
            label.textColor = 0xAA999999;
        }
        
        isDisabledInMenu = disable;
    }
}


class SkillMenuSliderOptionView : SkillMenuOptionView {
    mixin SkillMenuSliderOptionMix;

    SkillMenuSliderOptionView init(OptionMenuItem menuItem) {
        let hiState = CommonUI.barBackgroundState();
        hiState.textColor = 0xFFB4B4FF;
        hiState.blendColor = 0;
        
        let pressState = CommonUI.barBackgroundState();
        pressState.textColor = 0xFFB4B4FF;
        pressState.blendColor = 0x88B4B4FF;

        let disableState = UIButtonState.Create("", 0xAA999999);
        //pressState.blendColor = 0;

        let defaultState = UIButtonState.Create("", 0xFFFFFFFF);
        defaultState.blendColor = 0;

        let cv = menuItem ? CVar.FindCVar(menuItem.getAction()) : null;
        bool active = cv && cv.GetFloat() > 0;

        textLeft = 65;

        super.init(
            (0,0), (350, 44),
            menuItem ? StringTable.Localize(menuItem.mLabel) : "[Unkown Option]", "SEL46FONT",
            UIButtonState.Create("", 0xFFFFFFFF),
            hiState,
            pressState,
            disableState,
            textAlign: UIView.Align_Left | UIView.Align_Middle
        );
        setTextPadding(textLeft, 5, 0, active ? 40 : 5);
        label.scaleToHeight(30);
        originalFontScale = label.fontScale;
        maxSize.x = 500;
        pinHeight(active ? 84 : 52);
        pinWidth(1.0, isFactor: true);
        buttonIndex = 0;
        hasAnimated = true;     // Don't trigger animation as soon as we appear, it happens manually
        cancelsSubviewRaycast = false;

        self.menuItem = menuItem;
        alpha = 0;

        // Add the checkbox
        checkbox = new("StandardCheckbox").init((15,0), (40, 40));
        checkbox.pin(UIPin.Pin_Top, offset: 6);
        checkbox.forwardSelection = self;
        
        add(checkbox);

        double mmin = 0, mmax = 10, mstep = 1;

        if(menuItem) {
            checkbox.setSelected(cv && cv.getInt() > 0, false);

            let mitem = OptionMenuItemTooltipSlider(menuItem);
            if(mitem) {
                mmin = mitem.mMin;
                mmax = mitem.mMax;
                mstep = mitem.mStep;
            }
        }

        // Add the slider
        slider = new("UISlider").init((0,0), (100, 30), mmin + mstep, mmax, mstep, 
            NineSlice.Create("graphics/options_menu/slider_bg.png", (7, 14), (24, 16)),
            NineSlice.Create("graphics/options_menu/slider_bg_full.png", (7, 14), (24, 16)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down.png", (8,8), (13,13))
        );
        
        slider.pin(UIPin.Pin_Left, offset: 15);
        slider.pin(UIPin.Pin_Right, offset: -35);
        slider.pin(UIPin.Pin_Bottom, UIPin.Pin_Bottom, offset: -6);
        slider.minSize.y = 30;
        slider.pinHeight(30);
        //slider.rejectHoverSelection = true;
        slider.slideButt.rejectHoverSelection = true;
        slider.buttonSize = 30;
        slider.forwardSelection = self;
        slider.slideButt.forwardSelection = self;
        slider.hidden = !active;
        slider.forceIncrement = true;
        slider.requiresLayout = true;


        if(menuItem && cv) {
            let o = OptionMenuItemTooltipSliderMode(menuItem);

            slider.setValue(cv.GetFloat());
            lastValue = cv.GetFloat();

            if(o.isNew) addNewImage();
        }

        add(slider);

        return self;
    }
}


class SkillMenuSliderOptionView2 : SkillMenuOptionView {
    mixin SkillMenuSliderOptionMix;

    SkillMenuSliderOptionView2 init(OptionMenuItem menuItem) {
        slide = 0.00000001; // I hate myself
        magnify = 1.0;
        
        let hiState = UIButtonState.Create("", 0xFFB4B4FF);
        hiState.blendColor = 0;
        
        let pressState = UIButtonState.Create("", 0xFFB4B4FF);
        pressState.blendColor = 0x88B4B4FF;

        let defaultState = UIButtonState.Create("", 0xFFFFFFFF);
        defaultState.blendColor = 0;

        let disableState = UIButtonState.Create("", 0xAA999999);
        disableState.blendColor = 0;

        let cv = menuItem ? CVar.FindCVar(menuItem.getAction()) : null;
        bool active = cv && cv.GetFloat() > 0;

        textLeft = 50;

        super.init(
            (0,0), (350, 44),
            menuItem ? StringTable.Localize(menuItem.mLabel) : "[Unkown Option]", "SEL27OFONT",
            UIButtonState.Create("", 0xFFFFFFFF),
            hiState,
            pressState,
            disableState,
            textAlign: UIView.Align_Left | UIView.Align_Middle
        );
        setTextPadding(textLeft, 4, 0, active ? 40 : 5);
        label.scaleToHeight(29);
        originalFontScale = label.fontScale;
        maxSize.x = 500;
        pinHeight(active ? 84 : 52);
        pinWidth(1.0, isFactor: true);
        buttonIndex = 0;
        hasAnimated = true;     // Don't trigger animation as soon as we appear, it happens manually
        cancelsSubviewRaycast = false;

        self.menuItem = menuItem;
        alpha = 1;

        // Add the checkbox
        checkbox = new("StandardCheckbox").init((0,0), (40, 40));
        checkbox.pin(UIPin.Pin_Top, offset: 6);
        checkbox.forwardSelection = self;
        
        add(checkbox);

        double mmin = 0, mmax = 10, mstep = 1;

        if(menuItem) {
            checkbox.setSelected(cv && cv.getInt() > 0, false);

            let mitem = OptionMenuItemTooltipSlider(menuItem);
            if(mitem) {
                mmin = mitem.mMin;
                mmax = mitem.mMax;
                mstep = mitem.mStep;
            }
        }

        // Add the slider
        slider = new("UISlider").init((0,0), (100, 30), mmin + mstep, mmax, mstep, 
            NineSlice.Create("graphics/options_menu/slider_bg.png", (7, 14), (24, 16)),
            NineSlice.Create("graphics/options_menu/slider_bg_full.png", (7, 14), (24, 16)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down.png", (8,8), (13,13))
        );
        
        slider.pin(UIPin.Pin_Left, offset: 50);
        slider.pin(UIPin.Pin_Right, offset: -35);
        slider.pin(UIPin.Pin_Bottom, UIPin.Pin_Bottom, offset: -6);
        slider.minSize.y = 30;
        slider.pinHeight(30);
        //slider.rejectHoverSelection = true;
        slider.slideButt.rejectHoverSelection = true;
        slider.buttonSize = 30;
        slider.forwardSelection = self;
        slider.slideButt.forwardSelection = self;
        slider.hidden = !active;
        slider.forceIncrement = true;
        slider.requiresLayout = true;

        if(menuItem) {
            slider.setValue(cv.GetFloat());
            lastValue = cv.GetFloat();
        }

        add(slider);

        return self;
    }
}


class SkillMenuRadioOptionView : SkillMenuOptionView {
    mixin SkillMenuCheckboxOptionMix;

    int groupID;

    override void onAddedToParent(UIView parentView) {
        UIButton.onAddedToParent(parentView);
        label.pixelAlign = false;
    }

    SkillMenuRadioOptionView init(String title, int idx = 0, bool selected = false) {
        let hiState = UIButtonState.Create("", 0xFFB4B4FF);
        hiState.blendColor = 0;
        
        let pressState = UIButtonState.Create("", 0xFFB4B4FF);
        pressState.blendColor = 0x88B4B4FF;

        let defaultState = UIButtonState.Create("", 0xFFFFFFFF);
        defaultState.blendColor = 0;

        slide = 0.00000001; // I hate myself
        magnify = 1.0;

        super.init(
            (0,0), (350, 44),
            title, "SEL27OFONT",
            UIButtonState.Create("", 0xFFFFFFFF),
            hiState,
            pressState,
            textAlign: UIView.Align_Left | UIView.Align_Middle
        );
        setTextPadding(64, 5, 0, 5);
        label.scaleToHeight(30);
        originalFontScale = label.fontScale;
        maxSize.x = 500;
        pinHeight(52);
        pin(UIPin.Pin_Left);
        pin(UIPin.Pin_Right);
        hasAnimated = true;     // Don't trigger animation as soon as we appear, it happens manually

        checkbox = new("QualityRadioButton").init((15,0), (40, 40));
        checkbox.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        checkbox.forwardSelection = self;

        if(selected) checkbox.setSelected(true);
        
        add(checkbox);

        controlID = idx;
        buttonIndex = idx;

        return self;
    }


    override void setDisabled(bool disable) {
        if(checkbox) checkbox.setDisabled(disable);
        
        // Cheating
        if(disable) {
            buttStates[State_Normal].textColor = 0xAA999999;
            buttStates[State_Hover].textColor = 0xAA999999;
            label.textColor = 0xAA999999;
        } else {
            buttStates[State_Normal].textColor = 0xFFFFFFFF;
            buttStates[State_Hover].textColor = 0xFFB4B4FF;
            label.textColor = 0xFFFFFFFF;
        }
        isDisabledInMenu = disable;
    }
}


class SkillMenuButtonStandard : TitleButton {
    SkillMenuButtonStandard init(string text) {
        Super.init((0,0), (100, 30), text, 'PDA16FONT',
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFFFFFFFF),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13))
        );

        setTextPadding(12,8,12,8);
        label.multiline = true;
        pin(UIPin.Pin_Left);
        pinHeight(UIView.Size_Min);
        pinWidth(UIView.Size_Min);

        return self;
    }


    override void animateToNormal() {
        let animator = getAnimator(); 
        if(animator) animator.clear(label);
    }

    override void animateToHover() {
        let animator = getAnimator(); 
        if(animator) animator.clear(label);
    }
}