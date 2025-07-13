class ResourceView : UIImage {
    int deltaValue, value, displayValue;
    double valueTime, changeTime;
    UILabel label;
    UIImage icon;

    const IMAGE_RIGHT = 32 + 7;
    const TEXT_LPADDING = 37 + 7;
    const TEXT_RPADDING = 15;
    const FIXED_HEIGHT = 41;

    ResourceView init(int value, string iconImage, int textColor = Font.CR_UNTRANSLATED, bool rightAligned = false, bool valid = true) {
        Super.Init((0,0), (100, FIXED_HEIGHT), "", NineSlice.Create(WeaponStationGFXPath .. (valid ? "resourceBG.png" : "resourceBG2.png"), (10, 10), (16, 16)));

        pinHeight(FIXED_HEIGHT);
        
        deltaValue = self.value = displayValue = value;

        label = new("UILabel").init((0,0), (100, 39), String.Format("%d", value), "SEL46FONT", textColor, textAlign: rightAligned ? (Align_Right | Align_Middle) : (Align_Left | Align_Middle));
        label.scaleToHeight(31);
        label.monospace = true;
        label.multiline = false;

        if(rightAligned) label.pinToParent(TEXT_RPADDING, -1, -TEXT_LPADDING);
        else label.pinToParent(TEXT_LPADDING, -1, -TEXT_RPADDING);
        
        add(label);

        icon = new("UIImage").init((0,0), (32, 32), iconImage, imgStyle: UIImage.Image_Aspect_Fit, imgAnchor: rightAligned ? ImageAnchor_Left : ImageAnchor_Right);
        if(rightAligned) {
            icon.pin(UIPin.Pin_Right, offset: -5);
            icon.pin(UIPin.Pin_Left, UIPin.Pin_Right, offset: -IMAGE_RIGHT);
        } else {
            icon.pin(UIPin.Pin_Left, offset: 5);
            icon.pin(UIPin.Pin_Right, UIPin.Pin_Left, offset: IMAGE_RIGHT);
        }
        icon.pin(UIPin.Pin_Top, offset: 5);
        icon.pin(UIPin.Pin_Bottom, offset: -5);
        add(icon);

        return self;
    }

    override Vector2 calcMinSize(Vector2 parentSize) {
        Vector2 size = minSize;

        double hPadding = TEXT_LPADDING + TEXT_RPADDING;

        if(label && label.text != "" && !label.hidden) {
            Vector2 lSize = label.calcMinSize(parentSize) + (hPadding, 0);

            size.x = MIN(MAX(minSize.x, lSize.x), maxSize.x);
            size.y = MIN(MAX(minSize.y, FIXED_HEIGHT), maxSize.y);
        }

        return size;
    }

    void setValue(int newValue, bool animated = true) {
        deltaValue = value;
        value = newValue;

        if(animated) {
            valueTime = getTime();
            changeTime = CLAMP((abs(newValue - deltaValue) / 500.0) * 1.0, 0.0, 1.0);
        }
    }

    void setValid(bool valid) {
        slices.texture.texID = TexMan.CheckForTexture(WeaponStationGFXPath .. (valid ? "resourceBG.png" : "resourceBG2.png"));
    }

    override void draw() {
        if(hidden) { return; }

        int dval = valueTime != 0 ? UIMath.Lerpi(deltaValue, value, CLAMP((getTime() - valueTime) / changeTime, 0, 1)) : value;
        if(displayValue != dval) {
            label.setText(String.Format("%d", dval));
            displayValue = dval;
            requiresLayout = true;
        }
        

        Super.draw();
    }
}