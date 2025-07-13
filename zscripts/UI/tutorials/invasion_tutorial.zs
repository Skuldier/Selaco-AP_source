class InvasionTutorialPopup : MajorTutorialPopup {
    override void Init(TutorialInfo tut) {
        Super.Init(tut);
    }
}

class InvasionTutorialMenu : MajorTutorialMenu {


    override void Init(Menu parent) {
        Super.Init(parent);
    }

    override void getTextures() {
        textFont = "PDA18FONT";
        titleFont = "SEL21FONT";
        topTex = TexMan.CheckForTexture("TUTRTOP", Texman.Type_Any);
        midTex = TexMan.CheckForTexture("TUTRMID", Texman.Type_Any);
        botTex = TexMan.CheckForTexture("TUTRBOT", Texman.Type_Any);
        fadeTex = TexMan.CheckForTexture("TUTMBG2", Texman.Type_Any);
        buttTex = TexMan.CheckForTexture("TUTBUTR", Texman.Type_Any);
        buttTex2 = TexMan.CheckForTexture("TUTBUTR2", Texman.Type_Any);
        buttTex3 = TexMan.CheckForTexture("TUTBUTR3", Texman.Type_Any);

        topSize = TexMan.GetScaledSize(topTex);
        midSize = TexMan.GetScaledSize(midTex);
        botSize = TexMan.GetScaledSize(botTex);
        
        buttSize = TexMan.GetScaledSize(buttTex);

        warningSize = TexMan.GetScaledSize(warningTex);

        imageSize = TexMan.GetScaledSize(info.image);

        buttTextColor = headerTextColor = textColor = 0xFFCE1D13;

        buttOffset = 38;
        headerTop = 17;
        imageOffset = -5;
    }

    override void CleanClose() {
        closing = true;
        startTime = ticks;
        S_StartSound ("ui/closeTutorialInvasion", CHAN_VOICE, CHANF_UI, snd_menuvolume);
    }
}