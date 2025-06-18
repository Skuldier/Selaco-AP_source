extend class HUD {
    protected void saveAnimStart(bool fromMenu = false) {
        saveAnim = new("SavingAnimation").init();
		saveAnim.setUIScale(scale);
        saveAnim.startTime = getTime();
        saveAnim.showEmblem = !fromMenu;
        saveAnim.preparing = !fromMenu;
    }

    protected void saveAnimEnd() {
        if(!saveAnim) {
            saveAnim = new("SavingAnimation").init();
		    saveAnim.setUIScale(scale);
        }

        saveAnim.preparing = false;
        saveAnim.startTime = getTime();
    }

    static void SaveStarted() {
        let h = HUD(StatusBar);
        if(h) {
            h.saveAnimStart();
        }
    }

    static void SaveCompleted() {
        let h = HUD(StatusBar);
        if(h) {
            h.saveAnimEnd();
        }
    }

    static void SavedFromMenu() {
        let h = HUD(StatusBar);
        if(h) {
            h.saveAnimStart(true);
        }
    }

    static Vector2 ShakeOffset() {
        let h = HUD(StatusBar);
        if(h) {
            return h.currentOffset;
        }
        return (0,0);
    }

    static void ShowWeaponInfo() {
        let h = HUD(StatusBar);
        if(h) {
            h.changeWeaponTime = MSTime() / 1000.0;
        }
    }

    static void WeaponBarTimeout(int ticks) {
        let h = HUD(StatusBar);
        if(h) {
            h.wpbar.cooldown = max(ticks, h.wpbar.cooldown);
        }
    }

    static HUDElement FindElement(class<HUDElement> cls) {
        let h = HUD(StatusBar);
        if(h) {
            for(int x = h.elements.size() - 1; x >= 0; x--) {
                if(h.elements[x] is cls) {
                    return h.elements[x];
                }
            }
        }

        return null;
    }

    static void AddElement(class<HUDElement> cls) {
        let h = HUD(StatusBar);
        if(h) {
            let element = HUDElement(new(cls)).init();

            if(h.elements.size() == 0) {
                h.elements.push(element);
            } else {
                for(int y = 0; y < h.elements.size(); y++) {
                    if(h.elements[y].getOrder() > element.getOrder()) {
                        h.elements.Insert(y, element);
                        break;
                    } else if(y + 1 == h.elements.size()) {
                        h.elements.Push(element);
                        break;
                    }
                }
            }

            element.onScreenSizeChanged(h.screenSize, h.virtualScreenSize, h.screenInsets);

            if(h.CPlayer && h.CPlayer.mo is 'Dawn') element.onAttached(h, Dawn(h.CPlayer.mo));
        }
    }

    static HUDElement RemoveElement(class<HUDElement> cls) {
        let h = HUD(StatusBar);
        if(h) {
            for(int x = h.elements.size() - 1; x >= 0; x--) {
                if(h.elements[x] is cls) {
                    let element = h.elements[x];
                    h.elements.delete(x);
                    return element;
                }
            }
        }

        return null;
    }

    static void AddElementStr(String className) {
        AddElement(className);
    }

    static HUDElement RemoveElementStr(String className) {
        return RemoveElement(className);
    }

    static void SwitchToGasMask(bool mask, int startTime = 0) {
        let h = HUD(StatusBar);
        if(h) {
            h.overlay.switchToGasMask(mask, startTime);
        }
    }
}