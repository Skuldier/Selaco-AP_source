class CreditsMenu : SelacoGamepadMenu {
    UIVerticalLayout lay;
    UIPin layTop;
    double scrollMultiplier, manScrollOffset;
    double scrollSpeed;
    double dimStart;
    double deltaTime, startTime;
    double topStart;
    
    double gamepadLook;

    double darkness;

    bool ending, handledCreditsOver, opening;

    const SCROLL_SPEED = 1.25;
    const SCROLL_SPEEDUP = 0.1;
    const SCROLL_SPEEDUP_MENU = 0.25;

    override void init(Menu parent) {
		Super.init(parent);
        mouseMovementShowsCursor = false;
        allowDimInGameOnly();
        
        animated = true;

        scrollMultiplier = 1;
        topStart = !(self is 'EndGameCreditsMenu') ? 400 : mainView.frame.size.y; // The offset that scrolling starts from
        scrollSpeed = SCROLL_SPEED;

        lay = new("UIVerticalLayout").init((0,0), (0, 0));
        layTop = lay.pin(UIPin.Pin_Top, UIPin.Pin_Top, 0, topStart);
        lay.pin(UIPin.Pin_Left, offset: 100);
        lay.pin(UIPin.Pin_Right, offset: -100);
        lay.layoutMode = UIViewManager.Content_SizeParent;
        lay.raycastTarget = false;
        lay.alpha = (self is 'EndGameCreditsMenu') ? 1 : 0;
        mainView.add(lay);

        darkness = 0.85;

        let menuDescriptor = ListMenuDescriptor(MenuDescriptor.GetDescriptor("CreditsList"));
        if(menuDescriptor) {
            addCredits(menuDescriptor);
        }

        dimStart = getRenderTime();
        deltaTime = getRenderTime();
        startTime = getRenderTime();

        hideCursor(true);
	}

    override void onFirstTick() {
        hideCursor(true);

        if(!(self is 'EndGameCreditsMenu')) {
            lay.animateFrame(0.65, toAlpha: 1.0);
        } else {
            lay.alpha = 1;
        }
    }

    void addCreditImg(ListMenuItemStaticPatch patch) {
        let img = new("UIImage").initTex((0,0), (0,400), patch.mTexture, imgStyle: UIImage.Image_Aspect_Fit);
        img.pin(UIPin.Pin_Left);
        img.pin(UIPin.Pin_Right);
        img.heightPin = UIPin.Create(0,0,UIView.Size_Min);
        lay.addManaged(img);
    }

    void addCredits(ListMenuDescriptor desc) {
        for(int x = 0; x < desc.mItems.size(); x++) {
            if(desc.mItems[x] is 'ListMenuItemCredit') {
                AddCredit(ListMenuItemCredit(desc.mItems[x]));
                continue;
            }
            
            ListMenuItemTextItem it = ListMenuItemTextItem(desc.mItems[x]);
            if(!it) {
                ListMenuItemStaticPatch patch = ListMenuItemStaticPatch(desc.mItems[x]);
                if(patch) { addCreditImg(patch); }
                continue;
            }

            string act = String.Format("%s", it.getAction());
            if(act != "") {
                let v = new("UIView").init((0,0), (0,30));
                v.pin(UIPin.Pin_Left);
                v.pin(UIPin.Pin_Right);


                let item = new("UILabel").init((0,0), (0,0), StringTable.Localize(it.mText), it.mFont, it.mColor, UIView.Align_Right | UIView.Align_Middle);
                item.heightPin = UIPin.Create(UIPin.Pin_Static, value: 30);
                item.pin(UIPin.Pin_Right, value: 0.5, -10, true);
                item.pin(UIPin.Pin_Left);

                v.add(item);

                item = new("UILabel").init((0,0), (0,0), StringTable.Localize(act), it.mFont, it.mColorSelected, UIView.Align_Left | UIView.Align_Middle);
                item.heightPin = UIPin.Create(UIPin.Pin_Static, value: 30);
                item.pin(UIPin.Pin_Left, UIPin.Pin_Right, value: 0.5, 10, true);
                item.pin(UIPin.Pin_Right);
                v.add(item);

                lay.addManaged(v);

            } else {
                if(it.mText == "") {
                    let item = new("UIView").init((0,0), (1, 30));
                    item.minSize = (1, 30);
                    lay.addManaged(item);
                } else {
                    let item = new("UILabel").init((0,0), (0,0), StringTable.Localize(it.mText), it.mFont, it.mColor, UIView.Align_Centered);
                    item.heightPin = UIPin.Create(UIPin.Pin_Static, value: 30);
                    item.pin(UIPin.Pin_Right);
                    item.pin(UIPin.Pin_Left);

                    lay.addManaged(item);
                }
                
            }
        }        
    }


    void addCredit(ListMenuItemCredit it) {
        if(it.mText[0] == "") {
            let item = new("UIView").init((0,0), (1, 30));
            item.minSize = (1, 30);
            lay.addManaged(item);
        } else {
            int numLines = 4;
            for(; it.mText[numLines - 1] == "" && numLines > 0; numLines--);
            let v = new("UIView").init((0,0), (0,30));
            v.pin(UIPin.Pin_Left);
            v.pin(UIPin.Pin_Right);

            if(numLines == 2) {
                let item = new("UILabel").init((0,0), (0,0), StringTable.Localize(it.mText[0]), it.mFont, it.mColor, UIView.Align_Right | UIView.Align_Middle);
                item.pinHeight(30);
                item.pin(UIPin.Pin_Right, value: 0.5, -10, true);
                item.pin(UIPin.Pin_Left);

                v.add(item);

                item = new("UILabel").init((0,0), (0,0), StringTable.Localize(it.mText[1]), it.mFont, it.mColor2, UIView.Align_Left | UIView.Align_Middle);
                item.pinHeight(30);
                item.pin(UIPin.Pin_Left, UIPin.Pin_Right, value: 0.5, 10, true);
                item.pin(UIPin.Pin_Right);
                v.add(item);
            } else {
                double eachX = (0.65 / double(numLines)) * 2;
                double pX = 1.0 + (-eachX * (double(numLines - 1) / 2.0));

                for(int x = 0; x < numLines; x++) {
                    let item = new("UILabel").init((0,0), (0,0), StringTable.Localize(it.mText[x]), it.mFont, it.mColor, UIView.Align_Centered);
                    item.pin(UIPin.Pin_Top);
                    item.pin(UIPin.Pin_Bottom);
                    item.pin(UIPin.Pin_HCenter, UIPin.Pin_HCenter, value: pX, isFactor: true);
                    item.pinWidth(UIView.Size_Min);
                    item.multiline = false;
                    pX += eachX;

                    v.add(item);
                }
            }

            lay.addManaged(v);
        }
    }


    override void ticker() {
        Super.ticker();
        animated = true;

        let look = getGamepadRawLook();
        gamepadLook = look.y;

        if(!ending && lay.frame.pos.y + lay.frame.size.y < 100) {
            dimStart = getRenderTime();
            ending = true;
        }

        if(lay.frame.pos.y + lay.frame.size.y < -200 && !handledCreditsOver) {
            handledCreditsOver = true;

            // Close the menu after credits finish rolling
            handleCreditsOver();
        }
    }

    virtual void handleCreditsOver() {
        Close();
    }

    override void drawSubviews() {
        double time = getRenderTime();
        double te = time - deltaTime;
        deltaTime = time;
        
        double dim;

        if(ending) {
            dim = (1.0 - ((time - dimStart) / 3.0)) * darkness;
        } else {
            dim = MIN((time - dimStart) / 0.35, 1.0) * darkness;
        }

        let smul = scrollMultiplier;

        if(gamepadLook > 0.05) smul = 1.0 - (gamepadLook * 0.85);
        else if(gamepadLook < -0.05) smul = 1.0 + (-gamepadLook * 1.7);
        
        if(startTime != 0) manScrollOffset += te * smul;

        Screen.dim(0xFF020202, dim, 0, 0, lastScreenSize.x, lastScreenSize.y);

        if(startTime != 0) {
            layTop.offset = topStart - (scrollSpeed * (time - startTime + manScrollOffset) * 35.0);
            lay.frame.pos.y = layTop.offset;
        }

        Super.drawSubviews();
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
		return Super.MenuEvent(mkey, fromcontroller);
	}

    override bool onUIEvent(UIEvent ev) {
		if (ev.type == UIEvent.Type_LButtonDown) {
			scrollMultiplier = 0.11;
            return true;
		} else if(ev.type == UIEvent.Type_LButtonUp) {
            scrollMultiplier = 1;
            return true;
        } else if(ev.type == UIEvent.Type_RButtonDown) {
            scrollMultiplier = 3.7;
            return true;
        } else if(ev.type == UIEvent.Type_RButtonUp) {
            scrollMultiplier = 1.0;
            return true;
        }

		return Super.onUIEvent(ev);
	}
}


class EndGameCreditsMenu : CreditsMenu {
    UILabel thanksLabel, thanksLabel2, escLabel;
    UIImage tutImage;
    Array<UIViewAnimation> unlockAnimations;
    int escCounter, lastEscTicks;
    float curMusVolume;
    bool playingKickassMusic;
    bool closeAllowed, closing;

    bool unlockedHardboiled, unlockedSpecialCampaign, unlockedBottomlessMags;

    const ESC_COUNT = 3;

    static const string tuts[] = {
        "ARMOR1",
        "TUTBIPO1",
        "HUGGER1",
        "TUTFIRE1",
        "TUTTRAN1",
        "CODEX1",
        "SHOP1",
        "HACKING1",
        "MELEE1"
    };

    override void init(Menu parent) {
        Super.init(parent);

        scrollSpeed = 0.985;
        darkness = 1.0;
        
        // Tell HUD to shut up
        let h = HUD(StatusBar);
        if(h) {
            h.isMuted = true;
        }

        thanksLabel = new("UILabel").init((0,0), (500, 40), "Thanks for playing!", 'K22FONT', textAlign: UIView.Align_Centered);
        thanksLabel.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        thanksLabel.pin(UIPin.Pin_VCenter, value: 1.0, offset: 50, isFactor: true);
        thanksLabel.alpha = 0;

        thanksLabel2 = new("UILabel").init((0,0), (500, 40), "\c[HI][Press any key to continue]", 'PDA13FONT', textAlign: UIView.Align_Centered);
        thanksLabel2.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        thanksLabel2.pin(UIPin.Pin_Bottom, value: 1.0, offset: -120, isFactor: true);
        thanksLabel2.alpha = 0;

        escLabel = new("UILabel").init((0,0), (20, 40), "Press BACK (2) more times...", 'PDA18FONT');
        escLabel.pin(UIPin.Pin_Right, value: 1.0, offset: -62, isFactor: true);
        escLabel.pin(UIPin.Pin_Bottom, value: 1.0, offset: -62, isFactor: true);
        escLabel.pinWidth(UIView.Size_Min);
        escLabel.pinHeight(UIView.Size_Min);
        escLabel.multiline = false;
        escLabel.alpha = 0;
        mainView.add(escLabel);

        tutImage = new("UIImage").init((0,0), (150, 150), "TUTFIRE1");
        tutImage.pinWidth(UIView.Size_Min);
        tutImage.pinHeight(UIView.Size_Min);
        tutImage.alpha = 0;
        tutImage.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        tutImage.pin(UIPin.Pin_VCenter, value: 0.65, isFactor: true);
        mainView.add(tutImage);

        mainView.add(thanksLabel);
        mainView.add(thanksLabel2);

        curMusVolume = 1.0;
        playingKickassMusic = false;

        opening = true;
    }

    override void onFirstTick() {
        if(unlockedBottomlessMags || unlockedHardboiled || unlockedSpecialCampaign) {
            opening = true;
            startTime = 0;

            addOpeningAnimations();
        } else {
            opening = false;
        }
    }

    override bool onBack() {
        if(closeAllowed && !closing && !opening) {
            Close();
            Level.ReturnToTitle();
            //closing = true;
            //addClosingAnimations();
        }

        return true;   // Can't skip end game credits without countdown
    }

    override void ticker() {
        Super.ticker();

        if(ticks == 1) {
            let anim = tutImage.animateFrame(
                3.0,
                toAlpha: 1.0,
                ease: Ease_In
            );
            anim.startTime += 60 * 3;
            anim.endTime += 60 * 3;
        }

        if(escCounter >= ESC_COUNT && !closing && !opening) {
            Close();
            Level.ReturnToTitle();
            /*closing = true;
            addClosingAnimations();*/

            return;
        }

        /*if(closing) {
            bool okToClose = true;
            foreach(anim : unlockAnimations) {
                if(anim.checkValid(getTime())) {
                    okToClose = false;
                    break;
                }
            }

            if(okToClose) {
                Close();
                Level.ReturnToTitle();
            }
        }*/

        if(opening) {
            bool doneOpening = true;
            foreach(anim : unlockAnimations) {
                if(anim.checkValid(getTime())) {
                    doneOpening = false;
                    break;
                }
            }

            if(doneOpening) {
                startTime = getRenderTime();
                opening = false;
            }
        }

        if(ticks - lastEscTicks > (35 * 2.5)) {
            escCounter = 0;
        }

        if(!playingKickassMusic) {
            if(curMusVolume <= 0 && !opening) {
                playingKickassMusic = true;
                S_ChangeMusic("SAFEROOM", looping: false, force: true);
            } else if(curMusVolume > 0) {
                curMusVolume = MAX(curMusVolume - 0.05, 0);
                SetMusicVolume(curMusVolume);
            }
        } else if(curMusVolume < Level.MusicVolume) {
            curMusVolume = MIN(curMusVolume + 0.06, Level.MusicVolume);
            SetMusicVolume(curMusVolume);
        }

        int tutCTicks = 35 * 60 * 3 + (35 * 4);
        if(ticks >= tutCTicks && (ticks - tutCTicks) % (35 * 4) == 0) {
            tutImage.setImage(tuts[random(0, tuts.size() - 1)]);
            tutImage.requiresLayout = true;
        }
    }

    override bool onUIEvent(UIEvent ev) {
        // Cheat shortcut: CTRL+SHIFT+ALT+TAB
        if(!closing && !opening && (ev.type == UIEvent.Type_KeyDown || ev.type == UIEvent.Type_Char) && ev.IsShift && ev.IsCtrl && ev.keyChar == UIEvent.Key_Tab) {
            manScrollOffset = lay.frame.size.y;
            MenuSound("menu/advance");
        }

        if(closeAllowed) {
            switch(ev.type) {
                case UIEvent.Type_KeyDown:
                case UIEvent.Type_LButtonDown:
                case UIEvent.Type_RButtonDown:
                    onBack();
                    return true;
                    break;
                default:
                    break;
            }
        }

        if (ev.type == UIEvent.Type_LButtonDown) {
			scrollMultiplier = 0.15;
            return true;
		} else if(ev.type == UIEvent.Type_LButtonUp) {
            scrollMultiplier = 1;
            return true;
        } else if(ev.type == UIEvent.Type_RButtonDown) {
            scrollMultiplier = 2.7;
            return true;
        } else if(ev.type == UIEvent.Type_RButtonUp) {
            scrollMultiplier = 1.0;
            return true;
        }

		return Super.onUIEvent(ev);
	}
    

    void addUnlockAnim(string text, out double timeOffset) {
        let col = 0xFFFAD364;

        let unlockLabel = new("UILabel").init((0,0), (500, 40), text, 'K32FONT', textColor: 0xFFFAD364, textAlign: UIView.Align_Centered);
        //unlockLabel.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        unlockLabel.pin(UIPin.Pin_Left, offset: 80);
        unlockLabel.pin(UIPin.Pin_Right, offset: -80);
        unlockLabel.pin(UIPin.Pin_VCenter, value: 1.0, offset: 50, isFactor: true);
        unlockLabel.alpha = 0;
        mainView.add(unlockLabel);

        let anim = unlockLabel.animateFrame(
            0.25,
            toAlpha: 1.0,
            ease: Ease_Out
        );
        anim.startTime += timeOffset;
        anim.endTime += timeOffset;
        anim.startSound = "ACHIEV";

        let labanim = unlockLabel.animateLabel(
            0.25,
            fromScale: (1.5, 1.5),
            toScale: unlockLabel.fontScale,
            ease: Ease_Out
        );
        labanim.startTime += timeOffset;
        labanim.endTime += timeOffset;

        let anim2 = unlockLabel.animateFrame(
            0.15,
            fromAlpha: 1.0,
            toAlpha: 0.0,
            ease: Ease_In
        );
        anim2.startTime += timeOffset + 2.0;
        anim2.endTime += timeOffset + 2.0;

        labanim = unlockLabel.animateLabel(
            0.15,
            fromScale: unlockLabel.fontScale,
            toScale: unlockLabel.fontScale * 0.95,
            ease: Ease_Out
        );
        labanim.startTime += timeOffset + 2.0;
        labanim.endTime += timeOffset + 2.0;

        timeOffset += 3.0;

        unlockAnimations.push(anim2);
    }

    void addOpeningAnimations() {
        StatTracker cheats = Stats.FindTracker(STAT_YOUCHEATED);
        double timeOffset = 1.5;

        // Hide thanks labels if they are up
        /*double oldAlpha = thanksLabel.alpha;
        animator.clear(thanksLabel);
        thanksLabel.animateFrame(
            0.15,
            fromAlpha: oldAlpha,
            toAlpha: 0.0,
            ease: Ease_In
        );
        
        oldAlpha = thanksLabel2.alpha;
        animator.clear(thanksLabel2);
        thanksLabel2.animateFrame(
            0.15,
            fromAlpha: oldAlpha,
            toAlpha: 0.0,
            ease: Ease_In
        );

        // Hide dawn pic if its up
        oldAlpha = tutImage.alpha;
        animator.clear(tutImage);
        tutImage.animateFrame(
            0.15,
            fromAlpha: oldAlpha,
            toAlpha: 0.0,
            ease: Ease_In
        );

        lay.animateFrame(
            0.5,
            toAlpha: 0.0,
            ease: Ease_In
        );*/

        //if(!sv_cheats && cheats.value == 0 && Globals.GetInt("g_hardboiled") == 0 && skill > 2 && skill < 6) {
        if(unlockedHardboiled) {
            addUnlockAnim(StringTable.Localize("$HARDBOILED_UNLOCKED"), timeOffset);
        }

        //if(!sv_cheats && cheats.value == 0 && Globals.GetInt("g_randomizer") == 0) {
        if(unlockedSpecialCampaign) {
            addUnlockAnim(StringTable.Localize("$RANDOMIZER_UNLOCKED"), timeOffset);
        }

        if(unlockedBottomlessMags) {
            addUnlockAnim(StringTable.Localize("$MAGS_UNLOCKED"), timeOffset);
        }
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(mkey == MKEY_Back && !closeAllowed && !closing && !opening) {
            escCounter++;
            escLabel.setText(String.Format("Press BACK (%d) more times...", ESC_COUNT - escCounter));

            animator.clear(escLabel);
            escLabel.animateFrame(
                3.0,
                fromAlpha: 1,
                toAlpha: 0,
                ease: Ease_Out
            );

            lastEscTicks = ticks;

            return true;
        } else if(mkey == MKEY_BACK && closeAllowed && !closing) {
            //closing = true;
            //addClosingAnimations();
            Close();
            Level.ReturnToTitle();

            return true;
        }

        return Super.MenuEvent(mkey, fromcontroller);
    }

    override void handleCreditsOver() {
        closeAllowed = true;
        
        // Animate ThanksLabel into view
        thanksLabel.animateFrame(
            1.25,
            fromAlpha: 0,
            toAlpha: 1.0,
            ease: Ease_In
        );

        let anim = thanksLabel2.animateFrame(
            1.0,
            fromAlpha: 0,
            toAlpha: 1.0,
            ease: Ease_In
        );

        anim.startTime += 3.0;
        anim.endTime += 3.0;

        //Level.ReturnToTitle();
    }


    override void drawSubviews() {
        Screen.dim(0xFF000000, 1.0, 0, 0, lastScreenSize.x, lastScreenSize.y);
        Super.drawSubviews();
    }
}


class ListMenuItemCredit : ListMenuItem {
    String mText[4];
    Font mFont;
	int mColor;
    int mColor2;

    void Init(ListMenuDescriptor desc, String t1, String t2 = "", String t3 = "", String t4 = "") {
		Super.Init(0, 0);
		mFont = desc.mFont;
		mColor = desc.mFontColor;
        mColor2 = desc.mFontcolor2;
		
        mText[0] = t1;
        mText[1] = t2;
        mText[2] = t3;
        mText[3] = t4;
	}
}