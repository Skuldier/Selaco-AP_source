class SkillMenuSkill : SkillMenuSub {
    mixin CVARBUDDY;

    SkillMenuButton mutatorButt, skill2butt, smfButt, randomizerButt;
    UIVerticalLayout mutatorLayouts[6];
    UIVerticalLayout mutatorLayout;
    UIImage descriptionImage;

    Array<UILabel> mutatorLabels;

    int smfCount;

    const smallButtScale = 0.73;
    const smallButtSize = 36;

    override void init(Menu parent) {
        Super.init(parent);

        UIHelper.ResetNewGameOptions();
        if(isRandomizer) {
            iSetCVAR('g_randomizer', 1);
        }

        bool isSmallVert = mainView.frame.size.y < 900;

        // Skill icon image
        descriptionImage = new("UIImage").init((20,25), (300, 300), "BSKILL02", imgStyle: UIImage.Image_Scale);
        descriptionImage.pin(UIPin.Pin_VCenter, value: 1.0, offset: 5, isFactor: true);
        descriptionContainer.add(descriptionImage);

        // Move description text over to fit image
        descriptionContainer.padding.set(340, 20, 20, 20);

        addSeparator("Difficulty", 30);

        let skill0butt = new("SkillMenuButton").init(StringTable.Localize("$SKILL_0"), StringTable.Localize("$DIFF_ENSIGN"), 0);
        let skill1butt = new("SkillMenuButton").init(StringTable.Localize("$SKILL_1"), StringTable.Localize("$DIFF_LIEUTENANT"), 1);
        skill2butt = new("SkillMenuButton").init(StringTable.Localize("$SKILL_2"), StringTable.Localize("$DIFF_COMMANDER"), 2);
        let skill3butt = new("SkillMenuButton").init(StringTable.Localize("$SKILL_3"), StringTable.Localize("$DIFF_CAPTAIN"), 3);
        let skill4butt = new("SkillMenuButton").init(StringTable.Localize("$SKILL_4"), StringTable.Localize("$DIFF_ADMIRAL"), 4);

        mainLayout.addManaged(skill0butt);
        mainLayout.addManaged(skill1butt);
        mainLayout.addManaged(skill2butt);
        mainLayout.addManaged(skill3butt);
        mainLayout.addManaged(skill4butt);

        if(!isRandomizer) {
            // Add spacer
            addSeparator("Extra Difficulties");

            // Narrative Mode
            let narrButt = new("SkillMenuButton").init(StringTable.Localize("$SKILL_6"), StringTable.Localize("$DIFF_STORY"), 6);
            narrButt.label.fontScale = (smallButtScale, smallButtScale);
            narrButt.originalFontScale = (smallButtScale, smallButtScale);
            narrButt.heightPin.value = smallButtSize;
            mainLayout.addManaged(narrButt);

            // Selaco Must Fall
            smfButt = new("SkillMenuButton").init(StringTable.Localize("$SKILL_5"), StringTable.Localize("$DIFF_SMF"), 5);
            smfButt.label.fontScale = (smallButtScale, smallButtScale);
            smfButt.originalFontScale = (smallButtScale, smallButtScale);
            smfButt.heightPin.value = smallButtSize;

            // Check if SMF should be enabled
            // I did a stupid and made the completion flag g_hardboiled instead of something more obvious
            // Now we have to live with it.
            if(Globals.GetInt("g_hardboiled") <= 0 && Globals.GetInt("g_randomizer") <= 0 && Globals.GetInt("g_chapter1_complete") <= 0) {
                smfButt.isDisabledInMenu = true;
                smfButt.buttStates[UIButton.State_Normal].textColor = 0xAA999999;
                smfButt.buttStates[UIButton.State_Hover].textColor = 0xAA999999;
                smfButt.label.textColor = 0xAA999999;
            }

            mainLayout.addManaged(smfButt);
        }
        

        if(isRandomizer) {
            addSeparator("Randomizer");

            randomizerButt = new("SkillMenuButton").init(StringTable.Localize("$MENU_RANDOMIZER_CONFIGURE"), "", -2);
            //randomizerButt.label.fontScale = (smallButtScale, smallButtScale);
            //randomizerButt.originalFontScale = (smallButtScale, smallButtScale);
            //randomizerButt.heightPin.value = smallButtSize;
            mainLayout.addManaged(randomizerButt);
        }


        addSeparator("Mutators");

        mutatorButt = new("SkillMenuButton").init(StringTable.Localize("$SKILL_MUTATOR_ADD"), "", -1);
        mutatorButt.label.fontScale = (smallButtScale, smallButtScale);
        mutatorButt.originalFontScale = (smallButtScale, smallButtScale);
        mutatorButt.heightPin.value = smallButtSize;
        mainLayout.addManaged(mutatorButt);

        mainLayout.addSpacer(5);

        // Add mutator layout
        //mutatorLayout = new("UIHorizontalLayout").init((0,0), (100, 300));
        mutatorLayout = new("UIVerticalLayout").init((0,0), (100, 300));
        mutatorLayout.pin(UIPin.Pin_Left, offset: 15);
        mutatorLayout.pinHeight(UIView.Size_Min);
        mutatorLayout.pin(UIPin.Pin_Right, offset: -15);
        mutatorLayout.alpha = 0;
        mutatorLayout.hidden = true;
        mutatorLayout.layoutMode = UIViewManager.Content_SizeParent;
        mutatorLayout.ignoresClipping = true;
        mutatorLayout.clipsSubviews = false;
        //mutatorLayout.itemSpacing = 2;
        mainLayout.addManaged(mutatorLayout);
        
        /*let mlabel = new("UILabel").init((0,0), (100, 20), "Active Mutators:   ", 'PDA16FONT');
        mlabel.alpha = 0.95;
        mlabel.pinWidth(UIView.Size_Min);
        mlabel.pinHeight(UIView.Size_Min);
        mlabel.multiline = false;
        mutatorLayout.addManaged(mlabel);*/

        /*for(int x = 0; x < mutatorLayouts.size(); x++) {
            mutatorLayouts[x] = new("UIVerticalLayout").init((0,0), (200, 300));
            mutatorLayouts[x].layoutMode = UIViewManager.Content_SizeParent;
            mutatorLayouts[x].pinWidth(200);
            mutatorLayouts[x].clipsSubviews = false;
            mutatorLayouts[x].ignoresClipping = true;
            mutatorLayout.addManaged(mutatorLayouts[x]);
        }*/

        setSkill(2);

        updateSelectedMutators();

        calculateNavigation();
    }
    

    override void onFirstTick() {
        Super.onFirstTick();

        navigateTo(skill2butt);
    }


    void setSkill(int skill) {
        if(skill < 0) {
            descriptionContainer.hidden = true;
            return;
        }

        descriptionContainer.hidden = false;

        descriptionImage.setImage(String.Format("BSKILL0%d", skill));

        let skillText = StringTable.Localize("$SKILL_DESC_" .. skill);

        // Get the first line as the title
        Array<string> lines;
        skillText.split(lines, "\n");

        if(lines.size() > 1) {
            descriptionTitleLabel.setText(lines[0]);

            // Hello GC, I see you over there
            let s = lines[1];
            for(int x = 2; x < lines.size(); x++) s = s .. "\n" .. lines[x];
            descriptionLabel.setText(s);
        } else {
            descriptionTitleLabel.setText("");
            descriptionLabel.setText(skillText);
        }
        
        descriptionTitleLabel.textColor = skill >= 5 ? 0xFFb3adad : 0xFFFFFFFF;
    }


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(animatingClosed || animatingNext) return;

        if(event == UIHandler.Event_Activated) {
            let b = SkillMenuButton(ctrl);
            
            // Handle rapid press SMF button
            if(b && b.isDisabledInMenu) {
                if(ctrl == smfButt) {
                    smfCount++;

                    if(smfCount < 20) {
                        MenuSound("ui/buy/error");
                        return;
                    }
                } else {
                    MenuSound("ui/buy/error");
                    return;
                }
            }


            if(b && b.skill == -1) {
                // Open Mutator interface
                MenuSound("menu/advance");
                animateToNext("SkillMenuMutators");
                return;
            } else if(b && b.skill == -2) {
                // Open Randomizer configuration
                MenuSound("menu/advance");

                let prompt = new("OptionsPrompt").initNew(self, "RandomizerSettings", enableReset: true);
                prompt.ActivateMenu();
                return;
            }

            if(b && b.skill > -1) {
                // Tell master menu to start the game with the selected skill
                if(masterMenu) {
                    lockInterface();
                    MenuSound("ui/startgame");
                    masterMenu.skillSelected(b.skill);
                }

                return;
            }
        }

        // Special case for catching selections
        if(event == UIHandler.Event_Alternate_Activate && hasCalledFirstTick) {
            let b = SkillMenuButton(ctrl);

            if(b) {
                setSkill(b.skill);
                return;
            }
        }
    }


    override void animateIn() {
        updateSelectedMutators();

        Super.animateIn();

        if(masterMenu) {
            masterMenu.animateHeaderLabel(isRandomizer ? StringTable.Localize("$SKILL_HEADER_RANDOMIZER") : StringTable.Localize("$SKILL_HEADER"));
        }
    }


    void updateSelectedMutators() {
        // Remove mutator labels
        /*for(int x = 0; x < mutatorLabels.size(); x++) {
            UIVerticalLayout lay = UIVerticalLayout(mutatorLabels[x].parent);
            if(lay) lay.removeManaged(mutatorLabels[x]);
        }*/
        mutatorLayout.clearManaged();
        mutatorLabels.clear();

        bool anyMutators = false;

        let menuDescriptor = OptionMenuDescriptor(MenuDescriptor.GetDescriptor("NewGameSettings"));
        if(menuDescriptor) {
            for(int x = 0; x < menuDescriptor.mItems.size(); x++) {
                if(menuDescriptor.mItems[x] is 'OptionMenuItemTooltipSlider') {
                    let tts = OptionMenuItemTooltipSlider(menuDescriptor.mItems[x]);
                    if(tts.getSlidervalue() > 0) {
                        anyMutators = true;
                        addMutator(StringTable.Localize(tts.mLabel));
                    }
                } else if(menuDescriptor.mItems[x] is 'OptionMenuItemTooltipOption') {
                    let tto = OptionMenuItemTooltipOption(menuDescriptor.mItems[x]);
                    if(tto.getSelection() > 0) {
                        anyMutators = true;
                        addMutator(StringTable.Localize(tto.mLabel));
                    }
                }
            }
        }

        mutatorLayout.hidden = !anyMutators;
        mutatorButt.label.setText(StringTable.Localize(anyMutators ? "$SKILL_MUTATOR_CHANGE" : "$SKILL_MUTATOR_ADD"));
    }


    void addMutator(string text, bool isFirst = false) {
        let lab = new("UILabel").init((0,0), (100, 24), isFirst ? text : ("- " .. text), 'PDA16FONT');
        lab.alpha = 0.65;
        lab.pin(UIPin.Pin_Left);
        lab.pin(UIPin.Pin_Right);
        lab.pinHeight(24);
        lab.multiline = false;
        lab.autoScale = true;
        mutatorLabels.push(lab);

        /*for(int x = mutatorLayouts.size() - 1; x >= 0; x--) {
            if(mutatorLayouts[x].numManaged() > 2) continue;

            mutatorLayouts[x].addManaged(lab);
        }*/
        mutatorLayout.addManaged(lab);
    }
}


// Used in main menu to just open the OptionsPrompt
class RandomizerConfigMenu : UIMenu {
   override void Init(Menu parent) {
        Super.Init(parent);

        isModal = true;
    }

    override void onFirstTick() {
        Super.onFirstTick();

        let prompt = new("OptionsPrompt").initNew(self, "RandomizerSettings", true);
        prompt.ActivateMenu();
    }

    override void ticker() {
        Super.ticker();

        animated = true;

        if(isTopMenu() && hasCalledFirstTick) {
            close();
        }
    }
}