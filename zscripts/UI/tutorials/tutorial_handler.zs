#include "ZScripts/UI/tutorials/major_tutorial.zs"
#include "ZScripts/UI/tutorials/minor_tutorial.zs"
#include "ZScripts/UI/tutorials/normal_tutorial.zs"
#include "ZScripts/UI/tutorials/invasion_tutorial.zs"

// This structure is necessary because you cannot serialize BrokenLines!
// I am fully aware that changes to a font or mods could make this data invalid when loading a savegame.
// But the data only stays around as long as a tutorial is on screen. 
// This should be a fair compromise to precalculate text drawing data instead of doing it every frame
class FixedBrokenLines {
    int numLines;
    string lines[20];
    int widths[20];

    // Just for compatibility
    int Count() {
        return numLines;
    }

    // Just for compatibility
	String StringAt(int line) {
        return lines[line];
    }

    // Just for compatibility
    int StringWidth(int line) {
        return widths[line];
    }

    void FromBrokenLines(BrokenLines bl) {
        numLines = MIN(20, bl.count());
        for(int x = 0; x < numLines && x < 20; x++) {
            lines[x] = bl.StringAt(x);
            widths[x] = bl.StringWidth(x);
        }
    }
}

class TutorialInfo {
    string txt;
    string header;                  // Header/title text
    TextureID image;
    int maxTimeout;                 // Max time on screen, -1 to wait for input
    int msgType;                    // TutMsgType: Determines positioning, size and behaviour
}

enum TutMsgType {
    TUT_MSG_SMALL       = 0,
    TUT_MSG_BIG         = 1,
    TUT_MSG_MANDATORY   = 2,
    TUT_MSG_INVASION    = 3
};


class TutorialHandler : StaticEventHandler {
    mixin ScreenSizeChecker;
    mixin HUDScaleChecker;
    mixin CVARBuddy;
    mixin HudDrawer;

    float scale;

    Array<int> keybinds;
    string kbText;
    bool hudIsDisabled;
    bool playerDiedHorribly;

    TutorialPopup currentTut;
    TutorialItem tutItem;

    ui Vector2 virtualScreenSize;                       // Passed on to drawers
    ui Vector2 screenInsets, virtualScreenScale;        // Ditto
    
    uint mapTicker;

    static private TutorialInfo CalcTut(int type, string txt, string image = "") {
        TutorialInfo tut = new("TutorialInfo");
        Array<string> p;

        // Parse text and check for an image
        txt.split(p, "|||");
        if(p.size() > 2) {
            image = p[0];
        }

        if(p.size() > 1) {
            tut.header = p[p.size() - 2];
        }

        if(p.size() > 0) {
            txt = p[p.size() - 1];
        }

        // Use parsed image or defined image to calc image deets
        if(image != "") {
            TextureID tex = TexMan.CheckForTexture(image, TexMan.Type_Any);
            tut.image = tex;
        }
        tut.txt = txt;

        return tut;
    }

    clearscope bool isShowing() {
        return currentTut != null;
    }

    bool isActive() {
        return currentTut != null && (!tutItem.closing || tutItem.closeTicks == tutItem.openTicks);
    }

    double getCurrentHeight() {
        return currentTut ? currentTut.getHeight() : 0;
    }

    double getCurrentWidth() {
        return currentTut ? currentTut.getWidth() : 0;
    }

    // Creates and adds a tutorial message to the queue
    // The message text and definition are loaded from LANGUAGE
    // Set forced to 1 to show the message even if it has been seen before
    static void TutorialMessage(string code, int type = 1, int forced = 0) {
        // Don't show the tutorial if show_tooltips is disabled
        CVar cv = CVar.GetCVar("g_showtooltips");
        if(cv){
            switch(type) {
                case TUT_MSG_INVASION:
                    break;  // Don't ever skip invasion tutorials
                case TUT_MSG_MANDATORY:
                    if(cv.getInt() == 0) { return; }
                    break;
                default:
                    if(cv.getInt() < 2) { return; }
                    break;
            }   
        }

        let evt = GetHandler();
        if (evt) {
            // Do not show tutorials in the first second
            // This avoids showing armor/weapon tutorials at level spawn
            if(level.totalTime - evt.tutItem.SpawnTime <= 30) { return; }

            // Unless forced, don't show duplicates
            // Don't check for duplicates with long strings
            if(forced <= 0 && code.length() < 40) {
                if(evt.hasSeenTutorial(code)) { return; }
                
                // HACK: To prevent the navigation tutorial from clearing if you fail to get past the first enemy
                // Shame on you for failing so hard.
                if(!(code ~== "TUT_NAVIGATION")) {
                    // Save in Globals as well
                    string tcode = "TUTORIAL_" .. code;
                    int globs = Globals.GetInt(tcode);
                    Globals.SetInt(tcode, globs + 1);
                }
            }

            evt.AddTutorialMessage(code, type);
        } else {
            Console.Printf("\c[RED]TutorialHandler: No tutorial handler for incoming tutorial message!");
        }
    }


    static void ManualTutorialMessage(string title, string text, string image = "", int type = 1) {
        // Don't show the tutorial if show_tooltips is disabled
        CVar cv = CVar.GetCVar("g_showtooltips");
        if(cv){
            switch(type) {
                case TUT_MSG_INVASION:
                    break;  // Don't ever skip invasion tutorials
                case TUT_MSG_MANDATORY:
                    if(cv.getInt() == 0) { return; }
                    break;
                default:
                    if(cv.getInt() < 2) { return; }
                    break;
            }
        }

        let evt = GetHandler();
        if (evt) {
            evt.TutorialMessageMan(title, text, image, type);
        } else {
            Console.Printf("\c[RED]TutorialHandler: No tutorial handler for incoming tutorial message!");
        }
    }

    static void SetTutorialSeen(string code) {
        // Save in Globals as well
        string tcode = "TUTORIAL_" .. code;
        int globs = Globals.GetInt(tcode);
        Globals.SetInt(tcode, globs + 1);
    }

    static clearscope TutorialHandler GetHandler() {
        let evt = TutorialHandler(StaticEventHandler.Find("TutorialHandler"));
        return evt;
    }


    void AddTutorialMessageItem(TutorialInfo tut) {
        int type = tut.msgType;

        // Add tut to queue, or if this is the first one just display it
        if(!currentTut) {
            tutItem.openTicks = 0;
            currentTut = newTutPopup(tut);
            currentTut.Init(tut);
            tutItem.currentTut = currentTut;

            tutItem.tutIndex = 0;
            tutItem.maxTuts = 1;
        } else {
            if(type == TUT_MSG_MANDATORY || type == TUT_MSG_INVASION) {
                // Mandatory tutorials go to the front of the line and push anything that was open back into the queue
                tutItem.queue.Insert(0, currentTut.info);
                currentTut.Destroy();

                currentTut = newTutPopup(tut);
                currentTut.Init(tut);
                tutItem.currentTut = currentTut;

                tutItem.openTicks = 0;
                tutItem.closing = false;
            } else {
                // Add the new one normally
                tutItem.queue.Push(tut);
            }

            tutItem.maxTuts += 1;
        }

        if(type == TUT_MSG_MANDATORY || type == TUT_MSG_INVASION) {
            S_StartSound ("ui/getTutorialBig", CHAN_VOICE, CHANF_UI, snd_menuvolume);
        } else {
            if(tutItem.sndCooldownTicks > 8) {
                S_StartSound ("menu/GetTutorial", CHAN_VOICE, CHANF_UI, snd_menuvolume);
                tutItem.sndCooldownTicks = 0;
            }
        }
        
        UpdateMessage();
    }

    void AddTutorialMessage(string code, int type = 1) {
        string a = Stringtable.Localize("$" .. code);

        TutorialInfo tut = CalcTut(type, a);
        tut.msgType = type;
        
        // Add tut to queue, or if this is the first one just display it
        AddTutorialMessageItem(tut);

        // Signal this message has been seen
        if(code.length() != 0 && code.length() < 40) {
            tutItem.seenTutorials.Insert(code, "1");
        }
    }

    // Manually create a tutorial message with defined text, image and type
    // Does not load anything from LANGUAGE
    void TutorialMessageMan(string title, string text, string image, int type) {
        TutorialInfo tut = new("TutorialInfo");
        tut.header = title;

        // Use parsed image or defined image to calc image deets
        if(image != "") {
            TextureID tex = TexMan.CheckForTexture(image, TexMan.Type_Any);
            tut.image = tex;
        }
        tut.txt = text;
        tut.msgType = type;
        
        AddTutorialMessageItem(tut);
    }


    void UpdateMessage() {
        // Update tutorial messaging and keybinds
        Array<int> tempKeybinds;
		Bindings.GetAllKeysForCommand(keybinds, "+use");
        Bindings.GetAllKeysForCommand(tempKeybinds, "+usereload");
        keybinds.append(tempKeybinds);
        
        //string nmk = UIHelper.NamesForKeys(keybinds);
		kbText = "\cuPRESS $[j,+use]$ \cuTO CLOSE THIS NOTIFICATION";
        kbText = UIHelper.FilterKeybinds(kbText);

        if(tutItem.maxTuts > 1) {
            kbText = kbText .. "  \cj(" .. (tutItem.tutIndex + 1) .. "/" .. tutItem.maxTuts .. ")";
        }
    }

    ui void adjustScreenScale() {
        calcScreenScale(lastScreenSize, virtualScreenSize, screenInsets);

        if(currentTut) {
            currentTut.screenSize = lastScreenSize;
            currentTut.virtualScreenSize = virtualScreenSize;
            currentTut.screenInsets = screenInsets;
            currentTut.isTightScreen = virtualScreenSize.x < 1700 || virtualScreenSize.y < 900;
            currentTut.build();
        }
    }

    TutorialPopup newTutPopup(TutorialInfo tut) {
        switch(tut.msgType) {
            case TUT_MSG_MANDATORY:
                return TutorialPopup(new("MajorTutorialPopup"));
            case TUT_MSG_INVASION:
                return TutorialPopup(new("InvasionTutorialPopup"));
            case TUT_MSG_SMALL:
                return TutorialPopup(new("MinorTutorialPopup"));
            default:
                return new("NormalTutorialPopup");
        }
    }


    // Event Handler Stuff ======================================
	override void WorldLoaded(WorldEvent e) {
        mapTicker = 0;

        // Make sure the player has the tutorial item
        if(!players[consoleplayer].mo)
        {
            return;
        }
        if(players[consoleplayer].mo.countInv("TutorialItem") < 1) {
            players[consoleplayer].mo.GiveInventory("TutorialItem", 1);
        }
        
        playerDiedHorribly = false;
        tutItem = TutorialItem(players[consoleplayer].mo.FindInventory("TutorialItem"));

        // Get the current tutorial
        currentTut = tutItem.currentTut;

        // Get the key for Use
		UpdateMessage();

        if(currentTut) {
            currentTut.build();
        }
	}

    override void ConsoleProcess(ConsoleEvent e) {
        if(e.name ~== "tuts") {
            Console.Printf("\c[BRICK]Tutorials in queue: %d  There is %s current tutorial (%s).", tutItem.queue.size(), currentTut ? "1" : "no", tutItem.currentTut ? "1" : "no");
            for(int x = 0; x < tutItem.queue.size(); x++) {
                Console.Printf("     %d : %s - %d", tutItem.queue[x].msgType, tutItem.queue[x].header, tutItem.queue[x].image);
            }
        }
	}


	override void WorldTick() {
        if(!tutItem) {
            Console.Printf("\c[YELLOW]Tutorial Handler: Tutorial item cannot be found!");
            if(players[consoleplayer].mo) {
                tutItem = TutorialItem(players[consoleplayer].mo.FindInventory("TutorialItem"));
                if(!tutItem) Console.Printf("\c[RED]Tutorial Handler: Tutorial item is no longer in the player inventory!");
            }
            return;
        }

        tutItem.ticks++;
        tutItem.openTicks++;
        tutItem.sndCooldownTicks++;

        hudIsDisabled = iGetCVar("hud_enabled") < 1;

        // No more processing if the player is dead
        if(!players[consolePlayer].mo || players[consolePlayer].mo.health <= 0 || players[consolePlayer].health <= 0) {
            playerDiedHorribly = true;
            return;
        } 
        
        playerDiedHorribly = false;

        // Every two seconds, check keybinds again if necessary
        // This is to handle the dumb edge case where a tutorial is on screen and the user changes keybinds for +use
        if(currentTut && tutItem.ticks % 70 == 0) {
            UpdateMessage();
        }
        
        uint msgTimeTicks = (MajorTutorialPopup.messageTime * GameTicRate);
        if(currentTut && currentTut.info.msgType == TUT_MSG_MANDATORY && tutItem.openTicks >= msgTimeTicks) {
            // Don't open the menu if we are dead!
            if(tutItem.openTicks == msgTimeTicks) {
                // Set menu. This will pause the game!
                S_StartSound ("ui/openTutorialBig", CHAN_VOICE, CHANF_UI, snd_menuvolume);
                Menu.SetMenu("MajorTutorialMenu");
            } else if(!tutItem.closing) {
                // Menu must have just closed as the game has resumed
                // Set the conditions required to close this menu
                tutItem.closing = true;
                tutItem.closeTicks = tutItem.openTicks;
            }
        } else if(currentTut && currentTut.info.msgType == TUT_MSG_INVASION && tutItem.openTicks >= msgTimeTicks) {
            if(tutItem.openTicks == msgTimeTicks) {
                // Set menu. This will pause the game!
                S_StartSound ("ui/openTutorialInvasion", CHAN_VOICE, CHANF_UI, snd_menuvolume);
                Menu.SetMenu("InvasionTutorialMenu");
            } else if(!tutItem.closing) {
                // Menu must have just closed as the game has resumed
                // Set the conditions required to close this menu
                tutItem.closing = true;
                tutItem.closeTicks = tutItem.openTicks;
            }
        }

        // Check for close animation finishing, and destroy or continue the queue
        if(tutItem.closing && tutItem.openTicks - tutItem.closeTicks > 21 && currentTut) {
            // Close the current tutorial, bring on the next if it exists
            tutItem.closing = false;

            currentTut.Destroy();
            currentTut = null;
            tutItem.currentTut = null;

            if(tutItem.queue.size() > 0) {
                TutorialInfo tut = tutItem.queue[0];
                
                currentTut = newTutPopup(tut);
                currentTut.Init(tut);
                tutItem.currentTut = currentTut;

                //currentTut = queue[0];
                tutItem.queue.delete(0);
            }

            if(currentTut) {
                // Any setup necessary?
                tutItem.openTicks = 0;
                tutItem.tutIndex++;
                UpdateMessage();
            } else {
                tutItem.maxTuts = 0;
                tutItem.tutIndex = 0;
            }
        }

        mapTicker++;
	}

    override void UITick() {
        if(mapTicker == 0 || screenSizeChanged() || hudScaleChanged()) {
            adjustScreenScale();
        }

        if(currentTut && tutItem) {
            currentTut.Tick(tutItem.openTicks);
        }
    }

    
    // Per-frame render, Keep it gentle so as not to impact performance
	override void RenderOverlay(RenderEvent e) {
        if(currentTut && tutItem && !Menu.GetCurrentMenu() && !hudIsDisabled && !playerDiedHorribly) {
            if(currentTut.screenSize.x ~== 0) { adjustScreenScale(); }
            currentTut.Draw(kbText, tutItem.closing, ((double(tutItem.openTicks - (tutItem.closing ? tutItem.closeTicks : 0))) + e.FracTic) * ITICKRATE);
        }	
    }

    override bool InputProcess (InputEvent e) {
        if(e.type == InputEvent.Type_KeyDown && tutItem && tutItem.openTicks > 15) {
            for(int x =0; x < keybinds.size(); x++) {
                if(e.KeyScan == keybinds[x]) {
                    // Send a net event to close the current tutorial message
                    EventHandler.SendNetworkEvent("tutClose");

                    // Check if there is an active large tutorial window up, and close that
                    if(menuactive != Menu.Off && Menu.GetCurrentMenu() is "MajorTutorialMenu") {
                        MajorTutorialMenu(Menu.GetCurrentMenu()).cleanClose();
                    }

                    return false;
                }
            }
        }
        

        return false;
    }

    override void NetworkProcess(ConsoleEvent e) {
        if(e.name == "tutClose" && tutItem && tutItem.openTicks > 15 && !tutItem.closing) {
            // Close current tutorial (start close animation)
            if(currentTut && currentTut.info.msgType != TUT_MSG_MANDATORY && currentTut.info.msgType != TUT_MSG_INVASION) {
                tutItem.closing = true;
                //currentTut.startTime = 0;
                tutItem.closeTicks = tutItem.openTicks;

                // Play close sound
                S_StartSound ("menu/CloseTutorial", CHAN_VOICE, CHANF_UI, snd_menuvolume);
            }
        }
    }

    clearscope bool hasSeenTutorial(string code) {
        if(code.length() >= 40) return false;
        return Globals.GetInt("TUTORIAL_" .. code) > 0 || (tutItem && tutItem.seenTutorials && tutItem.seenTutorials.At(code) != "");
    }

    static clearscope bool PlayerHasSeenTutorial(string code) {
        let i = GetHandler();
        return i && i.hasSeenTutorial(code);
    }
}


// Storage for the actual tutorial queue
class TutorialItem : Inventory {
    default {
		inventory.maxamount 1;
	}

    uint ticks, openTicks, sndCooldownTicks, closeTicks;
    int tutIndex, maxTuts;
    bool closing;
    TutorialPopup currentTut;
    Array<TutorialInfo> queue;

    Dictionary seenTutorials;

    override void BeginPlay() {
        Super.BeginPlay();
        seenTutorials = Dictionary.Create();
    }
}