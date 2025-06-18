// Extensible HUD element, can be added or removed from HUD whenever
class HUDElement ui abstract {
    mixin UIDrawer;
    mixin HudDrawer;
    mixin CVARBuddy;

    enum ElementSort {
        SORT_UNDERLAY   = -100,
        SORT_DEFAULT    = 0,
        SORT_CROSSHAIR  = 100,
        SORT_WEAPONBAR  = 1000,
        SORT_ONTOP      = 10000
    }

    bool showWhenDead, showWithoutArmor;
    uint ticks; 
    int order;
    Dawn player;
    HUD owner;

    const ITICKRATE = 1.0/double(TICRATE);

    virtual HUDElement init() {
        ticks = 0;
        order = getOrder();
        return self;
    }

    virtual int getOrder() { return SORT_DEFAULT; }    // Return sorting order, only used when added to the HUD
    virtual void onWeaponChanged(SelacoWeapon oldWeapon, SelacoWeapon newWeapon) {}
    virtual void onHealthChanged(int oldHealth, int newHealth) {}
    virtual void onScreenSizeChanged(Vector2 screenSize, Vector2 virtualScreenSize, Vector2 insets) { 
        self.screenSize = screenSize;
        self.virtualScreenSize = virtualScreenSize;
        self.screenInsets = insets;
        calcTightScreen();
        calcUltrawide();
    }
    virtual void onAttached(HUD owner, Dawn player) {
        self.owner = owner;
        self.player = player;
    }
    virtual void onDetached() {
        self.owner = null;
        self.player = null;
    }

    // return TRUE for the HUD to remove this element after the tick
    virtual bool tick() { ticks++; return false; }
    virtual void draw(double fracTic, float alpha, Vector2 shake, Vector2 momentum) {}

    // Helpers =================================================
    protected int invCount(class<Inventory> inv, int defValue = 0) {
		let i = owner ? owner.CPlayer.mo.FindInventory(inv) : null;
		return i ? i.Amount : defValue; 
	}

	protected Inventory inv(class<Inventory> inv) {
		return owner ? owner.CPlayer.mo.FindInventory(inv) : null;
	}

    double tmTime(double ticFrac) {
		return (ticFrac + double(ticks)) * ITICKRATE;
	}
}

// Subclass this to automatically add these elements to the HUD when it is created
class HUDElementStartup : HUDElement abstract {}