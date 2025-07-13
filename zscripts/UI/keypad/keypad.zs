#include "ZScripts/UI/helper.zs"

class KeypadGlobalHandler : StaticEventHandler {
    string kpCode;
    string kpSuccessStory;
    string kpFailStory;
    Keypad kpItem;
    int imsimAttempts;
    int successNotifyDelay;
    bool isValidCode; // used to not give 'Master of unlocking' challenge for "joke" codes

    const SuccessNotifyTicks = 30;

    clearscope static KeypadGlobalHandler instance() {
        return KeypadGlobalHandler(StaticEventHandler.Find("KeypadGlobalHandler"));
    }

    // NOTE: Fail script is no longer used for ACS version, keeping the param so as not to crash previous builds
    static void ShowKeypad(Actor activator, string code, string successScript, string failScript = "") {
        // Ignore Activator now, use local player always
        activator = players[consolePlayer].mo;

        // Check to see if menu is already up, and ignore this call
        //let m = Menu.GetCurrentMenu();
        if(menuactive) {
            return;
        }

        let evt = instance();
        if (evt) {
            if(evt.successNotifyDelay > 0) { return; }  // There is a delay after using another keypad, cancel until that delay is over

            evt.kpCode = code;
            evt.kpSuccessStory = successScript;
            evt.kpFailStory = failScript;
            evt.successNotifyDelay = 0;

            S_StartSound ("menu/kpOpen", CHAN_VOICE, CHANF_UI, snd_menuvolume);
            Menu.SetMenu("KeypadMenu2");
        }
    }


    static void ShowKeypadForItem(Actor activator, Keypad keypadItem) {
        // Check to see if menu is already up, and ignore this call
        if(menuactive) {
            return;
        }

        let evt = instance();
        if (evt) {
            if(evt.successNotifyDelay > 0) { return; }  // There is a delay after using another keypad, cancel until that delay is over

            evt.kpCode = keypadItem.keypadCode;
            evt.kpItem = keypadItem;
            evt.kpSuccessStory = "";
            evt.kpFailStory = "";
            evt.successNotifyDelay = 0;

            S_StartSound ("menu/kpOpen", CHAN_VOICE, CHANF_UI, snd_menuvolume);
            Menu.SetMenu("KeypadMenu2");
        }
    }

    // Cancel keypad if it is open, otherwise does nothing
    static void Cancel() {
        let evt = instance();
        if(evt) {
            evt.reset();
        }
    }

    override void worldTick() {
        // Handle delay for having unlocked a keypad
        if(successNotifyDelay > 0) {
            successNotifyDelay++;

            if(successNotifyDelay > SuccessNotifyTicks) {
                successNotifyDelay = 0;
                if(isValidCode) {
                    isValidCode = false;
                    Stats.AddStat(STAT_KEYPAD_UNLOCKED, 1, 0);
                }
            }
        }
    }

    override void networkProcess(ConsoleEvent e) {
        let id = e.Name.IndexOf("kpCodeEnter:");
        if(id == 0) {
            let code = e.Name.Mid(12);
            if(code == kpCode) {
                if(kpItem) {
                    kpItem.keypadSuccess();
                    reset();
                } else {
                    let scriptname = kpSuccessStory;
                    reset();
                    players[consolePlayer].mo.ACS_NamedExecute(scriptname);
                }

                isValidCode = true;
                successNotifyDelay = 1;
            } else if(code == "0451") {
                imsimAttempts++;
                isValidCode = false;
                if(imsimAttempts == 2) {
                    players[consolePlayer].mo.A_SpawnItem("NothingInteresting");
                }
                players[consolePlayer].mo.A_SpawnItemEx("KeypadShock", 0, 0, 32);
                reset();
                successNotifyDelay = 1;
            } else {
                isValidCode = false;

                // Run failure script, but only on kpItem for now
                if(kpItem) {
                    kpItem.keypadFailure();
                }
            }
        }

        if(e.Name == "kpCancel") {
            reset();
        }
    }

    void reset() {
        kpCode = "";
        kpSuccessStory = "";
        kpFailStory = "";
        kpItem = NULL;
    }
}


