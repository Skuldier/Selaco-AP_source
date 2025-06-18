#include "ZScripts/UI/new_game/skill_menu_options.zs"
#include "ZScripts/UI/new_game/settings_prompt.zs"
#include "ZScripts/UI/new_game/level_select_menu.zs"
#include "ZScripts/UI/diff_menu/change_diff_menu.zs"

// Sub Menus
#include "ZScripts/UI/new_game/skill_menu_mode.zs"
#include "ZScripts/UI/new_game/skill_menu_skill.zs"
#include "ZScripts/UI/new_game/skill_menu_mutators.zs"

// TODO: Add prompt when selecting harder difficulties
// TODO: Animate more things
class SkillMenu2 : SelacoGamepadMenu {
    mixin SCVARBuddy;

    UIImage revealCover;
    RevealImage headerImage;
    UILabel headerLabel;
    UIView headerView;
    UIImage backgroundImage;
    StandardBackgroundContainer background;

    bool shouldFade, startingGame, noSoundThisTick;
    bool fadingOut;
    double dimStart;
    int startGameSkill, startGameLevel;
    double startGameTime;

    const startGameDelay = 1.5;
    const startGameBlackTime = 1.0;

    const smallButtScale = 0.73;
    const smallButtSize = 36;


    override void init(Menu parent) {
        Super.init(parent);
        
        allowDimInGameOnly();
        Animated = true;

        startGameSkill = -1;
        startGameTime = 0;

        bool isSmallVert = mainView.frame.size.y < 900;

        calcScale(Screen.GetWidth(), Screen.GetHeight());

        bool isTitleMap = Level.MapName == "TITLEMAP";

        shouldFade = true;
        dimStart = getRenderTime();

        if(isTitleMap) {
            backgroundImage = new("UIImage").init((0,0), (0,0), "SELACITY", imgStyle: UIImage.Image_Aspect_Fill);
            backgroundImage.pinToParent();
            backgroundImage.alpha = 0;
            backgroundImage.blendColor = 0xAA000000;
            mainView.add(backgroundImage);
        }

        background = CommonUI.makeStandardBackgroundContainer();
        mainView.add(background);

        if(isSmallVert) background.firstPin(UIPin.Pin_Top).offset = 110;

        if(JoystickConfig.NumJoysticks()) {
            background.addGamepadFooter(InputEvent.Key_Pad_B, "Back");
        }

        // Headerview will contain all the header objects for repositioning
        headerView = new("UIView").init((0,0), (10000,1));
        headerView.ignoresClipping = true;
        headerView.clipsSubviews = false;
        background.add(headerView);

        // Selaco logo
        headerImage = new("RevealImage").init((-6, -75), (632, 150), "SELACOLM");
        headerView.add(headerImage);
        headerImage.alpha = 0;

        revealCover = new("UIImage").init((-130,-70), (200, 140), "SKILWIPE");
        headerView.add(revealCover);
        revealCover.alpha = 0;

        headerLabel = new("UILabel").init((0,75), (500, 40), "SETUP GAME", "SEL46FONT");
        headerLabel.scaleToHeight(40);
        headerLabel.alpha = 0;
        headerView.add(headerLabel);

        // Reset all options to default
        UIHelper.ResetNewGameOptions();
    }


    override void layoutChange(int screenWidth, int screenHeight) {
		hasLayedOutOnce = true;
		calcScale(screenWidth, screenHeight);

        bool isSmallVert = mainView.frame.size.y < 900;
        background.firstPin(UIPin.Pin_Top).offset = isSmallVert ? 110 : 180;

		mainView.layout();
	}


    override void onFirstTick() {
        Super.onFirstTick();

        mainView.layout();
        hasLayedOutOnce = true;

        headerImage.revealTime = 0.13;
        headerImage.startAnim();

        // Alpha fade in
        revealCover.animateFrame(
            0.05,
            fromAlpha: 0,
            toAlpha: 1,
            ease: Ease_In
        );

        headerImage.animateFrame(
            0.05,
            fromAlpha: 0,
            toAlpha: 1,
            ease: Ease_In
        );

        revealCover.animateImage(
            0.18,
            fromScale: (3.0, 1.0),
            toScale: (1.0, 1.0),
            ease: Ease_Out
        );

        revealCover.animateFrame(
            0.18,
            fromPos: revealCover.frame.pos,
            toPos: (revealCover.frame.pos.x + 1700, revealCover.frame.pos.y),
            ease: Ease_In
        );

        // Alpha fade out, delayed
        let anim = revealCover.animateFrame(
            0.04,
            fromAlpha: 1,
            toAlpha: 0,
            ease: Ease_Out
        );

        anim.startTime += 0.14;
        anim.endTime += 0.14;
        
        // Animate in background image if it exists
        if(backgroundImage) {
            let anim = backgroundImage.animateFrame(
                1.07,
                fromAlpha: 0,
                toAlpha: 1,
                ease: Ease_Out
            );
        }

        // Open first menu
        Menu.SetMenu('SkillMenuMode');
        let m = SkillMenuMode(Menu.GetCurrentMenu());
        if(m) {
            m.masterMenu = self;
            m.animateIn();
        }
    }


    void animateHeaderLabel(String text) {
        headerLabel.setText(text);
        headerLabel.alpha = 0;
        let anim = headerLabel.animateFrame(
            0.12,
            fromPos: (-150, headerLabel.frame.pos.y),
            toPos: (0, headerLabel.frame.pos.y),
            fromAlpha: 0,
            toAlpha: 0.5,
            ease: Ease_Out
        );

        anim.startTime += 0.03;
        anim.endTime += 0.03;
    }


    void animateAwayHeaderLabel() {
        // Animate away header label
        let anim = headerLabel.animateFrame(
            0.12,
            fromPos: headerLabel.frame.pos,
            toPos: headerLabel.frame.pos - (150, 0),
            fromAlpha: headerLabel.alpha,
            toAlpha: 0,
            ease: Ease_In
        );

        anim.startTime += 0.03;
        anim.endTime += 0.03;
    }


    void skillSelected(int skill) {
        startGameSkill = skill;
        startingGame = true;
        startGameTime = getRenderTime();
    }


    override void ticker() {
        Super.ticker();

        if(startGameTime > 0.1 && startingGame) {
            SetMusicVolume(MAX(0.0, Level.MusicVolume - ((getRenderTime() - startGameTime) / (startGameDelay * 0.5))));

            if(getRenderTime() - startGameTime > 4) {
                startGame();
            }

        } else {
            SetMusicVolume(Level.MusicVolume);
        }

        noSoundThisTick = false;

        if(!startingGame && isTopMenu()) {
            close();
        }

        if(fadingOut && !animator.isAnimating()) {
            // Check top menu for animations
            SkillMenuSub sub = SkillMenuSub(Menu.GetCurrentMenu());
            if(sub && !sub.animator.isAnimating()) {
                sub.close();
            } else if(!sub) {
                close();
            }
        }
    }


    override void onResume(bool cursorWasHidden) {
        Super.onResume(cursorWasHidden);
        
        /*if(cursorWasHidden) {
            for(int x = 0; x < butts.size(); x++) {
                if(SkillMenuButton(butts[x]).skill == startGameSkill) {
                    navigateTo(butts[x]);
                    return;
                }
            }
        }*/
    }


    void startGame() {
        // Tell the intro-handler that a new game is starting
        let handler = IntroHandler(StaticEventHandler.Find("IntroHandler"));
        if(handler) {
            handler.notifyNewGame();
        }
        
        Level.StartNewGame(0, startGameSkill, "Dawn");
    }


    // Draw a fade when necessary
    const dimTime = 0.5;

    override void drawSubviews() {
        if(shouldFade) {
            double time = getRenderTime();
            if(time - dimStart > 0 || fadingOut) {
                double dim = UIMath.EaseOutCubicf(MIN((time - dimStart) / dimTime, 1.0)) * 0.7;
                Screen.dim(0xFF020202, dim, 0, 0, lastScreenSize.x, lastScreenSize.y);
            }
        }
        
        Super.drawSubviews();

        if(startGameTime > 0.1 && startingGame && isTopMenu()) {
            Screen.ClearClipRect();
            Screen.dim(0xFF020202, (getRenderTime() - startGameTime) / startGameDelay, 0, 0, lastScreenSize.x, lastScreenSize.y);
        }
    }


    void animateClosed() {
        fadingOut = true;
        dimStart = getRenderTime();
        shouldFade = false;

        // Animate sub menu out
        SkillMenuSub sub = SkillMenuSub(Menu.GetCurrentMenu());
        if(sub) {
            sub.animateOut();
        }

        // Animate out background image if it exists
        if(backgroundImage) {
            animator.clear(backgroundImage);
            let anim = backgroundImage.animateFrame(
                0.15,
                toAlpha: 0,
                ease: Ease_In
            );
        }

        let anim = headerImage.animateFrame(
            0.18,
            toPos: headerImage.frame.pos - (80, 0),
            toAlpha: 0,
            ease: Ease_In
        );
    }

    override bool onBack() {
        if(startingGame) return true;   // Prevent leaving when game is starting
        if(fadingOut) return true;

        shouldFade = false;
        fadingOut = true;

        // Restore music volume
        SetMusicVolume(Level.MusicVolume);
        
        animateClosed();

        return false;
    }


    /*override bool MenuEvent(int mkey, bool fromcontroller) {
		switch (mkey) {
            case Menu.MKEY_Clear:
            {
                if(fromcontroller) {
                    SkillMenuCheckboxOptionView cb = SkillMenuCheckboxOptionView(activeControl);
                    if(cb && !cb.isDisabledInMenu) {
                        // Open the submenu
                        let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("NewGameSettings"));
                        if(menuDescriptor) {
                            let mode = OptionMenuItemTooltipOptionMode(menuDescriptor.mItems[cb.controlID]);
                            if(mode && mode.subMenu != "") {
                                let prompt = new("OptionsPrompt").initNew(self, mode.subMenu);
                                prompt.ActivateMenu();
                            }
                        }
                    }
                }
            }
            case Menu.MKEY_MBYes:
            case Menu.MKEY_Abort:
                NewGameSettingsPrompt prompt = NewGameSettingsPrompt(Menu.GetCurrentMenu());
                if(prompt) {
                    updateSelectedMutators();
                }

                return true;
			default:
				break;
		}

		return Super.MenuEvent(mkey, fromcontroller);
	}*/
}


class OptionMenuItemTooltipOptionMode : OptionMenuItemTooltipOption {
    string unlocker, subMenu;
    bool isNew;

    OptionMenuItemTooltipOption Init(String label, String tool, Name command, Name values, String unlock = "", int isNew = false, string subMenu = "") {
        self.isNew = isNew;
        self.unlocker = unlock;
        self.subMenu = subMenu;
		Super.Init(label, tool, "", command, values, 'none');
        
		return self;
	}
}

class OptionMenuItemTooltipSliderMode : OptionMenuItemTooltipSlider {
    bool isNew;

    OptionMenuItemTooltipSliderMode Init(String label, String tooltip, String defImage, Name command, double min, double max, double step, int showval = 1, CVar graycheck = NULL, int isNew = false) {
        self.isNew = isNew;
        Super.Init(label, tooltip, defImage, command, min, max, step, showval, graycheck);
        return self;
    }
}


class OptionMenuItemTooltipOptionText : OptionMenuItemTooltipOption {
    int spaceLeft, spaceTop, spaceRight, spaceBottom;

    OptionMenuItemTooltipOption Init(String label, int spaceTop = 5, int spaceBottom = 15, int spaceLeft = 0, int spaceRight = 0) {
        self.spaceLeft = spaceLeft;
        self.spaceRight = spaceRight;
        self.spaceTop = spaceTop;
        self.spaceBottom = spaceBottom;
		Super.Init(label, "", "", 'none', 'none', 'none');
        
		return self;
	}
}




// Framework for a sub menu in the skill menu
// Essentially this is an enhanced listmenu
class SkillMenuSub : SelacoGamepadMenu abstract {
    StandardBackgroundContainer background;
    UIVerticalScroll mainScroll;
    UIVerticalLayout mainLayout, descriptionContainer;
    UILabel descriptionTitleLabel, descriptionLabel;

    bool animatingClosed, animatingNext, isRandomizer;
    SkillMenuSub nextMenu;

    SkillMenu2 masterMenu;


    override void init(Menu parent) {
        Super.init(parent);

        isModal = true;
        animated = true;

        background = CommonUI.makeStandardBackgroundContainer();
        mainView.add(background);

        bool compactWidth = mainView.frame.size.x <= 1800;
        bool compactHeight = mainView.frame.size.y <= 900;

        if(compactHeight) background.firstPin(UIPin.Pin_Top).offset = 110;


        mainScroll = new("UIVerticalScroll").init((0,0), (500 + 150,100), 14, 14,
            NineSlice.Create("PDABAR5", (10,10), (11,13)), null,
            UIButtonState.CreateSlices("PDABAR6", (10,10), (11,13)),
            UIButtonState.CreateSlices("PDABAR7", (10,10), (11,13)),
            UIButtonState.CreateSlices("PDABAR8", (10,10), (11,13)),
            insetA: 15, insetB: 15
        );

        mainScroll.ignoresClipping = true;
        mainScroll.pin(UIPin.Pin_Left, offset: -150);
        mainScroll.pin(UIPin.Pin_Top, offset: 115 + 60);
        mainScroll.maxSize.x = (mainView.frame.size.x > 1800 ? 480 : 380) + 150;
        mainScroll.minSize.y = 200;
        mainScroll.pin(UIPin.Pin_Bottom, offset: -50);
        mainScroll.autoHideScrollbar = true;
        
        mainLayout = UIVerticalLayout(mainScroll.mLayout);
        mainLayout.padding.left = 150;
        mainLayout.ignoreHiddenViews = true;
        mainLayout.clipsSubviews = false;
        background.add(mainScroll);


        descriptionContainer = new("UIVerticalLayout").init((520,200), (700, 280));
        descriptionContainer.pin(UIPin.Pin_Left, offset: compactWidth ? 400 : 550);
        descriptionContainer.pin(UIPin.Pin_Right, offset: compactWidth ? 0 : -80);
        descriptionContainer.pin(UIPin.Pin_Top, offset: 115 + 60);
        //descriptionContainer.pin(UIPin.Pin_VCenter, UIPin.Pin_Top, offset: 115 + 40 + 180);
        descriptionContainer.minSize.y = 360;
        descriptionContainer.maxSize.x = 1100;
        descriptionContainer.padding.set(20, 20, 20, 20);
        descriptionContainer.layoutMode = UIViewManager.Content_SizeParent;
        descriptionContainer.itemSpacing = 20;
        descriptionContainer.clipsSubviews = false;
        descriptionContainer.alpha = 0;
        background.add(descriptionContainer);

        let descriptionContainerBG = new("UIImage").init((0,0), (0,0), "", NineSlice.Create("SKILLBG9", (24, 17), (60, 45)));
        descriptionContainerBG.pinToParent(-8, 0, 8, 16);
        descriptionContainer.add(descriptionContainerBG);

        descriptionTitleLabel = new("UILabel").init((0, 450), (10, 40), "Title Label", "SEL46FONT");
        descriptionTitleLabel.scaleToHeight(35);
        descriptionTitleLabel.multiline = true;
        descriptionTitleLabel.pin(UIPin.Pin_Left);
        descriptionTitleLabel.pin(UIPin.Pin_Right);
        descriptionTitleLabel.pinHeight(UIView.Size_Min);
        descriptionTitleLabel.textColor = 0xFFFFFFFF;
        descriptionContainer.addManaged(descriptionTitleLabel);

        // Skill description
        descriptionLabel = new("UILabel").init((0, 450), (10, 40), "Description goes here.", "PDA18FONT", fontScale: (1, 1));
        descriptionLabel.multiline = true;
        descriptionLabel.pin(UIPin.Pin_Left);
        descriptionLabel.pin(UIPin.Pin_Right);
        descriptionLabel.pinHeight(UIView.Size_Min);
        descriptionLabel.verticalSpacing = 5;
        descriptionLabel.textColor = 0xFFEEEEEE;
        descriptionContainer.addManaged(descriptionLabel);
    }


    virtual void animateIn() {
        /*if(hasCalledFirstTick) {
            mainView.layout();
        } else {
            mainLayout.layout();
        }*/
        mainView.layout();

        // Animate everything in the container
        int cnt = 0;
        for(int x = 0; x < mainLayout.numManaged(); x++) {
            let v = TitleButton(mainLayout.getManaged(x));
            if(v) {
                v.setAlpha(0);
                v.animateIn(cnt * 0.03);
                cnt++;
                continue;
            }

            let view = mainLayout.getManaged(x);
            if(view is 'SkillSeperator' || view is 'UILabel' || view is 'UIHorizontalLayout' || view is 'UIVerticalLayout') {
                let xPos = 0;
                let leftPin = view.firstPin(UIPin.Pin_Left);
                if(leftPin) xPos = leftPin.offset;  // Cheating but whatever

                let anim = view.animateFrame(
                    0.12,
                    fromPos: (xPos, view.frame.pos.y),
                    toPos: (150 + xPos, view.frame.pos.y),
                    fromAlpha: 0,
                    toAlpha: 1,
                    ease: Ease_Out
                );

                anim.startTime += 0.03 * cnt;
                anim.endTime += 0.03 * cnt;
                cnt++;
            }
        }
        

        // Animate description container
        descriptionContainer.alpha = 0;
        let anim = descriptionContainer.animateFrame(
            0.12,
            fromPos: descriptionContainer.frame.pos + (150, 0),
            toPos: descriptionContainer.frame.pos,
            fromAlpha: 0,
            toAlpha: 1,
            ease: Ease_Out
        );

        anim.startTime += 0.22;
        anim.endTime += 0.22;


        // Refresh the selected control
        if(activeControl is 'TitleButton') {
            TitleButton(activeControl).animateToHover();
        }
    }


    virtual void animateOut() {
        animator.clear(descriptionContainer, cancelEach: false);
        animator.clearChildren(mainLayout, cancelEach: false);
        //mainView.layout();

        int cnt = 0;
        for(int x = 0; x < mainLayout.numManaged(); x++) {
            let v = TitleButton(mainLayout.getManaged(x));
            if(v) {
                v.animateOut(cnt * 0.018, 0.10);
                cnt++;
                continue;
            }

            let view = mainLayout.getManaged(x);
            if(view is 'SkillSeperator' || view is 'UILabel' || view is 'UIHorizontalLayout' || view is 'UIVerticalLayout') {
                let xPos = 0;
                let leftPin = view.firstPin(UIPin.Pin_Left);
                if(leftPin) xPos = leftPin.offset;  // Cheating but whatever

                let anim = view.animateFrame(
                    0.10,
                    toPos: (xPos, view.frame.pos.y),
                    toAlpha: 0,
                    ease: Ease_In
                );

                anim.startTime += 0.018 * cnt;
                anim.endTime += 0.018 * cnt;
                cnt++;
            }
        }


        // Animate description container
        let anim = descriptionContainer.animateFrame(
            0.12,
            toPos: descriptionContainer.frame.pos + (150, 0),
            toAlpha: 0,
            ease: Ease_In
        );

        anim.startTime += 0.08;
        anim.endTime += 0.08;

        if(masterMenu) {
            masterMenu.animateAwayHeaderLabel();
        }
    }


    virtual SkillMenuSub animateToNext(class<SkillMenuSub> cls, bool isRandomizer = false) {
        SkillMenuSub m = SkillMenuSub(new(cls));
        m.isRandomizer = isRandomizer || self.isRandomizer;
        m.init(self);
        m.masterMenu = masterMenu;
        nextMenu = m;
        animatingNext = true;
        animateOut();

        return m;
    }


    override void ticker() {
        Super.ticker();

        // Close menu when animating out
        if(animatingClosed && animator && !animator.isAnimating()) {
            let m = SkillMenuSub(uiParentMenu);
            if(m) {
                m.animateIn();
            }
            close();
        } else if(animatingNext && nextMenu && animator && !animator.isAnimating()) {
            nextMenu.activateMenu();
            nextMenu.animateIn();
            nextMenu = null;
            animatingNext = false;
        }
    }

    override void close() {
        if(masterMenu) masterMenu.background.removeGamepadFooterKey(InputEvent.Key_Pad_X);

        if(uiParentMenu && uiParentMenu is 'SkillMenuSub') {
            SkillMenuSub(uiParentMenu).animateIn();
        } 

        Super.close();
    }


    UIView addSeparator(string text, double vSpace = 60) {
        let separator = new("SkillSeperator").init((0,0), (190, vSpace));
        let spacerInner = new("UIView").init((5,vSpace - 10), (190, 2));
        spacerInner.backgroundColor = 0xFFDDDDDD;
        spacerInner.alpha = 0.7;
        separator.add(spacerInner);
        let spacerText = new("UILabel").init((5,0), (190, vSpace - 13), text, "PDA13FONT", 0xFFb3adad, textAlign: UIView.Align_Bottom);
        separator.add(spacerText);
        mainLayout.addManaged(separator);
        separator.alpha = 0;

        separator.pin(UIPin.Pin_Left);
        separator.pin(UIPin.Pin_Right);

        return separator;
    }


    virtual void calculateNavigation() {
        UIControl lastCon = null;
        UIControl firstCon = null;
        for(int x = 0; x < mainLayout.numManaged(); x++) {
            let con = UIControl(mainLayout.getManaged(x));
            if(con) {
                if(x > 0) {
                    if(lastCon) lastCon.navDown = con;
                    con.navUp = lastCon;
                }

                if(!firstCon) firstCon = con;
                lastCon = con;
            }
        }

        if(lastCon && firstCon && firstCon != lastCon) {
            lastCon.navDown = firstCon;
            firstCon.navUp = lastCon;
        }
    }


    void lockInterface(bool lock = true) {
        for(int x = 0; x < mainLayout.numManaged(); x++) {
            let c = UIButton(mainLayout.getManaged(x));
            if(c) {
                c.setDisabled(lock);
            }
        }
        if(lock) clearNavigation();
    }


    override bool navigateTo(UIControl con, bool mouseSelection) {
		let ac = activeControl;
        let ff = Super.navigateTo(con, mouseSelection);

        if(ac != activeControl && !mouseSelection && hasCalledFirstTick) {
            if(mouseSelection) {
                MenuSound("ui/cursor2");
            } else {
                MenuSound("menu/cursor");
            }
        }

        if(!mouseSelection) mainScroll.scrollTo(con, true, 40);
        
        return ff;
	}


    // Since there will always be a sub menu over the master menu, all sub menus have to be able to handle the top level fadeout
    override void drawSubviews() {
        Super.drawSubviews();

        if(masterMenu && masterMenu.startGameTime > 0.1 && masterMenu.startingGame && isTopMenu()) {
            Screen.ClearClipRect();
            Screen.dim(0xFF020202, (masterMenu.getRenderTime() - masterMenu.startGameTime) / masterMenu.startGameDelay, 0, 0, lastScreenSize.x, lastScreenSize.y);
        }
    }


    override bool onBack() {
        if(masterMenu && masterMenu.startingGame) return true;   // Prevent leaving when game is starting

        return Super.onBack();
    }
}


// Dummy class for identification
class SkillSeperator : UIView {}