#include "ZScripts/UI/options_menu/som_checkbox.zs"
#include "ZScripts/UI/options_menu/som_choice_view.zs"
#include "ZScripts/UI/options_menu/reset_controls_prompt.zs"

class SOMOptionView : UIControl {
    enum OptionType {
        Option_Unknown = 0,
        Option_Toggle,              // Multichoice, but only two options, either yes/no or on/off
        Option_Toggle_Inverse,      // Off is 1
        Option_MultiChoice,         // Use a dropdown, or cycle with arrow keys/gamepad
        Option_MultiChoice_Bar,     // Use a button bar to present all options
        Option_Slider,              // Linear number slider
        Option_TextInput,           // Type a value in here
        Option_NumberInput,         // Type only numbers in here
        Option_Color,               // Select a color, *(TODO: make a special color selector)
        Option_Keybind,             // Standard button but lets you enter a keybind key
        Option_Command,             // Runs a CCMD when pressed. No control required, render centered probably
        Option_Link                 // Opens another menu
    }

    UILabel label, valueLabel;
    UIControl control;
    UIImage bgImage;
    UIPin cLeftpin;
    OptionMenuItem menuItem;
    OptionType type;
    NineSlice bgSlice, bgSlice2;
    UIScrollBarConfig scrollbarConfig;
    CVar requireCVar, requireNoneCVar;

    int indent, index;

    const padUPDOWN = 16;
    const divide = 0.60;
    const midOffset = -14;

    const SEL_COLOR = 0xFFB0C6F7;
    const NORM_COLOR = 0xFFFFFFFF;
    const DISABLE_COLOR = 0xFF999999;


    // If something has changed, make sure our value reflects the change
    void updateValue() {
        switch(type) {
            case Option_MultiChoice: {
                    OptionMenuItemOption o = OptionMenuItemOption(menuItem);
                    if(menuItem is "OptionMenuItemTooltipOption") { OptionMenuItemTooltipOption(o).findSelection(); }
                    int selectedItem = o.getSelection();
                    UIDropdown(control).setSelectedItem(selectedItem);
                }
                break;
            case Option_MultiChoice_Bar: {
                    OptionMenuItemOption o = OptionMenuItemOption(menuItem);    // No check here, I want a crash if this type is incorrect
                    if(menuItem is "OptionMenuItemTooltipOption") { OptionMenuItemTooltipOption(o).findSelection(); }
                    int selectedItem = o.GetSelection();
                    UIButtonBar(control).setSelectedItem(selectedItem);
                }
                break;
            case Option_Toggle: {
                    OptionMenuItemOption o = OptionMenuItemOption(menuItem);
                    if(menuItem is "OptionMenuItemTooltipOption") { OptionMenuItemTooltipOption(o).findSelection(); }
                    SOMCheckbox(control).setSelected(o.GetSelection() == 1);
                }
                break;
            case Option_Toggle_Inverse: {
                    OptionMenuItemOption o = OptionMenuItemOption(menuItem);
                    if(menuItem is "OptionMenuItemTooltipOption") { OptionMenuItemTooltipOption(o).findSelection(); }
                    SOMCheckbox(control).setSelected(o.GetSelection() == 0);
                }
                break;
            case Option_Slider: {
                    OptionMenuItemSlider o = OptionMenuItemSlider(menuItem);
                    let val = o.GetSliderValue();
                    let slide = UISlider(control);
                    slide.setValue(val, moveButt: true);

                    updateSliderValDisplay();
                }
                break;
            case Option_Keybind:
                setKeybindTitle();  // Hopefully keybinds take immediately otherwise we might be screwed
                break;
            case Option_Color: {
                OptionMenuItemColorPicker o = OptionMenuItemColorPicker(menuItem);
                let cview = SOMColorSliders(control);
                Color col = o.mCVar ? o.mCVar.GetInt() : 0;
                col = Color(255, col.r, col.g, col.b);
                cview.colorValue = col;
                cview.refreshValues();
            }
            default:
                break;
        }

        if(requireCVar) {
            setDisabled(requireCVar.GetInt() <= 0);
        }

        if(requireNoneCVar) {
            setDisabled(requireNoneCVar.GetInt() > 0);
        }
    }

    void updateSliderValDisplay() {
        OptionMenuItemSlider o = OptionMenuItemSlider(menuItem);
        let slide = UISlider(control);
        let value = slide.value;
        let showValue = o.mShowValue;

        // This is 100% BS but people really don't like the values of Y sens being so far off from X sens
        // So I'm going to FAKE the values. God help those that use the console because this will be horribly confusing
        if(!Engine.FourPointNine() && menuItem.getAction() == 'm_sensitivity_y') {
            value *= 2;
        }

        String valText;
        if(showValue == -1) {
            valText = string.Format("%.2f", clamp(slide.getNormalizedValue(), 0.00001, 1.0));
        } else {
            String formatter = String.format("%%.%df", showValue);
            valText = string.Format(formatter, value);
        }
        
        valueLabel.setText(valText);
    }


    SOMOptionView init(String nam, OptionMenuItem item, UIScrollBarConfig scrollConfig, bool noBackground = false) {
        Super.Init((0,0), (100, 40));

        menuItem = item;
        self.scrollbarConfig = scrollConfig;
        
        // calc indent
        while(nam.byteAt(indent) == 9) { indent++; }

        nam.replace("\t", "");
        nam = StringTable.Localize(nam);
        //layoutWithChildren = true;

        minSize = (100, 38);

        type = Option_Unknown;
        clipsSubviews = false;
        //rejectHoverSelection = true;

        // Determine option type from the item class
        if(menuItem is 'OptionMenuItemTextField') {
            type = Option_TextInput;
        } else if(menuItem is 'OptionMenuItemNumberField') {
            type = Option_NumberInput;
        } else if(menuItem is 'OptionMenuItemCommand') {
            type = Option_Command;
        } else if(menuItem is 'OptionMenuItemColorPicker') {
            type = Option_Color;
        } else if(menuItem is 'OptionMenuItemSlider') {
            type = Option_Slider;
        } else if(menuItem is 'OptionMenuItemControlBase') {
            type = Option_Keybind;
        } else if(menuItem is 'OptionMenuItemTooltipOptionBar') {
            type = Option_MultiChoice_Bar;
        } else if(menuItem is 'OptionMenuItemMenuLink') {
            type = Option_Link;
        } else if(menuItem is 'OptionMenuItemTooltipPreset') {
            type = Option_MultiChoice;
        } else if(menuItem is 'OptionMenuItemOptionBase') {
            // Check options to see if this is a yes/no sceneario
            OptionMenuItemOption o = OptionMenuItemOption(menuItem);
            type = Option_MultiChoice;
        }

        double leftPos = indent * 30;

        //backgroundColor = 0x33888888;
        if(!noBackground) {
            bgSlice2 = NineSlice.Create("graphics/options_menu/op_bg2.png", (11,11), (19,19));
            bgSlice = NineSlice.Create("graphics/options_menu/op_bg.png", (11,11), (19,19));

            bgImage = new("UIImage").init((0,0), (100, 100), "", bgSlice2);
            bgImage.pinToParent();
            bgImage.firstPin(UIPin.Pin_Left).offset = leftPos;
            bgImage.raycastTarget = false;
            //bgImage.hidden = true;
            add(bgImage);
        }
       

        // Create label
        label = new("UILabel").init((40,0), (0, 50), " ", "PDA18FONT", textColor: NORM_COLOR, textAlign: UIView.Align_Left | Align_Middle);
        label.heightPin = UIPin.Create(0,0,UIView.Size_Min);
        label.pin(UIPin.Pin_Right, value: divide, midOffset, true);
        label.pin(UIPin.Pin_Left, offset: 15 + leftPos);
        label.pin(UIPin.Pin_Top, value: padUPDOWN * 0.5);
        label.pin(UIPin.Pin_Bottom, value: padUPDOWN * 0.5);
        //label.backgroundColor = 0xFF0000FF;
        label.multiline = true;
        add(label);

        OptionMenuItemTooltipOption toolOp = OptionMenuItemTooltipOption(menuItem);
        if(toolOp) {
            toolOp.mSelection = -1; // Invalidate cached selection
        }

        // Create control based on type of menu item
        switch(type) {
            case Option_MultiChoice: 
                {
                    OptionMenuItemOption o = OptionMenuItemOption(menuItem);    // No check here, I want a crash if this type is incorrect
                    Array<string> items;
                    bool isPreset = menuItem is "OptionMenuItemTooltipPreset";
                    int cnt = o.numItems();
                    int selectedItem = isPreset ? OptionMenuItemTooltipPreset(menuItem).findSelection() : o.GetSelection();
                    
                    // Get names for dropdown
                    for(int x = 0; x < cnt; x++) {
                        items.push(o.getItem(x));
                    }

                    string noneText = StringTable.Localize("$SETTING_CUSTOM");
                    if(isPreset) {
                        let opi = OptionMenuItemTooltipPreset(menuItem);
                        noneText = opi.mOffItem >= 0 ? o.getItem(opi.mOffItem) : "CUSTOM";
                    }

                    let dd = new("SOMChoiceView").init(items, selectedItem, scrollbarConfig, noneText, self);
                    dd.pin(UIPin.Pin_Left, UIPin.Pin_Right, divide, 0, true);
                    dd.pin(UIPin.Pin_Right, offset: -15);
                    dd.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
                    dd.pinHeight(UIView.Size_Min);
                    dd.navUp = navUp;
                    dd.navDown = navDown;
                    add(dd);
                    control = dd;

                    if(menuItem is 'OptionMenuItemResolutionOption' || menuItem.getAction() == 'vid_maxfps' || menuItem.getAction() == 'vk_device') {
                        dd.allowDuplicateSelection = true;
                    }
                }
                break;
            case Option_MultiChoice_Bar:
                {
                    OptionMenuItemOption o = OptionMenuItemOption(menuItem);    // No check here, I want a crash if this type is incorrect
                    Array<string> items;
                    int cnt = o.numItems();
                    int selectedItem = o.GetSelection();
                    
                    // Get names for button bar
                    for(int x = 0; x < cnt; x++) {
                        items.push(o.getItem(x));
                    }

                    let bb = new("UIButtonBar").init((0,0), (100, 30), items, "PDA16FONT",
                        NineSlice.Create("graphics/options_menu/op_bbar.png", (8,8), (14, 14)),
                        null,
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
                        UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13))
                    );
                    bb.pin(UIPin.Pin_Left, UIPin.Pin_Right, divide, 0, true);
                    bb.pin(UIPin.Pin_Right, offset: -15);
                    bb.pin(UIPin.Pin_VCenter, value: 1);
                    bb.spacing = 2;
                    bb.minSize.x = 85;
                    bb.minSize.y = 30;
                    bb.navUp = navUp;
                    bb.navDown = navDown;
                    bb.setSelectedItem(selectedItem);
                    add(bb);
                    control = bb;

                    for(int x = 0; x < bb.itemButts.size(); x++) {
                        bb.itemButts[x].rejectHoverSelection = true;
                        bb.itemButts[x].forwardSelection = self;
                    }
                }
                break;
            case Option_Toggle_Inverse:
            case Option_Toggle:
                {
                    OptionMenuItemOption o = OptionMenuItemOption(menuItem);
                    
                    bool isOn = type == Option_Toggle ? (o.GetSelection() == 1) : (o.GetSelection() == 0);
                    let toggle = new("SOMCheckbox").init((0,0), (30,30), isOn);
                    toggle.pin(UIPin.Pin_Left, UIPin.Pin_Right, divide, 0, true);
                    toggle.pin(UIPin.Pin_VCenter, value: 1);
                    toggle.navUp = navUp;
                    toggle.navDown = navDown;
                    toggle.minSize = (30,30);
                    add(toggle);
                    control = toggle;
                }
                break;
            case Option_Slider:
                {
                    OptionMenuItemSlider o = OptionMenuItemSlider(menuItem);

                    let slider = new("UISlider").init((0,0), (100, 30), o.mMin, o.mMax, o.mStep, 
                        NineSlice.Create("graphics/options_menu/slider_bg.png", (7, 14), (24, 16)),
                        NineSlice.Create("graphics/options_menu/slider_bg_full.png", (7, 14), (24, 16)),
                        UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down.png", (8,8), (13,13))
                    );

                    slider.setValue(o.GetSliderValue());
                    slider.pin(UIPin.Pin_Left, UIPin.Pin_Right, divide, 0, true);
                    slider.pin(UIPin.Pin_Right, offset: -95);
                    slider.pin(UIPin.Pin_VCenter, value: 1);
                    slider.minSize.y = 30;
                    slider.navUp = navUp;
                    slider.navDown = navDown;
                    slider.rejectHoverSelection = true;
                    slider.slideButt.rejectHoverSelection = true;
                    control = slider;
                    add(slider);

                    //if(o.mShowValue) {
                        valueLabel = new("UILabel").init((0,0), (70, 30), "0.00", "PDA13FONT", 0xFFDDDDDD, UILabel.Align_Left | UILabel.Align_Middle);
                        valueLabel.pin(UIPin.Pin_Right, offset: -15);
                        valueLabel.pin(UIPin.Pin_Top);
                        valueLabel.pin(UIPin.Pin_Bottom);

                        updateSliderValDisplay();
                        add(valueLabel);
                    //}
                }
                break;
            case Option_Keybind:
                {
                    OptionMenuItemControlBase o = OptionMenuItemControlBase(menuItem);
                    
                    let btn = new("UIButton").init((0,0), (100, 30), "< EMPTY >", "PDA16FONT",
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: Font.CR_UNTRANSLATED),
                        UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
                        UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13))
                    );
                    btn.pin(UIPin.Pin_Left, UIPin.Pin_Right, divide, 0, true);
                    btn.pin(UIPin.Pin_Right, offset: -15);
                    btn.pin(UIPin.Pin_VCenter, value: 1);
                    btn.pinHeight(UIView.Size_Min);
                    btn.setTextPadding(8,4,8,4);
                    btn.label.multiline = true;
                    btn.navUp = navUp;
                    btn.navDown = navDown;
                    btn.rejectHoverSelection = true;
                    btn.minSize = (120, 34);
                    
                    control = btn;

                    setKeybindTitle();

                    add(btn);
                }
                break;
            case Option_Command:
                {
                    OptionMenuItemCommand o = OptionMenuItemCommand(menuItem);
                    
                    let btn = new("UIButton").init((0,0), (100, 30), "Activate", "PDA16FONT",
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFFFFFFFF),
                        UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
                        UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13))
                    );
                    btn.pin(UIPin.Pin_Left, UIPin.Pin_Right, divide, 0, true);
                    btn.pin(UIPin.Pin_Right, offset: -15);
                    btn.pin(UIPin.Pin_VCenter, value: 1);
                    btn.pinHeight(UIView.Size_Min);
                    btn.setTextPadding(8,4,8,4);
                    btn.label.multiline = true;
                    btn.navUp = navUp;
                    btn.navDown = navDown;
                    btn.rejectHoverSelection = true;
                    btn.minSize = (120, 30);
                    
                    control = btn;
                    add(btn);
                }
                break;
            case Option_Link:
                {
                    OptionMenuItemMenuLink o = OptionMenuItemMenuLink(menuItem);
                    
                    let btn = new("UIButton").init((0,0), (100, 30), "Open", "PDA16FONT",
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFFFFFFFF),
                        UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_norm.png", (9,9), (13,13), sound: "ui/cursor2", soundVolume: 0.45),
                        UIButtonState.CreateSlices("graphics/options_menu/op_dropdown_down.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt.png", (8,8), (14, 14), textColor: 0xFF999999),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13)),
                        UIButtonState.CreateSlices("graphics/options_menu/op_butt_select.png", (9,9), (13,13))
                    );
                    btn.pin(UIPin.Pin_Left, UIPin.Pin_Right, divide, 0, true);
                    btn.pin(UIPin.Pin_Right, offset: -15);
                    btn.pin(UIPin.Pin_VCenter, value: 1);
                    btn.pinHeight(UIView.Size_Min);
                    btn.setTextPadding(8,4,8,4);
                    btn.label.multiline = false;
                    btn.navUp = navUp;
                    btn.navDown = navDown;
                    btn.rejectHoverSelection = true;
                    btn.minSize = (120, 30);
                    
                    control = btn;
                    add(btn);
                }
                break;
            case Option_Color:
                {
                    // Using RGB sliders because they are easier to interact with on Gamepad
                    OptionMenuItemColorPicker o = OptionMenuItemColorPicker(menuItem);
                    Color col = o.mCVar ? o.mCVar.getInt() : 0xFFFFFFFF;
                    let ctrl = new("SOMColorSliders").init(col);
                    ctrl.pin(UIPin.Pin_Left, UIPin.Pin_Right, divide, 0, true);
                    ctrl.pin(UIPin.Pin_Right, offset: -15);
                    ctrl.pin(UIPin.Pin_Top, offset: 7);
                    ctrl.navUp = navUp;
                    ctrl.navDown = navDown;
                    //ctrl.resetButton.navUp = navUp;
                    ctrl.sliders[0].navUp = navUp;
                    ctrl.sliders[2].navDown = navDown;
                    ctrl.rejectHoverSelection = true;
                    ctrl.forwardSelection = self;
                    label.textAlign = Align_TopLeft;
                    label.firstPin(UIPin.Pin_Top).offset = 7;
                    control = ctrl;
                    
                    add(ctrl);
                }
                break;
            default:
                break;
        }

        if(control) {
            control.rejectHoverSelection = true;
            control.forwardSelection = self;

            // Set disabled
            if(menuItem is 'ListMenuItemSelectable' && ListMenuItemSelectable(menuItem).mParam & 128) {
                control.setDisabled(true);
            }
        }

        requiresLayout = true;
        label.text = nam;

        return self;
    }

    override void setDisabled(bool disable) {
        Super.setDisabled(disable);

        if(!(menuItem is 'ListMenuItemSelectable' && ListMenuItemSelectable(menuItem).mParam & 128)) {
            control.setDisabled(disable);
        }
        
        if(disable) {
            if(label) label.textColor = DISABLE_COLOR;
            if(valueLabel) valueLabel.textColor = DISABLE_COLOR;
        } else {
            if(label) label.textColor = NORM_COLOR;
            if(valueLabel) valueLabel.textColor = NORM_COLOR;
        }

        let slider = UISlider(control);
        if(slider) {
            slider.slideImage.setAlpha(disable ? 0.35 : 1.0);
        }
    }

    void setKeybindTitle() {
        if(type == Option_Keybind) {
            Array<int> keys;
            let o = OptionMenuItemControlBase(menuItem);
            let btn = UIButton(control);
            if(!(btn && o && o.mBindings)) { Console.Printf("Options menu: A keybind option was missing data [%s]", StringTable.Localize(menuItem.mLabel)); return; }
            o.mBindings.GetAllKeysForCommand(keys, o.GetAction());
            btn.label.setText(UIHelper.NamesForKeys(keys));
        }
    }

    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        if(ctrl == control && event == UIHandler.Event_Activated) {
            return handleActivate(fromMouse, fromController);
        } else if(ctrl == control && event == UIHandler.Event_ValueChanged) {
            return handleValueChange(fromMouse, fromController);
        }

        return Super.handleSubControl(ctrl, event, fromMouse, fromController);
    }

    override bool onActivate(bool mouseSelection, bool fromController) {
        return handleActivate(mouseSelection, fromController);
    }

    bool handleActivate(bool mouse, bool controller) {
        if(control is "SOMCheckbox") {
            // Handle toggle
            let check = SOMCheckbox(control);
            check.setSelected(!check.selected);

            // save value
            if(type == Option_Toggle_Inverse) {
                OptionMenuItemOption(menuItem).setSelection(check.selected ? 0 : 1);
            } else {
                OptionMenuItemOption(menuItem).setSelection(check.selected ? 1 : 0);
            }
            

            playSound("ui/choose2");

            sendEvent(UIHandler.Event_ValueChanged, mouse, controller);
            return true;
        } else if(control is "UIButton" && type == Option_Keybind) {
            // Create a listener for the key
            UIButton(control).setSelected();
            Menu.MenuSound("ui/choose2");
            let input = new("SelacoEnterKey");
            input.Init(Menu.GetCurrentMenu(), OptionMenuItemControlBase(menuItem), self, controller);
            input.ActivateMenu();
            return true;
        } else if(type == Option_Command) {
            Menu.MenuSound("ui/choose2");

            if(menuItem is "OptionMenuItemTooltipCommand") {
                let mi = OptionMenuItemTooltipCommand(menuItem);

                // If this has a function instead of a command, it means the menus are to handle
                // the function with the ValueChanged event, instead of just running a CCMD
                if(mi.mFunc == "") {
                    SelacoOptionActivator.RunCCMDI(OptionMenuItemCommand(menuItem));
                    //SelacoOptionActivator.RunCCMD("menu_resolution_commit_changes", "Commit Resolution Change");    // Why is this here again? I forget
                } else {
                    mi.Activate();

                    if(mi.mFunc == "defaults") {
                        // Reset all items on this page to their defaults after a prompt
                        let m = new("PromptMenu").initNew(getMenu(), "$MENU_TITLE_RESETDEFAULTS", "$MENU_TEXT_RESETDEFAULTS", "$CANCEL_BUTTON", "$OK_BUTTON", defaultSelection: 0);
                        m.usrString = "RESET_DEFAULT";
                        m.allowBack = true;
                        m.ActivateMenu();
                        return true;
                    } else if(mi.mFunc == "resetaltfires") {
                        // Reset altfire progress!
                        let m = new("PromptMenu").initNew(getMenu(), "$MENU_TITLE_RESETALTFIRES", "$MENU_TEXT_RESETALTFIRES", "$CANCEL_BUTTON", "$RESET_BUTTON", destructiveIndex: 1, defaultSelection: 0);
                        m.usrString = "RESET_ALTFIRES1";
                        m.allowBack = true;
                        m.ActivateMenu();
                        return true;
                    } else if(mi.mFunc == "setSteamDeck") {
                        UIHelper.SetSteamdeckPresets();
                        self.command = "reset"; // Signals reset to menu
                        sendEvent(UIHandler.Event_ValueChanged, mouse, controller);
                        return true;
                    } else if(mi.mFunc == "resetControls") {
                        let prompt = new("ResetControlsPrompt");
                        prompt.init(getMenu());
                        prompt.ActivateMenu();
                        return true;
                    } else if(mi.mFunc == "resetTutorials") {
                        EventHandler.SendNetworkEvent("resetTutorials", 1);
                        let m = new("PromptMenu").initNew(getMenu(), "$MENU_TITLE_RESET_TUTORIALS", "$MENU_TEXT_RESET_TUTORIALS", "$OK_BUTTON", defaultSelection: 0);
                        m.usrString = "RESET_TUTORIALS";
                        m.allowBack = true;
                        m.ActivateMenu();
                        return true;
                    }
                }
            } else {
                SelacoOptionActivator.RunCCMDI(OptionMenuItemCommand(menuItem));
                //SelacoOptionActivator.RunCCMD("menu_resolution_commit_changes", "Commit Resolution Change");    // Why is this here again? I forget
            }
            
            sendEvent(UIHandler.Event_ValueChanged, mouse, controller);
            let m = getMenu();
            if(m) {
                m.MenuEvent(Menu.MKEY_Input, 0);
            }
            return true;
        } else if(control is "UIDropdown") {
            let dd = UIDropdown(control);
            if(mouse || menuItem is 'OptionMenuItemResolutionOption' || menuItem.getAction() == 'vid_maxfps') {
                if(!dd.wasOpenBeforeClick) {
                    Menu.MenuSound("ui/choose2");
                    dd.open(true);
                }
            } else {
                dd.cycleNext();
                OptionMenuItemOption(menuItem).setSelection(dd.getSelectedItem());
                sendEvent(UIHandler.Event_ValueChanged, mouse, controller);
                Menu.MenuSound("ui/choose2");
            }
        } else if(type == Option_Link) {
            OptionMenuItemMenuLink o = OptionMenuItemMenuLink(menuItem);
            
            if(o.mMenu == 'CustomizeControlsSelaco') {
                SelacoOptionMenu(getMenu()).changeSectionName("CustomizeControlsSelaco", mouse);
            } else {
                Menu.SetMenu(o.mMenu);
            }
        } else if(type == Option_Slider) {
            return Super.onActivate(mouse, controller);
        } else if(type == Option_Color) {
            SOMColorSliders sld = SOMColorSliders(control);
            let m = getMenu();
            if(m && sld) {
                playSound("ui/choose2");
                //sld.resetButton.navUp = navUp;
                sld.sliders[0].navUp = navUp;
                sld.sliders[2].navDown = navDown;
                m.navigateTo(sld.sliders[0]);
            }
            return true;
        }

        return false;
    }

    void returnFromKeybind() {
        if(control is "UIButton" && type == Option_Keybind) {
            let o = OptionMenuItemControlBase(menuItem);

            // Check if it's delete or backspace
            /*if(o.mInput == 211) {
                // Delete the bind instead of binding
                o.mBindings.UnbindACommand(o.getAction());
            } else*/ if(o.mInput != InputEvent.KEY_ESCAPE) {
                // Check first to see if this binding will unbind an existing command
                string act = o.getAction();
                act = act.makeLower();
                bool isAutomap = act.IndexOf("am_") == 0 || act.IndexOf("+am_") == 0 || act.indexOf("-am_") == 0;
                
                String bind = isAutomap ? AutomapBindings.GetBinding(o.mInput) : Bindings.GetBinding(o.mInput);
                
                if(bind != "" && bind != o.getAction()) {
                    // prompt user to overwrite
                    Array<int> keys;
                    keys.push(o.mInput);
                    string keyName = UIHelper.NamesForKeysColor(keys, colorCode: "f", usingGamepad: true);
                    string actionName = UIHelper.NameForKeybind(bind);
                    string desc = String.Format("The action \cf%s\c- is already bound to %s\c-.\n\nDo you want to overwrite this binding?", actionName, keyName);
                    let m = new("PromptMenu").initNew(getMenu(), "Overwrite Binding", desc, "$CANCEL_BUTTON", "$OK_BUTTON", defaultSelection: 1);
                    m.usrString = "CONFIRM_BIND";
                    m.allowBack = true;
                    

                    let opMenu = SelacoOptionMenu(getMenu());
                    if(opMenu) {
                        opMenu.lastKeybind = o.getAction();
                        opMenu.lastKeybindKey = o.mInput;
                        opMenu.lastBindings = o.mBindings;
                    }

                    m.ActivateMenu();
                } else {
                    o.mBindings.SetBind(o.mInput, o.getAction());
                }
            }

            UIButton(control).setSelected(false);
            setKeybindTitle();

            // TODO: Store somewhere that this was caused by a controller or not
            sendEvent(UIHandler.Event_ValueChanged, false);

            checkControlHeightChange();
        }
    }

    bool handleValueChange(bool mouse = true, bool controller = false, bool notify = true, bool sound = true) {
        if(control is "UISlider") {
            UISlider slider = UISlider(control);

            // save value
            OptionMenuItemSlider(menuItem).SetSliderValue(slider.value);

            // Change value text
            if(valueLabel) {
                updateSliderValDisplay();
            }

            if(notify) sendEvent(UIHandler.Event_ValueChanged, mouse, controller);
            return true;
        } else if(control is "UIDropdown") {
            let op = OptionMenuItemOption(menuItem);
            let dd = UIDropdown(control);

            if(menuItem.getAction() != 'vid_maxfps' || dd.getSelectedItem() != 0) {
                op.setSelection(dd.getSelectedItem());
            }

            // If this is a resolution dropdown, pop up the dialog
            if(menuItem is 'OptionMenuItemResolutionOption' && dd.getSelectedItem() == 0) {
                // Pop up custom resolution menu
                int rX = Screen.GetWidth(), ry = Screen.GetHeight();
                if(rX * rY < Screen.GetWindowWidth() * Screen.GetWindowHeight()) {
                    rX = Screen.GetWindowWidth();
                    rY = Screen.GetWindowHeight();
                }

                ResolutionPrompt.present("$TITLE_RESOLUTION_CUSTOM", "$DESCRIPTION_RESOLUTION_CUSTOM", rX, rY, self, fromController: controller); 
            } else if(menuItem.getAction() == 'vid_maxfps' && dd.getSelectedItem() == 0) {
                // Custom pop up for Max FPS
                let cv = CVar.GetCVar("vid_maxfps");
                MaxFPSPrompt.present("$TITLE_FPS_CUSTOM", "$DESCRIPTION_FPS_CUSTOM", cv ? cv.getInt() : 0, self, fromController: controller); 
            }
            
            // If changing this option brought up a dialog window, set the source to the active control
            else if(Menu.GetCurrentMenu() is 'CustomPromptPopup') {
                CustomPromptPopup(Menu.GetCurrentMenu()).sourceControl = self;
            }

            // setSelection may have changed the index, so make sure the dropdown matches
            int sel = op.getSelection();
            if(sel != dd.getSelectedItem() && sel >= 0) {
                UIDropdown(control).setSelectedItem(sel);
            }

            if(sound) playSound("ui/choose2");
            if(notify) sendEvent(UIHandler.Event_ValueChanged, mouse, controller);

            checkControlHeightChange();

            return true;
        } else if(control is "UIButtonBar") {
            OptionMenuItemOption(menuItem).setSelection(UIButtonBar(control).getSelectedItem());

            if(sound) playSound("ui/choose2");
            if(notify) sendEvent(UIHandler.Event_ValueChanged, mouse, controller);
            return true;
        } else if(control is "SOMColorSliders") {
            SOMColorSliders slider = SOMColorSliders(control);
            OptionMenuItemColorPicker(menuItem).mCVar.setInt(slider.colorValue);
            if(notify) sendEvent(UIHandler.Event_ValueChanged, mouse, controller);
            return true;
        }

        return false;
    }


    void checkControlHeightChange() {
        if(!control || !control.heightPin || control.heightPin.value != UIView.Size_Min) return;
        
        let ms = control.calcMinSize((frame.size.x, 999999));
        if(ms.y != control.frame.size.y) {
            requiresLayout = true;
        }
    }


    override void onRemoved(UIView oldSuperview) {
        if(control is "UIDropdown") {
            UIDropdown(control).close();
        }
    }

    override Vector2 calcMinSize(Vector2 parentSize) {
        //double w = parentSize.x * divide + midOffset;
        double pinnedW = calcPinnedWidth(parentSize);
        parentSize = (pinnedW, parentSize.y);
        Vector2 labMin = label.calcMinSize(parentSize);

        // In case the control is larger than the label for some reason, give us enough space for that
        if(control) {
            Vector2 controlMin = control.calcMinSize((parentSize.x, 99999));

            if(menuItem is 'OptionMenuItemResolutionOption') {
                double pw = control.calcPinnedWidth(parentSize);
            }

            if(controlMin.y > labMin.y) {
                labMin.y = controlMin.y;
            }
        }

        return (parentSize.x, MAX(minSize.y, labMin.y + padUPDOWN));
    }

    override void onSelected(bool mouseSelection) {
        Super.onSelected(mouseSelection);

        if(!disabled) {
            if(bgImage) bgImage.setSlices(bgSlice);
            if(!mouseSelection) playSound("ui/cursor2", 0.75);
        }
    }

    override void onDeselected() {
        Super.onDeselected();
        if(bgImage) bgImage.setSlices(bgSlice2);
    }

    bool onClear() {
        // Handle clear action (backspace usually)
        if(type == Option_Keybind) {
            playSound("ui/choose2");
            let o = OptionMenuItemControlBase(menuItem);
            o.mBindings.UnbindACommand(o.getAction());
            setKeybindTitle();
            checkControlHeightChange();
            return true;
        }

        return false;
    }

    override bool menuEvent(int key, bool fromcontroller) {
        let m = getMenu();

        switch(type) {
            case Option_MultiChoice:
                // Prevent players using the gamepad from locking themselves out of navigating the menus
                if(fromController && (key == Menu.MKEY_Left || key == Menu.MKEY_Right || key == Menu.MKEY_Enter) && (menuItem.getAction() == "m_blockcontrollers" || menuItem.getAction() == "use_joystick")) {
                    playSound("menu/kpError");
                    return true;
                }

                if(key == Menu.MKEY_Left) {
                    if(UIDropdown(control).selectPrevious()) {
                        handleValueChange(false, fromcontroller, sound: false);
                    }
                    
                    playSound("menu/change");
                    
                    return true;
                } else if(key == Menu.MKEY_Right) {
                    if(UIDropdown(control).selectNext()) {
                        handleValueChange(false, fromcontroller, sound: false);
                    }
                    
                    playSound("menu/change");
                    
                    return true;
                } else if(key == Menu.MKEY_Back) {
                    let dd = UIDropdown(control);
                    if(dd.isOpen()) {
                        dd.close();
                        playSound("menu/backup");
                        return true;
                    }
                }
                break;
            case Option_MultiChoice_Bar:
                if(key == Menu.MKEY_Left) {
                    if(UIButtonBar(control).selectPrevious()) {
                        handleValueChange(false, fromcontroller, sound: false);
                    }
                    
                    playSound("menu/change");
                    
                    return true;
                } else if(key == Menu.MKEY_Right) {
                    if(UIButtonBar(control).selectNext()) {
                        handleValueChange(false, fromcontroller, sound: false);
                    }
                    
                    playSound("menu/change");
                    
                    return true;
                }
                break;
            case Option_Toggle_Inverse:
            case Option_Toggle:
                if(key == Menu.MKEY_Left) {
                    UIButton(control).setSelected(false);
                    OptionMenuItemOption(menuItem).setSelection(type == Option_Toggle_Inverse ? 1 : 0);
                    playSound("menu/change");
                    sendEvent(UIHandler.Event_ValueChanged, false, fromController);
                    return true;
                } else if(key == Menu.MKEY_Right) {
                    UIButton(control).setSelected(true);
                    OptionMenuItemOption(menuItem).setSelection(type == Option_Toggle_Inverse ? 0 : 1);
                    playSound("menu/change");
                    sendEvent(UIHandler.Event_ValueChanged, false, fromController);
                    return true;
                }
                break;
            case Option_Slider:
                if(key == Menu.MKEY_Left) {
                    UISlider(control).decrease();
                    handleValueChange(false, fromController);
                    playSound("menu/change");
                    return true;
                } else if(key == Menu.MKEY_Right) {
                    UISlider(control).increase();
                    handleValueChange(false, fromController);
                    playSound("menu/change");
                    return true;
                }
                break;
            case Option_Color:
                if(m) {
                    let sld = SOMColorSliders(control);
                    //sld.resetButton.navUp = navUp;
                    sld.sliders[0].navUp = navUp;
                    sld.sliders[2].navDown = navDown;

                    if(key == Menu.MKEY_Left) {
                        playSound("menu/change");
                        m.navigateTo(sld.sliders[2]);
                        return true;
                    } else if(key == Menu.MKEY_Right) {
                        playSound("menu/change");
                        m.navigateTo(sld.sliders[0]);
                        return true;
                    }
                }
                break;
            default:
                break;
        }

        return false;
    }
    

    virtual void customMenuReturned(CustomPromptPopup menu) {
        if(menu is 'ResolutionPrompt') {
            let m = ResolutionPrompt(menu);
            let op = OptionMenuItemResolutionOption(menuItem);
            if(op) {
                op.setCustomValue(m.width, m.height);
                UIDropdown(control).setSelectedItem(op.getSelection());
            }
        } else if(menu is 'MaxFPSPrompt') {
            let m = MaxFPSPrompt(menu);
            let op = OptionMenuItemOption(menuItem);
            if(op) {
                CVar cv = CVar.GetCVar("vid_maxfps");
                if(cv && m.fps >= 0) {
                    cv.setInt(m.fps);
                }
                UIDropdown(control).setSelectedItem(0);
            }
        } else {
            // Nothing yet
        }
    }
}


class SelacoOptionActivator : OptionMenu {
    override void Drawer() { mParentMenu.Drawer(); }

    static bool RunCCMD(string com, string description = "Command", Menu parentMenu = null) {
        MenuDelegateBase md = menuDelegate;
        menuDelegate = new("MenuDelegateBase");
        let umen = new("Menu");
        umen.init(parentMenu ? parentMenu : Menu.GetCurrentMenu());
        umen.ActivateMenu();
        let input = new("SelacoOptionActivator");
        let desc = new("OptionMenuDescriptor");
        desc.mItems.resize(1);
        desc.mItems[0] = new("OptionMenuItemCommand").Init(description, com, closeonselect : true);
        input.Init(umen, desc);
        input.ActivateMenu();
        bool res = input.menuEvent(Menu.MKEY_Enter, false);
        input.close();
        umen.close();
        menuDelegate = md;
        return res;
    }

    static bool RunCCMDI(OptionMenuItemCommand mi, Menu parentMenu = null) {
        MenuDelegateBase md = menuDelegate;
        menuDelegate = new("MenuDelegateBase");

        let input = new("SelacoOptionActivator");
        let desc = new("OptionMenuDescriptor");
        desc.mItems.resize(1);
        desc.mItems[0] = mi;
        input.Init(parentMenu ? parentMenu : Menu.GetCurrentMenu(), desc);
        input.ActivateMenu();

        bool res = input.menuEvent(Menu.MKEY_Enter, false);
        input.close();

        menuDelegate = md;

        return res;
    }

    override bool MenuEvent (int mkey, bool fromcontroller) {
        for(int x = 0; x < mDesc.mItems.size(); x++) {
            let a = OptionMenuItemCommand(mDesc.mItems[x]);
            let s = OptionMenuItemSafeCommand(mDesc.mItems[x]);

            if(s) {
                if(!s.menuEvent(Menu.MKEY_MBYes, true)) {
                    Console.Printf("\c[RED]Failed to execute command: %s", StringTable.Localize(a.mLabel));
                    return false;
                }
            } else {
                if(a) {
                    if(!a.activate()) {
                        Console.Printf("\c[RED]Failed to execute command: %s", StringTable.Localize(a.mLabel));
                        return false;
                    }
                }
            }
        }

        return true;
    }
}


class SOMColorSliders : UIControl {
    UISlider sliders[3];
    UILabel valLabels[3];
    UILabel hexLabel;
    UIImage exampleView;
    //UIButton resetButton;
    Color colorValue;

    const SLIDER_SPACE = 32;

    SOMColorSliders init(Color col) {
        Super.init((0,0), (100, 100));

        col = Color(255, col.r, col.g, col.b);
        colorValue = col;

        rejectHoverSelection = true;

        exampleView = new("UIImage").init((0,0), (100, 100), "", NineSlice.Create("graphics/options_menu/color_square.png", (10, 10), (20, 20)));
        exampleView.pin(UIPin.Pin_Left);
        exampleView.pin(UIPin.Pin_Right);//, offset: -70);
        exampleView.pin(UIPin.Pin_Top);
        exampleView.pinHeight(35);
        exampleView.blendColor = col;
        exampleView.forwardSelection = self;
        add(exampleView);

        hexLabel = new("UILabel").init((0,0), (100, 100), String.Format("%02X %02X %02X", colorValue.r, colorValue.g, colorValue.b), 'PDA13FONT', textAlign: UILabel.Align_Centered);
        hexLabel.pinToParent();
        hexLabel.textColor = UIMath.Invert(colorValue);
        exampleView.add(hexLabel);

        /*resetButton = new("UIButton").init((0,0), (35, 35), "", null,
            UIButtonState.Create("graphics/options_menu/reset.png"),
            UIButtonState.Create("graphics/options_menu/reset.png"),
            UIButtonState.Create("graphics/options_menu/reset.png"),
            null,
            UIButtonState.Create("graphics/options_menu/reset.png"),
            UIButtonState.Create("graphics/options_menu/reset.png"),
            UIButtonState.Create("graphics/options_menu/reset.png")
        );
        resetButton.imgStyle = UIImage.Image_Aspect_Fit;
        resetButton.pin(UIPin.Pin_Right);
        resetButton.pin(UIPin.Pin_Top);
        resetButton.pinWidth(35);
        resetButton.pinHeight(35);
        resetButton.buttStates[UIButton.State_Normal].blendColor = 0xFFFFFFFF;
        resetButton.buttStates[UIButton.State_Hover].blendColor = 0xB2596786;
        resetButton.buttStates[UIButton.State_Pressed].blendColor = 0xCC596786;
        resetButton.buttStates[UIButton.State_Selected].blendColor = 0xB2596786;
        resetButton.buttStates[UIButton.State_SelectedHover].blendColor = 0xB27987A6;
        resetButton.buttStates[UIButton.State_SelectedPressed].blendColor = 0xCC596786;
        resetButton.rejectHoverSelection = true;
        add(resetButton);*/


        for(int x = 0; x < 3; x++) {
            int colVal = x == 0 ? col.r : (x == 1 ? col.g : col.b);
            
            let slider = new("UISlider").init((0,0), (100, 30), 0, 255, 5,
                NineSlice.Create("graphics/options_menu/slider_bg.png", (7, 14), (24, 16)),
                NineSlice.Create("graphics/options_menu/slider_bg_full.png", (7, 14), (24, 16)),
                UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
                UIButtonState.CreateSlices("graphics/options_menu/slider_butt_hover.png", (8,8), (13,13)),
                UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down.png", (8,8), (13,13))
            );
            sliders[x] = slider;
            slider.setValue(colVal);
            slider.pin(UIPin.Pin_Left);
            slider.pin(UIPin.Pin_Right, offset: -70);
            slider.pin(UIPin.Pin_Top, offset: x * SLIDER_SPACE + 40);
            slider.minSize.y = 30;
            slider.navUp = x > 0 ? UIControl(sliders[x - 1]) : null;
            slider.rejectHoverSelection = true;
            slider.slideButt.rejectHoverSelection = true;
            add(slider);

            let colLab = x == 0 ? "R" : (x == 1 ? "G" : "B");
            let valueLabel = new("UILabel").init((0,0), (60, 30), String.Format("%s: %d", colLab, colVal), "PDA13FONT", 0xFFDDDDDD, UILabel.Align_Left | UILabel.Align_Middle);
            valueLabel.pin(UIPin.Pin_Right);
            valueLabel.pin(UIPin.Pin_Top, offset: x * SLIDER_SPACE + 40);
            valueLabel.pinHeight(30);
            valueLabel.pinWidth(60);
            valLabels[x] = valueLabel;
            add(valueLabel);

            if(x > 0) {
                sliders[x - 1].navDown = slider;
            }/* else {
                resetButton.navDown = slider;
            }*/
        }

        pinHeight(SLIDER_SPACE * 3 + 40);
        minSize = (200, 35 * 3 + 40);
        
        return self;
    }

    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        if(event == UIHandler.Event_ValueChanged) {
            for(int x = 0; x < 3; x++) {
                if(ctrl == sliders[x]) {
                    let slider = UISlider(ctrl);
                    int val = int(round(slider.value));
                    let colLab = x == 0 ? "R" : (x == 1 ? "G" : "B");

                    if(x == 0) colorValue.r = val;
                    else if(x == 1) colorValue.g = val;
                    else colorValue.b = val;

                    valLabels[x].setText(String.Format("%s: %d", colLab, val));

                    exampleView.blendColor = colorValue;
                    hexLabel.setText(String.Format("%02X %02X %02X", colorValue.r, colorValue.g, colorValue.b));
                    hexLabel.textColor = UIMath.Invert(colorValue);

                    sendEvent(UIHandler.Event_ValueChanged, fromMouse, fromController);
                    return true;
                }
            }
        }/* else if(event == UIHandler.Event_Activated && ctrl == resetButton) {
            colorValue = 0xFF768198;
            refreshValues();
            sendEvent(UIHandler.Event_ValueChanged, fromMouse, fromController);
            return true;
        }*/

        return Super.handleSubControl(ctrl, event, fromMouse, fromController);
    }

    void refreshValues() {
        exampleView.blendColor = colorValue;
        valLabels[0].setText(String.Format("R: %d", colorValue.r));
        valLabels[1].setText(String.Format("G: %d", colorValue.g));
        valLabels[2].setText(String.Format("B: %d", colorValue.b));
        sliders[0].setValue(colorValue.r);
        sliders[1].setValue(colorValue.g);
        sliders[2].setValue(colorValue.b);
        hexLabel.setText(String.Format("%02X %02X %02X", colorValue.r, colorValue.g, colorValue.b));
        hexLabel.textColor = UIMath.Invert(colorValue);
    }
}