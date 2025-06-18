class OptionMenuItemTooltipOption : OptionMenuItemOption {
	String mTooltip;
    String mDefaultImage;
    Name mValueDescriptions;
    int mSelection;

	OptionMenuItemTooltipOption Init(String label, String tool, String defImage, Name command, Name values, Name valuesDescriptions = "none", CVar graycheck = null, int center = 0) {
		mTooltip = tool.Filter();

        mDefaultImage = defImage;
        mValueDescriptions = valuesDescriptions;
        mSelection = -1;
		Super.Init(label, command, values, graycheck, center);
		return self;
	}

    // Returns [description, image]
    string, string, string getValueDescription(int selection = -1) {
        int cnt = OptionValues.GetCount(mValues);
        if(selection < 0) {
            selection = GetSelection();
        }

		string d = mValueDescriptions ? StringTable.Localize(OptionValues.GetText(mValueDescriptions, selection)) : "";
        string i = mValueDescriptions ? StringTable.Localize(OptionValues.GetTextValue(mValueDescriptions, selection)) : "";
        string vt = StringTable.Localize(OptionValues.GetText(mValues, selection));
        return d, i, vt;
	}

    override int GetSelection() {
        return mSelection == -1 ? findSelection() : mSelection;
    }

    virtual int findSelection() {
        mSelection = Super.GetSelection();
        return mSelection;
    }

    override void SetSelection(int Selection) {
        Super.SetSelection(Selection);
        mSelection = selection;
    }
}

class OptionMenuItemTooltipPreset : OptionMenuItemTooltipOption {
    int mOffItem;

    OptionMenuItemTooltipOption Init(String label, String tool, String defImage, Name values, Name valuesDescriptions, int offItem = -1) {
		mTooltip = tool.Filter();

        mDefaultImage = defImage;
        mValueDescriptions = valuesDescriptions;
        mSelection = -1;
        mOffItem = offItem;
		Super.Init(label, tool, defImage, "", values, valuesDescriptions);
		return self;
	}

    double cv(string c, double def = 0) {
        CVar c = CVar.FindCVar(c);
        if(c) {
            if(c.GetRealType() == Cvar.CVAR_Int) {
                return c.GetInt();
            } else {
                return c.GetFloat();
            }
        }

        return def;
    }

    void setCV(string c, double val) {
        CVar c = CVar.FindCVar(c);
        if(c) {
            if(c.GetRealType() == Cvar.CVAR_Int) {
                c.SetInt(int(val));
            } else {
                c.SetFloat(val);
            }
        }
    }

    override int findSelection() {
        // Check all option values against cvars in the list and see which option is correct
        for(int x = 0; x < OptionValues.GetCount(mValues); x++) {
            string preset = OptionValues.GetTextValue(mValues, x);
            bool noGood = false;

            for(int y = 0; y < OptionValues.GetCount(preset); y++) {
                if(!(OptionValues.GetValue(preset, y) ~== cv(OptionValues.GetText(preset, y), -999))) {
                    noGood = true;
                    //Console.Printf("DEBUG: %s - (%s)    %d-%d is no good: %f doesn't match %f", preset, OptionValues.GetText(preset, y),  x,y,  OptionValues.GetValue(preset, y), cv(OptionValues.GetText(preset, y), -999));
                    break;
                }
            }

            if(!noGood) {
                mSelection = x;
                return x;
            }
        }
        mSelection = mOffItem;
        return mSelection;
    }

    override void SetSelection(int selection) {
        mSelection = selection;

        if(selection >= 0 && selection < OptionValues.GetCount(mValues)) {
            string preset = OptionValues.GetTextValue(mValues, selection);

            for(int y = 0; y < OptionValues.GetCount(preset); y++) {
                string cvarname = OptionValues.GetText(preset, y);
                double value = OptionValues.GetValue(preset, y);

                setCV(cvarname, value);
            }
        }
	}
}

// Special item for audio device, when changed it should apply the changes by resetting the audio engine
class OptionMenuItemTooltipOptionAudioDevice : OptionMenuItemTooltipOption {
    string, string, string getValueDescription(int selection = -1) {
        int cnt = OptionValues.GetCount(mValues);
        if(selection < 0) {
            selection = GetSelection();
        }

		string d = mValueDescriptions ? StringTable.Localize(OptionValues.GetText(mValueDescriptions, selection)) : "";
        string i = mValueDescriptions ? StringTable.Localize(OptionValues.GetTextValue(mValueDescriptions, selection)) : "";
        string vt = getItem(selection);

        return d, i, vt;
	}

    override string getItem(int item) {
        string vt = StringTable.Localize(OptionValues.GetText(mValues, item));

        // Try to filter out unnecessary info from OpenAL
        int len = vt.length();
        int idxa = vt.MakeLower().indexOf("openal soft on") + 15;

        if(idxa < len) {
            vt = vt.mid(idxa);
        }

        return vt;
    }

    override void setSelection(int Selection) {
        int sel = mSelection;

        Super.setSelection(Selection);

        // Reset the sound device if this is not the previous selection
        let menu = Menu.GetCurrentMenu();
        if(Selection != sel) SelacoOptionActivator.RunCCMD("snd_reset", "Reset Sound Device", menu);
    }
}

// Special item for video device
class OptionMenuItemTooltipOptionVideoDevice : OptionMenuItemTooltipOption {
    Array<String> devices;

    OptionMenuItemTooltipOptionVideoDevice Init(String label, String tool, String defImage, Name command, Name values, Name valuesDescriptions = "none", CVar graycheck = null, int center = 0) {
		Screen.GetDeviceList(devices);
        Super.Init(label, tool, defImage, command, values, valuesDescriptions, graycheck, center);
		return self;
	}

    override string getItem(int item) {
        if(devices.size() == 0) {
            Screen.GetDeviceList(devices);
        }

        if(item < 0 || item >= devices.size()) {
            return "Unknown Device";
        }

        return devices[item];
    }

    override void setSelection(int Selection) {
        Super.setSelection(Selection);
    }

    override int numItems() {
        if(devices.size() == 0) {
            Screen.GetDeviceList(devices);
        }

        return devices.size();
    }
}


// Special item for listing available screens
class OptionMenuItemTooltipOptionScreen : OptionMenuItemTooltipOption {
    Array<String> screens;

    const DEFAULT_SCREEN = "0. Default";

    OptionMenuItemTooltipOptionScreen Init(String label, String tool, String defImage, Name command, Name values, Name valuesDescriptions = "none", CVar graycheck = null, int center = 0) {
        Screen.GetScreenList(screens);
        screens.insert(0, DEFAULT_SCREEN);
        Super.Init(label, tool, defImage, command, values, valuesDescriptions, graycheck, center);
		return self;
	}

    override string getItem(int item) {
        if(screens.size() == 0) {
            Screen.GetScreenList(screens);
            screens.insert(0, DEFAULT_SCREEN);
        }

        if(item < 0 || item >= screens.size()) {
            return "Unknown Device";
        }

        return screens[item];
    }

    override void setSelection(int Selection) {
        Super.setSelection(Selection);
    }

    override int numItems() {
        if(screens.size() == 0) {
            Screen.GetScreenList(screens);
            screens.insert(0, DEFAULT_SCREEN);
        }

        return screens.size();
    }
}




class OptionMenuItemTooltipOptionBar : OptionMenuItemTooltipOption { } 
class OptionMenuItemRequire : OptionMenuItem {
    CVar mCvar;

    OptionMenuItemRequire Init(Name cvName) {
        mCvar = CVar.FindCVar(cvName);
        return self;
    }
}

class OptionMenuItemRequireNone : OptionMenuItemRequire { }
class OptionMenuItemMustHave : OptionMenuItem {
    CVar mCvar;

    OptionMenuItemMustHave Init(Name cvName) {
        mCvar = CVar.FindCVar(cvName);
        return self;
    }
}

class OptionMenuItemMustNotHave : OptionMenuItemMustHave { }

class OptionMenuItemDisable : OptionMenuItem {
    OptionMenuItemDisable Init() {
        Super.Init("","");
        return self;
    }
}

class OptionMenuItemDisableInGame : OptionMenuItem {
    OptionMenuItem Init() {
        Super.Init("","");
        return self;
    }
}

class OptionMenuItemOnlyInTitlemap : OptionMenuItemDisableInGame {}

class OptionMenuItemOnlyInGame : OptionMenuItem {
    OptionMenuItem Init() {
        Super.Init("","");
        return self;
    }
}


class OptionMenuItemSeparator : OptionMenuItem {
    int mSize;

    OptionMenuItemSeparator Init(int size = 2) {
        mSize = size;
        Super.Init("","");
        return self;
    }
}

class OptionMenuItemSeparatorTitle : OptionMenuItemSeparator {
    OptionMenuItemSeparatorTitle Init(String label = "", int size = 2) {
        Super.Init(size);
        mLabel = label;
        return self;
    }
}

class ListMenuItemSeparator : ListMenuItem {
    int mSize;

    ListMenuItemSeparator Init(int size = 2) {
        mSize = size;
        Super.Init();
        return self;
    }
}

class OptionMenuItemSpace : OptionMenuItem {
    int mSize;

    OptionMenuItemSpace Init(int size = 20) {
        mSize = size;
        Super.Init("","");
        return self;
    }
}

class OptionMenuItemSubtext : OptionMenuItemStaticText {
    Font mFont;

    OptionMenuItemSubtext Init(String label, int cr = -1, string fnt = "PDA13FONT") {
        Super.Init(label, cr);
        mFont = Font.GetFont(fnt);
        
        return self;
    }
}

class OptionMenuItemMenuLink : OptionMenuItem {
    string mMenu;

    OptionMenuItemMenuLink Init(string title = "Menu", string menuName = "") {
        Super.Init(title,"");
        mMenu = menuName;

        return self;
    }
}


class OptionMenuItemResolutionOption : OptionMenuItemTooltipOption {
    OptionMenuItemResolutionOption Init(String label, String tooltip, String defImage, Name values, Name valuesDescriptions = "", CVar graycheck = null) {
        Super.Init(label, tooltip, defImage, "", values, valuesDescriptions, graycheck, false);
        return self;
    }

    string getSelectionTitle() {
        if(mSelection == -1) { getSelection(); }

        if(mSelection == 0) {
            return StringTable.Localize(OptionValues.GetText(mValues, mSelection)) .. " (" .. Screen.GetWidth() .. "x" .. Screen.GetHeight() .. ")";
        }

        return StringTable.Localize(OptionValues.GetText(mValues, mSelection));
    }

    override void setSelection(int Selection) {
        mSelection = selection;
        
        // Determine the resolution
        if(mSelection > 0) {
            int w, h;
            [w, h] = resFromString(StringTable.Localize(OptionValues.GetTextValue(mValues, mSelection)));
            
            if(w > 0 && h > 0) {
                // Set resolution with hacks
                let menu = Menu.GetCurrentMenu();
                SelacoOptionActivator.RunCCMD(String.Format("menu_resolution_set_custom %d %d", w, h), "Set Resolution", menu);
                SelacoOptionActivator.RunCCMD("menu_resolution_commit_changes", "Apply Resolution", menu);
            }
        } else {
            mSelection = -1;
            getSelection();
        }
    }

    protected int, int resFromString(string str) {
        Array<string> splits;
        str.split(splits, "x");

        if(splits.size() == 2) {
            return splits[0].ToInt(10), splits[1].ToInt(10);
        }

        return 0, 0;
    }

    override int getSelection() {
        if(mSelection != -1) { return mSelection; }

        // Determine selection from current screen size
        int sw = Screen.GetWidth();
        int sh = Screen.GetHeight();

        for(int x =0; x < OptionValues.GetCount(mValues); x++) {
            int w, h;
            [w, h] = resFromString(StringTable.Localize(OptionValues.GetTextValue(mValues, x)));

            if(sw == w && sh == h) {
                mSelection = x;
                return x;
            }
        }

        mSelection = 0;
        return 0;
    }

    void setCustomValue(int width, int height) {
        if(width < 800 || height < 600) return;
        
        Console.Printf("\c[YELLOW]Attempting to set custom Resolution %d x %d...", width, height);

        let menu = Menu.GetCurrentMenu();
        SelacoOptionActivator.RunCCMD(String.Format("menu_resolution_set_custom %d %d", width, height), "Set Resolution", menu);
        SelacoOptionActivator.RunCCMD("menu_resolution_commit_changes", "Apply Resolution", menu);

        // Determine the new selection value, we cannot rely on the screen size because it won't apply until the next frame
        mSelection = 0;

        for(int x = 0; x < OptionValues.GetCount(mValues); x++) {
            int w, h;
            [w, h] = resFromString(StringTable.Localize(OptionValues.GetTextValue(mValues, x)));

            if(width == w && height == h) {
                mSelection = x;
                break;
            }
        }
    }
}


class OptionMenuItemTooltipSlider : OptionMenuItemSlider {
    String mTooltip;
    String mDefaultImage;

    OptionMenuItemSlider Init(String label, String tooltip, String defImage, Name command, double min, double max, double step, int showval = 1, CVar graycheck = NULL) {
		mTooltip = tooltip;
        mDefaultImage = defImage;
        
        Super.Init(label, command, min, max, step, showval, graycheck);
		mCVar = CVar.FindCVar(command);

		return self;
	}
}


class OptionMenuItemTooltipCommand : OptionMenuItemCommand {
    String mFunc;
    String mTooltip;

    OptionMenuItemTooltipCommand Init(String label, String tooltip, String defImage, Name command, String func = "", bool closeonselect = false) {
        Super.Init(label, command, closeonselect : closeonselect);
        mFunc = func;
        mTooltip = tooltip;

        return self;
    }
}

class OptionMenuItemColorPickerDD : OptionMenuItemTooltipOption {
    OptionMenuItemColorPickerDD Init(String label, String tool, String defImage, Name command, Name values, Name valuesDescriptions = "none", CVar graycheck = null, int center = 0) {
		Super.init(label, tool, defImage, command, values, valuesDescriptions, graycheck, center);

		return self;
	}

    override int findSelection() {
        mSelection = OptionMenuItemOption.GetSelection();
        if(mSelection < 0) mSelection = 0;
        return mSelection;
    }

    override void setSelection(int Selection) {
        if(Selection > 0) {
            OptionMenuItemOption.SetSelection(Selection);
        }
        mSelection = selection;
	}

    Color getColor() {
        Color col;
        if(mCVar) col = mCVar.getInt();
        else col = 0;

        return col;
    }
}


class OptionMenuItemModHeader : OptionMenuItemOption {
    String mName, mAuthor, mDescription, mBanner, mReadMe;

	OptionMenuItemModHeader Init(String name, String author, String description = "", String bannerGFX = "", String readme = "") {
		mName = name;
        mAuthor = author;
        mDescription = description;
        mBanner = bannerGFX;
        mReadMe = readme;

		Super.Init("", "none", "");
		return self;
	}
}


class ListMenuItemTextItemImage : ListMenuItemTextItem
{
	String mImage;

	void Init(ListMenuDescriptor desc, String text, String image, String hotkey, Name child, int param = 0) {
        mImage = image;

        Super.Init(desc, text, hotkey, child, param);
    }
}