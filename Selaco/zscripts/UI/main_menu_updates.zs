const NEXT_UPDATE_ESTIMATED_TIME_IN_UTC = 1656122400;


class UpdateWarningView : UIVerticalLayout {
    UILabel warningLabel, timeLabel;
    UIImage bgImage;
    uint ticks;

    static bool IsAnUpdateComing() {
        let newsCounterText = StringTable.Localize("$NEWS_COUNTER");
        int nc = newsCounterText != "NEWS_COUNTER" && newsCounterText != "" ? newsCounterText.toInt(10) : 1;
        let cv = CVar.FindCVar("news_counter");

        return cv && cv.GetInt() < nc;
        //return NEXT_UPDATE_ESTIMATED_TIME_IN_UTC != 0 && (NEXT_UPDATE_ESTIMATED_TIME_IN_UTC - SystemTime.Now() > 0 || SystemTime.Now() - NEXT_UPDATE_ESTIMATED_TIME_IN_UTC < 5 * 24 * 60 * 60);
    }

    UpdateWarningView init(Vector2 pos = (0,0), Vector2 size = (100,100)) {
        Super.init(pos, size);
        
        padding.left = 22;
        padding.right = 22;
        padding.top = 22;
        padding.bottom = 22;

        bgImage = new("UIImage").init((0,0), (10, 10), "", NineSlice.Create("BGENERIC", (9,9), (14,14)));
        bgImage.pinToParent();
        add(bgImage);

        warningLabel = new("UILabel").init(
            (0,0), (100, 40),
            StringTable.Localize("$UPDATE_WARNING"), 
            "K22FONT", 
            textAlign: UIView.Align_Middle,
            fontScale: (0.65, 0.65)
        );
        warningLabel.pin(UIPin.Pin_Left, offset: 22);
        warningLabel.pin(UIPin.Pin_Right, offset: -22);
        warningLabel.pinHeight(UIView.Size_Min);

        /*timeLabel = new("UILabel").init(
            (0,0), (100, 40),
            "", 
            "K22FONT",
            0xFFb0c6f7,
            textAlign: UIView.Align_Middle,
            fontScale: (0.65, 0.65)
        );
        timeLabel.pin(UIPin.Pin_Left, offset: 22);
        timeLabel.pin(UIPin.Pin_Right, offset: -22);
        timeLabel.pinHeight(UIView.Size_Min);*/

        addManaged(warningLabel);
        //addManaged(new('UIView').init((0,0), (0, 25)));
        //addManaged(timeLabel);

        // Add News Button
        /*let butt = new("UIButton").init(
            (0,0), (100, 40),
            "Patch Notes", 'PDA13FONT',
            null
        );
        butt.pin(UIPin.Pin_Left, offset: 22);
        butt.pinWidth(UIView.Size_Min);
        butt.command = "OpenNews";

        addManaged(butt);*/

        layoutMode = UIViewManager.Content_SizeParent;

        //setTime();

        return self;
    }

    /*override void tick() {
        Super.tick();

        if(hidden) { return; }

        if(ticks % 10 == 0) setTime();
        ticks++;
    }

    void setTime() {
        let now = SystemTime.Now();
        let diff = NEXT_UPDATE_ESTIMATED_TIME_IN_UTC - now;
        if(diff > 60 * 60) {
            // Less than a day?
            if(diff < (24 * 60 * 60)) {
                let h = int(floor(diff / (60 * 60)));
                timeLabel.setText(String.Format("Hiding In: %d %s", h, (h > 1 ? "hours" : "hour")));
            } else {
                let d = int(floor(diff / (24 * 60 * 60)));
                timeLabel.setText(String.Format("Hiding In: %d days", d));
            }
        } else {
            //warningLabel.setText(StringTable.Localize("$UPDATE_READY"));
            hidden = true;
        }
    }*/
}

class ListMenuItemUpdateView : ListMenuItem {
    void Init(ListMenuDescriptor desc) {
        Super.Init();
    }
}


class MainMenuInfoView : UIVerticalLayout {
    UILabel infoLabel;
    UIImage bgImage;
    UIImage img;

    MainMenuInfoView init(Vector2 pos = (0,0), Vector2 size = (100,100), String infoText = "$MAIN_MENU_INFO", String displayImage = "") {
        Super.init(pos, size);
        
        padding.left = 22;
        padding.right = 22;
        padding.top = 22;
        padding.bottom = 22;

        bgImage = new("UIImage").init((0,0), (10, 10), "", NineSlice.Create("BGENERIC", (9,9), (14,14)));
        bgImage.pinToParent();
        add(bgImage);
        
        if(displayImage != "") {
            img = new("UIImage").init((0,0), (size.x, 100), displayImage, imgStyle: UIImage.Image_Aspect_Fill);
            img.pin(UIPin.Pin_Left);
            img.pin(UIPin.Pin_Right);
            img.pinHeight(120);
            addManaged(img);
        }

        infoLabel = new("UILabel").init(
            (0,0), (100, 40),
            StringTable.Localize(infoText), 
            "K22FONT", 
            textAlign: UIView.Align_Middle,
            fontScale: (0.75, 0.75)
        );
        infoLabel.pin(UIPin.Pin_Left);//, offset: 22);
        infoLabel.pin(UIPin.Pin_Right);//, offset: -22);
        infoLabel.pinHeight(UIView.Size_Min);

        addSpacer(20);

        addManaged(infoLabel);
        layoutMode = UIViewManager.Content_SizeParent;

        return self;
    }
}