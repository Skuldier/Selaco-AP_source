// Simple HUD element that pre-draws some font assets that are needed later, to prevent stutters
// Only draws when loading a non-titlemap
class HUDElementPredraw : HUDElementStartup {
    bool shouldDraw, hasDrawn;

    static const Font Fonts[] = {
        "SEL46FONT", "SEL52FONT", "SEL27OFONT", "SEL21FONT", "SEL21OFONT", "SEL16FONT", "SEL14FONT", "PDA18FONT", "PDA16FONT", "PDA13FONT", "SELACOFONT", "SELACOFONTLARGE", "SELOFONT", "SMALLFONT"
    };

    static const String FontColors[] = {
        "HI", "RED", "WHITE"
    };

    override HUDElement init() {
        Super.init();
        shouldDraw = false;

        return self;
    }

    override void onAttached(HUD owner, Dawn player) {
        Super.onAttached(owner, player);

        if(Level.MapName != "TITLEMAP") {
            shouldDraw = true;
            hasDrawn = false;
        } else {
            hasDrawn = true;
        }
    }

    override bool tick() {
        return hasDrawn;
    }

    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        if(!shouldDraw) return;

        shouldDraw = false;
        hasDrawn = true;

        string txt = ""; //"ABCDEFGHIJKLMN\nOPQRSTUVWXYZabcd\nefghijklmnopqrs\ntuvwxyz!@#$\n%^&*()[];\n'\"<>.,/\\~\n";
        for(int x = 32; x < 126; x++) {
            txt.AppendCharacter(x);
        }

        txt.AppendCharacter(149);   // Bullet

        for(int x = 0; x < UIHelper.FontIconLookupPad.size(); x++) {
            txt.AppendCharacter(UIHelper.FontIconLookupPad[x]);
        }

        double left = Screen.GetWidth() * 2;
        
        for(int f = 0; f < Fonts.size(); f++) {
            DrawStr(Fonts[f], txt, (left, -200), DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_TEXT_HCENTER, Font.CR_UNTRANSLATED, 1.0, false);

            for(int col = 0; col < FontColors.Size(); col++) {
                DrawStr(Fonts[f], txt, (left, -200), DR_SCREEN_HCENTER | DR_SCREEN_VCENTER | DR_TEXT_HCENTER, Font.FindFontColor(FontColors[col]), 1.0, false);
            }
        }
    }
}