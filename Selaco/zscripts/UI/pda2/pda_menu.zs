#include "ZScripts/UI/pda2/scroll_bg.zs"
#include "ZScripts/UI/pda2/tooltip.zs"
#include "ZScripts/UI/pda2/tabs.zs"
#include "ZScripts/UI/pda2/app_window.zs"
#include "ZScripts/UI/pda2/reader.zs"
#include "ZScripts/UI/pda2/stat_windows.zs"
#include "ZScripts/UI/pda2/stat_wind_norm.zs"
#include "ZScripts/UI/pda2/stat_reader.zs"
#include "ZScripts/UI/pda2/invasion_tiers.zs"
#include "ZScripts/UI/pda2/objectives.zs"
#include "ZScripts/UI/pda2/challenges_window.zs"

enum PDA_APP_ID {
    PDA_APP_READER      = 1,
    PDA_APP_STATS       = 2,
    PDA_APP_MAP         = 3,
    PDA_APP_INVASION    = 4,
    PDA_APP_BORGIR      = 5,
    PDA_APP_OBJECTIVES  = 6,
    PDA_APP_CHALLENGES  = 7,
    PDA_APP_COUNT
}

class PDAMenu3 : SelacoGamepadMenu {
    mixin CVARBuddy;

    UIScrollBG background;
    UIView innerView, desktopView;
    UIVerticalLayout sidebarView;
    UIImage aceLogo;
    UILabel footerLabel, timeLabel, mapLabel;
    
    double logoTime;

    ResourceView creditsView, partsView, saferoomsView, clearancesView;
    PDATab readerButt, mapButt, statsButt, tiersButt, manualButt, objectivesButt;
    UIButton readerIcon, burgerIcon;
    PDAReaderWindow readerWindow;
    StatReaderWindow statsWindow;
    PDAInvasionWindow invasionWindow;
    ObjectivesWindow objectiveWindow;
    PDAChallengesWindow mapWindow;
    PDAAppWindow currentAppWindow;

    double dimStart, closeStart;
    int currentApp;
    bool hasChangedAppsThisTick;
    
    //int codexKey1, codexKey2;
    Array<int> codexKeys, rawBackKeys;

    float targetMusicVolume, curMusicVolume, musicVolumeSteps;

    const CLOSE_TIME = 0.15;
    static const class<PDAAppWindow> APP_CLASSES[] = {
        null,
        'PDAReaderWindow',
        'StatReaderWindow',
        null,
        'PDAInvasionWindow',
        'BBWindow',
        'ObjectivesWindow',
        'PDAChallengesWindow'
    };


    override void init(Menu parent) {
        bool usingGP = InputHandler.Instance().isUsingGamepad;

        ReceiveAllInputEvents = true;
        DontDim = true;
        DontBlur = false;
        closeStart = 0;
        menuActive = Menu.OnNoPause;
        curMusicVolume = Level.MusicVolume;
        targetMusicVolume = Level.MusicVolume * 0.25;
        musicVolumeSteps = (Level.MusicVolume - targetMusicVolume) / 15.0;


        Super.init(parent);

        MenuSound("codex/open");

        Bindings.GetAllKeysForCommand(rawBackKeys, "codex");
        for(int x =0; x < rawBackKeys.size(); x++) {
            codexKeys.push(UIHelper.GetUIKey(rawBackKeys[x]));
        }

        //calcScale(Screen.GetWidth(), Screen.GetHeight());

        innerView = new("UIView").init((0,0), (100, 100));
        innerView.pin(UIPin.Pin_Top);
        innerView.pin(UIPin.Pin_Bottom);
        innerView.pin(UIPin.Pin_HCenter, value: 1.0, isFactor: true);
        innerView.maxSize.x = 1920;
        innerView.pinWidth(1.0, isFactor: true);
        innerView.alpha = 0;
        mainView.add(innerView);
        
        
        background = new("UIScrollBG").init("graphics/pda/grid1.png", NineSlice.Create("graphics/pda/mainFrameInner.png", (70, 70), (572, 343)));
        innerView.add(background);
        
        if(usingGP) {
            background.force = (-0.4, 0.4);
        }

        let bgFrame = new("UIImage").init((0,0), (100,100), "", NineSlice.Create("graphics/pda/mainFrameOuter.png", (13, 13), (87, 87), drawCenter: false));
        bgFrame.pinToParent();
        innerView.add(bgFrame);

        aceLogo = new("UIImage").init((0,0), (100,100), "graphics/pda/logo.png", imgStyle: UIImage.Image_Aspect_Fit);
        aceLogo.pin(UIPin.Pin_Left, UIPin.Pin_Right, value: 0.05, isFactor: true);
        aceLogo.pinWidth(0.35, isFactor: true);
        aceLogo.pinHeight(0.5, isFactor: true);
        aceLogo.pin(UIPin.Pin_Bottom, value: 0.9, isFactor: true);
        innerView.add(aceLogo);

        let bgFrame2 = new("UIImage").init((0,0), (100,100), "", NineSlice.Create("PDAOUTLN", (363, 91), (380, 106), drawCenter: false));
        bgFrame2.pinToParent(15, 51, -15, -15);
        innerView.add(bgFrame2);

        timeLabel = new("UILabel").init((15,75+20), (223 + 50, 33), "00:00:00", "SEL16FONT", 0xFF7985A5, UIView.Align_Right | UIView.Align_Middle);
        timeLabel.multiline = false;
        timeLabel.monospace = true;
        innerView.add(timeLabel);

        mapLabel = new("UILabel").init((15,75), (223 + 50, 33), UIHelper.GetShortLevelName(Level.LevelName), "SEL21FONT", textAlign: UIView.Align_Right | UIView.Align_Middle, fontScale: (0.80, 0.80));
        mapLabel.multiline = false;
        innerView.add(mapLabel);
        


        // Footer label mostly for flavour, probably won't show any real data
        footerLabel = new("UILabel").init((0,0), (600, 40), "1.21GW Free       SYSVER 2.0.1 - ROOTKIT DEHackED  0.996a", "SEL14FONT", 0xFF7987A6, UIView.Align_Middle | UIView.Align_Right);
        footerLabel.multiline = false;
        footerLabel.pin(UIPin.Pin_Bottom, offset: -15);
        footerLabel.pin(UIPin.Pin_Right, offset: -30);
        innerView.add(footerLabel);


        desktopView = new("UIView").init((0,0), (100, 100));
        desktopView.pinToParent(35 + 250 + 20, 53, -(17 + 20), -60);
        innerView.add(desktopView);

        sidebarView = new("UIVerticalLayout").init((0,0), (250, 100));
        sidebarView.pin(UIPin.Pin_Left, offset: 15 + 20);
        sidebarView.pin(UIPin.Pin_Top, offset: 136);
        sidebarView.pin(UIPin.Pin_Bottom, offset: -60);
        innerView.add(sidebarView);


        // Add app icons if needed
        let burgerItem = BBItem.Find();
        if(burgerItem) {
            // Add burger icon to the desktop
            burgerIcon = new("UIButton").init(
                (110, 110), (105, 105),
                "Burger Flipper",
                "PDA7FONT",
                UIButtonState.Create("BBICON01"),
                hover: UIButtonState.Create("BBICON01"),
                pressed: UIButtonState.Create("BBICON01"),
                disabled: UIButtonState.Create("BBICON01"),
                textAlign: UIView.Align_Center | UIView.Align_Bottom
            );
            burgerIcon.clipsSubviews = false;
            burgerIcon.setTextPadding(-100, 0, -100, -10);
            burgerIcon.label.drawShadow = true;
            burgerIcon.doubleClickEnabled = true;
            burgerIcon.pin(UIPin.Pin_Left, offset: 80);
            burgerIcon.pin(UIPin.Pin_Bottom, offset: -80);
            innerView.add(burgerIcon);

            let bbtxt = new("UILabel").init(
                (0,0), (50, 40),
                String.Format("%s", UIHelper.GetGamepadString(InputEvent.KEY_PAD_y)), "PDA16FONT",
                textAlign: UIView.Align_Centered,
                fontScale: (1, 1)
            );
            bbtxt.pin(UIPin.Pin_VCenter, UIPin.Pin_VCenter, value: 1.0, offset: 30, isFactor: true);
            bbtxt.pin(UIPin.Pin_HCenter, value: 1.0, offset: 50, isFactor: true);
            bbtxt.raycastTarget = false;
            bbtxt.hidden = !usingGP;
            burgerIcon.add(bbtxt);

            CommonUI.MakeStandardButtonEffects(burgerIcon);
        }

        
        let hLayout = new("UIHorizontalLayout").init((344,10), (600, 33 + 2));
        hLayout.itemSpacing = -4;
        //hLayout.pin(UIPin.Pin_Left, offset: 344);
        //hLayout.pin(UIPin.Pin_Right, offset: -18);
        hLayout.pin(UIPin.Pin_HCenter, UIPin.Pin_HCenter, value: 1.0);
        hLayout.layoutMode = UIViewManager.Content_SizeParent;
        innerView.add(hLayout);

        // Add Left Trigger icon
        if(usingGP) {
            let triggerImage = new("UIImage").init((0,0), (23 + 15 + 15, 33), "PDATABLT", imgStyle: UIImage.Image_Center);
            hLayout.addManaged(triggerImage);
        }

        // Add "App" buttons
        // Create slices once, not for every button
        let defaultState = UIButtonState.CreateSlices("PDABBUT1", (40,10), (42, 23));
        let hoverState = UIButtonState.CreateSlices("PDABBUT2", (40,10), (42, 23), sound: "codex/tabHover");
        let pressedState = UIButtonState.CreateSlices("PDABBUT3", (40,10), (42, 23), sound: "codex/tabClick");
        let selectedState = UIButtonState.CreateSlices("PDABBUT3", (40,10), (42, 23));
        let selectedHoverState = UIButtonState.CreateSlices("PDABBUT3", (40,10), (42, 23));
        let selectedDownState = UIButtonState.CreateSlices("PDABBUT2", (40,10), (42, 23));
        let disabledState = UIButtonState.CreateSlices("PDABBUT4", (40,10), (42, 23), textColor: 0xFF596786);

        readerButt = new("PDATab").init(
            (344, 0), (100, 33 + 2),
            "DATALOGS",
            "PDA16FONT",
            defaultState,
            hover: hoverState,
            pressed: pressedState,
            disabled: disabledState,
            selected: selectedState,
            selectedHover: selectedHoverState,
            selectedPressed: selectedDownState,
            textAlign: UIView.Align_Centered
        );
        readerButt.alpha = 0;
        readerButt.pinWidth(UIView.Size_Min);
        readerButt.setTextPadding(42, 0, 42, 0);
        hLayout.addManaged(readerButt);

        // Lazily repurposing the map button for Challenges right now
        mapButt = new("PDATab").init(
            (344, 0), (100, 33 + 2),
            "MILESTONES",
            "PDA16FONT",
            defaultState,
            hover: hoverState,
            pressed: pressedState,
            disabled: disabledState,
            selected: selectedState,
            selectedHover: selectedHoverState,
            selectedPressed: selectedDownState,
            textAlign: UIView.Align_Centered
        );
        mapButt.notImplementedText = "NOT YET UNLOCKED";
        mapButt.alpha = 0;
        mapButt.pinWidth(UIView.Size_Min);
        mapButt.setTextPadding(42, 0, 42, 0);
        mapButt.setDisabled(!(players[consolePlayer].mo && players[consolePlayer].mo.countInv("ChallengesUnlocked") > 0));
        

        objectivesButt = new("PDATab").init(
            (344, 0), (100, 33 + 2),
            "OBJECTIVES",
            "PDA16FONT",
            defaultState,
            hover: hoverState,
            pressed: pressedState,
            disabled: disabledState,
            selected: selectedState,
            selectedHover: selectedHoverState,
            selectedPressed: selectedDownState,
            textAlign: UIView.Align_Centered
        );
        objectivesButt.alpha = 0;
        objectivesButt.pinWidth(UIView.Size_Min);
        objectivesButt.setTextPadding(42, 0, 42, 0);
        hLayout.addManaged(objectivesButt);
        hLayout.addManaged(mapButt);    // TODO: Map button goes before objectives when we actually make the map

        statsButt = new("PDATab").init(
            (344, 0), (100, 33 + 2),
            "STATISTICS",
            "PDA16FONT",
            defaultState,
            hover: hoverState,
            pressed: pressedState,
            disabled: disabledState,
            selected: selectedState,
            selectedHover: selectedHoverState,
            selectedPressed: selectedDownState,
            textAlign: UIView.Align_Centered
        );
        statsButt.alpha = 0;
        statsButt.pinWidth(UIView.Size_Min);
        statsButt.setTextPadding(42, 0, 42, 0);
        //statsButt.setDisabled(true);
        hLayout.addManaged(statsButt);

        tiersButt = new("PDATab").init(
            (344, 0), (100, 33 + 2),
            "INVASION TIERS",
            "PDA16FONT",
            defaultState,
            hover: hoverState,
            pressed: pressedState,
            disabled: disabledState,
            selected: selectedState,
            selectedHover: selectedHoverState,
            selectedPressed: selectedDownState,
            textAlign: UIView.Align_Centered
        );
        tiersButt.alpha = 0;
        tiersButt.pinWidth(UIView.Size_Min);
        tiersButt.setTextPadding(42, 0, 42, 0);
        hLayout.addManaged(tiersButt);

        // Disable tiers if there are none
        int numInvasionTiers = 0;
        let invItem = InvasiontierItem(players[consoleplayer].mo.FindInventory('InvasiontierItem'));
        if(invItem) {
            for(int x = 1; x < INVTIER_COUNT; x++) {
                if(invItem.tiers[x] && invItem.tiers[x].unlocked && !invItem.tiers[x].bypassed) numInvasionTiers++;
            }
        }
        tiersButt.setDisabled(numInvasionTiers <= 0);
        tiersButt.isImplemented = true;

        manualButt = new("PDATab").init(
            (344, 0), (100, 33 + 2),
            "MANUAL",
            "PDA16FONT",
            defaultState,
            hover: hoverState,
            pressed: pressedState,
            disabled: disabledState,
            selected: selectedState,
            selectedHover: selectedHoverState,
            selectedPressed: selectedDownState,
            textAlign: UIView.Align_Centered
        );
        manualButt.alpha = 0;
        manualButt.pinWidth(UIView.Size_Min);
        manualButt.setTextPadding(42, 0, 42, 0);
        manualButt.setDisabled(true);
        hLayout.addManaged(manualButt);
        

        if(usingGP) {
            let triggerImage = new("UIImage").init((0,0), (23 + 15 + 15, 33), "PDATABRT", imgStyle: UIImage.Image_Center);
            hLayout.addManaged(triggerImage);
        }

        let stat1 = new("PDAStatWindowNormal").init((0, 110 - 27), (250, 152));
        stat1.pin(UIPin.Pin_Left);
        stat1.pin(UIPin.Pin_Right);
        sidebarView.addManaged(stat1);

        sidebarView.addSpacer(25);


        let horzView = new("UIHorizontalLayout").init((0,0), (100, 50));
        horzView.pinHeight(UIView.Size_Min);
        horzView.pin(UIPin.Pin_Left);
        horzView.pin(UIPin.Pin_Right);
        horzView.itemSpacing = 5;
        sidebarView.addManaged(horzView);

        creditsView = new("ResourceView").init(players[consolePlayer].mo.countInv("creditscount"), WeaponStationGFXPath .. "resourceSelver.png", 0xFFFAD364, rightAligned: false);
        creditsView.setSlices(NineSlice.Create("PDASELF3", (11,11), (22, 21)));
        creditsView.minSize.x = 140;
        creditsView.pin(UIPin.Pin_Right);
        partsView = new("ResourceView").init(players[consolePlayer].mo.countInv("weaponparts"), WeaponStationGFXPath .. "resourceWeaponParts.png", rightAligned: false);
        partsView.setSlices(NineSlice.Create("PDASELF3", (11,11), (22, 21)));
        partsView.minSize.x = 140;
        partsView.pin(UIPin.Pin_Left);
        
        let horzView2 = new("UIHorizontalLayout").init((0,0), (100, 50));
        horzView2.pinHeight(UIView.Size_Min);
        horzView2.pin(UIPin.Pin_Left);
        horzView2.pin(UIPin.Pin_Right);
        horzView2.itemSpacing = 5;
        sidebarView.addSpacer(5);
        sidebarView.addManaged(horzView2);

        saferoomsView = new("ResourceView").init(players[consolePlayer].mo.countInv("WorkshopTierItem"), WeaponStationGFXPath .. "resourceSaferoom.png", rightAligned: true);
        saferoomsView.setSlices(NineSlice.Create("PDASELF3", (11,11), (22, 21)));
        saferoomsView.minSize.x = 75;
        saferoomsView.pin(UIPin.Pin_Right);

        clearancesView = new("ResourceView").init(players[consolePlayer].mo.countInv("ClearanceLevel"), WeaponStationGFXPath .. "resourceSecurityCard.png", rightAligned: true);
        clearancesView.setSlices(NineSlice.Create("PDASELF3", (11,11), (22, 21)));
        clearancesView.minSize.x = 75;
        clearancesView.pin(UIPin.Pin_Left);

        horzView.addManaged(creditsView);
        horzView.addManaged(saferoomsView);
        horzView2.addManaged(partsView);
        horzView2.addManaged(clearancesView);

        /*let stat2 = new("PDAStatWindowObjectives").init((0, stat1.frame.pos.y + stat1.frame.size.y + 50), (250, 152));
        stat2.pin(UIPin.Pin_Left);
        stat2.pin(UIPin.Pin_Right);
        sidebarView.add(stat2);*/



        // Open previously opened apps
        let evt = PDAManager(StaticEventHandler.Find("PDAManager"));
        PDAEntry entry = evt ? PDAEntry(players[consolePlayer].mo.FindInventory("PDAEntry", true)) : null;
        bool openedApps = false;

        if(entry) {
            Array<PDAAppWindow> apps;

            for(int x = 0; x < PDA_APP_COUNT; x++) {
                if(entry.appSettings[x] && entry.appSettings[x].order > 0) {
                    openedApps = true;
                    PDAAppWindow wind = PDAAppWindow(new(APP_CLASSES[x])).vInit((100, 100), (800, 450));
                    wind.parentMenu = self;
                    wind.sortOrder = entry.appSettings[x].order;
                    if(wind is 'BBWindow' && developer > 1) innerView.add(wind);
                    else desktopView.add(wind);
                    insertAppWind(apps, wind);

                    // Set custom references
                    switch(x) {
                        case PDA_APP_READER:
                            readerWindow = PDAReaderWindow(wind);
                            readerButt.setSelected(true);
                            break;
                        case PDA_APP_STATS:
                            statsWindow = StatReaderWindow(wind);
                            statsButt.setSelected(true);
                            break;
                        case PDA_APP_OBJECTIVES:
                            objectiveWindow = ObjectivesWindow(wind);
                            objectivesButt.setSelected(true);
                            break;
                        case PDA_APP_INVASION:
                            invasionWindow = PDAInvasionWindow(wind);
                            tiersButt.setSelected(true);
                            break;
                        case PDA_APP_MAP:
                        case PDA_APP_CHALLENGES:
                            mapWindow = PDAChallengesWindow(wind);
                            mapButt.setSelected(true);
                            break;
                        default:
                            break;
                    }
                }
            }

            // Now stack them in order
            for(int x = 0; x < apps.size(); x++) {
                desktopView.moveToFront(apps[x]);
            }

            // Set active control for top window
            PDAAppWindow topApp = apps.size() > 0 ? PDAAppWindow(apps[apps.size() - 1]) : null;
            if(topApp) {
                topApp.navigateToFirstControl(true, usingGP);
                //navigateTo(topApp.getActiveControl(), mouseSelection: false, controllerSelection: usingGP);
                currentAppWindow = topApp;
            }
        }

        // Open the Reader by default if nothing else is open
        if(!openedApps) {
            // Open reader window by default
            openReader();
        }

        // If we have a recently received datapad (in the last 30 seconds) set the reader to the new datapad
        // Also open the reader if it's still not open by this point
        if(entry && entry.unreadCounter < (TICRATE * 30) && entry.unreadItem > 0) {
            // Close Burger Flipper if it's open
            closeBurgers();

            openReader();
            readerWIndow.setOpenEntry(entry.unreadArea, entry.unreadItem);
            //navigateTo(readerWindow.getActiveControl());

            // Notify that this item has been auto-read
            EventHandler.SendNetworkEvent("pdaTimeoutClear");
        } else if(numInvasionTiers && invItem && invItem.hasNewTiers) {
            // Close Burger Flipper if it's open
            closeBurgers();
            openInvasions();
            
            EventHandler.SendNetworkEvent("seenTiers");
        }
        
        layout();

        dimStart = getTime();
        setMapTime();

        mainView.cancelsSubviewRaycast = true;  // Save some CPU by cancelling raycasts until initial animation is over
    }


    void removeBurgerFlipper() {
        if(burgerIcon) {
            burgerIcon.removeFromSuperview();
            burgerIcon = null;
        }
    }

    private void openReader() {
        if(readerWindow) {
            switchToAppWindow(readerWindow);
            return;
        }

        readerWindow = new("PDAReaderWindow").init((100, 100), (800, 450));
        readerWindow.parentMenu = self;
        desktopView.add(readerWindow);
        navigateTo(readerWindow.getActiveControl());
        switchToAppWindow(readerWindow);
        readerButt.setSelected(true);
    }

    private void openInvasions() {
        if(invasionWindow) {
            switchToAppWindow(invasionWindow);
            return;
        }

        invasionWindow = new("PDAInvasionWindow").init((100, 100), (800, 500));
        invasionWindow.parentMenu = self;
        desktopView.add(invasionWindow);
        navigateTo(invasionWindow.getActiveControl());
        switchToAppWindow(invasionWindow);
        tiersButt.setSelected(true);
    }

    private void openStats() {
        if(statsWindow) {
            switchToAppWindow(statsWindow);
            return;
        }

        statsWindow = new("StatReaderWindow").init((100, 100), (800, 450));
        statsWindow.parentMenu = self;
        desktopView.add(statsWindow);
        switchToAppWindow(statsWindow);
        navigateTo(statsWindow.getActiveControl());
        statsButt.setSelected(true);
    }

    private void openMap() {
        if(mapWindow) {
            switchToAppWindow(mapWindow);
            return;
        }

        mapWindow = new("PDAChallengesWindow").init((100, 100), (800, 450));
        mapWindow.parentMenu = self;
        desktopView.add(mapWindow);
        switchToAppWindow(mapWindow);
        navigateTo(mapWindow.getActiveControl());
        mapButt.setSelected(true);
    }

    private void openObjectives() {
        if(objectiveWindow) {
            switchToAppWindow(objectiveWindow);
            return;
        }

        objectiveWindow = new("ObjectivesWindow").init((100, 100), (800, 450));
        objectiveWindow.parentMenu = self;
        desktopView.add(objectiveWindow);
        switchToAppWindow(objectiveWindow);
        navigateTo(objectiveWindow.getActiveControl());
        objectivesButt.setSelected(true);
    }

    private void openBurgers() {
        // Find burger app in open apps and move to front if it exists
        for(int x = 0; x < desktopView.numSubviews(); x++) {
            if(desktopView.viewAt(x) is 'BBWindow') {
                switchToAppWindow(BBWindow(desktopView.viewAt(x)));
                return;
            }
        }

        let burgerWindow = new("BBWindow").init((100, 100), (800, 450));
        burgerWindow.parentMenu = self;
        if(developer > 1) innerView.add(burgerWindow);
        else desktopView.add(burgerWindow);
        switchToAppWindow(burgerWindow);
        let con = burgerWindow.getActiveControl();
        if(con) navigateTo(con, false);
        else clearNavigation();
    }


    private void toggleBurgers() {
        BBWindow burgerWindow;

        for(int x = 0; x < desktopView.numSubviews(); x++) {
            if(desktopView.viewAt(x) is 'BBWindow') {
                burgerWindow = BBWindow(desktopView.viewAt(x));
                break;
            }
        }

        if(burgerWindow) {
            burgerWindow.close();
            burgerWindow = null;
        } else {
            openBurgers();
        }
    }


    private void closeBurgers() {
        BBWindow burgerWindow;

        for(int x = 0; x < desktopView.numSubviews(); x++) {
            if(desktopView.viewAt(x) is 'BBWindow') {
                burgerWindow = BBWindow(desktopView.viewAt(x));
                break;
            }
        }

        if(burgerWindow) {
            burgerWindow.close();
        }
    }


    private void switchToAppWindow(PDAAppWindow appWind) {
        // If fullscreen, close all other fullscreen apps and move this app to the bottom
        if(appWind is 'PDAFullscreenAppWindow') {
            for(int x = 0; x < desktopView.numSubviews(); x++) {
                let v = PDAFullscreenAppWindow(desktopView.viewAt(x));

                // Close any currently running full screen windows
                if(v && v != appWind) {
                    v.close();
                }
            }

            desktopView.moveToBack(appWind);
        } else {
            desktopView.moveToFront(appWind);
        }

        currentAppWindow = appWind;
    }


    private void insertAppWind(Array<PDAAppWindow> apps, PDAAppWindow app) {
        if(apps.size() == 0) {
            apps.Push(app);
            return;
        }

        for(int x = 0; x < apps.size(); x++) {
            if(apps[x].sortOrder > app.sortOrder) {
                apps.Insert(x, app);
                break;
            } else if(x + 1 == apps.size()) {
                apps.Push(app);
                break;
            }
        }
    }
    
    
    void saveWindows() {
        for(int x = 0; x < desktopView.numSubviews(); x++) {
            let appWindow = PDAAppWindow(desktopView.viewAt(x));
            if(appWindow) {
                appWindow.savePos(x + 1);
            }
        }
    }
    

    void setMapTime() {
        timeLabel.setText(CommonUI.getTimeString(Level.maptime));
    }
    
    void layout() {
        /*bool smallHeight = mainView.frame.size.y < 800;
        bool smallWidth = mainView.frame.size.x < 1300;*/

        background.freeze = mainView.scale.x < 1 || mainView.scale.y < 1;
        /*innerView.firstPin(UIPin.Pin_Left).offset = smallWidth ? 10 : 60;
        innerView.firstPin(UIPin.Pin_Right).offset = smallWidth ? -10 : -40;
        innerView.firstPin(UIPin.Pin_Top).offset = smallHeight ? 10 : 60;
        innerView.firstPin(UIPin.Pin_Bottom).offset = smallHeight ? -10 : -40;*/
    }

    override void layoutChange(int screenWidth, int screenHeight) {
        // TODO: Make sure windows are fit into the screen after resizing
        calcScale(screenWidth, screenHeight);
        background.freeze = mainView.scale.x < 1 || mainView.scale.y < 1;
        layout();
        mainView.layout();
        hasLayedOutOnce = true;
    }

    // Same as standard scale but minimum has changed
    override void calcScale(int screenWidth, int screenHeight, Vector2 baselineResolution) {
		let size = (screenWidth, screenHeight);
        let uscale = ui_scaling ? ui_scaling.getFloat() : 1.0;
		lastUIScale = uscale;
        if(uscale <= 0.001) uscale = 1.0;

        let newScale = uscale * CLAMP(size.y / baselineResolution.y, 0.599, 2.0);
		
        // If we are close enough to 1.0.. 
        if(abs(newScale - 1.0) < 0.08) {
            newScale = 1.0;
        } else if(abs(newScale - 2.0) < 0.08) {
            newScale = 2.0;
        }

        lastUIScale = newScale;

		mainView.frame.size = (screenWidth / newScale, screenHeight / newScale);
        mainView.scale = (newScale, newScale);

		// For UIDrawer
		screenSize = (screenWidth, screenHeight);
		virtualScreenSize = screenSize / newScale;
	}


    override void ticker() {
        Super.ticker();

        if(!players[consolePlayer].mo || players[consolePlayer].mo.health <= 0) {
            CleanClose();
            return;
        }

        setMapTime();

        if(curMusicVolume > targetMusicVolume) {
            curMusicVolume = MAX(targetMusicVolume, curMusicVolume - musicVolumeSteps);
            SetMusicVolume (curMusicVolume);
        }

        if(ticks == 1) {
            // Animate scale in for the whole view
            innerView.animateFrame(
                0.10,
                fromPos: innerView.frame.pos - (50, 0),
                toPos: innerView.frame.pos,
                fromAlpha: 0.5,
                toAlpha: 1.0
            );
            
            animateTabIn(readerButt);
            animateTabIn(mapButt,       delay: 0.025);
            animateTabIn(objectivesButt,delay: 0.05);
            animateTabIn(statsButt,     delay: 0.075);
            animateTabIn(tiersButt,     delay: 0.1);
            animateTabIn(manualButt,    delay: 0.125);
        } else if(ticks == 19) {
            mainView.cancelsSubviewRaycast = false;
        }

        if(closeStart > 0.1 && getTime() - closeStart > CLOSE_TIME) {
            CleanClose();
            return;
        }

        hasChangedAppsThisTick = false;
    }

    void animateTabIn(UIButton btn, double time = 0.15, double delay = 0.0) {
        let anim = btn.animateFrame(
            time,
            //fromPos: btn.frame.pos - (80, 0),
            fromPos: btn.frame.pos - (0, 33),
            toPos: btn.frame.pos,
            fromAlpha: 0.0,
            toAlpha: 1.0
        );

        if(anim) {
            anim.startTime += delay;
            anim.endTime += delay;
        }
    }

    override void handleControl(UIControl ctrl, int event, bool fromMouse) {
        // Double click, or ENTER or A 
        if(event == UIHandler.Event_Activated) { //} || (event == UIHandler.Event_Activated && !fromMouse)) {
            if(burgerIcon != null && ctrl == burgerIcon) {
                openBurgers();
            }
        }

        if(event == UIHandler.Event_Activated) {
            if(ctrl == readerButt) {
                openReader();
                saveWindows();
            } else if(ctrl == statsButt) {
                openStats();
                saveWindows();
            } else if(ctrl == tiersButt) {
                openInvasions();
                saveWindows();
            } else if(ctrl == objectivesButt) {
                openObjectives();
                saveWindows();
            }  else if(ctrl == mapButt) {
                openMap();
                saveWindows();
            }
        }

        // Detect window close
        if(event == UIHandler.Event_Closed) {
            if(ctrl == readerWindow) {
                readerWindow = null;
                readerButt.setSelected(false);
            }

            if(ctrl == objectiveWindow) {
                objectiveWindow = null;
                objectivesButt.setSelected(false);
            }

             if(ctrl == mapWindow) {
                mapWindow = null;
                mapButt.setSelected(false);
            }

            if(ctrl == statsWindow) {
                statsWindow = null;
                statsButt.setSelected(false);
            }

            if(ctrl == invasionWindow) {
                invasionWindow = null;
                tiersButt.setSelected(false);
            }

            // Find top-most window and set that as current
            if(ctrl == currentAppWindow) {
                currentAppWindow = null;

                for(int x = desktopView.numSubviews() - 1; x >= 0; x--) {
                    let w = PDAAppWindow(desktopView.viewAt(x));

                    if(w) {
                        currentAppWindow = w;
                        break;
                    }
                }
            }
        }
    }

    override bool mouseDownEvent(ViewEvent ev) {
		let mdv = mDownView;

        bool ret = Super.mouseDownEvent(ev);

        if(mDownView && mDownView != mdv) {
            // Trace the path up and see if this view is, or is inside a window. Then move the window to the top.
            let v = mDownView;
            while(v) {
                if(v is "UIWindow") {
                    if(v is "PDAAppWindow") {
                        switchToAppWindow(PDAAppWindow(v));
                    }
                    saveWindows();
                    break;
                }
                v = v.parent;
            }
        }

        return ret;
	}

    override void onDestroy() {
        SetMusicVolume (Level.MusicVolume);
        Super.onDestroy();
    }

    UIWindow findActiveWindow() {
        for(int x = desktopView.numSubviews() - 1; x >= 0; x--) {
            let subview = desktopView.viewAt(x);

            if(subview is "UIWindow") {
                return UIWindow(subview);
            }
        }

        return null;
    }
    
    void animateClose() {
        if(closeStart ~== 0) {
            saveWindows();
            
            MenuSound("codex/close");

            closeStart = getTime();
            animator.clear(innerView);
            innerView.animateFrame(
                0.151,
                fromPos: innerView.frame.pos,
                toPos: innerView.frame.pos - (50, 0),
                fromAlpha: 1.0,
                toAlpha: 0.1
            );
        }
    }

    void cleanClose() {
        // Tell the HUD to stop shutting up
        let h = HUD(StatusBar);
        if(h) {
            h.isMuted = false;
        }

        Close();
    }

    // Keep an eye on this, it could result in the same event being sent twice to the active window...
    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(mkey == MKEY_Back) {
            // Close
            animateClose();
            return true;
        }


        if(!Super.MenuEvent(mkey, fromcontroller)) {
            let activeWindow = findActiveWindow();

            // Send menu event to the active window
            if(activeControl != activeWindow && activeWindow != null) {
                return activeWindow.menuEvent(mkey, fromcontroller);
            }
        }

        return false;
    }

    override bool OnUIEvent(UIEvent ev) {
        if(ev.type == UIEvent.Type_KeyDown) {
            for(int x = 0; x < codexKeys.size(); x++) {
                if(ev.KeyChar == codexKeys[x]) {
                    animateClose();
                    return true;
                }
            }
        }


        return Super.OnUIEvent(ev);
    }

    override bool OnInputEvent(InputEvent ev) { 
		if(ev.type == InputEvent.Type_KeyDown) {
            for(int x = 0; x < rawBackKeys.size(); x++) {
                if(ev.KeyScan == rawBackKeys[x]) {
                    animateClose();
                    return true;
                }
            }

            if(ev.KeyScan == InputEvent.Key_Pad_Y && BBItem.Find()) {
                toggleBurgers();
            }
        }
        
        if(ev.type == InputEvent.Type_KeyDown && (ev.KeyScan == InputEvent.Key_Pad_LTrigger || ev.KeyScan == InputEvent.Key_Pad_RTrigger) && !hasChangedAppsThisTick) {
            // Automatic navigate to previous tab/window
            // Determine which window is showing on top
            let activeWindow = findActiveWindow();
            if(!activeWindow) {
                openReader();
                saveWindows();
                return true;
            }

            // Determine next window to open
            if(ev.KeyScan == InputEvent.Key_Pad_RTrigger) {
                if(activeWindow == readerWindow) {
                    openObjectives();
                } else if(activeWindow == objectiveWindow) {
                    openMap();
                } else if(activeWindow == mapWindow) {
                    openStats();
                } else if(activeWindow == statsWindow) {
                    openInvasions();
                }else if(activeWindow == invasionWindow) {
                    openReader();
                }
            } else {
                if(activeWindow == readerWindow) {
                    openInvasions();
                } else if(activeWindow == objectiveWindow) {
                    openReader();
                } else if(activeWindow == mapWindow) {
                    openObjectives();
                } else if(activeWindow == statsWindow) {
                    openMap();
                } else if(activeWindow == invasionWindow) {
                    openStats();
                }
            }
            

            // Animate previous window to close
            let appWindow = PDAAppWindow(activeWindow);
            if(appWindow) appWindow.animateClose();

            saveWindows();
            hasChangedAppsThisTick = true;

            return true;
        }

        let activeWindow = PDAAppWindow(findActiveWindow());
        if(activeWindow) {
            if(activeWindow.onInputEvent(ev)) {
                return true;
            }
        }

        return Super.OnInputEvent(ev);
	}

    override void drawSubviews() {
        double time = getTime();
        
        // Set background blur
        if(closeStart > 0.001) {
            BlurAmount =  1.0 - MIN((time - closeStart) / CLOSE_TIME, 1.0);
        } else if(time - dimStart > 0) {
            BlurAmount =  MIN((time - dimStart) / 0.1, 1.0);
        }

        //double dim = MIN((time - dimStart) / 0.35, 1.0) * 0.75;
        //Screen.dim(0xFF020202, dim, 0, 0, lastScreenSize.x, lastScreenSize.y);
        
        if(closeStart > 0.001 && time - closeStart >= CLOSE_TIME) {
            return;
        }
        Super.drawSubviews();
    }


    const dawnLen = 1.5;
    override void drawer() {
        Super.Drawer();

        double time = getTime();

        if(time - dimStart < dawnLen && dimStart >= 0) {
            TextureID tid = TexMan.checkForTexture("PDAGLOW", TexMan.Type_Any);
            Vector2 ts = TexMan.GetScaledSize(tid);
            
            double scWidth = Screen.GetWidth();
		    double scHeight = Screen.GetHeight();
            double tm = (time - dimStart) / dawnLen;
            double sc = UIMath.EaseOutXYA(1.035, 1.0, tm);

            double x = (scWidth / 2.0) - ((scWidth * sc) / 2.0);
            double y = (scHeight / 2.0) - ((scHeight * sc) / 2.0) + 
                        (sin(MSTime() * 0.2) * UIMath.EaseOutXYA(3.0, 6.0, tm));
            
            // Clip to the PDA screen
            UIBox clipRect;
            background.getScreenClipActual(clipRect);
            Screen.setClipRect(int(clipRect.pos.x), int(clipRect.pos.y), int(clipRect.size.x), int(clipRect.size.y));

            // Draw
            Screen.DrawTexture(tid, false, x, y, 
                DTA_DestWidthF, scWidth * sc,
                DTA_DestHeightF, scHeight * sc,
                DTA_ALPHA, 0.35 * UIMath.EaseInCubicF(1.0 - (tm)));
        }
    }
}


