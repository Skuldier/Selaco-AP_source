class PDAAppWindow : UIWindow {
    UIView  titleView;           // Container for label, button and drag bar
    UIButton closeButton;
    UILabel titleLabel;
    UIImage dragBar;
    int appID;
    int sortOrder;              // Kind of a hack, only used when the codex is loaded

    int dragPadding;            // Padding between title and close button
    int dragPaddingVert;

    bool hasLayedOutOnce;

    virtual PDAAppWindow vInit( Vector2 pos, Vector2 size ) { return self; }

    PDAAppWindow init(  Vector2 pos, Vector2 size,
                        string title, Font titleFont,
                        NineSlice slices,
                        int dragHeight = 30, 
                        int sizerWidth = 10,
                        int paddingTop = 30,
                        int paddingLeft = 10,
                        int paddingRight = 10,
                        int paddingBottom = 10,
                        bool hasClose = true,
                        bool showDragBar = true,
                        int titleHeight = 30,
                        int titleOffset = 0,
                        int titleOffsetX = 0,
                        int dragBarPadding = 10,
                        int dragBarPaddingVert = 10 ) {

        Super.init(pos, size, 
            slices,
            true, true, true,
            dragHeight, 
            sizerWidth,
            paddingTop,
            paddingLeft,
            paddingRight,
            paddingBottom
        );

        dragPadding = dragBarPadding;
        dragPaddingVert = dragBarPaddingVert;

        // Create title container
        titleView = new("UIView").init((0,0), (1, titleHeight));
        titleView.pin(UIPin.Pin_Top, offset: titleOffset);
        titleView.pin(UIPin.Pin_Left, offset: sizerWidth + titleOffsetX);
        titleView.pin(UIPin.Pin_Right, offset: -sizerWidth);
        titleView.raycastTarget = false;
        add(titleView);

        // Create close button
        if(hasClose) {
            closeButton = new("UIButton").init((0,0), (24, 24), "", null, 
                UIButtonState.Create("PDACLO1"),
                UIButtonState.Create("PDACLO2"),
                UIButtonState.Create("PDACLO3")
            );
            closeButton.pin(UIPin.Pin_Right);
            closeButton.pin(UIPin.Pin_VCenter, value: 1);
            closeButton.rejectHoverSelection = true;
            titleView.add(closeButton);
        }

        // Create title label
        if(titleFont != null) {
            titleLabel = new("UILabel").init((0,0), (100, 20), title, titleFont, textAlign: UIView.Align_Middle);
            titleLabel.pin(UIPin.Pin_Left);
            titleLabel.pin(UIPin.Pin_Top);
            titleLabel.pin(UIPin.Pin_Bottom);
            titleLabel.pinWidth(UIView.Size_Min);
            titleView.add(titleLabel);
        }

        // Crate drag bar as visual indicator of drag area
        if(showDragBar) {
            dragBar = new("UIImage").init((0,0), (100, 20), "PDADRAGB", null, UIImage.Image_Repeat);
            titleView.add(dragBar);
        }

        return self;
    }

    override void layout(Vector2 parentScale, double parentAlpha) {
        if(!hasLayedOutOnce) {
            if(parent) {
                if(!restorePos()) {
                    setDefaultPositionAndSize(parent.frame.size.x, parent.frame.size.y);
                }

                savePos();  // Save our pos, size and open status
            }
            hasLayedOutOnce = true;
        }
        
        // Lay out children
        Super.layout(parentScale, parentAlpha);

        // If we have a drag bar, manually size it between the title text and the close button (if there is a close button)
        if(dragBar) {
            dragBar.frame.pos.x = titleLabel.frame.pos.x + titleLabel.frame.size.x + dragPadding;
            dragBar.frame.pos.y = dragPaddingVert;
            dragBar.frame.size.y = titleView.frame.size.Y - (dragPaddingVert * 2);
            dragBar.frame.size.x = closeButton ? closeButton.frame.pos.x - dragBar.frame.pos.x - dragPadding : titleView.frame.size.x - dragBar.frame.pos.x - dragPadding;
            dragBar.buildShape();
        }
    }

    // Catch drag/size events and save pos after dragging
    override void onMouseUp(Vector2 screenPos) {
        bool hasChanged = false;
        if(isDragging || isSizing[0] || isSizing[1] || isSizing[2]) {
            hasChanged = true;
        }

        Super.onMouseUp(screenPos);

        if(hasChanged) {
            savePos();
        }
    }

    virtual void setDefaultPositionAndSize(int desktopWidth, int desktopHeight) {
        frame.pos = (32 + 224 + 15, 15);
        frame.size = (desktopWidth - frame.pos.x - 20, desktopHeight - 45);
    }


    virtual void onClose() {
        // TODO: Save window state into savegame (size/position/stateinfo)
        sendEvent(UIHandler.Event_Closed, false);

        Menu.MenuSound("codex/closeWindow");
    }

    void close() {
        onClose();

        // TODO: Animation
        savePos(0); // Save pos, save closed status
        removeFromSuperview();
        
        self.Destroy();
    }

    // TODO: Animation
    virtual void animateClose() {
        close();
    }

    void savePos(int forceO = -1) {
        if(appID > 0 && parent) {
            // Determine this apps order, based on arrangement in view stack
            int o = 0;

            if(forceO >= 0) { o = forceO; }
            else {
                for(int x = 0; x < parent.subviews.size(); x++) {
                    if(parent.subviews[x] == self) {
                        o = x + 1;
                        break;
                    }
                }
            }
            
            if(hasLayedOutOnce) EventHandler.SendNetworkEvent(String.Format("pdaAppPos:%f:%f:%f:%f", frame.pos.x / parent.frame.size.x, frame.pos.y / parent.frame.size.y, frame.size.x / parent.frame.size.x, frame.size.y / parent.frame.size.y), self.appID, o);
            else EventHandler.SendNetworkEvent(String.Format("pdaAppPos:%f:%f:%f:%f", 0, 0, 0, 0), self.appID, o);
        }
    }

    virtual bool restorePos() {
        let evt = PDAManager(StaticEventHandler.Find("PDAManager"));
        PDAEntry entry = evt ? PDAEntry(players[consolePlayer].mo.FindInventory("PDAEntry", true)) : null;

        if(entry && appID > 0) {
            let settings = entry.appSettings[appID];

            if(!settings) { return false; }

            // Convert normalized stored position to local coords
            let ps = parent.frame.size;
            Vector2 p;
            Vector2 s;
            s.x = round(MAX(minSize.x, settings.size.x * ps.x));
            s.y = round(MAX(minSize.y, settings.size.y * ps.y));
            p.x = round(MAX(0, settings.pos.x * ps.x));
            p.y = round(MAX(0, settings.pos.y * ps.y));

            // Make sure the frame fits in the space available
            if(p.x + s.x > ps.x) {
                p.x = MAX(0, ps.x - s.x);
                s.x = MIN(s.x, ps.x);
            }

            if(p.y + s.y > ps.y) {
                p.y = MAX(0, ps.y - s.y);
                s.y = MIN(s.y, ps.y);
            }

            frame.pos = p;
            frame.size = s;

            if(frame.size.x >= ps.x) {
                frame.pos.x = 0;
                frame.size.x = ps.x;
            }

            if(frame.size.y >= ps.y) {
                frame.pos.y = 0;
                frame.size.y = ps.y;
            }


            return true;
        }


        return false;
    }

    override bool handleSubControl(UIControl ctrl, int event, bool fromMouse, bool fromController) {
        if(event == UIHandler.Event_Activated) {
            if(ctrl == closeButton) {
                // Close this window
                // TODO: Animate closings
                close();
                return true;
            }
        }

        return Super.handleSubControl(ctrl, event, fromMouse, fromController);
    }

    override bool menuEvent(int key, bool fromcontroller) {
        UIMenu m = getMenu();
        if(!m) { return false; }    // How the hell could this even happen?

        /*if(key == Menu.MKEY_Clear) {
            // Close the window
            if(canClose()) {
                close();
            }

            return true;
        }*/

        return Super.menuEvent(key, fromcontroller);
    }

    virtual bool onInputEvent(InputEvent ev) {
        return false;
    }

    virtual bool canClose() {
        return true;
    }

    virtual UIControl getActiveControl() {
        return null;
    }

    virtual void navigateToFirstControl(bool atOpen = false, bool gamepad = false) {
        let c = getActiveControl();
        let m = getMenu();
        if(c && m) {
            m.navigateTo(c, false, gamepad);
        }
    }
}


class PDAFullscreenAppWindow : PDAAppWindow {
    PDAFullscreenAppWindow init(Vector2 pos = (0,0), Vector2 size = (100, 100)) {
        frame.pos = pos;
        frame.size = size;
        alpha = 1;
        scale = (1,1);
        maxSize = (99999, 99999);
        clipsSubviews = true;
        requiresLayout = true;
        raycastTarget = true;

        contentView = new("UIView").init((0,0), (1,1));
        contentView.pinToParent();
        add(contentView);

        pinToParent();

        return self;
    }


    void createStandardTitleBar(String title) {
        // Create title label
        titleLabel = new("UILabel").init((0, 36), (300, 40), title, "SEL46FONT", 0xFFB9C0D1);
        titleLabel.scaleToHeight(35);
        titleLabel.pin(UIPin.Pin_Left, offset: 10);
        titleLabel.pin(UIPin.Pin_Right);
        add(titleLabel);

        // Create separator
        let sep = new("UIView").init((0,83), (100, 2));
        sep.pin(UIPin.Pin_Left);
        sep.pin(UIPin.Pin_Right);
        sep.backgroundColor = 0xFF586685;
        add(sep);
        
        // Offset top of content view to match
        let topPin = contentView.firstPin(UIPin.Pin_Top);
        if(topPin) {
            topPin.offset = 85;
            contentView.requiresLayout = true;
        }
    }

    override bool restorePos() {
        return true;    // Fullscreen apps don't restore pos
    }

    override void setDefaultPositionAndSize(int desktopWidth, int desktopHeight) {
        // Do nothing
    }
}