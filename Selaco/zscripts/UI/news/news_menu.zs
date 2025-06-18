// Yes this is pretty much the same as the TOS menu. Sue me.
class NewsMenu : SelacoGamepadMenu {
    UILabel titleLabel;
    UIButton continueButton;
    StandardBackgroundContainer background;
    UIImage textBackground;
    UIVerticalScroll scrollView;
    
    double dimStart;

    override void init(Menu parent) {
        Super.init(parent);

        DontDim = true;
        DontBlur = true;
        //AnimatedTransition = true;
        //Animated = true;

        // Update READ CVAR
        let cv = CVar.FindCVar("news_counter");
        if(cv) {
            // Get current number
            let newsCounterText = StringTable.Localize("$NEWS_COUNTER");
            int nc = newsCounterText != "NEWS_COUNTER" && newsCounterText != "" ? newsCounterText.toInt(10) : 1;
            cv.setInt(nc);
        }

        background = CommonUI.makeStandardBackgroundContainer(title: StringTable.Localize("$TITLE_NEWS_FULL"));
        mainView.add(background);

        textBackground = new("UIImage").init((0, 0), (760, 600), "", NineSlice.Create("graphics/options_menu/op_bbar3.png", (9,9), (14,14)));
        textBackground.pinToParent();
        background.add(textBackground);
        
        // If there is a joystick connected, add the gamepad footer
        if(JoystickConfig.NumJoysticks()) background.addGamepadFooter(InputEvent.Key_Pad_B, "Back");

        /*let dawnPic = new("UIImage").init((0,0), (185, 185), "CHLNGS1");
        dawnPic.pin(UIPin.Pin_Right);
        dawnPic.pin(UIPin.Pin_Bottom, UIPin.Pin_Top, offset: -20);
        background.add(dawnPic);*/

        scrollView = new("UIVerticalScroll").init((0,0), (0,0), 30, 24,
            NineSlice.Create("graphics/options_menu/slider_bg_vertical.png", (14, 6), (16, 24)),
            null,
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down.png", (8,8), (13,13)),
            null,
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_selected.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_selected.png", (8,8), (13,13)),
            UIButtonState.CreateSlices("graphics/options_menu/slider_butt_down_selected.png", (8,8), (13,13))
        );
        scrollView.scrollbar.selectButtonOnFocus = true;
        scrollView.scrollbar.buttonSize = 20;
        scrollView.pinToParent(10, 10, -5, -10);
        scrollView.autoHideScrollbar = true;
        scrollView.scrollbar.minButtonScrollSize = 60;
        scrollView.mLayout.setPadding(20, 20, 20, 20);
        background.add(scrollView);

        loadNews();

        navigateTo(scrollView.scrollbar);

        dimStart = getTime() + 0.2;
    }


    void loadNews() {
        // Load news text file
        int lump = Wads.findLump("NEWSTXT", ns: 0);
        if(lump <= 0) {
            addHeader("ERROR");
            addNewsText("NEWS COULD NOT BE LOADED! NEWSTXT NOT FOUND.");
            return;
        }

        string newsText = Wads.readLump(lump);

        // Parse newsText and create entries, VERY CRUDE
        // Find every chunk until a tag
        string curTag = "";
        string content = "";

        for(uint pos = 0, lastPos = 0; pos < newsText.length();) {
            lastPos = pos;

            if(getNextTag(newsText, curTag, pos)) {
                if(lastPos < pos) {
                    let txt = newsText.mid(lastPos, pos - lastPos);

                    // Skip whitespace and the first \n after a tag
                    for (uint i = 0, nc = 0; i < txt.Length();) {
                        int ch;
                        uint next;
                        [ch, next] = txt.GetNextCodePoint(i);

                        if(ch == int("\n")) {
                            if(nc > 0) {
                                txt = txt.mid(i);
                                break;
                            }
                            nc++;
                        } else if(ch != int("\t") && ch != int(" ") && ch != int("\r")) {
                            txt = txt.mid(i);
                            break;
                        }

                        i = next;
                        if(i >= txt.length()) {
                            txt = "";
                            break;
                        }
                    }

                    // Add text
                    if(txt.length() > 0) addNewsText(txt);
                }

                pos += curTag.length() + 2;
                lastPos = pos;
                
                if(curTag ~== "sep/") {
                    addSpacerLine();
                    pos += 2;
                } else if(getClosingTag(newsText, curTag, pos, content)) {
                    if(curTag ~== "h1") {
                        addHeader(content, 1);
                    } else if(curTag ~== "h2") {
                        addHeader(content, 2);
                    } else if(curTag ~== "h3") {
                        addHeader(content, 3);
                    }
                } else {
                    break;
                }
            } else {
                // Add regular text
                if(lastPos < newsText.length() - 1) {
                    addNewsText(newsText.mid(lastPos, newsText.length() - lastPos));
                }
                
                break;
            }
        }
    }


    bool getNextTag(out string newsText, out string tag, out uint pos) {
        int tagPos = newsText.IndexOf("<", pos);
        int tagEnd = tagPos >= 0 ? newsText.IndexOf(">", tagPos) : -1;

        if(tagPos >= 0 && tagEnd > 0) {
            tag = newsText.mid(tagPos + 1, tagEnd - tagPos - 1);
            pos = tagPos;
            return true;
        }

        return false;
    }


    bool getClosingTag(out string newsText, out string tag, out uint pos, out string content) {
        while(pos < newsText.length()) {
            int tagPos = newsText.IndexOf("</", pos);
            int tagEnd = tagPos >= 0 ? newsText.IndexOf(">", tagPos) : -1;

            if(tagPos > 0 && tagEnd > 0) {
                string ttag = newsText.mid(tagPos + 2, tagEnd - tagPos - 2);
                
                if(ttag ~== tag) {
                    content = newsText.mid(pos, tagPos - pos);
                    pos = tagEnd + 1;
                    return true;
                } else {
                    pos = tagEnd + 1;
                }
            } else {
                return false;
            }
        }

        return false;
    }


    void addSpacerLine() {
        let spacer = new("UIView").init((0,0), (1, 80));
        let spacerLine = new("UIImage").init((0,40), (100, 2), "ONLYWITE");
        spacerLine.alpha = 0.45;
        spacerLine.pin(UIPin.Pin_Left);
        spacerLine.pin(UIPin.Pin_Right);
        spacer.add(spacerLine);
        spacer.pin(UIPin.Pin_Left, offset: 10);
        spacer.pin(UIPin.Pin_Right, offset: -40);
        scrollView.mLayout.addManaged(spacer);
    }

    
    void addHeader(String header, int level = 1) {
        header = header.filter();
        if(header != "" && header != " ") {
            Font fnt = "SEL21FONT";
            double lheight = 40;

            if(level == 0) {
                fnt = "SEL46FONT";
                lheight = 55;
            } else if(level == 2) {
                fnt = "PDA18FONT";
                lheight = 35;
            } else if(level == 3) {
                fnt = "PDA16FONT";
                lheight = 30;
            }

            header = String.Format("\c[HI]%s\c-", header);

            let headerLabel = new("UILabel").init((0,0), (100, lheight), header, fnt, textAlign: UIView.Align_Left);
            headerLabel.multiline = false;
            headerLabel.pin(UIPin.Pin_Left, offset: 10);
            headerLabel.pin(UIPin.Pin_Right, offset: -10);
            scrollView.mLayout.addManaged(headerLabel);
        }
    }


    void addNewsText(String txt) {
        let newsLabel = new("UILabel").init((0,0), (100,100), txt, "PDA16FONT");
        newsLabel.multiline = true;
        newsLabel.pin(UIPin.Pin_Left, offset: 10);
        newsLabel.pin(UIPin.Pin_Right, offset: -10);
        newsLabel.pinHeight(UIView.Size_Min);
        newsLabel.verticalSpacing = 3;

        scrollView.mLayout.addManaged(newsLabel);
    }


    override void beforeFirstDraw() {
        // We must have laid out already, so let's get the scroll size and set the increment accordingly
        scrollView.scrollbar.increment = 25.0 / scrollView.mLayout.frame.size.y;
        scrollView.scrollbar.pageIncrement = scrollView.mLayout.frame.size.y > 0 ? scrollView.frame.size.y / scrollView.mLayout.frame.size.y : 1;
    }

    string getText(string key) {
        let a = StringTable.Localize("$" .. key);
        if(a == key) { return ""; }
        return a;
    }

    override void ticker() {
        Super.ticker();
        animated = true;

        let v = getGamepadRawLook();
        if(abs(v.y) > 0.1) {
            scrollView.scrollBy((v.y * 25.0) / scrollView.mLayout.frame.size.y, true, false, false);
        }
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
        if(mkey == MKEY_BACK) {
            dimStart = 999999;
            return Super.MenuEvent(mkey, fromcontroller);
        }

        if(mkey == MKEY_Up) {
            if(activeControl != scrollView.scrollbar) {
                navigateTo(scrollView.scrollbar);
                return true;
            }
        } else if(mkey == MKEY_Down) {
            if(activeControl == scrollView.scrollbar && scrollView.scrollbar.getNormalizedValue() > 0.99) {
                navigateTo(continueButton);
            }
        }

        return Super.MenuEvent(mkey, fromcontroller);
    }

    override void drawSubviews() {
        double time = getTime();
        if(time - dimStart > 0) {
            double dim = MIN((time - dimStart) / 0.25, 1.0) * 0.8;
            Screen.dim(0xFF020202, dim, 0, 0, lastScreenSize.x, lastScreenSize.y);
        }

        Super.drawSubviews();
    }
}