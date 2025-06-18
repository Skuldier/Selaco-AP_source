class BBSettingsPopUp : UIView {
    UIView blockerView;
    BBWindow window;
    UIButton resetButton;
    UIButton uninstallButton;
    UIButton doneButton;

    BBSettingsPopUp init() {
        Super.init((0,0), (400, 0));
        pinToParent();
        
        blockerView = new("UIView").init((0,0), (0,0));
        blockerView.pinToParent();
        blockerView.backgroundColor = 0xFF333333;
        blockerView.alpha = 0.5;
        add(blockerView);

        let background = new("UIImage").init((0,0), (400, 350), "", NineSlice.Create("BBADBG1", (24, 72), (32, 85)));
        background.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        background.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);
        add(background);

        let titleLabel = new("UILabel").init((0,0), (0, 53), "$BB_Settings", "SEL21FONT", textAlign: UIView.Align_Centered);
        titleLabel.pin(UIPin.Pin_Left);
        titleLabel.pin(UIPin.Pin_Top, offset: 12);
        titleLabel.pin(UIPin.Pin_Right);
        background.add(titleLabel);
        titleLabeL.shadowOffset = (2,2);
        titleLabel.drawShadow = true;

        let vlayout = new("UIVerticalLayout").init((0,0), (300, 400));
        vlayout.pinToParent(35, 12 + 53 + 15, -35, -35);
        vlayout.itemSpacing = 10;
        background.add(vlayout);


        let normState     = UIButtonState.CreateSlices("BBBUTT05", (16,16), (20, 84), scaleCenter: true);
        let hovState      = UIButtonState.CreateSlices("BBBUTT06", (16,16), (20, 84), scaleCenter: true);
        let pressState    = UIButtonState.CreateSlices("BBBUTT07", (16,16), (20, 84), scaleCenter: true);

        // Add Reset button
        resetButton = new("UIButton").init((0,0), (0, 45), "$BB_ResetProgress", "PDA18FONT", normState, hovState, pressState);
        resetButton.label.shadowOffset = (-1, -1);
        resetButton.label.drawShadow = true;
        resetButton.label.shadowColor = 0x66333333;
        resetButton.pin(UIPin.Pin_Left, offset: 20);
        resetButton.pin(UIPin.Pin_Right, offset: -20);
        vlayout.addManaged(resetButton);

        // Add Uninstall button
        uninstallButton = new("UIButton").init((0,0), (0, 45), "$BB_Uninstall", "PDA18FONT", normState, hovState, pressState);
        uninstallButton.label.shadowOffset = (-1, -1);
        uninstallButton.label.drawShadow = true;
        uninstallButton.label.shadowColor = 0x66333333;
        uninstallButton.pin(UIPin.Pin_Left, offset: 20);
        uninstallButton.pin(UIPin.Pin_Right, offset: -20);
        vlayout.addManaged(uninstallButton);

        // Add Return To Game button
        doneButton = new("UIButton").init((0,0), (0, 45), "$BB_ReturnToGame", "PDA18FONT", normState, hovState, pressState);
        doneButton.label.shadowOffset = (-1, -1);
        doneButton.label.drawShadow = true;
        doneButton.label.shadowColor = 0x66333333;
        doneButton.pin(UIPin.Pin_Left, offset: 20);
        doneButton.pin(UIPin.Pin_Right, offset: -20);
        vlayout.addSpacer(50);
        vlayout.addManaged(doneButton);

        resetButton.onClick = resetPressed;
        resetButton.receiver = self;

        uninstallButton.onClick = uninstallPressed;
        uninstallButton.receiver = self;

        doneButton.onClick = donePressed;
        doneButton.receiver = self;

        UIControl lastCtrl = null;
        for(int x = 0; x < vlayout.numManaged(); x++) {
            let c = UIControl(vlayout.getManaged(x));
            if(c) {
                if(lastCtrl) {
                    lastCtrl.navDown = c;
                    c.navUp = lastCtrl;
                }
                lastCtrl = c;
            }
        }

        return self;
    }


    static bool donePressed(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = BBSettingsPopUp(self);
        self.removeFromSuperview();
        if(!mouse && self.window && self.window.lastControlBeforeSettings) {
            self.window.getMenu().navigateTo(self.window.lastControlBeforeSettings, mouse, gamepad);
            self.window.lastControlBeforeSettings = null;
            self.window.settingsPop = null;
        }
        return true;
    }


    static bool resetPressed(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = BBSettingsPopUp(self);

        let m = new("PromptMenu").initNew(self.getMenu(), "$BB_WIPE_TITLE", "$BB_WIPE_DESCRIPTION", "$BB_SETTINGS_WIPE", "$BB_SETTINGS_CANCEL", destructiveIndex: 0, defaultSelection: 1);
        m.onClosed = BBWindow.wipePromptClosed;
        m.receiver = self.window;
        m.usrData = 1;
        m.ActivateMenu();
        return true;
    }


    static bool uninstallPressed(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = BBSettingsPopUp(self);

        let m = new("PromptMenu").initNew(self.getMenu(), "$BB_UNINSTALL_TITLE", "$BB_UNINSTALL_DESCRIPTION", "$BB_SETTINGS_UNINSTALL", "$BB_SETTINGS_CANCEL", destructiveIndex: 0, defaultSelection: 1);
        m.onClosed = BBWindow.uninstallPromptClosed;
        m.receiver = self.window;
        m.usrData = 2;
        m.ActivateMenu();
        return true;
    }
}