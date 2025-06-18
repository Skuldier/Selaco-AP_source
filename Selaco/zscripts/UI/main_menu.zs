#include "zscripts/UI/main_menu_updates.zs"

class MasterMenu : UIDefMenu {
    mixin CVARBuddy;
    mixin SelacoFeedbackMenu;
    mixin UIInputHandlerAccess;

    enum OnlyFans {  
        threeAMMustBe   = 0x00000000,   // Very lonely
        onlyInHardcore  = 0x00000001,
        onlyInNormal    = 0x00000002, 
        onlyIsPlaying   = 0x00000004, 
        onlyTitleMap    = 0x00000008, 
        onlyUserMaps    = 0x00000010,
        onlyDevMode     = 0x00000020, 
        onlyInGame      = 0x00000040, 
        onlyIfCVar      = 0x00000080, 
        onlyIfNotCVar   = 0x00000100,
        onlyGamepad     = 0x00000200,
        onlySaveGame    = 0x00000400,
        noSMF           = 0x00000800,
        onlySMF         = 0x00001000,
        onlyRandomizer  = 0x00002000,
    }
    
    bool useGamepad;
    OnlyFans onlyFlags;
    string cvName;
    
    bool hasFixedBinds;

    bool closing;   // Hack to prevent menu from showing in the first tick
    int numTitleButts;  // Count title butts as they are added, for adding animation
    Array<TitleButton> titleButtons;

    override UIDefMenu init(Menu parent, ListMenuDescriptor desc) {   
        if(Level.maptime <= 1) {
            closing = true;
            GenericMenu.Init(parent);
            Close();
            return self;
        }

        Super.init(parent, desc);
        allowDimInGameOnly();
        ReceiveAllInputEvents = true;

        // Add bg, manually for now. Later let's put it in the menudef
        let bgImage = new("UIImage").init((0,0), (1, 1), "MENUVIGN");
        bgImage.pinToParent();
        mainView.add(bgImage);
        mainView.moveToBack(bgImage);

        if(level.MapName ~== "TITLEMAP") {
            MenuSound("menu/frontfade");
        } else {
            MenuSound("menu/activate2");
        }

        return self;
    }


    override void ticker() {
        // Trying to prevent showing the menu on the first tick
        if(closing) {
            Close(); // This might not work
            return;
        }

        Super.ticker();

        // Special case for checking if a user has previously set a setting to RIDICULOUS to warn them that it's bad
        if(ticks == 25 && iGetCVar("g_promptridiculous")) {
            if( iGetCVar("r_particleIntensity") > 4 || 
                iGetCVar("r_particleLifespan") > 4  ||
                iGetCVar("r_smokequality") > 4      ||
                iGetCVar("r_BloodQuality") > 3
            ) {
                
                MenuSound("ui/message");
                let m = new("PromptMenu").initNew(self, "$MENU_TITLE_RIDICULOUS", "$MENU_TEXT_RIDICULOUS_STARTUP", "$MENU_BTN_RIDICULOUS");
                m.ActivateMenu();
                
                let cv = CVar.FindCVar("g_promptridiculous");
                if(cv) {
                    cv.setInt(0);
                }
            }
        }

        // Sometimes the main menu stays up when you end the game, so constantly check for TITLEMAP
        //allowDimInGameOnly();
    }

    override void onFirstTick() {
        Super.onFirstTick();

        if(isUsingGamepad() || isMenuUsingKeyboard()) {
            LevelEventHandler levHandler = LevelEventHandler.Instance();
            if(levHandler && levHandler.mainMenuPos != "") {
                for(int x = 0; x < desc.mItems.size(); x++) {
                    ListMenuItemTextButton tb = ListMenuItemTextButton(desc.mItems[x]);
                    if(tb && tb.target == levHandler.mainMenuPos) {
                        // Find the button
                        for(int y = 0; y < titleButtons.size(); y++) {
                            if(titleButtons[y].controlID == x) {
                                navigateTo(titleButtons[y]);
                                break;
                            }
                        }
                    }
                }
            }

            if(!activeControl) {
                navigateTo(titleButtons[0]);
            }
        }

        if(isUsingGamepad()) {
            hideCursor();
        } else {
            showCursor(true);
        }
    }

    override void drawer() {
        // Trying to prevent showing the menu on the first tick
        if(closing) { return; }
        Super.drawer();
    }

    override UIView createItemView(ListMenuItem i) {
        if(i is "ListMenuItemOnlyInGame") {
            onlyFlags |= onlyInGame;
            return null;
        }

        if(i is "ListMenuItemOnlyUserMaps") {
            onlyFlags |= onlyUserMaps;
            return null;
        }
        
        if(i is "ListMenuItemOnlyInNormal") {
            //onlyInNormal = true;
            //onlyInHardcore = false;
            onlyFlags |= onlyInNormal;
            onlyFlags &= ~onlyInHardcore;
            return null;
        }

        if(i is "ListMenuItemOnlyInHardcore") {
            //onlyInHardcore = true;
            //onlyInNormal = false;
            onlyFlags |= onlyInHardcore;
            onlyFlags &= ~onlyInNormal;
            return null;
        }

        if(i is "ListMenuItemOnlyIsPlaying") {
            onlyFlags |= onlyIsPlaying;
            return null;
        }

        if(i is "ListMenuItemOnlyRandomizer") {
            onlyFlags |= onlyRandomizer;
            return null;
        }

        if(i is "ListMenuItemNoSMF") {
            onlyFlags |= noSMF;
            return null;
        }

        if(i is "ListMenuItemOnlySMF") {
            onlyFlags |= onlySMF;
            return null;
        }

        if(i is "ListMenuItemOnlyGamepad") {
            onlyFlags |= onlyGamepad;
            return null;
        }

        if(i is "ListMenuItemOnlyTitleMap") {
            onlyFlags |= onlyTitleMap;
            return null;
        }

        if(i is "ListMenuItemOnlySaveGame") {
            onlyFlags |= onlySaveGame;
            return null;
        }

        if(i is "ListMenuItemOnlyDevMode") {
            onlyFlags |= onlyDevMode;
            return null;
        }

        if(i is "ListMenuItemOnlyIfNot") {
            onlyFlags |= onlyIfNotCVar;
            cvName = ListMenuItemOnlyIfNot(i).mCVName;
            return null;
        } 
        
        if(i is "ListMenuItemOnlyIf") {
            onlyFlags |= onlyIfCVar;
            cvName = ListMenuItemOnlyIf(i).mCVName;
            return null;
        }

        if(onlyFlags & onlyIfCVar) {
            if(!iGetCVar(cvName)) {
                reset();
                return null;
            }
        }

        if(onlyFlags & onlyIfNotCVar) {
            if(iGetCVar(cvName)) {
                reset();
                return null;
            }
        }

        if(onlyFlags & onlyDevMode) {
            // Check for Dev Mode
            // This is the first time that someone other than Cockatrice has added something to the Almighty CockUI. It feels like I invaded someones privacy. This is disgusting, this is all wrong. Get me out of here!
            if(CVar.FindCVar("devmode").GetInt() == false) {
                reset();
                return null;
            }
        } 

        if(onlyFlags & onlyInHardcore) {
            // Check for hardcore mode
            if(inv("HardcoreMode") == null) {
                reset();
                return null;
            }
        } 

        if(onlyFlags & onlyInNormal) {
            // Check for normal mode
            if(inv("HardcoreMode") != null) {
                reset();
                return null;
            }
        } 

        if(onlyFlags & onlyTitleMap) {
            if(Level.MapName != "TITLEMAP") {
                reset();
                return null;
            }
        }

        if(onlyFlags & onlySaveGame) {
            int lastSavegame = UIHelper.FindLastSavedGame();
            Console.Printf("Last Savegame: %d", lastSavegame);
            if(lastSavegame <= -1) {
                reset();
                return null;
            }
        }

        if(onlyFlags & onlyIsPlaying) {
            if(inv("isPlaying") == null || Level.MapName == "TITLEMAP") {
                reset();
                return null;
            }
        }

        if(onlyFlags & onlyInGame) {
            if(Level.MapName == "TITLEMAP") {
                reset();
                return null;
            }
        }

        if(onlyFlags & onlyUserMaps) {
            if(!UIHelper.CheckForUsermaps()) {
                reset();
                return null;
            }
        }

        if(onlyFlags & onlyGamepad) {
            if(!isUsingGamepad()) {
                reset();
                return null;
            }
        }

        if(onlyFlags & noSMF) {
            if(Level.MapName == "TITLEMAP" || skill == 5) {
                reset();
                return null;
            }
        }

        if(onlyFlags & onlySMF) {
            if(Level.MapName == "TITLEMAP" || skill != 5) {
                reset();
                return null;
            }
        }

        if(onlyFlags & onlyRandomizer) {
            if(Level.MapName == "TITLEMAP" || g_randomizer <= 0) {
                reset();
                return null;
            }
        }

        reset();

        if(i is 'ListMenuItemUpdateView') {
            if(UpdateWarningView.IsAnUpdateComing())
                return new('UpdateWarningView').init();
            else if(g_launch_count > 1 && g_first_menu < 1) {
                CVar.GetCVar("g_first_menu").setInt(g_first_menu + 1);
                
                // Prefech Steamworks image
                TexMan.MakeReady(TexMan.CheckForTexture("stmwrks"));

                return new("MainMenuInfoView").init(infoText: "$MAIN_MENU_INFO", displayImage: "stmwrks");
            }
        }

        UIView v = Super.createItemView(i);
        if(v is 'TitleButton') {
            // Animate title buttons based on count
            let tb = TitleButton(v);
            titleButtons.push(tb);
            tb.buttonIndex = numTitleButts++;
        }

        if(i is 'ListMenuItemLabel' && v is 'UILabel') {
            UILabel lv = UILabel(v);

            // Replace some special characters in labels, because why wouldn't GZDoom do this properly?
            lv.text.replace("\x80", String.Format("%c", 0x80));
            lv.text.replace("\x81", String.Format("%c", 0x81));
            lv.text.replace("\x82", String.Format("%c", 0x82));
            lv.text.replace("\x83", String.Format("%c", 0x83));
            lv.text.replace("\x84", String.Format("%c", 0x84));
            lv.text.replace("\x85", String.Format("%c", 0x85));
            lv.text.replace("\x86", String.Format("%c", 0x86));
            lv.text.replace("\x87", String.Format("%c", 0x87));
            lv.text.replace("\x88", String.Format("%c", 0x88));
            lv.text.replace("\x89", String.Format("%c", 0x89));

            lv.text.replace("\x8A", String.Format("%c", 0x8A));
            lv.text.replace("\x8B", String.Format("%c", 0x8B));
            lv.text.replace("\x8C", String.Format("%c", 0x8C));
            lv.text.replace("\x8D", String.Format("%c", 0x8D));
            lv.text.replace("\x8E", String.Format("%c", 0x8E));
            lv.text.replace("\x8F", String.Format("%c", 0x8F));
            lv.text.replace("\x90", String.Format("%c", 0x90));
            lv.text.replace("\x91", String.Format("%c", 0x91));
            lv.text.replace("\x92", String.Format("%c", 0x92));
            lv.text.replace("\x93", String.Format("%c", 0x93));
            
            lv.text.replace("\x94", String.Format("%c", 0x94));
            lv.text.replace("\x95", String.Format("%c", 0x95));
            lv.text.replace("\x96", String.Format("%c", 0x96));
            lv.text.replace("\x97", String.Format("%c", 0x97));
            lv.text.replace("\x98", String.Format("%c", 0x98));
            lv.text.replace("\x99", String.Format("%c", 0x99));
            lv.text.replace("\x9A", String.Format("%c", 0x9A));
            lv.text.replace("\x9B", String.Format("%c", 0x9B));
            
        }
        return v;
    }

    void reset() {
        onlyFlags = threeAMMustBe;
        cvName = "";
    }

    protected Inventory inv(string inv) {
		return players[consolePlayer].mo != null ? players[consolePlayer].mo.FindInventory(inv) : null;
	}

    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent) {
        if(event == UIHandler.Event_Activated) {
            // This is a giant hack, but let's just remove any UIImage that is the top object in the button
            if(desc.mItems.size() > ctrl.controlID) {
                let i = desc.mItems[ctrl.controlID];
                
                LevelEventHandler levHandler = LevelEventHandler.Instance();
                ListMenuItemTextButton tb = ListMenuItemTextButton(i);
                if(levHandler && tb) {
                    levHandler.mainMenuPos = tb.target;
                }

                if(i is "ListMenuItemNewsButton") {
                    int svCount = ctrl.numSubviews();
                    if(svCount > 0 && ctrl.viewAt(svCount - 1) is "UIImage") {
                        ctrl.removeViewAt(svCount - 1);
                    }
                }

                if(i is "ListMenuItemTextButton") {
                    let i = ListMenuItemTextButton(i);

                    if(i.target == "ResumeGame") {
                        int savegame = -1;
                        SavegameManager manager = null;
                        [savegame, manager] = UIHelper.FindLastSavedGame();

                        if(manager && savegame > -1) {
                            let handler = IntroHandler(StaticEventHandler.Find("IntroHandler"));
                            if(handler) {
                                handler.notifyNewGame();
                            }

                            manager.LoadSavegame(savegame);
                        }

                        return;
                    }
                }
            }

            if(ctrl is 'UIButton') {
                let butt = UIButton(ctrl);

                if(butt.command == "OpenNews") {
                    Menu.SetMenu("NewsMenu");

                    return;
                }
            }
        }
        Super.handleControl(ctrl, event, fromMouseEvent);

        // Special handling for Options Menu
        if(Menu.GetCurrentMenu() is 'SelacoOptionMenu') {
            let op = SelacoOptionMenu(Menu.GetCurrentMenu());
            op.openedFromMouse = fromMouseEvent;
        }
    }

    override bool onUIEvent(UIEvent ev) {
        if(!hasFixedBinds) {
            // Remove previously bound controls that conflict
            AutomapBindings.UnbindACommand('am_setmark');
            AutomapBindings.UnbindACommand('am_togglegrid');
            hasFixedBinds = true;
        }

        return Super.onUIEvent(ev);
    }

    override bool OnInputEvent(InputEvent ev) {
        if(ev.type == InputEvent.Type_KeyDown) {
            switch(ev.KeyScan) {
                case InputEvent.Key_Pad_LShoulder:
                    // Quick save
                    if(inv("HardcoreMode") == null && inv("isPlaying") != null && Level.MapName != "TITLEMAP") {
                        close();
                        EventHandler.SendNetworkEvent("quicksaveselaco");
                    }
                    return true;
                case InputEvent.Key_Pad_RShoulder:
                    // Quick load
                    // TODO: Replace with a confirmation prompt
                    if(Level.MapName != "TITLEMAP") {
                        if(iGetCVAR("saveloadconfirmation") > 0) {
                            Menu.SetMenu("QuickloadGameMenu");
                        } else {
                            close();
                            EventHandler.SendNetworkEvent("quickload");
                        }
                    }
                    return true;
                default:
                    break;
            }
        }

        return false;
    }

    override void didNavigate(bool withController) {
		if(withController) {
            InputHandler ih = getInputHandler();

            if(ih) {
                ih.AddUIFeedback(ih.navFeedback);
            }
        }
	}

	override void didActivate(UIControl control, bool withController) {
		if(withController) {
            InputHandler ih = getInputHandler();

            if(ih) {
                ih.AddUIFeedback(ih.buttonFeedback);
            }
        }
	}

    override void didReverse(bool withController) {
		if(withController) {
            InputHandler ih = getInputHandler();

            if(ih) {
                ih.AddUIFeedback(ih.reverseButtonFeedback);
            }
        }
	}


    override bool onBack() {
		Close();
		let m = GetCurrentMenu();
		
        if(level.MapName ~== "TITLEMAP") MenuSound("menu/backfade");
        else MenuSound("menu/clear");
        
		if (!m) menuDelegate.MenuDismissed();

		return true;
	}
}

class UIPulseImageIHateIt : UIImage {
    UIPulseImageIHateIt init(Vector2 pos, Vector2 size, string image, NineSlice slices = null, ImageStyle imgStyle = Image_Scale, Vector2 imgScale = (1,1)) {
        Super.init(pos, size, image, slices, imgStyle, imgScale);
        
        return self;
    }

    override void draw() {
        cAlpha = sin((MSTime())) * 0.5 + 0.5;
        Super.draw();
    }
}

// TODO: @cockatrice - Clean these up you fool, just use one single ListMenuItem that can receive flags
// IE: Only InHardcore | IsPlaying 
class ListMenuItemOnlyInHardcore : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}

class ListMenuItemOnlyGamepad : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}

class ListMenuItemOnlyInNormal : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}

class ListMenuItemOnlyIsPlaying : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}

class ListMenuItemOnlyRandomizer : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}

class ListMenuItemNoSMF : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}

class ListMenuItemOnlySMF : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}

class ListMenuItemOnlyTitleMap : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}

class ListMenuItemOnlySaveGame : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}

class ListMenuItemOnlyUserMaps : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}

class ListMenuItemOnlyDevMode : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}

class ListMenuItemOnlyInGame : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}

class ListMenuItemOnlyIf : ListMenuItem {
    string mCVName;
    void Init(ListMenuDescriptor desc, string cvarName) {
        Super.Init();
        mCVName = cvarName;
    }
}

class ListMenuItemOnlyIfNot : ListMenuItemOnlyIf { }


class ListMenuItemAchiementsView : UIListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }

    override UIView buildView() {
        return new("MainMenuAchievementsView").init((0,0), (80, 80));
    }
}


class ListMenuItemNewsButton : ListMenuItemTitleButton {


    void Init(ListMenuDescriptor desc, String text, String hotkey = "", String target = "",  int align = 48, int yPadTop = 0, int yPadBottom = 0, float textScaleX = 1.0, float textScaleY = 1.0) {
        Super.Init(desc, text, hotkey, target, align, yPadTop, yPadBottom, textScaleX, textScaleY);
    }

    override UIView buildView() {
        bool isNew = false;
        let newsCounterText = StringTable.Localize("$NEWS_COUNTER");
        int nc = newsCounterText != "NEWS_COUNTER" && newsCounterText != "" ? newsCounterText.toInt(10) : 1;
        let cv = CVar.FindCVar("news_counter");
        if(cv && cv.GetInt() < nc) {
           isNew = true;
        }


        let v = Super.buildView();
        let tv = TitleButton(v);
        if(tv && isNew) {
            tv.clipsSubviews = false;
            tv.isNew = isNew;
            let notifIcon = new("UIPulseImageIHateIt").init((0,0), (20, 20), "PDAUNR");
            notifIcon.pin(UIPin.Pin_Left, offset: -20);
            notifIcon.pin(UIPin.Pin_VCenter, value: 1.0);
            notifIcon.alpha = 0;
            tv.add(notifIcon);
            tv.newIcon = notifIcon;
        }

        return v;
    }
}

class ListMenuItemTitleButton : ListMenuItemTextButton {
    override UIView buildView() {
        let hiState = CommonUI.barBackgroundState();
        hiState.textColor = colorSelected;
        
        let v = TitleButton(new("TitleButton").init(
            pos, (350, 40),
            text, fnt,
            UIButtonState.Create("", color),
            hiState,
            UIButtonState.Create("", colorSelected),
            textAlign: align
        ));

        v.setTextPadding(10, yPadTop, 0, yPadBottom);
        if(v.label) v.label.fontScale = textScale;
        v.originalFontScale = textScale;
        v.pinHeight(UIView.Size_Min);

        return v;
    }
}

class ListMenuItemSpacer : UIListMenuItem {
    int vSpace;

    void Init(ListMenuDescriptor desc, int space) {
        Super.Init();
        vSpace = space;
    }

    override UIView buildView() {
        return new("UIView").init((0,0), (1, vSpace));
    }
}


class TitleButton : UIButton {
    int buttonIndex;
    bool hasAnimated;
    bool isNew;
    double magnify, slide;
    Vector2 originalFontScale;
    UIView newIcon;
    UIImage image;

    void setImage(string tex) {
        if(image) {
            image.setImage(tex);
        } else {
            image = new("UIImage").init((17, 0), (40, 40), tex, imgStyle: UIImage.Image_Aspect_Fit);
            image.pin(UIPin.Pin_Top, UIPin.Pin_Bottom, value: 0.05, isFactor: true);
            image.pin(UIPin.Pin_Bottom, value: 1.0 - 0.05, isFactor: true);
            add(image);

            // Adjust text offsets for image
            textPadding.left += 66;
            textPins[0].offset = textPadding.left;
            requiresLayout = true;
        }
    }

    override void onAddedToParent(UIView parentView) {
        Super.onAddedToParent(parentView);
        label.pixelAlign = false;
        hasAnimated = false;
        setAlpha(0);
    }

    override void tick() {
        Super.tick();

        // Add initial animation
        if(!hasAnimated) {
            hasAnimated = true;

            animateIn();

            if(currentState == State_Hover || currentState == State_SelectedHover) {
                animateToHover();
            }
        }
    }

    void animateIn(double delay = double.max, double time = 0.12) {
        hasAnimated = true;

        if(delay == double.max) delay = min(0.025 * UIMath.EaseOutQuadF(min(1.0, buttonIndex / 25.0)) * 25.0,  0.375);

        let anim = animateFrame(
            time,
            fromPos: frame.pos - (150, 0),
            toPos: frame.pos,
            fromAlpha: 0,
            toAlpha: 1.0,
            ease: Ease_Out
        );

        anim.startTime += delay;
        anim.endTime += delay;
        //anim.layoutSubviewsEveryFrame = true;

        if(newIcon) {
            newIcon.alpha = 0;
            anim = newIcon.animateFrame(
                time,
                fromPos: newIcon.frame.pos - (150, 0),
                toPos: newIcon.frame.pos,
                ease: Ease_Out
            );
            anim.startTime += delay;
            anim.endTime += delay;
        }
    }


    void animateOut(double delay = double.max, double time = 0.12) {
        hasAnimated = true;
        
        if(delay == double.max) delay = min(0.025 * UIMath.EaseOutQuadF(min(1.0, buttonIndex / 25.0)) * 25.0,  0.375);

        let anim = animateFrame(
            time,
            fromPos: frame.pos,
            toPos: frame.pos - (150, 0),
            fromAlpha: alpha,
            toAlpha: 0,
            ease: Ease_In
        );

        anim.startTime += delay;
        anim.endTime += delay;
        //anim.layoutSubviewsEveryFrame = true;

        if(newIcon) {
            anim = newIcon.animateFrame(
                time,
                fromPos: newIcon.frame.pos,
                toPos: newIcon.frame.pos - (150, 0),
                ease: Ease_In
            );
            anim.startTime += delay;
            anim.endTime += delay;
        }
    }

    override void transitionToState(int idx, bool sound) {
        int oldState = currentState;
        Super.transitionToState(idx, sound);

        if(currentState != oldState && (currentState == State_Hover || currentState == State_SelectedHover)) {
            if(newIcon) {
                newIcon.hidden = true;
            }
            if(hasAnimated) animateToHover();
        } else if(currentState != oldState && (currentState == State_Normal || currentState == State_Selected)) {
            if(newIcon) {
                newIcon.hidden = false;
            }
            if(hasAnimated) animateToNormal();
        }
    }

    virtual void animateToNormal() {
        let animator = getAnimator(); 
        if(animator) animator.clear(label);

        // Add animation to the label
        label.animateLabel(
            0.08,
            fromScale: label.fontScale,
            toScale: originalFontScale,
            ease: Ease_Out
        );

        label.animateFrame(
            0.08,
            toPos: (0 + textPadding.left, label.frame.pos.y),
            ease: Ease_Out
        );
    }

    virtual void animateToHover() {
        let animator = getAnimator(); 
        if(animator) animator.clear(label);

        // Add animation to the label
        label.animateLabel(
            0.06,
            fromScale: label.fontScale,
            toScale: originalFontScale * (magnify > 0 ? magnify : 1.15),
            ease: Ease_Out
        );
        
        label.animateFrame(
            0.06,
            toPos: ((label.fnt.GetCharWidth("0") * originalFontScale.x * 0.5 * (slide > 0 ? slide : 1.0)) + textPadding.left, label.frame.pos.y),
            ease: Ease_Out
        );
    }
}


class MainMenuAchievementsView : UIVerticalLayout {
    mixin CVARBUDDY;
    UILabel warningLabel, titleLabel;
    UIImage bgImage;
    uint ticks;


    MainMenuAchievementsView init(Vector2 pos = (0,0), Vector2 size = (100,100)) {
        Super.init(pos, size);
        
        padding.left = 22;
        padding.right = 22;
        padding.top = 22;
        padding.bottom = 22;
        itemSpacing = 5;

        bgImage = new("UIImage").init((0,0), (10, 10), "", NineSlice.Create("BGENERIC", (9,9), (14,14)));
        bgImage.pinToParent();
        add(bgImage);

        titleLabel = new("UILabel").init(
            (0,0), (100, 40),
            StringTable.Localize("$ACHIEVEMENT_WARNING_TITLE"), 
            "K22FONT", 
            textAlign: UIView.Align_Middle,
            fontScale: (0.75, 0.75)
        );
        titleLabel.pin(UIPin.Pin_Left, offset: 22);
        titleLabel.pin(UIPin.Pin_Right, offset: -22);
        titleLabel.pinHeight(UIView.Size_Min);
        addManaged(titleLabel);

        warningLabel = new("UILabel").init(
            (0,0), (100, 40),
            StringTable.Localize(iGetCVAR("g_statdb_modded") ? "$ACHIEVEMENT_WARNING_MODS" : "$ACHIEVEMENT_WARNING"), 
            "K22FONT", 
            textAlign: UIView.Align_Middle,
            fontScale: (0.65, 0.65)
        );
        warningLabel.pin(UIPin.Pin_Left, offset: 22);
        warningLabel.pin(UIPin.Pin_Right, offset: -22);
        warningLabel.pinHeight(UIView.Size_Min);

        addManaged(warningLabel);

        layoutMode = UIViewManager.Content_SizeParent;

        if(StatDatabase.IsAvailable()) {
            hidden = true;
        }

        return self;
    }

    override void tick() {
        Super.tick();

        if(hidden != StatDatabase.IsAvailable()) {
            hidden = !hidden;
            if(parent) parent.requiresLayout = true;
        }
    }
}