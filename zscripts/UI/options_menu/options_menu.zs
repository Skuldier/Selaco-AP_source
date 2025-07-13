#include "ZScripts/UI/options_menu/options_menu_base.zs"
#include "ZScripts/UI/options_menu/options_items.zs"
#include "ZScripts/UI/options_menu/som_option_view.zs"
#include "ZScripts/UI/options_menu/options_keybind.zs"
#include "ZScripts/UI/options_menu/gamepad_objects.zs"
#include "ZScripts/UI/options_menu/custom_prompt.zs"
#include "ZScripts/UI/options_menu/options_prompt.zs"


class SelacoOptionMenu : SelacoOptionsMenuBase {
    ListMenuDescriptor menuDescriptor;
    UIVerticalLayout lay, rightLay;
    UIVerticalScroll scrollView;
    UIView rightPanel;
    StandardBackgroundContainer background;          // Used as the main container
    //UIImage previewBG;                               // Dark bg behind preview
    UIImage previewImage;                            // Preview of settings
    UILabel valueLabel, valueTitleLabel;             // Description of the current value of the current setting
    UILabel tooltipLabel;                            // Description of the current setting in general
    UIScrollBarConfig dropScrollConfig;              // Scrollbar setup for dropdowns
    UIPin scrollViewPin, layPin, rightPanelPin, leftLayPin;
    
    UIButton gamepadDeleteBindIcon;                  // Footer view for X=delete bind

    bool smallWidth, noMenuList;
    double dimStart;
    int requiresItemLayout, requiresPresetLayout, requiresItemUpdate;

    // Keybind holder
    int lastKeybindKey;
    Name lastKeybind;
    KeyBindings lastBindings;

    bool openedFromMouse;                                   // opened from mouse will fully restore the navigation path
    double mouseSensMulti;

    Array<UIButton> sectionButts;
    
    UIButton lastSelectedSectionButt;

    const midFactor = 0.62;
    const leftLayOffset = 300;
    const dimTime = 0.3;
    const dimDelay = 0.25;

    const RIGHT_PANEL_WIDTH = 480.0;

    override void init(Menu parent) {
		Super.init(parent);
        AnimatedTransition = false;
        //allowDimInGameOnly();
        DontDim = true;

        gamepadIndexStart = -1;
        isGamepadMenu = false;

        // Calculate the mouse sensitivity ratio
        // Engine version determines ratio
        mouseSensMulti = 0;//fGetCVar('m_sensitivity_ratio', 0);
        dropScrollConfig = CommonUI.makeDropScrollConfig();
        
        background = CommonUI.makeStandardBackgroundContainer(title: StringTable.Localize("$TITLE_OPTIONS"));
        mainView.add(background);

        if(JoystickConfig.NumJoysticks()) {
            background.addGamepadFooter(InputEvent.Key_Pad_B, "Back");
        }

        lay = new("UIVerticalLayout").init((0,0), (300, 200));
        lay.pin(UIPin.Pin_Left);
        lay.pin(UIPin.Pin_Top);
        lay.pin(UIPin.Pin_Bottom);
        lay.itemSpacing = 3;
        lay.clipsSubviews = false;
        
        lay.pinWidth(300);
        background.add(lay);

        // Alternate layout for preview stuff
        /*leftLay = new("UIVerticalLayout").init((0,0), (320, 200));
        leftLay.pin(UIPin.Pin_Bottom);
        leftLayPin = leftLay.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 0, offset: leftLayOffset, isFactor: true);
        leftLay.pin(UIPin.Pin_Left, offset: 30);
        leftLay.padding.top = 10;
        leftLay.hidden = true;
        mainView.add(leftLay);

        previewBG = new("UIImage").init((0,0), (1,1), "", NineSlice.Create("graphics/options_menu/op_bg3.png", (6,6), (24,24)));
        previewBG.pinToParent();
        leftLay.add(previewBG);*/

        // rightPanel contains the middle and right layouts
        rightPanel = new("UIView").init((0,0), (300, 800));
        rightPanel.pin(UIPin.Pin_Left, offset: lay.widthPin.value + 15, priority: 666);
        rightPanel.pin(UIPin.Pin_Right);
        rightPanel.pin(UIPin.Pin_Bottom);
        rightPanel.pin(UIPin.Pin_Top);
        background.add(rightPanel);

        rightLay = new("UIVerticalLayout").init((0,0), (100, 800));
        rightLay.pin(UIPin.Pin_Bottom);
        rightLay.pin(UIPin.Pin_Top);
        rightLay.pin(UIPin.Pin_Left, UIPin.Pin_Right, offset: -RIGHT_PANEL_WIDTH);
        rightLay.pin(UIPin.Pin_Right);
        rightLay.padding.top = 20;
        rightLay.itemSpacing = 4;
        rightPanel.add(rightLay);

        let rightLayBackground = new("UIImage").init((0,0), (100, 100), "graphics/options_menu/desc_bg.png");
        rightLayBackground.pinToParent();
        rightLay.add(rightLayBackground);

        previewImage = new("UIImage").init((0,0), (100, 305), "", imgStyle: UIImage.Image_Aspect_Fit);
        previewImage.pin(UIPin.Pin_Left, offset: 0);
        previewImage.pin(UIPin.Pin_Right, offset: 0);
        rightLay.addManaged(previewImage);


        valueTitleLabel = new("UILabel").init((0,0), (100, 40), "", "SEL21OFONT");
        valueTitleLabel.multiline = true;
        valueTitleLabel.pin(UIPin.Pin_Left, offset: 25);
        valueTitleLabel.pin(UIPin.Pin_Right, offset: -25);
        valueTitleLabel.pinHeight(UIView.Size_Min);
        rightLay.addManaged(valueTitleLabel);

        rightLay.addSpacer(10);

        tooltipLabel = new("UILabel").init((0,0), (100, 40), "", "PDA16FONT");
        tooltipLabel.multiline = true;
        tooltipLabel.pin(UIPin.Pin_Left, offset: 25);
        tooltipLabel.pin(UIPin.Pin_Right, offset: -25);
        tooltipLabel.pinHeight(UIView.Size_Min);
        rightLay.addManaged(tooltipLabel);

        valueLabel = new("UILabel").init((0,0), (100, 40), "", "PDA16FONT");
        valueLabel.multiline = true;
        valueLabel.pin(UIPin.Pin_Left, offset: 25);
        valueLabel.pin(UIPin.Pin_Right, offset: -25);
        valueLabel.pinHeight(UIView.Size_Min);
        rightLay.addManaged(valueLabel);

        scrollView = new("OptionsVerticalScroll").init((0,0), (0,0), 30, 24,
            NineSlice.Create("graphics/options_menu/slider_bg_vertical.png", (14, 6), (16, 24)),
            null,
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down.png", (8,8), (13,13))
        );
        scrollView.pin(UIPin.Pin_Bottom);
        scrollView.pin(UIPin.Pin_Top);
        scrollView.pin(UIPin.Pin_Left);
        scrollViewPin = scrollView.pin(UIPin.Pin_Right, offset: -(RIGHT_PANEL_WIDTH + 15));
        scrollView.minSize.x = 700;
        //scrollView.maxSize.x = 820 + 30;
        scrollView.autoHideScrollbar = true;
        //scrollView.hugEnd = true;
        scrollView.scrollbar.buttonSize = 20;
        scrollView.scrollbar.rejectHoverSelection = true;
        scrollView.rejectHoverSelection = true;
        scrollView.mLayout.ignoreHiddenViews = true;
        scrollView.mLayout.layoutWithChildren = true;
        rightPanel.add(scrollView);

        midLay = UIVerticalLayout(scrollView.mLayout);
        midLay.itemSpacing = 2.0;

        // Create options sections based on MENUDEF descriptor, only using basic list items here
        menuDescriptor = ListMenuDescriptor(MenuDescriptor.GetDescriptor("OptionsMenu2"));
        if(menuDescriptor) {
            UIButton lastButt = null;
            for(int x = 0; x < menuDescriptor.mItems.size(); x++) {
                if(menuDescriptor.mItems[x] is 'ListMenuItemSeparator') {
                    addSectionSeparator();
                    continue;
                }

                if(menuDescriptor.mItems[x] is 'ListMenuItemSpacer') {
                    addSectionSpacer(ListMenuItemSpacer(menuDescriptor.mItems[x]).vSpace);
                    continue;
                }
                
                ListMenuItemTextItem it = ListMenuItemTextItem(menuDescriptor.mItems[x]);
                if(!it) continue;

                let hiState = CommonUI.barBackgroundState();
                hiState.textColor = 0xFFB4B4FF;

                TitleButton butt = TitleButton(new("TitleButton").init(
                    (0,0), (350, 40),
                    StringTable.Localize(it.mText), "SEL27OFONT",
                    UIButtonState.Create("", 0xFFFFFFFF),
                    hiState,
                    UIButtonState.Create("", 0xFFB4B4FF),
                    textAlign: UIView.Align_Left | UIView.Align_Middle
                ));
                butt.navUp = lastButt;
                butt.command = "section:" .. it.getAction();
                butt.setTextPadding(0, 5, 0, 5);
                butt.label.fontScale = (0.87, 0.87);
                butt.originalFontScale = (0.87, 0.87);
                butt.maxSize.x = 500;
                butt.pinHeight(42);
                butt.pinWidth(1.0, isFactor: true);
                butt.buttonIndex = x;
                butt.controlID = sectionButts.size();

                if(it is 'ListMenuItemTextItemImage') {
                    butt.setImage(ListMenuItemTextItemImage(it).mImage);
                    let v = new("UIView").init((0,0), (2, 0));
                    v.backgroundColor = 0xFFFFFFFF;
                    v.pin(UIPin.Pin_Right, offset: 15);
                    v.pin(UIPin.Pin_Bottom, offset: -5);
                    v.pin(UIPin.Pin_Top, offset: 5);
                    v.alpha = 0.45;
                    butt.image.add(v);
                    butt.image.clipsSubviews = false;
                    butt.setTextPadding(80, 5, 0, 5);
                }

                lay.addManaged(butt);

                if(it.mParam == 128) {
                    butt.setDisabled(true);
                }

                if(lastButt) {
                    lastButt.navDown = butt;
                }

                sectionButts.push(butt);
                lastButt = butt;
            }

            // Make a looping up/down navigation between all buttons
            if(sectionButts.size() > 1) {
                sectionButts[sectionButts.size() - 1].navDown = sectionButts[0];
                sectionButts[0].navUp = sectionButts[sectionButts.size() - 1];
            }

            // Select the first enabled control
            for(int x = 0; x < sectionButts.size(); x++) {
                if(!sectionButts[x].isDisabled()) {
                    navigateTo(sectionButts[x]);
                    break;
                }
            }
        }


        dimStart = getTime();

        layout();
        mainView.requiresLayout = true;
        configPreview();
    }


    void layout() {
        // Assume mainView has already been layed out
        // Just adjust for sufficient width to show the preview/tooltip area
        smallWidth = (mainView.frame.size.x - 700 - 160) < (RIGHT_PANEL_WIDTH + 15);
        noMenuList = mainView.frame.size.x < 1800;
        rightLay.hidden = smallWidth;

        if(smallWidth) {
            scrollViewPin.offset = 0;
        } else {
            scrollViewPin.offset = -(RIGHT_PANEL_WIDTH + 15);
        }
    }


    // Animate transition between showing only the left panel, and showing the full options menu
    // Only required when the view space is not large enough to contain everything (4:3, or zoomed)
    void transitionScreen(bool showOptions = true, bool animate = true) {
        if(noMenuList) {
            if(showOptions) {
                background.popHeaderLabel();
                background.addHeaderLabel(lastSelectedSectionButt ? lastSelectedSectionButt.label.text : "", animate);
                lay.firstPin(UIPin.Pin_Left).offset = -lay.frame.size.x;
                lay.raycastTarget = false;  // Prevent mouse clicks/hover events
                rightPanel.raycastTarget = true;
                rightPanel.cancelsSubviewRaycast = false;
                rightPanel.firstPin(UIPin.Pin_Left).offset = 0;
                rightPanel.layout();
                
                if(animate) {
                    lay.animateFrame(
                        0.15,
                        fromPos: lay.frame.pos,
                        toPos: (-(lay.frame.size.x * 0.75), lay.frame.pos.y),
                        fromAlpha: lay.alpha,
                        toAlpha: 0,
                        ease: Ease_Out
                    );

                    rightPanel.animateFrame(
                        0.2,
                        fromPos: (150, rightPanel.frame.pos.y),
                        toPos: (0, rightPanel.frame.pos.y),
                        fromAlpha: 0,
                        toAlpha: 1,
                        ease: Ease_Out
                    );
                } else {
                    lay.alpha = 0.1;
                    rightPanel.alpha = 1;
                }
                
            } else {
                lay.firstPin(UIPin.Pin_Left).offset = 0;
                lay.raycastTarget = true;
                rightPanel.raycastTarget = false;
                rightPanel.cancelsSubviewRaycast = true;
                rightPanel.firstPin(UIPin.Pin_Left).offset = lay.widthPin.value + 15;
                background.popHeaderLabel();

                if(animate) {
                    lay.animateFrame(
                        0.15,
                        fromPos: lay.frame.pos,
                        toPos: (0, lay.frame.pos.y),
                        fromAlpha: lay.alpha,
                        toAlpha: 1,
                        ease: Ease_Out
                    );

                    rightPanel.animateFrame(
                        0.2,
                        fromPos: rightPanel.frame.pos,
                        toPos: (150, rightPanel.frame.pos.y),
                        fromAlpha: rightPanel.alpha,
                        toAlpha: 0,
                        ease: Ease_In
                    );
                } else {
                    lay.alpha = 1;
                    rightPanel.alpha = 0;
                }
            }

        } else {
            // Normal size!
            lay.firstPin(UIPin.Pin_Left).offset = 0;
            lay.raycastTarget = true;
            rightPanel.raycastTarget = true;
            rightPanel.cancelsSubviewRaycast = false;
            let rpin = rightPanel.firstPin(UIPin.Pin_Left);
            rpin.offset = lay.widthPin.value + 15;
            lay.alpha = 1;

            background.popHeaderLabel();

            if(showOptions) {
                background.addHeaderLabel(lastSelectedSectionButt ? lastSelectedSectionButt.label.text : "", animate);

                rightPanel.layout();

                if(animate) {
                    rightPanel.animateFrame(
                        0.2,
                        fromPos: (rpin.offset + 150, rightPanel.frame.pos.y),
                        toPos: (rpin.offset, rightPanel.frame.pos.y),
                        fromAlpha: 0,
                        toAlpha: 1,
                        ease: Ease_Out
                    );
                } else {
                    rightPanel.alpha = 1;
                }

            } else {
                if(animate) {
                    rightPanel.animateFrame(
                        0.2,
                        fromPos: rightPanel.frame.pos,
                        toPos: (rpin.offset + 150, rightPanel.frame.pos.y),
                        fromAlpha: rightPanel.alpha,
                        toAlpha: 0,
                        ease: Ease_In
                    );
                } else {
                    rightPanel.alpha = 0;
                }
            }
        }


        if(!animate) {
            lay.requiresLayout = true;
            rightPanel.requiresLayout = true;
        }
    }

    void closeOptions() {
        background.popHeaderLabel();

        // De-select all buttons
        for(int x = 0; x < sectionButts.size(); x++) {
            sectionButts[x].setSelected(false);
        }
        
        optionsDescriptor = null;
        midLay.clearManaged();
        optionViews.clear();
        presetViews.clear();
        firstControl = lastControl = null;

        // Only navigate to previous control if we are using keyboard navigation
        if(!lastEventWasMouse) {
            navigateTo(lastSelectedSectionButt);
        } else {
            clearNavigation();
        }

        scrollView.requiresLayout = true;           // Needs to lay out to hide scroll bar
        configPreview();

        // Hide any button commands
        // TODO: Use keys for this instead of actual references
        if(gamepadDeleteBindIcon) {
            background.removeGamepadFooter(gamepadDeleteBindIcon);
            gamepadDeleteBindIcon = null;
        }

        transitionScreen(false, true);
    }

    
    override void createOptionsGroup(string def, UIButton sourceButton, UIScrollBarConfig dropScrollConfig) {
        Super.createOptionsGroup(def, sourceButton, dropScrollConfig);

        scrollView.scrollNormalized(0);
        scrollView.requiresLayout = true;
    }


    /*override void addOptions(OptionMenuDescriptor desc, UIButton sourceButton, UIControl lastCon, UIScrollBarConfig dropScrollConfig) {
        Super.addOptions(desc, sourceButton, lastCon);
    }*/


    override void reloadGamepads(UIScrollBarConfig dropScrollConfig) {
        if(!isGamepadMenu || gamepadIndexStart < 0) return;

        double oldContainer = scrollView.mLayout.frame.size.y - scrollView.frame.size.y;
        double oldScroll = scrollView.scrollbar.getNormalizedValue();

        Super.reloadGamepads(self.dropScrollConfig);

        scrollView.layout();

        // Determine final scroll position (normalized) after adjusting sizes
        //(double val, bool animated = false, bool sendEvt = true, bool fromMouse = true, int animateTicks = scrollTicks)
        scrollView.scrollNormalized(clamp((oldContainer * oldScroll) / (scrollView.mLayout.frame.size.y - scrollView.frame.size.y), 0.0, 1.0), false, false);
    }


    void addSectionSeparator(int height = 2) {
        UIView v = new("UIView").init((0,0), (0,height));
        v.backgroundColor = 0x33666666;
        v.pin(UIPin.Pin_Left, offset: 10);
        v.pin(UIPin.Pin_Right, offset: -20);
        lay.addManaged(v);
    }

    void addSectionSpacer(int height) {
        lay.addSpacer(height);
    }

    void changeSectionName(String newSection, bool fromMouse) {
        for(int x = 0; x < sectionButts.size(); x++) {
            UIButton btn = sectionButts[x];

            Array<String> ar;
            btn.command.Split(ar, ":");

            if(newSection.makeLower() == ar[1].makeLower()) {
                changeSection(btn.controlID, fromMouse);
                return;
            }
        }
    }


    void changeSection(int sectionIndex, bool fromMouse) {
        UIButton btn;
        for(int x = 0; x < sectionButts.size(); x++) {
            sectionButts[x].setSelected(sectionButts[x].controlID == sectionIndex);
            if(sectionButts[x].controlID == sectionIndex) btn = sectionButts[x];
        }

        Array<String> ar;
        btn.command.Split(ar, ":");

        bool wasOpen = !!optionsDescriptor;

        createOptionsGroup(ar[1], btn, dropScrollConfig);
        lastSelectedSectionButt = btn;
        MenuSound("menu/advance");

        // Special case: Check for mouse linked sliders and set appropriate values
        resetMouseSensRatio();
        
        // Navigate control to the new list of controls, but only if we didn't use the mouse to get here
        if(firstControl) {
            navigateToLastSelectedItem(fromMouse);
        } else if(fromMouse) {
            clearNavigation();
            configPreview();
        }

        // Save selected section for next time we open the menu
        LevelEventHandler ev = LevelEventHandler.Instance();
        if(ev) ev.settingsPos[0] = sectionIndex + 1;

        // If this is the first time we have opened options, transition in
        if(!wasOpen) transitionScreen(true, true);
        else {
            background.popHeaderLabel();
            background.addHeaderLabel(lastSelectedSectionButt ? lastSelectedSectionButt.label.text : "", false);
        }
    }


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(event == UIHandler.Event_Selected) {
            let c = SOMOptionView(ctrl);
            if(c) {
                if(c.type == SOMOptionView.Option_Keybind && JoystickConfig.NumJoysticks()) {
                    if(!gamepadDeleteBindIcon) {
                        gamepadDeleteBindIcon = background.addGamepadFooter(InputEvent.Key_Pad_X, "Clear Binding", 0);
                    }
                } else {
                    if(gamepadDeleteBindIcon) {
                        background.removeGamepadFooter(gamepadDeleteBindIcon);
                        gamepadDeleteBindIcon = null;
                    }
                }
            }
            return;
        }

        if(event == UIHandler.Event_Activated) {
            Array<String> ar;
            ctrl.command.Split(ar, ":");

            if(ar.size() > 1) {
                if(ar[0] == "section") {
                    // Set this button state to selected and deselected for other buttons
                    int sectionIndex = 0;

                    UIButton btn = UIButton(ctrl);
                    if(btn) {
                        sectionIndex = btn.controlID;
                    }

                    changeSection(sectionIndex, fromMouseEvent);
                }
            }

            if(ctrl.command == "linksens") {
                // Toggle the link sens
                let btn = UIButton(ctrl);
                if(btn) {
                    let xControl = findOptionView('m_sensitivity_x');
                    let yControl = findOptionView('m_sensitivity_y');
                    //let xSlider = UISlider(xControl ? xControl.control : null);
                    //let ySlider = UISlider(yControl ? yControl.control : null);

                    btn.setSelected(!btn.selected);

                    iSetCVar('m_sensitivity_linked', btn.selected ? 1 : 0);

                    if(btn.selected) {
                        resetMouseSensRatio();
                    }


                    if(yControl) {
                        yControl.setDisabled(btn.selected);
                        
                        // Navigate away from the Y control if it was selected
                        if(btn.selected && activeControl == yControl || activeControl == yControl.control) {
                            navigateTo(findOptionView('m_sensitivity_x'));
                        }
                    }
                }
            }

            if(ctrl is 'SOMOptionView') {
                let opv = SOMOptionView(ctrl);
                
                // If we activated X sensitivity, toggle the link button
                if(!fromMouseEvent && opv.menuItem.getAction() == 'm_sensitivity_x' && linkButt) {
                    handleControl(linkButt, UIHandler.Event_Activated, false);
                    return;
                }
            }
        }

        // Update preview if a option has changed value
        if(event == UIHandler.Event_ValueChanged) {
            if(ctrl is "SOMOptionView") {
                let sctrl = SOMOptionView(ctrl);

                if(ctrl == activeControl) { configPreview(sctrl); }

                // If we changed a preset, we need to layout all of the option views next tick
                if(sctrl.menuItem is "OptionMenuItemTooltipPreset") {
                    requiresItemLayout = 2;
                } else {
                    // Update preset views
                    requiresPresetLayout = 2;
                }

                // Special case: If we changed one of the settings to Ridiculous then tell the user they are insane
                let o = OptionMenuItemOption(sctrl.menuItem);
                if(o && iGetCVar("g_promptridiculous")) {
                    String a = o.GetAction();
                    if( (o.getSelection() == 5 && a ~== "cl_maxdecals") || 
                        (o.getSelection() == 4 && (
                        a ~== "r_particleIntensity"    ||
                        a ~== "r_particleLifespan"     ||
                        a ~== "r_BloodQuality"         ||
                        a ~== "r_smokeQuality"))) {
                        
                        MenuSound("ui/message");
                        let m = new("PromptMenu").initNew(self, "$MENU_TITLE_RIDICULOUS", "$MENU_TEXT_RIDICULOUS", "$MENU_BTN_RIDICULOUS");
                        m.ActivateMenu();
                        

                        let cv = CVar.FindCVar("g_promptridiculous");
                        if(cv) {
                            cv.setInt(0);
                        }
                    }
                }

                // Special case: If we changed mouse sensitivity and they are linked, change the opposite value by the delta
                if(iGetCVar('m_sensitivity_linked')) {
                    Name act = sctrl.menuItem.GetAction();

                    if(sctrl.control is "UISlider" && (act == 'm_sensitivity_x' || act == 'm_sensitivity_y')) {
                        // Find the counterpart
                        let ov = findOptionView(act == 'm_sensitivity_x' ? 'm_sensitivity_y' : 'm_sensitivity_x');
                        let sctrlSlider = UISlider(sctrl.control);

                        // Offset value by the delta
                        if(ov && sctrlSlider) {
                            let slider = UISlider(ov.control);
                            if(slider) {
                                // Use the stored offset first
                                if(Engine.FourPointNine()) {
                                    slider.setValue(act == 'm_sensitivity_x' ? sctrlSlider.value + mouseSensMulti : sctrlSlider.value - mouseSensMulti, clampValue: true);
                                }
                                ov.handleValueChange(true, false, notify: false);
                                ov.updateValue();
                            }
                        }
                    }
                }

                // Special case, if this was the gamepad advanced setting, and we are on the gamepad menu, refresh
                if(o && o.GetAction() == "g_gamepad_advanced" && isGamepadMenu) {
                    reloadGamepads();
                }

                // Special case, if this was an action button we need to reload our values
                if(sctrl.command == "reset") {
                    requiresItemLayout = 2;
                }


                for(int x = 0; x < optionViews.size(); x++) {
                    if(optionViews[x].requireCVar) {
                        requiresItemUpdate = 2;
                        break;
                    }
                }


                // Special case, if this was a color dropdown, toggle the color picker immediately below when necessary
                if(sctrl.type == SOMOptionView.Option_MultiChoice && sctrl.menuItem is 'OptionMenuItemColorPickerDD') {
                    if(sctrl.navDown && sctrl.navDown is 'SOMOptionView') {
                        SOMOptionView nextControl = SOMOptionView(sctrl.navDown);
                        if(nextControl.type == SOMOptionView.Option_Color) {
                            bool isHidden = nextControl.hidden;

                            nextControl.hidden = SOMChoiceView(sctrl.control).getSelectedItem() > 0;
                            nextControl.setDisabled(nextControl.hidden);

                            if(nextControl.hidden) {
                                if(activeControl == nextControl) {
                                    navigateTo(nextControl.navUp);
                                }
                            }

                            Color col = OptionMenuItemColorPickerDD(sctrl.menuItem).GetColor();
                            SOMColorSliders(nextControl.control).colorValue = Color(255, col.r, col.g, col.b);
                            SOMColorSliders(nextControl.control).refreshValues();
                            if(nextControl.hidden != isHidden) {
                                //requiresItemLayout = 2;
                            }
                        }
                    }
                }
            }
        }
    }

    SOMOptionView findOptionView(Name actionName) {
        for(int x = 0; x < optionViews.size(); x++) {
            Name n = optionViews[x].menuItem.getAction();

            if(n == actionName) {
                return optionViews[x];
            }
        }

        return null;
    }

    override void ticker() {
        Super.ticker();
        
        Animated = true;    // Since we support smooth input, always run at full fps

        // Scroll with joystick
        // Kind of a silly option, since it will scroll back when you change items but it's for consistency
        let v = getGamepadRawLook();
        if(abs(v.y) > 0.1) {
            if(scrollView.mLayout.frame.size.y > scrollView.frame.size.y) {
                scrollView.scrollByPixels((v.y * CommonUI.STANDARD_SCROLL_AMOUNT), true, false, false);
            }
        }

        // If we are in the joystick menu, check to make sure the number of joysticks has not changed since the last check
        // and reload the joystick info if it has
        if(isGamepadMenu) {
            let numJoys = JoystickConfig.NumJoysticks();
            if(gamepadCount != numJoys) {
                gamepadCount = numJoys;
                reloadGamepads();
            }
        }

        if(requiresItemLayout > 0) {
            if(requiresItemLayout == 1) {
                for(int x = 0; x < optionViews.size(); x++) {
                    optionViews[x].updateValue();
                    optionViews[x].requiresLayout = true;
                }
                requiresItemLayout = 0;
            } else {
                requiresItemLayout--;
            }
        }

        if(requiresItemUpdate > 0) {
            if(requiresItemUpdate == 1) {
                for(int x = 0; x < optionViews.size(); x++) {
                    optionViews[x].updateValue();
                }
                requiresItemUpdate = 0;

                // Reset the mouse sensitivity ratio if it's on screen
                resetMouseSensRatio();
            } else {
                requiresItemUpdate--;
            }
        }

        if(requiresPresetLayout > 0) {
            if(requiresPresetLayout == 1) {
                for(int x = 0; x < presetViews.size(); x++) {
                    presetViews[x].updateValue();
                    presetViews[x].requiresLayout = true;
                }
                requiresPresetLayout = 0;
            } else {
                requiresPresetLayout--;
            }
        }
    }

    override void onFirstTick() {
        // Select previously selected sections
        LevelEventHandler levHandler = LevelEventHandler.Instance();
        if(levHandler && levHandler.settingsPos[0] > 0 && menuDescriptor) {
            int section = levHandler.settingsPos[0] - 1;
            int itemIndex = levHandler.settingsPos[1] - 1;
            UIButton sourceButton;

            for(int x = 0; x < sectionButts.size(); x++) {
                //sectionButts[x].setSelected(x == section);
                if(x == section) sourceButton = sectionButts[x];
            }

            Super.navigateTo(sourceButton);

            // Open the last selected panel
            if(!noMenuList && openedFromMouse && itemIndex >= 0 && section >= 0) {
                UIButton selBtn;
                for(int x = 0; x < sectionButts.size(); x++) {
                    sectionButts[x].setSelected(x == section);
                    if(x == section) selBtn = sectionButts[x];
                }

                Array<String> ar;
                selBtn.command.Split(ar, ":");

                if(ar.size() > 1) {
                    createOptionsGroup(ar[1], selBtn, dropScrollConfig);
                    lastSelectedSectionButt = selBtn;

                    navigateToLastSelectedItem(true);
                    transitionScreen(true, true);
                }
            }
        }
    }

    void navigateToLastSelectedItem(bool fromMouse) {
        LevelEventHandler levHandler = LevelEventHandler.Instance();
        if(levHandler && levHandler.settingsPos[1] > 0) {
            int selectedSection = -1;
            int itemIndex = levHandler.settingsPos[1] - 1;

            // Make sure we are in the last selected section
            for(int x = 0; x < sectionButts.size(); x++) {
                if(lastSelectedSectionButt == sectionButts[x]) {
                    selectedSection = x;
                    break;
                }
            }

            if(levHandler.settingsPos[0] - 1 == selectedSection) {
                // Find the control
                for(int x = itemIndex; x < optionViews.size(); x++) {
                    if(optionViews[x] is 'SOMOptionView') {
                        let som = SOMOptionView(optionViews[x]);

                        if(som.index == levHandler.settingsPos[1] - 1) {
                            // Layout the whole screen before we navigate, since we need to instantly scroll to the selected object
                            mainView.layout();
                            Super.navigateTo(optionViews[x]);
                            scrollView.scrollTo(som, false, 40);
                            configPreview(som);

                            return;
                        }
                    }
                }
            }
        }

        // Fallback, just navigate to the first option
        if(!fromMouse) {
            for(int x = 0; x < optionViews.size(); x++) {
                if(optionViews[x] is 'SOMOptionView') {
                    navigateTo(optionViews[x]);
                    return;
                }
            }
        }
    }

    override void drawSubviews() {
        /*double time = getTime();
        if(time - dimStart > 0) {
            double dim = MIN((time - dimStart) / dimTime, 1.0) * 0.7;
            Screen.dim(0xFF020202, dim, 0, 0, lastScreenSize.x, lastScreenSize.y);
        }*/
        double time = MSTime() / 1000.0;
        if(time - dimStart > 0) {
            Screen.dim(0xFF020202, MIN((time - dimStart) / 0.15, 1.0) * 0.75, 0, 0, Screen.GetWidth(), Screen.GetHeight());
        }

        Super.drawSubviews();
    }

    override bool onBack() {
        return false;    // Cancel back/close commands
    }

    void cleanClose() {
        dimStart = 9999999;   // Stop it from rendering

        // TODO: Add animation on close
        close();
        let m = GetCurrentMenu();
        MenuSound(m != null ? "menu/backup" : "menu/clear");
        if (!m) menuDelegate.MenuDismissed();
    }

    void configPreview(SOMOptionView opView = null) {
        if(smallWidth) {
            rightLay.hidden = true;
            return;
        }

        if(opView && opView.menuItem is "OptionMenuItemTooltipOption") {
            let tt = OptionMenuItemTooltipOption(opView.menuItem);
            
            int selection = tt.getSelection();
            string img, fart;
            [fart, img] = tt.getValueDescription();

            // Check to make sure the texture works, otherwise set the default texture
            if(img != "" && TexMan.checkForTexture(img, TexMan.Type_Any).isValid()) {
                previewImage.setImage(img);
            } else {
                previewImage.setImage(tt.mDefaultImage);
            }

            let valueTitleText = opView.menuItem.mLabel.filter();
            valueTitleText.replace("\t", "");
            valueTitleText = StringTable.Localize(valueTitleText);

            let tooltipText = tt.mTooltip.filter();
            tooltipText.replace("\t", "");
            tooltipText = StringTable.Localize(tooltipText);
            

            //valueTitleLabel.setText((previewImage.tex.texID.isValid() ? "\n" : "") .. valueTitleText);
            valueTitleLabel.setText("\n" .. valueTitleText);
            tooltipLabel.setText(tooltipText);

            // Get all the descriptions
            // Don't show descriptions if we are an alternate layout and an image is showing
            string description = "";
            if(tt.mValueDescriptions) {
                for(int x = 0; x < OptionValues.GetCount(tt.mValueDescriptions); x++) {
                    let valDesc = StringTable.Localize(OptionValues.GetText(tt.mValueDescriptions, x));
                    description = String.format("%s\n%s - %s\n", description.filter(),
                        x == selection ? "\c[OMNIBLUE]" .. StringTable.Localize(OptionValues.GetText(tt.mValues, x)) .. "\c-" : "\c[DARKGRAY]" .. StringTable.Localize(OptionValues.GetText(tt.mValues, x)) .. "\c-", 
                        valDesc.filter()
                    );
                }
            } else {
                description = "";//"\n\c[OMNIBLUE]" .. StringTable.Localize(OptionValues.GetText(tt.mValues, selection));
            }

            valueLabel.setText(description);

            rightLay.requiresLayout = true;
            rightLay.hidden = false;
            
        } else if(opView && opView.menuItem is 'OptionMenuItemTooltipSlider') { 
            let tt = OptionMenuItemTooltipSlider(opView.menuItem);

            previewImage.setImage(tt.mDefaultImage);

            let valueTitleText = opView.menuItem.mLabel.filter();
            valueTitleText.replace("\t", "");
            valueTitleText = StringTable.Localize(valueTitleText);

            let tooltipText = tt.mTooltip.filter();
            tooltipText.replace("\t", "");
            tooltipText = StringTable.Localize(tooltipText);
            
            valueTitleLabel.setText("\n" .. valueTitleText);
            tooltipLabel.setText(tooltipText);
            valueLabel.setText("");

            rightLay.requiresLayout = true;
            rightLay.hidden = false;
        } else if(opView && opView.menuItem is 'OptionMenuItemTooltipCommand') { 
            let tt = OptionMenuItemTooltipCommand(opView.menuItem);

            previewImage.setImage("");

            let valueTitleText = opView.menuItem.mLabel.filter();
            valueTitleText.replace("\t", "");
            valueTitleText = StringTable.Localize(valueTitleText);

            let tooltipText = tt.mTooltip.filter();
            tooltipText.replace("\t", "");
            tooltipText = StringTable.Localize(tooltipText);
            
            valueTitleLabel.setText("\n" .. valueTitleText);
            tooltipLabel.setText(tooltipText);
            valueLabel.setText("");

            rightLay.requiresLayout = true;
            rightLay.hidden = false;
        } else {
            rightLay.hidden = true;
        }

        //rightLay.requiresLayout = true;
    }


    void resetMouseSensRatio() {
        let xControl = findOptionView('m_sensitivity_x');
        let yControl = findOptionView('m_sensitivity_y');
        let xSlider = UISlider(xControl ? xControl.control : null);
        let ySlider = UISlider(yControl ? yControl.control : null);
        if(xSlider && ySlider) mouseSensMulti = ySlider.value - xSlider.value;
        else mouseSensMulti = 0.0;
    }


    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(mkey == MKEY_MBYes) {
            ResetControlsPrompt pm = ResetControlsPrompt(Menu.GetCurrentMenu());
            if(pm) {
                // Reset controls now!
                SelacoOptionActivator.RunCCMD('resetb2defaults');

                // Everything changed, relayout everything
                requiresItemUpdate = 2;
                requiresItemLayout = 2;
                return true;
            }
        }

        if(mkey > MKEY_MBYes) {
            int res = mkey - MKEY_MBYes;

            // Which prompt menu was this?
            PromptMenu pm = PromptMenu(Menu.GetCurrentMenu());
            if(pm) {
                if(pm.usrString ~== "RESET_DEFAULT") {
                    if(res == 1) {
                        // Find each item and reset to default when possible
                        for(int x = 0; x < optionViews.size(); x++) {
                            let ov = optionViews[x];
                            let cv = Cvar.FindCVar(ov.menuItem.getAction());
                            OptionMenuItem it = ov.menuItem;

                            if(cv) {
                                if(developer) Console.Printf("Reset: %s", ov.menuItem.getAction());
                                cv.ResetToDefault();
                            }

                            // If this is a custom color picker, we are going to assume the default value is NOT custom
                            // Because I can't be arsed to do this in another tick or after layout when everything is resolved
                            if(it is 'OptionMenuItemColorPicker' && SOMOptionView(ov.navUp) && SOMOptionView(ov.navUp).menuItem is 'OptionMenuItemColorPickerDD') {
                                // Check value to see if we should hide the custom color picker
                                ov.hidden = true;
                                ov.setDisabled(true);
                            }
                        }

                        // Everything changed, relayout everything
                        requiresItemUpdate = 2;
                        requiresItemLayout = 2;
                    }
                } else if(pm.usrString ~== "RESET_ALTFIRES1") {
                    let m = new("PromptMenu").initNew(self, "$MENU_TITLE_RESETALTFIRES", "$MENU_TEXT_RESETALTFIRES2", "$CANCEL_BUTTON", "$RESET_BUTTON", destructiveIndex: 1, defaultSelection: 0);
                    m.usrString = "RESET_ALTFIRES2";
                    m.allowBack = true;
                    m.ActivateMenu();
                } else if(pm.usrString ~== "RESET_ALTFIRES2") {
                    EventHandler.SendNetworkEvent("resetaltfires", 1);
                    let m = new("PromptMenu").initNew(self, "$MENU_TITLE_RESETALTFIRES", "$MENU_TEXT_RESETALTFIRES3", "$OK_BUTTON", defaultSelection: 0);
                    m.usrString = "RESET_ALTFIRES2";
                    m.allowBack = false;
                    m.ActivateMenu();
                } else if(pm.usrString ~== "CONFIRM_BIND") {
                    if(res == 1) {
                        // Bind key
                        if(lastBindings) {
                            lastBindings.SetBind(lastKeybindKey, lastKeybind);
                        }

                        // Everything changed, relayout everything
                        requiresItemUpdate = 2;
                        requiresItemLayout = 2;
                    }
                }
            }

            return true;
        }

        switch (mkey) {
            case MKEY_Left:
            case MKEY_Right:
            case MKEY_Down:
                if(!activeControl && firstControl) {
                    if(navigateTo(firstControl)) return true;
                } else if(!activeControl && sectionButts.size() > 0) {
                    if(navigateTo(sectionButts[0])) return true;
                }
                break;
            case MKEY_Up:
                if(!activeControl && lastControl) {
                    if(navigateTo(lastControl)) return true;
                } else if(!activeControl && sectionButts.size() > 0) {
                    if(navigateTo(sectionButts[sectionButts.size() - 1])) return true;
                }
                break;
            case MKEY_Back:
                // Close current options if they are open
                if(activeControl && activeControl.menuEvent(mkey, fromcontroller)) {
                    return true;
                }

                if(optionsDescriptor != null) {
                    closeOptions();
                    MenuSound("menu/backup");
                    didReverse(fromcontroller);

                    return true;
                }

                didReverse(fromcontroller);
                cleanClose();
                return true;
            case MKEY_Input:
                if(Menu.GetCurrentMenu() is 'CustomPromptPopup') {
                    let v = CustomPromptPopup(Menu.GetCurrentMenu()).sourceControl;
                    if(v is 'SOMOptionView') {
                        SOMOptionView(v).customMenuReturned(CustomPromptPopup(Menu.GetCurrentMenu()));
                    }
                } else {
                    // This is possibly a keybind return message
                    // Update all keybind values in all options
                    for(int x = 0; x < optionViews.size(); x++) {
                        optionViews[x].setKeybindTitle();
                    }
                }

                return true;
                break;
            case MKEY_Clear:
                // Forward this keypress to the active control
                if(activeControl && activeControl is "SOMOptionView") {
                    let ov = SOMOptionView(activeControl);
                    if(ov.onClear()) { didActivate(ov, fromcontroller); return true; }
                } else if(activeControl && activeControl.parent is "SOMOptionView") {
                    let ov = SOMOptionView(activeControl.parent);
                    if(ov.onClear()) { didActivate(ov, fromcontroller); return true; }
                } else if(mHoverView is "SOMOptionView") {
                    let ov = SOMOptionView(mHoverView);
                    if(ov.onClear()) { didActivate(ov, fromcontroller); return true; }
                } else if(mHoverView && mHoverView.parent is "SOMOptionView") {
                    let ov = SOMOptionView(mHoverView.parent);
                    if(ov.onClear()) { didActivate(ov, fromcontroller); return true; }
                }

                break;
            default:
                break;
        }

		return Super.MenuEvent(mkey, fromcontroller);
	}

    override bool navigateTo(UIControl con, bool mouseSelection) {
		let ac = activeControl;
        let cc = Super.navigateTo(con, mouseSelection);
        if(cc) {
            if(!mouseSelection && con.parent == midLay) {
                scrollView.scrollTo(con, true, 40);
            }

            if(con is "SOMOptionView") {
                SOMOptionView som = SOMOptionView(con);
                configPreview(som);

                LevelEventHandler ev = LevelEventHandler.Instance();
                if(ev) ev.settingsPos[1] = som.index + 1;
            }

            if(ac != activeControl && con.command.indexOf("section:") >= 0 && !mouseSelection && ticks > 1) {
                MenuSound("menu/cursor");
            }
                
            return true;
        }

        return false;
	}

    override void layoutChange(int screenWidth, int screenHeight) {
        calcScale(screenWidth, screenHeight);
        layout();
        configPreview(SOMOptionView(activeControl));
        mainView.layout();

        transitionScreen(!!optionsDescriptor, false);
        
        hasLayedOutOnce = true;
    }

    override bool OnInputEvent(InputEvent ev) { 
		if(ev.type == InputEvent.Type_DeviceChange && isGamepadMenu) {
            reloadGamepads();
            Console.Printf("Reloading gamepads");
        }

        return Super.OnInputEvent(ev);
	}
}



class OptionsVerticalScroll : UIVerticalScroll {
    override void layout(Vector2 parentScale, double parentAlpha) {
        //let m = getMenu();
        //Console.Printf("Options scroll layout! %d", m ? m.ticks : -1);
        Super.layout(parentScale, parentAlpha);
    }
}
