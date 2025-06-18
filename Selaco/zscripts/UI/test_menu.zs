class TestMenu : UIMenu {
	const fart = "aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ" ;
	SoundHandle handle;

	override void init(Menu parent) {
		Super.init(parent);
		Console.Printf(UIHelper.FilterKeybinds("Keybinds for clear: $<clear>$"));
		string butts;
		string buttFormat = "Here are some button icons! %s";
		for(int x = 0x80; x <= 0x9A; x++) {
			butts = butts .. String.Format("%c ", x);
		}

		string letters;
		for(int x = 32; x <= 93; x++) {
			letters = letters .. String.Format("%c ", x);
		}

		letters = letters ..  "\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

		let l = new("UILabel").init((100, 100), (600, 1200), letters, "SEL21OFONT");
		mainView.add(l);

		l = new("UILabel").init((710, 100), (600, 1200), "0123456789", "SEFNT100", Font.CR_UNTRANSLATED);
		l.pinHeight(UIView.Size_Min);
		l.backgroundColor = 0xBBFF00FF;
		mainView.add(l);


		// todo: Verify that calculated string widths are correct vs actual string width on screen
		Font sfnt = "SELACOFONT";
		Console.Printf("String width: %d" , sfnt.StringWidth("Lorem ipsum dolor sit amet"));

		let br = sfnt.BreakLines("Lorem ipsum dolor sit amet", 384);
		Console.Printf("Lines: %d", br.count());
		for(int x =0; x < br.count(); x++) {
			Console.Printf("Line %d  Width %d", x, br.stringWidth(x));
		}


		Console.Printf("Num Joysticks: %d", JoystickConfig.NumJoysticks());

		for(int x = 0; x < JoystickConfig.NumJoysticks(); x++) {
			let j = JoystickConfig.GetJoystick(x);

			Console.Printf("Joystick: %s", j.getName());
		}


		for(int y = 0; y < LevelInfo.GetLevelInfoCount(); y++) {
			let info = LevelInfo.GetLevelInfo(y);
			int c2 = Wads.CheckNumForFullName("maps/" .. info.MapName .. ".wad");
			int wadnum = Wads.GetLumpWadNum(c2);

			Console.Printf("Level info for %s - %s :     (C1 %d   WadNum %d  %s)", info.mapname, info.LookupLevelName(), c2, wadnum, Wads.GetWadName(wadnum));
		}

		mainView.requiresLayout = true;

		handle = S_StartSound("PLASMARIFLE/LOOP", CHAN_VOICE, CHANF_LOOP | CHANF_UI, volume: 1, pitch:1);
		
		SoundHandle handle2 = handle;
		SoundHandle handle3;
		Console.Printf("Handle: %d Handle2: %d Handle3: %d IsValid: %d  IsValid3: %d", handle, handle2, handle3, handle.isValid(), handle3.isValid());
		Console.Printf("Isplaying: %d", handle.Isplaying());
	}

	override void Ticker() {
		Super.ticker();

		//S_SoundHandlePitch(handle, 1.0 + ((ticks % 300) / 300.0) * 1.5);
		handle.setPitch(1.0 + ((ticks % 100) / 100.0) * 1.5);
		handle.setVolume((ticks % 50) / 50.0);
		if(ticks % 35 == 0)
			Console.Printf("Isplaying: %d", handle.Isplaying());
	}

	override bool onBack() {
		//S_StopSoundHandle(handle);
		handle.stopSound();
		Console.Printf("End IsPlaying: %d", handle.Isplaying());
		return Super.onBack();
	}


	bool CheckForUsermaps() {
		for(int y = 0; y < LevelInfo.GetLevelInfoCount(); y++) {
			let info = LevelInfo.GetLevelInfo(y);
			int c2 = Wads.CheckNumForFullName("maps/" .. info.MapName .. ".wad");
			int wadnum = Wads.GetLumpWadNum(c2);

			if((info.cluster < 1 || info.cluster > 3) && wadnum > 2) return true;
		}
		return false;
	}
}



class Fishy : Fish1 {
	SoundHandle ambientSound;
	bool pitchFlop;

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		ambientSound = StartSound("bro/music", CHAN_AUTO, CHANF_LOOPING, 1.0, pitch: 1.1);
	}

	override void Tick() {
		Super.Tick();

		if(level.time % 70 == 0) {
			ambientSound.setPitch(pitchFlop ? 1.0 : 1.1);
			pitchFlop = !pitchFlop;
		}
	}
}