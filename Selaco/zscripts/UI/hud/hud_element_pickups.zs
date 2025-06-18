struct HUDPickup {
    TextureID tex;
    class<SelacoItem> cls;
    String msg;
    int amount;
    bool isFull;
}


class HUDPickups : HUDElementStartup {
    double topLine, rOffset;
    Font fnt;

    HUDPickup pickups[7];
    int numPickups;
    uint lastTime, lastLineTime;

    const LINE_HEIGHT = 45.0;
    const TEX_SIZE = 38;
    const TICKS_DISPLAYED = double(35 * 4);

    override HUDElement init() {
        fnt = "SEL27OFONT";

        return Super.init();
    }

    void addPickup(class<SelacoItem> cls, int amount = 0, bool isFull = false) {
        readonly<SelacoItem> c = GetDefaultByType(cls);

        // Find existing class first
        for(int x = 0; x < numPickups; x++) {
            if(pickups[x].cls == cls || (c.pickupType && GetDefaultByType(pickups[x].cls).pickupType == c.pickupType)) {
                lastTime = level.totalTime;
                pickups[x].amount += amount > 0 || isFull ? amount : max(1, c.pickupCount);
                pickups[x].isFull = isFull;
                return;
            }
        }

        int maxPickups = isTightScreen ? 3 : pickups.size();
        if(numPickups >= maxPickups) {
            // Shuffle pickups forward
            for(int x = 0; x < pickups.size() - 1; x++) {
                pickups[x].cls = pickups[x+1].cls;
                pickups[x].amount = pickups[x+1].amount;
                pickups[x].tex = pickups[x+1].tex;
                pickups[x].msg = pickups[x+1].msg;
                pickups[x].isFull = pickups[x+1].isFull;
            }
            numPickups--;

            // Clear pickups after maxPickups if necessary
            for(int x = maxPickups; x < pickups.size(); x++) {
                pickups[x].cls = null;
            }
        }

        pickups[numPickups].cls = cls;
        pickups[numPickups].amount = amount > 0 ? amount : max(1, c.pickupCount);
        pickups[numPickups].tex = TexMan.CheckForTexture(c.pickupIcon);
        pickups[numPickups].msg = StringTable.Localize(c.pickupTag);
        pickups[numPickups].isFull = isFull;
        numPickups++;
        lastTime = level.totalTime;
        lastLineTime = level.totalTime;
    }


    override bool tick() {
        if(numPickups == 0) return Super.tick();

        if(owner.hasGasMask > 0) {
            topLine = 150.0 / owner.hudScale;
        } else {
            topLine = 80.0 / owner.hudScale;
        }
        rOffset = -owner.screenPadding.right - 50;

        if(level.totalTime - lastTime > TICKS_DISPLAYED) {
            // Clear pickup messages
            numPickups = 0;
        }

        return Super.tick();
    }

    override void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum)  {
        if(numPickups == 0) return;

        double tics = double(level.totalTime + fracTic);
        double lineTM = clamp((tics - double(lastLineTime)) / 5.0, 0.0, 1.0);
        double totalTM = 1.0 - clamp(((tics - double(lastTime) + 15.0) - TICKS_DISPLAYED) / 15.0, 0.0, 1.0);
        Vector2 offset = (shake + momentum) * 0.55;

        // Draw each pickup
        for(int x = numPickups - 1, cnt = 0; x >= 0; x--) {
            double a = (cnt == 0 ? lineTM : 1.0) * totalTM * alpha;
            double off = (cnt > 0 ? UIMath.EaseOutCubicf(lineTM) * LINE_HEIGHT : LINE_HEIGHT);

            // Draw image
            DrawTexAdvanced(pickups[x].tex, (rOffset, LINE_HEIGHT * (cnt - 1) + off + topLine) + offset, DR_SCALE_IS_SIZE | DR_IMG_RIGHT | DR_SCREEN_RIGHT | DR_WAIT_READY, a, scale: (TEX_SIZE, TEX_SIZE));

            let str = pickups[x].isFull ? String.Format("%s FULL", pickups[x].msg) : String.Format("+%d  %s", pickups[x].amount, pickups[x].msg);

            // Draw text
            DrawStr(
                fnt, 
                str, 
                (rOffset - TEX_SIZE - 10, LINE_HEIGHT * (cnt - 1) + off + topLine + (TEX_SIZE / 2)) + offset,
                DR_SCREEN_RIGHT | DR_TEXT_RIGHT | DR_TEXT_VCENTER,
                pickups[x].isFull ? 0xFFCC3333 : Font.CR_UNTRANSLATED, 
                a,
                false,
                scale: (0.95, 0.98)
            );


            cnt++;
        }
    }
}


// Add fields to the level event handler to keep track of pickups,
// Since we can't directly notify the hud element
extend class LevelEventHandler {
    Array< class< SelacoItem> > pickupQueue;
    Array< class< SelacoItem> > pickupQueueFull;
    Array<int> pickupQueueAmount;

    int lastPickupTick;

    ui void processPickupsUI() {
        // Get HUD element
        HUDPickups element = HUDPickups(HUD.FindElement("HUDPickups"));

        if(element) {
            // Send pickups
            for(int x = 0; x < pickupQueue.size(); x++) {
                element.addPickup(pickupQueue[x], pickupQueueAmount[x]);
            }

            for(int x = 0; x < pickupQueueFull.size(); x++) {
                element.addPickup(pickupQueueFull[x], 0, isFull: true);
            }
        }
    }

    void processPickups() {
        if(level.totalTime > lastPickupTick) {
            pickupQueueAmount.clear();
            pickupQueue.clear();
            pickupQueueFull.clear();
        }
    }

    static void addItemPickup(class<SelacoItem> cls, int amount = 0) {
        let i = Instance();
        i.pickupQueue.push(cls);
        i.pickupQueueAmount.push(amount);
        i.lastPickupTick = level.totalTime;
    }

    static void addItemFull(class<SelacoItem> cls) {
        let i = Instance();
        i.pickupQueueFull.push(cls);
        i.lastPickupTick = level.totalTime;
    }
}