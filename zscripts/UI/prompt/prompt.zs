#include "zscripts/UI/prompt/weapon_part_prompt.zs"

class PromptHandler : EventHandler {
    string buttonTitles[4];
    string completeScript;
    string title, text;
    class<WeaponUpgrade> upgradeClass;

    int weaponKitPromptTimer;

    static void ShowPrompt(string title, string text, string completeScript, string opt1, string opt2 = "", string opt3 = "", string opt4 = "") {
        let handler = Instance();

        if(!handler) {
            Console.Printf("\c[RED]No prompt handler class could be found trying to prompt: %s", title);
            return;
        }

        handler.buttonTitles[0] = StringTable.Localize(opt1);
        handler.buttonTitles[1] = StringTable.Localize(opt2);
        handler.buttonTitles[2] = StringTable.Localize(opt3);
        handler.buttonTitles[3] = StringTable.Localize(opt4);

        handler.text = StringTable.Localize(text);
        handler.title = StringTable.Localize(title);
        handler.completeScript = completeScript;

        S_StartSound ("menu/prompt", CHAN_VOICE, CHANF_UI, snd_menuvolume);
        Menu.SetMenu("PromptMenu");
    }


    static void ShowWeaponKitPrompt(class<WeaponUpgrade> upgrade) {
        let handler = Instance();

        if(!handler) {
            Console.Printf("\c[RED]No prompt handler class could be found trying to open weapon prompt!");
            return;
        }

        handler.buttonTitles[0] = StringTable.Localize("Equip");
        handler.buttonTitles[1] = StringTable.Localize("Store in Inventory");
        handler.buttonTitles[2] = "";
        handler.buttonTitles[3] = "";

        handler.text = "";
        handler.title = "";
        handler.completeScript = "";
        handler.upgradeClass = upgrade;

        handler.weaponKitPromptTimer = 35;
    }


    clearscope static PromptHandler Instance() {
        return PromptHandler(EventHandler.Find("PromptHandler"));
    }


    override void NetworkProcess(ConsoleEvent e) {
        if(e.name == "promptComplete") {
            completePrompt(e.args[0]);
        }
    }


    override void WorldTick() {
        if(weaponKitPromptTimer && --weaponKitPromptTimer == 0) {
            S_StartSound ("menu/prompt", CHAN_VOICE, CHANF_UI, snd_menuvolume);
            Menu.SetMenu("WeaponPartPrompt");
        }
    }


    void completePrompt(int buttIndex) {
        if(completeScript == "") return;

        let complete = completeScript;
        completeScript = "";
        players[consolePlayer].mo.ACS_NamedExecute(complete, 0, buttIndex);
    }
}


class PromptMenu : UIMenu {
    UIMenu parentMenu;
    UIImage mainBG, bg, imageView;
    UIView midView;
    UILabel textLabel;
    UIHorizontalLayout hlayout;
    UITexture imageTex;
    Vector2 imageScale;

    Array<UIButton> butts;
    Array<string> buttTitles;
    string title, text;
    bool initFromNew, allowBack;

    string usrString;
    int usrData;

    Function<ui void(Object, int)> onClosed;
    Object receiver;

    int closeTicks, destructiveIndex, defaultSelection;

    PromptMenu initNew(Menu parent, string title, string txt, string btn1, string btn2 = "", string btn3 = "", string btn4 = "", int destructiveIndex = -1, int defaultSelection = 0, String image = "", Vector2 imgScale = (1,1)) {
        initFromNew = true;

        self.title = StringTable.Localize(title);
        self.text = StringTable.Localize(txt);
        self.destructiveIndex = destructiveIndex;
        self.defaultSelection = defaultSelection;
        allowBack = false;
        buttTitles.push(StringTable.Localize(btn1));

        if(image != "") {
            imageTex = UITexture.get(image);
            imageScale = imgScale;
        }

        if(btn2 != "") buttTitles.push(StringTable.Localize(btn2));
        if(btn2 != "") buttTitles.push(StringTable.Localize(btn3));
        if(btn2 != "") buttTitles.push(StringTable.Localize(btn4));

        init(parent);
        return self;
    }

    override void init(Menu parent) {
		Super.init(parent);

        parentMenu = UIMenu(parent);

        AnimatedTransition = false;
        Animated = true;
        DontBlur = parent && parent.DontBlur;
        BlurAmount = parent ? parent.BlurAmount : 0;
        allowBack = false;
        if(parent) DontDim = parent.DontDim;
        else allowDimInTitlemapOnly();

        let pinstance = PromptHandler.Instance();

        bg = new("UIImage").init((0,0), (100, 100), "TUTMBG");
        bg.pinToParent();
        bg.alpha = 0;
        mainView.add(bg);

        mainBG = new("UIImage").init(
            (0,0), (450, 300), "",
            NineSlice.Create("PROMPTB3", (30, 70), (40, 76))
        );
        mainBG.alpha = 0;
        mainBG.pin(UIPin.Pin_VCenter, value: 1.0);
        mainBG.pin(UIPin.Pin_HCenter, value: 1.0);

        mainView.add(mainBG);

        midView = new("UIView").init((0,0), (0,0));
        midView.pinToParent(30 + 15, 90, -(30 + 15), -100);
        midView.clipsSubviews = true;
        mainBG.add(midView);

        // We will alter this manually in Layout()
        if(imageTex && imageTex.texID.isValid()) {
            imageView = new("UIImage").init((0,0), (0, 0), imageTex.path);
            imageView.imgScale = imageScale;
            imageView.pinWidth(UIView.Size_Min);
            imageView.pinHeight(UIView.Size_Min);
            imageView.pin(UIPin.Pin_Top);
            imageView.pin(UIPin.Pin_Left);
            midView.add(imageView);
        }

        // We will size this manually in Layout()
        let titleLabel = new("UILabel").init(
            (0,0), (100, 37),
            initFromNew ? title : pinstance.title,
            'SEL21FONT',
            textAlign: UIView.Align_Left | UIView.Align_Middle,
            fontScale: (0.857, 0.857) // 18pt
        );
        titleLabel.pin(UIPin.Pin_Top, offset: 24);
        titleLabel.pin(UIPin.Pin_Left, offset: 30 + 15);
        titleLabel.pin(UIPin.Pin_Right, offset: -30 - 15);
        mainBG.add(titleLabel);

        textLabel = new("UILabel").init(
            (0,0), (100, 100),
            initFromNew ? text : pinstance.text,
            'PDA16FONT',
            textAlign: UIView.Align_Left
        );
        textLabel.multiline = true;
        textLabel.pin(UIPin.Pin_Top);
        textLabel.pin(UIPin.Pin_Left, offset: (imageTex ? imageTex.size.x * imageScale.x + 25 : 0));
        textLabel.pin(UIPin.Pin_Right);
        textLabel.pinHeight(UIView.Size_Min);
        midView.add(textLabel);


        // Horizontal layout to center buttons
        hlayout = new("UIHorizontalLayout").init((0,0), (100, 100));
        hlayout.layoutMode = UIViewManager.Content_SizeParent;
        hlayout.itemSpacing = 15;
        //hlayout.pin(UIPin.Pin_HCenter, value: 1.0);
        hlayout.pin(UIPin.Pin_Right, offset: -30 - 15);
        hlayout.pin(UIPin.Pin_Bottom, offset: -10);
        mainBG.add(hlayout);

        createButtons();

        if(1){//isUsingController() || isUsingKeyboard()) {
            navigateTo(butts[defaultSelection < butts.size() ? defaultSelection : 0]);
        }
    }


    void createButtons() {
        let pinstance = PromptHandler.Instance();

        // Add buttons, empty text means no button
        let stateNorm = UIButtonState.CreateSlices("PRMTBUT1", (16,16), (20,20), textColor: 0xFFFFFFFF);
        let stateHigh = UIButtonState.CreateSlices("PRMTBUT2", (16,16), (20,20), sound: "ui/cursor2", soundVolume: 0.45);
        let stateDown = UIButtonState.CreateSlices("PRMTBUT3", (16,16), (20,20));
        let stateSelected = UIButtonState.CreateSlices("PRMTBUT4", (16,16), (20,20), sound: "ui/cursor2", soundVolume: 0.45);
        let stateSelectedDown = stateDown;

        int nButt = initFromNew ? buttTitles.size() : 4;
        for(int x = 0; x < nButt; x++) {
            string btnText = initFromNew ? buttTitles[x] : pinstance.buttonTitles[x];

            if(btnText != "") {
                UIButton btn;
                
                if(x != destructiveIndex) {
                    btn = new("UIButton").init((0,0), (100, 54), btnText, "PDA16FONT",
                        stateNorm, stateHigh, stateDown, null, stateSelected, stateHigh, stateSelectedDown
                    );
                } else {
                    btn = new("UIButton").init((0,0), (100, 54), btnText, "PDA16FONT",
                        UIButtonState.CreateSlices("PRMTBUT8", (16,16), (20,20), textColor: 0xFFFFFFFF), 
                        UIButtonState.CreateSlices("PRMTBUT9", (16,16), (20,20), sound: "ui/cursor2", soundVolume: 0.45), 
                        UIButtonState.CreateSlices("PRMTBUT0", (16,16), (20,20)), 
                        null, 
                        null, 
                        null, 
                        null
                    );
                }

                btn.pinWidth(UIView.Size_Min);
                btn.pin(UIPin.Pin_VCenter, value: 1.0);
                btn.setTextPadding(25, 0, 27, 0);
                btn.controlID = x;

                /*if(x == destructiveIndex) {
                    btn.desaturation = 1.0;
                    btn.blendColor = UIHelper.DestructiveColor;
                    btn.blendColor.a = 195;
                }*/
                //btn.label.fontScale = (0.75, 0.75);

                hlayout.addManaged(btn);
                butts.push(btn);

                if(butts.size() > 1) {
                    btn.navLeft = butts[butts.size() - 2];
                    butts[butts.size() - 2].navRight = btn;
                }
            }
        }
    }


    override void ticker() {
        Super.ticker();
        
        // If we are on top of a parent menu, tick it first
        if(parentMenu) {
            parentMenu.ticker();
        }
        
        if(closeTicks > 0) {
            if(closeTicks > 4) {
                Close();
            }
            closeTicks++;
        }
    }


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated && closeTicks == 0) {
            EventHandler.SendNetworkEvent("promptComplete", ctrl.controlID);
            MenuSound("menu/advance");
            if(!initFromNew) menuActive = Menu.OnNoPause;    // will this work here?
            else {
                if(onClosed) {
                    onClosed.call(receiver, ctrl.controlID);
                }
                // Send event to previous menu if this was created in that context
                else if(mParentMenu) {
                    mParentMenu.MenuEvent(MKEY_MBYes + ctrl.controlID, false);
                }
            }
            animateClose();
        }
    }


    void animateClose() {
        /*mainView.animateFrame(
            0.10,
            //fromAlpha: 1.0,
            toAlpha: 0.0
        );*/
        animator.clear();

        bg.animateFrame(
            0.10,
            toAlpha: 0.0
        );

        mainBG.animateFrame(
            0.10,
            fromPos: mainBG.frame.pos,
            toPos:mainBG.frame.pos + (0, 100),
            toAlpha: 0.0,
            ease: Ease_In
        );

        closeTicks = 1;
    }


    override void layoutChange(int screenWidth, int screenHeight) {
		Super.layoutChange(screenWidth, screenHeight);
        
        mainView.layout();

        // We are going to layout twice to get the sizes we need
        // It's such a simple view setup that this shouldn't be slow
        let minTextWidth = ceil( MAX( MAX(550, midView.frame.size.x), hlayout.frame.size.x + 30) );

        let textLabelMinSize = textLabel.calcMinSize((minTextWidth, 999999));
        mainBG.frame.size.x = minTextWidth + midView.firstPin(UIPin.Pin_Left).offset - midView.firstPin(UIPin.Pin_Right).offset;
        mainBG.frame.size.y = ceil( MAX(210, max(imageView ? imageView.frame.size.y + 190 + 25 : 0, textLabelMinSize.y + 190 + 25)) );
        
        mainView.layout();

        // Since this should only happen if screen size changes, or at startup let's add our animation here
        // Normally we would do this on the first tick
        bg.animateFrame(
            0.10,
            //fromAlpha: 0.0,
            toAlpha: initFromNew ? 0.6 : 1.0
        );

        mainBG.animateFrame(
            0.11,
            fromSize: (mainBG.frame.size.x, 190),
            toSize: (mainBG.frame.size.x, mainBG.frame.size.y),
            //fromAlpha: 0.0,
            toAlpha: 1.0,
            layoutSubviewsEveryFrame: true,
            ease: Ease_Out
        );

        mainView.animateFrame(
            0.18,
            layoutSubviewsEveryFrame: true
        );  // Adding this because we need to force a layout of everything
	}


    override bool onBack() {
        if(allowBack && closeTicks == 0) {
            MenuSound('menu/backup');
            animateClose();
        }
		return true;
	}


    override bool MenuEvent (int mkey, bool fromcontroller) {
        switch(mkey) {
            
            case MKEY_Enter:
                if(!activeControl && butts.size() > 1) {
                    navigateTo(butts[0]);
                    return true;
                } else if(!activeControl && butts.size() == 1) {
                    // Auto-activate if there is a single control
                    handleControl(butts[0], UIHandler.Event_Activated, false);
                    return true;
                }
            default:
                break;
        }

        return Super.MenuEvent(mkey, fromcontroller);
    }


    override UIControl findFirstControl(int mkey) {
        switch(mkey) {
            case MKEY_Left:
                return butts[butts.size() - 1];
            case MKEY_Right:
                return butts.size() > 0 ? butts[1] : butts[0];
            case MKEY_Back:
                break;
            default:
                return defaultSelection >= 0 ? butts[defaultSelection] : butts[0];
        }

        return Super.findFirstControl(mkey);
    }


    override void drawer() {
        // If we are on top of a parent menu, draw it first
        if(parentMenu) {
            parentMenu.drawer();
        }

        Super.drawer();
    }
}