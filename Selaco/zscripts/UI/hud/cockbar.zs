class Cockbar : BaseStatusBar {
    mixin UIDrawer;
    mixin HudDrawer;
    mixin HUDScaleChecker;
    mixin CVARBuddy;

    double scale, alpha;
    double hudScale;


	protected int invCount(class<Inventory> inv, int defValue = 0) {
		let i = CPlayer.mo.FindInventory(inv);
		return i ? i.Amount : defValue; 
	}

	protected Inventory inv(class<Inventory> inv) {
		return CPlayer.mo.FindInventory(inv);
	}

    protected double getAirSupply(Dawn player) {
        return MIN(1.0, double(player.player.air_finished - Level.maptime) / double(int(Level.airsupply * player.AirCapacity)));
    }

    override void Init() {
		Super.Init();

        cvHudScale = fGetCVar('hud_scaling');
        hudScale = cvHudScale > 0 ? cvHudScale : HUD_SCALING_DEFAULT;
        scale = calcScreenScale(screenSize, virtualScreenSize, screenInsets);

        alpha = 1.0;
    }

    override void ScreenSizeChanged() {
		Super.ScreenSizeChanged();

        scale = calcScreenScale(screenSize, virtualScreenSize, screenInsets);
        cvHudScale = fGetCVar('hud_scaling');
        hudScale = cvHudScale > 0 ? cvHudScale : HUD_SCALING_DEFAULT;
	}

    override void Tick() {
        Super.Tick();

        if(hudScaleChanged()) ScreenSizeChanged();
    }
}