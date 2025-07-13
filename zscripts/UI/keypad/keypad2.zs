class KeypadMenu2 : SelacoGamepadMenuInGame {
    UIButton padButts[10];
    UIButton clearButt;
    UIButton backButt, okButt;
    UIView blocker;
    UIImage digits[4];
    UIImage background, statusLight;

    const timeoutTicks = 25;
    const timeoutFailTicks = 25;
    const delayTimeoutTicks = 10;
    const SLOT_STATE_FAIL = 7;
    const SLOT_STATE_SUCCESS = 6;
    const SLOT_STATE_DELAY = 5;
    
    int kpValues[4];
    int slot;
    int timeoutCounter;

    int backKey1, backKey2;

    bool validAtStart;      // This is a latch to make sure we can manually open the keypad for testing, so an invalid keypad doesn't immediately close itself

    double dimStart;


     override void init(Menu parent) {
		Super.init(parent);
        DontDim = true;
        AnimatedTransition = false;
        Animated = true;
        menuActive = Menu.OnNoPause;    // This prevents the game from pausing when we open the menu
        DontBlur = false;

        // Cache the key used to move backwards
        [backKey1, backKey2] = Bindings.GetKeysForCommand("+back");

        backKey1 = UIHelper.GetUIKey(backKey1);
        backKey2 = UIHelper.GetUIKey(backKey2);
        
        timeoutCounter = timeoutTicks;
        slot = 0;
        kpValues[0] = -1;
        kpValues[1] = -1;
        kpValues[2] = -1;
        kpValues[3] = -1;
        
        // Create background
        background = new("UIImage").init(
            (0,0),
            (397, 292),
            "graphics/KEYPAD/Panel2.png"
        );
        background.scale = (2,2);
        background.noFilter = true;
        mainView.add(background);

        background.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        background.pin(UIPin.Pin_VCenter, value: 1.0, isFactor: true);

        // Create the digits
        for(int i = 0; i < 4; i++) {
            digits[i] = new("UIImage").init(
                (46 + (i * (28 + 7)), 42),
                (28, 40),
                ""
            );
            digits[i].noFilter = true;
            background.add(digits[i]);
        }

        Conf();


        // Add keypad buttons
        Vector2 startPos = (234, 97);
        for(int i = 0; i < 9; i++) {
            int num = 9 - (2 - i % 3) - (3 * Floor(i / 3.0));

            let hoverState = UIButtonState.Create("graphics/KEYPAD/kp" .. num .. ".png", sound: "menu/kpOver");
            let clickState = UIButtonState.Create("graphics/KEYPAD/kp" .. num .. "_lit.png", sound: "menu/kpPres0" .. num);

            padButts[num] = new("UIButton").init(
                (startPos.x + ((i - (floor( i / 3.) * 3) ) * 40), startPos.y + (40 * floor( i / 3.))),
                (39, 39),
                "", null,
                null,
                hoverState,
                clickState
            );
            padButts[num].controlID = num;
            padButts[num].noFilter = true;
            padButts[num].activateOnDownEvent = true;
            
            // Add the button element into the main frame.
            background.add(padButts[num]);
            //padButts[num].fade[OMZFButton.ButtonState_Inactive] = true;
        }

        // Zero button
        padButts[0] = new("UIButton").init(
            (274, 217),
            (39, 39),
            "", null,
            null,
            UIButtonState.Create("graphics/KEYPAD/kp0.png", sound: "menu/kpOver"),
            UIButtonState.Create("graphics/KEYPAD/kp0_lit.png", sound: "menu/kpPres00")
        );
        padButts[0].controlID = 0;
        padButts[0].noFilter = true;
        padButts[0].activateOnDownEvent = true;
        background.add(padButts[0]);
        //padButts[0].fade[OMZFButton.ButtonState_Inactive] = true;

        clearButt = new("UIButton").init(
            (234, 217),
            (39, 39),
            "", null,
            null,
            UIButtonState.Create("graphics/KEYPAD/kpBack.png", sound: "menu/kpOver"),
            UIButtonState.Create("graphics/KEYPAD/kpBack_lit.png", sound: "menu/kpPres01")
        );
        clearButt.controlID = 10;
        clearButt.noFilter = true;
        clearButt.activateOnDownEvent = true;
        background.add(clearButt);

        okButt = new("UIButton").init(
            (314, 217),
            (39, 39),
            "", null,
            null,
            UIButtonState.Create("graphics/KEYPAD/kpOK.png", sound: "menu/kpOver"),
            UIButtonState.Create("graphics/KEYPAD/kpOK_lit.png", sound: "menu/kpPres02")
        );
        okButt.noFilter = true;
        okButt.controlID = 11;
        okButt.activateOnDownEvent = true;
        background.add(okButt);


        // Create the back button
        /*backButt = new("UIButton").init(
            (314, 217),
            (39, 39),
            UIButtonState.Create("graphics/KEYPAD/kpBack.png"),
            UIButtonState.Create("graphics/KEYPAD/kpBack.png", sound: "menu/kpOver"),
            UIButtonState.Create("graphics/KEYPAD/kpBackDown.png", sound: "menu/kpPres02")
        );*/

        statusLight = new("UIImage").init(
            (246, 19),
            (110, 40),
            ""
        );
        statusLight.noFilter = true;
        background.add(statusLight);

        blocker = new("UIView").init((0,0), (10, 10));
        blocker.raycastTarget = true;
        blocker.pinToParent();


        // Create navigation
        clearButt.navLeft = okButt;
        clearButt.navUp = padButts[1];
        clearButt.navRight = padButts[0];
        clearButt.navUp = padButts[1];

        okButt.navLeft = padButts[0];
        okButt.navUp = padButts[3];
        okButt.navRight = clearButt;
        okButt.navUp = padButts[3];

        padButts[7].navRight = padButts[8];
        padButts[7].navDown = padButts[4];
        padButts[7].navLeft = padButts[9];
        padButts[7].navUp = clearButt;

        padButts[8].navRight = padButts[9];
        padButts[8].navDown = padButts[5];
        padButts[8].navLeft = padButts[7];
        padButts[8].navUp = padButts[0];

        padButts[9].navRight = padButts[7];
        padButts[9].navDown = padButts[6];
        padButts[9].navLeft = padButts[8];
        padButts[9].navUp = okButt;

        padButts[4].navRight = padButts[5];
        padButts[4].navDown = padButts[1];
        padButts[4].navLeft = padButts[6];
        padButts[4].navUp = padButts[7];

        padButts[5].navRight = padButts[6];
        padButts[5].navDown = padButts[2];
        padButts[5].navLeft = padButts[4];
        padButts[5].navUp = padButts[8];

        padButts[6].navRight = padButts[4];
        padButts[6].navDown = padButts[3];
        padButts[6].navLeft = padButts[5];
        padButts[6].navUp = padButts[9];

        padButts[1].navRight = padButts[2];
        padButts[1].navDown = clearButt;
        padButts[1].navLeft = padButts[3];
        padButts[1].navUp = padButts[4];

        padButts[2].navRight = padButts[3];
        padButts[2].navDown = padButts[0];
        padButts[2].navLeft = padButts[1];
        padButts[2].navUp = padButts[5];

        padButts[3].navRight = padButts[1];
        padButts[3].navDown = okButt;
        padButts[3].navLeft = padButts[2];
        padButts[3].navUp = padButts[6];

        padButts[0].navRight = okButt;
        padButts[0].navDown = padButts[8];
        padButts[0].navLeft = clearButt;
        padButts[0].navUp = padButts[2];


        dimStart = MSTime() / 1000.0;

        // Check if this is a valid keypad
        let evt = KeypadGlobalHandler.Instance();
        if(evt && evt.kpCode != "") {
            validAtStart = true;
        }
    }


    void conf() {
        for(int i = 0; i < 4; i++) {
            int val = kpValues[i];
            
            if(val < 0) {
                digits[i].setImage("");
            } else {
                digits[i].setImage("graphics/KEYPAD/dg" .. val .. ".png");
            }
        }
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated) {
            if(ctrl.controlID < 10) {
                ApplyKey(ctrl.controlID);
            } else if(ctrl == clearButt) {
                Backspace();
            } else if(ctrl == okButt) {
                PressOK();
            }
        }
    }

    override void ticker() {
		Super.ticker();

        // Check if the keypad is still valid in the backend
        if(validAtStart) {
            let evt = KeypadGlobalHandler.Instance();
            if(!evt || evt.kpCode == "") {
                Close();    // Usually this is just for dying
                return;
            }
        }

        // This is used to delay the closing of the menu, so you can actually see your last button press
        if(slot > 4) {
            timeoutCounter--;

            if(timeoutCounter < 0) {
                switch(slot) {
                    case SLOT_STATE_DELAY:
                        ProcessCode();
                        break;
                    case SLOT_STATE_SUCCESS:
                        Close();    // CleanClose is not required, because sending the original code will reset the global vars
                        break;
                    case SLOT_STATE_FAIL:
                    default:
                        if(timeoutCounter < -3) {
                            // We showed the err, go back to default operation
                            slot = 0;
                            kpValues[0] = kpValues[1] = kpValues[2] = kpValues[3] = -1;
                            statusLight.setImage("");
                            statusLight.setAlpha(1);
                            Conf();
                            EnableInterface(true);
                        } else {
                            statusLight.alpha -= 0.333;
                        }
                        
                        break;
                }
            } else if(slot == SLOT_STATE_FAIL) {
                
                // Flash the failure light
                int interval = floor(timeoutFailTicks / 6);
                if(timeoutCounter % interval == 0) {
                    statusLight.setImage(statusLight.tex.path == "graphics/KEYPAD/lightr.png" ? "graphics/KEYPAD/lightR3.png" : "graphics/KEYPAD/lightr.png");
                }
            } else if(slot == SLOT_STATE_SUCCESS) {
                // Fade in the green light
                double alpha = statusLight.alpha + 0.33333;
                statusLight.setAlpha(MIN(1, alpha));
            }
        }
    }

    override bool MenuEvent (int mkey, bool fromcontroller) {
        switch(mkey) {
            case MKEY_Back:
                MenuSound("ui/leavepad");
                CleanClose();
                return true;
            /*case MKEY_Enter:
                if(!okButt.isDisabled() && slot == 4) {
                    okButt.onActivate(false);
                    return true;
                    //PressOK();
                }
                return Super.MenuEvent(mkey, fromcontroller);*/
            case MKEY_Left:
            case MKEY_Right:
            case MKEY_Up:
            case MKEY_Down:
                if(!activeControl) {
                    // Select the first control
                    navigateTo(padButts[7]);
                    return true;
                }

                return Super.MenuEvent(mkey, fromcontroller);
            case 8:
                if(!clearButt.isDisabled()) {
                    //Backspace();
                    clearButt.onActivate(false, fromController);
                }
                return true;
            default:
                return Super.MenuEvent(mkey, fromcontroller);
        }
    }

    override bool OnUIEvent(UIEvent ev) {
        //Console.Printf("UI Event: %d - %d ", ev.type, ev.KeyChar);
        if(ev.type == UIEvent.Type_KeyDown) {
            //Console.Printf("KeyDown Event: %d - %d ", ev.type, ev.KeyChar);

            if(ev.KeyChar == 48 || ev.KeyChar == 96) {
                if(!blocker.parent) {
                    //ApplyKey(0);
                    padButts[0].onActivate(false);
                    if(slot == 4) {
                        if(!okButt.isDisabled()) {
                            okButt.onActivate(false);
                            PressOK(false);
                        }
                    }
                }
                return true;
            } else if(ev.KeyChar >= 49 && ev.KeyChar <= 57) {
                if(!blocker.parent) {
                    //ApplyKey(ev.KeyChar - 48);
                    padButts[ev.KeyChar - 48].onActivate(false);
                    if(slot == 4) {
                        if(!okButt.isDisabled()) {
                            okButt.onActivate(false);
                            PressOK(false);
                        }
                    }
                }
                return true;
            } else if(ev.KeyChar >= 97 && ev.KeyChar <= 105) {
                if(!blocker.parent) {
                    //ApplyKey(ev.KeyChar - 96);
                    padButts[ev.KeyChar - 96].onActivate(false);
                    if(slot == 4) {
                        if(!okButt.isDisabled()) {
                            okButt.onActivate(false);
                            PressOK(false);
                        }
                    }
                }
                return true;
            } else if(ev.KeyChar == UIEvent.Key_Backspace) {
                if(!blocker.parent) {
                    // Backspace
                    //Backspace();
                    clearButt.onActivate(false);
                }
                return true;
            } else if(ev.KeyChar == UIEvent.Key_Return) {
                if(!blocker.parent) {
                    // OK Button
                    //PressOK();
                    okButt.onActivate(false);
                }
                return true;
            }

            if(ev.KeyChar == backKey1 || ev.KeyChar == backKey2 || ev.KeyChar == UIEvent.Key_Escape || ev.KeyChar == UIEvent.Key_Back) {
                // Play close sound
                MenuSound("ui/leavepad");
                CleanClose();
                return true;
            }
        }
        return Super.OnUIEvent(ev);
    }

    override void drawer() {
        double time = MSTime() / 1000.0;
        if(time - dimStart > 0) {
            //double dim = MIN((time - dimStart) / 0.15, 1.0) * 0.75;
            //Screen.dim(0xFF020202, dim, 0, 0, Screen.GetWidth(), Screen.GetHeight());
            BlurAmount =  MIN((time - dimStart) / 0.1, 1.0);
        }

        Super.drawer();
    }

    void CleanClose() {
        // Clear the global vars because we don't need them anymore, and opening this menu (via console or something) might have 
        // weird undefined behaviour
        EventHandler.SendNetworkEvent("kpCancel");
        Close();
    }

    override void closeOnDeath() {
        EventHandler.SendNetworkEvent("kpCancel");
        Super.closeOnDeath();
    }

    void ProcessCode() {
        string code = "" .. kpValues[0] .. kpValues[1] .. kpValues[2] .. kpValues[3];

        let evt = KeypadGlobalHandler(StaticEventHandler.Find("KeypadGlobalHandler"));
        if (!evt) {
            MenuSound("menu/kpError");
            slot = SLOT_STATE_FAIL;   // Fallback. If the handler is not present we can never actually open this keypad
            timeoutCounter = timeoutTicks;
            Console.Printf("This keypad is not connected to anything!");
        } else {
            if(evt.kpCode != code) {
                MenuSound("menu/kpError");
                statusLight.setImage("graphics/KEYPAD/lightr.png");

                slot = SLOT_STATE_FAIL;
                timeoutCounter = timeoutFailTicks;
            } else {
                MenuSound("menu/kpSuccess");
                statusLight.setImage("graphics/KEYPAD/lightg.png");
                statusLight.alpha = 0;

                slot = SLOT_STATE_SUCCESS;
                timeoutCounter = timeoutTicks;
            }
        }
        
        EventHandler.SendNetworkEvent("kpCodeEnter:" .. code);
    }

    void Clear() {
        slot = 0;
        kpValues[0] = -1;
        kpValues[1] = -1;
        kpValues[2] = -1;
        kpValues[3] = -1;
        Conf();
    }

    void ApplyKey(int keyVal) {
        if(slot < 4) {
            kpValues[slot] = keyVal;
            slot++;
            Conf();
        }

        //MenuSound("menu/kpPress");
    }

    void Backspace() {
        if(slot > 0 && slot < 5) {
            kpValues[slot-1] = -1;
            
            slot--;
            Conf();
        }
    }

    void PressOK(bool sound = true) {
        slot = SLOT_STATE_DELAY;
        timeoutCounter = delayTimeoutTicks;

        // Disable keys until after success/failure
        EnableInterface(false);
    }

    void EnableInterface(bool enable = true) {
        if(enable && blocker.parent) {
            blocker.removeFromSuperview();
        } else if(!enable && !blocker.parent) {
            background.add(blocker);
        }
    }
}