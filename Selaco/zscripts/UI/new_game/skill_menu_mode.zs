class SkillMenuMode : SkillMenuSub {
    SkillMenuButton newCampaignButton, newRandomizerButton, incursionButton;
    UIImage descriptionImage;

    override void init(Menu parent) {
        Super.init(parent);


        // Skill icon image
        descriptionImage = new("UIImage").init((20,25), (300, 300), "GAMODE01", imgStyle: UIImage.Image_Scale);
        descriptionImage.pin(UIPin.Pin_VCenter, value: 1.0, offset: 5, isFactor: true);
        descriptionContainer.add(descriptionImage);

        // Move description text over to fit image
        descriptionContainer.padding.set(340, 20, 20, 20);

        // Create mode buttons
        newCampaignButton = new("SkillMenuButton").init(StringTable.Localize("$MENU_STANDARD_CAMPAIGN"), StringTable.Localize("$DESCRIPTION_STANDARD_CAMPAIGN"), 1);
        newRandomizerButton = new("SkillMenuButton").init(StringTable.Localize("$MENU_RANDOMIZER_CAMPAIGN"), StringTable.Localize("$DESCRIPTION_RANDOMIZER_CAMPAIGN"), 2);
        incursionButton = new("SkillMenuButton").init(StringTable.Localize("$MENU_INCURSION_CAMPAIGN"), StringTable.Localize("$DESCRIPTION_INCURSION_CAMPAIGN"), 3);
        incursionButton.isDisabledInMenu = true;
        
        newRandomizerButton.isDisabledInMenu = Globals.GetInt("g_randomizer") == 0 && Globals.GetInt("g_hardboiled") == 0;

        if(newRandomizerButton.isDisabledInMenu) {
            newRandomizerButton.buttStates[UIButton.State_Normal].textColor = 0xAA999999;
            newRandomizerButton.buttStates[UIButton.State_Hover].textColor = 0xAA999999;
            newRandomizerButton.label.textColor = 0xAA999999;
        }

        incursionButton.buttStates[UIButton.State_Normal].textColor = 0xAA999999;
        incursionButton.buttStates[UIButton.State_Hover].textColor = 0xAA999999;
        incursionButton.label.textColor = 0xAA999999;

        addSeparator("Campaign");
        mainLayout.addManaged(newCampaignButton);
        mainLayout.addManaged(newRandomizerButton);

        addSeparator("Instant Action");
        mainLayout.addManaged(incursionButton);

        calculateNavigation();
        navigateTo(newCampaignButton);
    }
    

    override void onFirstTick() {
        Super.onFirstTick();
    }


    override void handleControl(UIControl ctrl, int event, bool fromMouseEvent, bool fromController) {
        if(animatingClosed || animatingNext) return;

        if(event == UIHandler.Event_Activated) {
            let b = SkillMenuButton(ctrl);

            if(b && b.isDisabledInMenu) {
                MenuSound("ui/buy/error");
                return;
            }

            if(b == newCampaignButton || b == newRandomizerButton) {
                MenuSound("menu/advance");

                animateToNext("SkillMenuSkill", b == newRandomizerButton);
                return;
            }
        }

        if(event == UIHandler.Event_Alternate_Activate) {
            let b = SkillMenuButton(ctrl);

            if(b) {
                let itemText = b.description;

                // Get the first line as the title
                Array<string> lines;
                itemText.split(lines, "\n");

                if(lines.size() > 1) {
                    descriptionTitleLabel.setText(lines[0]);
                    let s = lines[1];
                    for(int x = 2; x < lines.size(); x++) s = s .. "\n" .. lines[x];
                    descriptionLabel.setText(s);
                } else {
                    descriptionTitleLabel.setText("");
                    descriptionLabel.setText(itemText);
                }

                // Set image
                descriptionImage.setImage(String.Format("GAMODE0%d", b.skill));

                return;
            }
        }
    }

    override void animateIn() {
        Super.animateIn();

        if(masterMenu) {
            masterMenu.animateHeaderLabel("Campaign Type");
        }
    }


    override bool onBack() {
        if(masterMenu && (masterMenu.startingGame || masterMenu.fadingOut)) return true;   // Prevent leaving when game is starting or fading out

        if(masterMenu) {
            lockInterface();
            masterMenu.animateClosed();
        } else {
            return false;
        }

        return true;
    }
}


