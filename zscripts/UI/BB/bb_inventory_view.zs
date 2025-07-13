class BBInventoryView : UIView {
    UIVerticalScroll scroll;
    UIVerticalLayout mainLayout;
    BBWindow window;
    Array<UIButton> buttons;

    BBInventoryView init() {
        Super.init((0,0), (0,0));

        pinToParent();

        let burgerItem = BBItem.Find();

        scroll = new("UIVerticalScroll").init((0,0), (0,0), 15, 15,
            NineSlice.Create("BBBAR01", (7,8), (8,28)), null,
            UIButtonState.CreateSlices("BBBAR02", (6,6), (9,13)),
            UIButtonState.CreateSlices("BBBAR03", (6,6), (9,13)),
            UIButtonState.CreateSlices("BBBAR04", (6,6), (9,13)),
            insetA: 10,
            insetB: 10,
            scrollPadding: 10
        );
        scroll.pinToParent();
        scroll.autoHideAdjustsSize = true;
        scroll.autoHideScrollbar = true;
        scroll.scrollbar.rejectHoverSelection = true;
        scroll.rejectHoverSelection = true;
        scroll.mLayout.itemSpacing = 10;
        //scroll.scrollbar.firstPin(UIPin.Pin_Right).offset = -8;
        add(scroll);

        mainLayout = UIVerticalLayout(scroll.mLayout);

        
        reload();

        return self;
    }


    UIControl getFirstControl() {
        foreach(b : buttons) {
            if(!b.hidden) return b;
        }
        return null;
    }


    void reload() {
        mainLayout.clearManaged();
        buttons.clear();
        let burgerItem = BBItem.Find();

        // Add header
        let hedImage = new("UIImage").init((0,0), (0,0), "BBHED3", imgStyle: UIImage.Image_Aspect_Fit);
        hedImage.pin(UIPin.Pin_Left);
        hedImage.pin(UIPin.Pin_Right);
        hedImage.pinHeight(27);
        mainLayout.addManaged(hedImage);

        UIButton lastButton = null;

        // Add a bunch of buttons for burger skins
        for(int x = 0; x < burgerItem.skinUnlocks.size(); x++) {
            if(x == 0 || burgerItem.skinUnlocks[x] > 0) {
                let bg = new("UIImage").init((0,0), (0,0), "BBBACK09", NineSlice.Create("BBBACK09", (24,24), (42, 43)));
                bg.pin(UIPin.Pin_Left);
                bg.pin(UIPin.Pin_Right);
                bg.pinHeight(180);
                
                let imgView = new("UIImage").init((0,0), (0,0), String.Format("CCPIC%d", x), imgStyle: UIImage.Image_Aspect_Fit);
                imgView.pinToParent();
                bg.add(imgView);


                let activateButton = new("UIButton").init((0,0), (90,40),
                    "Activate", "PDA16FONT",
                    UIButtonState.CreateSlices("BBBUTT05", (16,16), (20, 84), scaleCenter: true),
                    UIButtonState.CreateSlices("BBBUTT06", (16,16), (20, 84), scaleCenter: true),
                    UIButtonState.CreateSlices("BBBUTT07", (16,16), (20, 84), scaleCenter: true)
                );
                activateButton.label.fontScale = (0.8, 0.8);
                activateButton.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
                activateButton.pin(UIPin.Pin_Bottom, offset: -10);
                activateButton.command = "Skin";
                activateButton.controlID = x;
                activateButton.onClick = skinPressed;
                activateButton.receiver = self;
                bg.add(activateButton);
                buttons.push(activateButton);
                
                if(lastButton) lastButton.navDown = activateButton;
                activateButton.navUp = lastButton;
                activateButton.navRight = window ? window.inventoryButton : null;
                lastButton = activateButton;
                
                mainLayout.addManaged(bg);
            }
        }
    }


    static bool skinPressed(Object self, UIButton btn, bool mouse, bool gamepad) {
        let self = BBInventoryView(self);

        if(self.window) {
            let burgerItem = BBItem.Find();
            let skinID = btn.controlID;
            if(skinID != burgerItem.skin) {
                if(self.window) self.window.flash(0x66FFFFFF, 1.0, false);
                Menu.MenuSound("ui/burgerflipper/skin");
                EventHandler.SendNetworkEvent("bbskin", skinID);
            }
        }

        return true;
    }


    override void tick() {
        Super.tick();

    }

    void animateIn(double delay = 2.0) {
        
    }

    void animateOut(double delay = 0.0) {

    }
}
