class SOMChoiceView : UIDropdown {
    UIButton leftButton, rightButton;
    UILabel outLabel;

    SOMChoiceView init(Array<String> items, int selectedIndex, UIScrollBarConfig scrollConfig, String noneText, UIControl fSelection = null) {
        Super.init((0,0), (0,32), items, selectedIndex, "PDA16FONT", scrollConfig,
            UIButtonState.Create("", textColor: 0xFFFFFFFF),
            UIButtonState.Create("", textColor: 0xFFFFFFFF),
            UIButtonState.Create("", textColor: 0xFFFFFFFF),
            UIButtonState.Create("", textColor: 0x66AAAAAA),
            dropdownBG: NineSlice.Create("graphics/options_menu/op_dropdown_pop.png", (9,9), (13,13)),
            //indicator: "graphics/options_menu/op_dropdown_arrow.png",
            textAlign: Align_Centered,
            noneText: noneText
        );

        cancelsSubviewRaycast = false;

        setTextPadding(40,0,40,0);
        dropLayout.padding.top = dropLayout.padding.bottom = 8;

        // Add left and right arrow buttons
        leftButton = new("UIButton").init((0,0), (32,32), "", null,
            UIButtonState.Create("graphics/options_menu/arrow_left.png"),
            UIButtonState.Create("graphics/options_menu/arrow_left_high.png", sound: "ui/cursor2", soundVolume: 0.45),
            UIButtonState.Create("graphics/options_menu/arrow_left_down.png"),
            UIButtonState.Create("graphics/options_menu/arrow_left.png")
        );
        leftButton.pin(UIPin.Pin_Left);
        leftButton.pin(UIPin.Pin_VCenter, value: 1.0);
        leftButton.rejectHoverSelection = true;
        leftButton.forwardSelection = fSelection;
        add(leftButton);

        rightButton = new("UIButton").init((0,0), (32,32), "", null,
            UIButtonState.Create("graphics/options_menu/arrow_right.png"),
            UIButtonState.Create("graphics/options_menu/arrow_right_high.png", sound: "ui/cursor2", soundVolume: 0.45),
            UIButtonState.Create("graphics/options_menu/arrow_right_down.png"),
            UIButtonState.Create("graphics/options_menu/arrow_right.png")
        );
        rightButton.pin(UIPin.Pin_Right);
        rightButton.pin(UIPin.Pin_VCenter, value: 1.0);
        rightButton.rejectHoverSelection = true;
        rightButton.forwardSelection = fSelection;
        add(rightButton);

        // Make a second label for animated changes
        outLabel = new("UILabel").init((0,0), (100, 100), "", label.fnt, label.textColor, label.textAlign, label.fontScale);
        outLabel.pinToParent(textPadding.left, textPadding.top, -textPadding.right, -textPadding.bottom);
        outLabel.hidden = true;
        add(outLabel);

        minSize.y = 32;

        checkArrows();
        
        return self;
    }

    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        if(event == UIHandler.Event_Activated) {
            if(ctrl == leftButton) {
                if(selectPrevious()) {
                    //checkArrows();
                    sendEvent(UIHandler.Event_ValueChanged, fromMouse, fromController);
                }
                return true;
            } else if(ctrl == rightButton) {
                if(selectNext()) {
                    //checkArrows();
                    sendEvent(UIHandler.Event_ValueChanged, fromMouse, fromController);
                }
                return true;
            }
        }

        return Super.handleSubControl(ctrl, event, fromMouse, fromController);
    }

    void checkArrows() {
        if(disabled) {
            leftButton.alpha = 0.15;
            rightButton.alpha = 0.15;
        } else {
            leftButton.alpha = selectedItem <= 0 ? 0.15 : 1.0;
            rightButton.alpha = selectedItem >= items.size() - 1 ? 0.15 : 1.0;
        }
    }


    override bool selectNext() {
        String oldText = selectedItem >= 0 ? items[selectedItem] : "";

        if(Super.selectNext()) {
            checkArrows();
            animateChange(oldText, false);
            return true;
        }

        return false;
    }

    override bool selectPrevious() {
        String oldText = selectedItem >= 0 ? items[selectedItem] : "";

        if(Super.selectPrevious()) {
            checkArrows();
            animateChange(oldText, true);
            return true;
        }

        return false;
    }

    override void cycleNext() {
        Super.cycleNext();
        checkArrows();
    }

    void animateChange(String oldText, bool goBack = false) {
        outLabel.hidden = false;
        outLabel.text = oldText;
        //layout();

        let size = frame.size.x * 0.4;

        outLabel.animateFrame(
            0.12,
            fromPos: label.frame.pos,
            toPos: (goBack ? (textPadding.left + size, 0) : (textPadding.left - size , 0)),
            fromAlpha: 1,
            toAlpha: 0,
            ease: Ease_Out
        );

        label.animateFrame(
            0.12,
            fromPos: label.frame.pos + (goBack ? (-size, 0) : (size , 0)),
            toPos: (textPadding.left, label.frame.pos.y),
            fromAlpha: 0,
            toAlpha: 1,
            ease: Ease_Out
        );

        requiresLayout = true;
    }

    override void setSelectedItem(int selected) {
        Super.setSelectedItem(selected);
        checkArrows();
    }

    override void setTextPadding(double left, double top, double right, double bottom) {
        Super.setTextPadding(left, top, right, bottom);

        if(outLabel) {
            outLabel.firstPin(UIPin.Pin_Left).offset = left;
            outLabel.firstPin(UIPin.Pin_Top).offset = top;
            outLabel.firstPin(UIPin.Pin_Right).offset = -right;
            outLabel.firstPin(UIPin.Pin_Bottom).offset = -bottom;
            outLabel.requiresLayout = true;
        }
    }

    override void setDisabled(bool disable) {
        Super.setDisabled(disable);

        leftButton.setDisabled(disable);
        rightButton.setDisabled(disable);
        checkArrows();
    }
}