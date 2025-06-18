class MinimapOverlay ui {
    mixin UIDrawer;
    mixin HudDrawer;
    mixin CVARBuddy;
    //mixin ScreenSizeChecker;

    enum MMCtrlIndexes {
        pan = 0,
        zoom,
        //togglezoom,
        //centerview,
        togglefollow,
        togglelegend,
        NUM_CTRLS
    }

    
    string names[NUM_CTRLS];
    string ctrls[NUM_CTRLS];
    Array< class<MasterMarker> > mapMarkerTypes;
    
    //double mmTextHeight, mmStringHeight;
    double mmTextWidth, mmNameTextWidth;
    double mmFullTextWidth;
    double mmMaxWidth;

    bool showLegend;

    Color titleColor;

    Font mmFont, mmFont2;

    //const NUM_CTRLS_WITH_SPACES = NUM_CTRLS + 2;
    //const CTRL_SPACING = 2;
    const BIND_SPACING = 64;
    const BIND_SPACING2 = 8;
    const LEGEND_ITEM_HEIGHT = 50;
    const LEGEND_ICON_SIZE = 40;
    const LEGEND_GAP = LEGEND_ICON_SIZE + 15;


    MinimapOverlay init() {
        loadMinimapStrings();
        getScreenScale(screenSize, virtualScreenSize);
        titleColor = Font.FindFontColor("MAPOUT");
        showLegend = iGetCVAR("am_legend");

        return self;
    }

    void tick() {
        showLegend = iGetCVAR("am_legend");
    }

    void screenSizeChanged() {
        getScreenScale(screenSize, virtualScreenSize);
    }

    void loadMinimapControls() {
        // Simplify controls if they are just default arrow keys
        bool simpleArrows = false;

        ctrls[pan] = String.Format(    "%s %s %s %s", 
                                        UIHelper.FilterKeybinds("$[[HI],+am_panleft]$"),
                                        UIHelper.FilterKeybinds("$[[HI],+am_panup]$"),
                                        UIHelper.FilterKeybinds("$[[HI],+am_panright]$"),
                                        UIHelper.FilterKeybinds("$[[HI],+am_pandown]$")
        );

        ctrls[zoom] = String.Format("%s %s", UIHelper.FilterKeybinds("$[[HI],+am_zoomout]$"), UIHelper.FilterKeybinds("$[[HI],+am_zoomin]$"));
        //ctrls[togglezoom] = UIHelper.FilterKeybinds("$[[HI],am_gobig]$");
        ctrls[togglefollow] = UIHelper.FilterKeybinds("$[[HI],am_togglefollow]$");
        //ctrls[togglefollow] = UIHelper.FilterKeybinds("$[[HI],am_togglefollow]$");
        ctrls[togglelegend] = UIHelper.FilterKeybinds("$[[HI],am_togglelegend]$");

        // Determine width of names
        mmTextWidth = 0;
        for(int x = 0; x < NUM_CTRLS; x++) {
            let strw = mmFont.stringWidth(ctrls[x]);
            if(mmTextWidth < strw) mmTextWidth = strw;
        }

        //mmTextHeight = (mmStringHeight + CTRL_SPACING) * NUM_CTRLS_WITH_SPACES;

        // Determine width of names
        mmNameTextWidth = 0;
        mmFullTextWidth = 0;
        for(int x = 0; x < NUM_CTRLS; x++) {
            let strw = mmFont.stringWidth(names[x]);
            mmFullTextWidth += strw + mmFont.stringWidth(ctrls[x]) + BIND_SPACING + BIND_SPACING2;
            if(mmNameTextWidth < strw) mmNameTextWidth = strw;
        }
        mmNameTextWidth = max(mmNameTextWidth, 200);
    }

    void updateMinimapLegend() {
        // Find all types in the map and add to legend
        // Oh wait we can't actually do that, so the map markers will need to register themselves with the LevelEventHandler
        mapMarkerTypes.clear();
        mapMarkerTypes.copy(LocalLevelHandler.Instance().mapMarkerClasses);

        mmMaxWidth = 0;
        for(int x = 0; x < mapMarkerTypes.size(); x++) {
            mmMaxWidth = max(mmMaxWidth, mmFont2.stringWidth(StringTable.Localize(GetDefaultByType(mapMarkerTypes[x]).mapLabel)));
        }
        
        mmMaxWidth += BIND_SPACING2 + LEGEND_ICON_SIZE;
    }

    void loadMinimapStrings() {
        mmFont = 'PDA18FONT';
        mmFont2 = 'SEL21OFONT';
        //mmStringHeight = mmFont.getHeight();

        names[pan] = StringTable.Localize("$MAPCNTRLMNU_PAN");
        names[zoom] = StringTable.Localize("$MAPCNTRLMNU_ZOOM");
        //names[togglezoom] = StringTable.Localize("$MAPCNTRLMNU_TOGGLEZOOM");
        names[togglefollow] = StringTable.Localize("$MAPCNTRLMNU_CENTER");
        //names[togglefollow] = StringTable.Localize("$MAPCNTRLMNU_TOGGLEFOLLOW");
        names[togglelegend] = StringTable.Localize("$MAPCNTRLMNU_TOGGLELEGEND");

        loadMinimapControls();
    }

    
    void drawMinimapOverlay() {
        let margin = 40;
        let padding = 25;
        let paddingy = 15;
        let moveAlpha = 1.0;//!iGetCVar('am_followplayer', 1) ? 1.0 : 0.3;
        let mmNameLeft = margin + padding;

        int textColor = Font.CR_UNTRANSLATED;

        // Draw map info
        Dim(am_backcolor, 0.85, 0, 0, virtualScreenSize.x, 80);
        DrawStr("K32FONT", Level.LevelName, (-margin, 50), flags: DR_SCREEN_HCENTER | DR_TEXT_HCENTER | DR_TEXT_VCENTER, titleColor, a: 1.0, monoSpace: false, scale: (0.91, 0.91));


        // Draw controls
        if(!menuActive) {
            double mmTextScale = 1.0;
            double vTextSpace = virtualScreenSize.x - 80;

            // Adjust scale if the text would escape the bounds
            if(mmFullTextWidth > vTextSpace) {
                mmTextScale = vTextSpace / mmFullTextWidth;
            }

            let leftStart = mmFullTextWidth * -0.5 * mmTextScale;
            double posx = 0;
            for(int x = 0; x < names.size(); x++) {
                posx += DrawStr(mmFont, ctrls[x], (leftStart + posx, -80), DR_SCREEN_BOTTOM | DR_SCREEN_CENTER | DR_TEXT_VCENTER, textColor, a: 1.0 * (x == 0 ? moveAlpha : 1.0), monospace: false, scale: (mmTextScale, mmTextScale)) + (BIND_SPACING2 * mmTextScale);
                posx += DrawStr(mmFont, names[x], (leftStart + posx, -80), DR_SCREEN_BOTTOM | DR_SCREEN_CENTER | DR_TEXT_VCENTER, textColor, a: 1.0 * (x == 0 ? moveAlpha : 1.0), monospace: false, scale: (mmTextScale, mmTextScale));
                posx += BIND_SPACING * mmTextScale;
            }
        }
        
        int eachHeight = LEGEND_ITEM_HEIGHT;
        int fullHeight = mapMarkerTypes.size() * eachHeight;
        double lStart = (fullHeight * -0.5) + (eachHeight * 0.5);

        
        if(showLegend && mapMarkerTypes.size()) {
            // Get total height
            fullHeight = 0;
            double firstHeight;
            for(int x = 0; x < mapMarkerTypes.size(); x++) {
                let def = GetDefaultByType(mapMarkerTypes[x]);
                TextureID tex = TexMan.CheckForTexture (def.legendIcon != "" ? def.legendIcon : def.mapIcon, TexMan.Type_Any);
                if(tex.isValid()) {
                    let osize = TexMan.GetScaledSize(tex);
                    if(osize.y > osize.x) {
                        fullHeight += osize.y * (eachHeight / osize.x);
                        if(x == 0) firstHeight = fullHeight;
                        continue;
                    }
                    fullHeight += eachHeight;
                    if(x == 0) firstHeight = fullHeight;
                }
            }

            lStart = (fullHeight * -0.5);

            // Draw legend background
            //0xFF1f232f
            let top = (fullHeight + paddingy + paddingy) * -0.5;
            let width = max(mmMaxWidth + padding + (padding * 2), 300);
            Dim(0xFF1B1E27, 0.7, margin, top, width, fullHeight + paddingy + paddingy, DR_SCREEN_VCENTER);
            DrawImgAdvanced("AMLCONT2", (margin + 20, top), DR_SCREEN_VCENTER | DR_IMG_BOTTOM | DR_SCALE_IS_SIZE, scale: (width - 40, 62));
            DrawImgAdvanced("AMLCONT1", (margin, top), DR_SCREEN_VCENTER | DR_IMG_BOTTOM);
            DrawImgAdvanced("AMLCONT3", (margin + width, top), DR_SCREEN_VCENTER | DR_IMG_BOTTOM | DR_IMG_RIGHT);

            // Draw legend
            double pos = lStart;
            for(int x = 0; x < mapMarkerTypes.size(); x++) {
                let def = GetDefaultByType(mapMarkerTypes[x]);

                // Account for larger map icons
                TextureID tex = TexMan.CheckForTexture (def.legendIcon != "" ? def.legendIcon : def.mapIcon, TexMan.Type_Any);
                if(tex.isValid()) {
                    let osize = TexMan.GetScaledSize(tex);
                    if(osize.y > osize.x) {
                        // Adjust line height
                        double lheight = osize.y * (LEGEND_ICON_SIZE / osize.x);
                        double mheight = osize.y * (eachHeight / osize.x);
                        pos += mheight * 0.5;
                        DrawTexAdvanced(tex, (mmNameLeft, pos), flags: DR_SCREEN_VCENTER | DR_IMG_VCENTER | DR_SCALE_IS_SIZE | DR_NO_SPRITE_OFFSET, a: 1.0, scale: (LEGEND_ICON_SIZE, lheight));
                        DrawStr(mmFont2, StringTable.Localize(def.mapLabel), (mmNameLeft + LEGEND_GAP, pos), flags: DR_SCREEN_VCENTER | DR_TEXT_VCENTER, textColor, a: 1.0, monoSpace: false);
                        pos += mheight * 0.5;
                    } else {
                        pos += eachHeight * 0.5;
                        DrawTexAdvanced(tex, (mmNameLeft, pos), flags: DR_SCREEN_VCENTER | DR_IMG_VCENTER | DR_SCALE_IS_SIZE | DR_NO_SPRITE_OFFSET, a: 1.0, scale: (LEGEND_ICON_SIZE, LEGEND_ICON_SIZE));
                        DrawStr(mmFont2, StringTable.Localize(def.mapLabel), (mmNameLeft + LEGEND_GAP, pos), flags: DR_SCREEN_VCENTER | DR_TEXT_VCENTER, textColor, a: 1.0, monoSpace: false);
                        pos += eachHeight * 0.5;
                    }
                }
            }
        }
    }
}