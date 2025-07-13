class SelacoEnterKey : SelacoGamepadMenu {
	OptionMenuItemControlBase mOwner;
    SOMOptionView mSourceView;
    UIView centerView;
    UILabel bindLabel;
    int timeout;
    double dimStart;

	void Init(Menu parent, OptionMenuItemControlBase owner, SOMOptionView optionView, bool withGamepad = false) {
		Super.Init(parent);
		mOwner = owner;
        mSourceView = optionView;
		SetMenuMessage(1);
		menuactive = Menu.WaitKey;	// There should be a better way to disable GUI capture...

        centerView = new("UIView").init((0,0), (450, 80));
        centerView.pinWidth(1.0, offset: 30, isFactor: true);
        centerView.pin(UIPin.Pin_HCenter, value: 1.0);
        centerView.pin(UIPin.Pin_VCenter, value: 1.0);
        centerView.alpha = 0;
        centerView.clipsSubviews = false;

        let background = new("UIImage").init((0, 0), (760, 300), "", NineSlice.Create("graphics/options_menu/op_bbar4.png", (9,9), (14,14)));
        background.pinToParent(-10, -10, 10, 32);
        centerView.add(background);

        mainView.add(centerView);


        // Text labels
        let title = new("UILabel").init((0,0), (70, 30), StringTable.Localize("$KEYBIND_PROMPT"), "SEL21FONT", 0xFFFFFFFF, UILabel.Align_Centered);
        title.pin(UIPin.Pin_Left, offset: 15);
        title.pin(UIPin.Pin_Right, offset: -15);
        title.pin(UIPin.Pin_Top, offset: 15);
        title.multiline = false;
        centerView.add(title);

        let subTitle = new("UILabel").init((0,0), (70, 30), optionView.label.text, "SEL21FONT", 0xFFDDDDDD, UILabel.Align_Centered, (0.8, 0.8));
        subTitle.pin(UIPin.Pin_Left, offset: 15);
        subTitle.pin(UIPin.Pin_Right, offset: -15);
        subTitle.pin(UIPin.Pin_Top, offset: 55);
        subTitle.multiline = false;
        centerView.add(subTitle);

        bindLabel = new("UILabel").init((0,0), (70, 100), "", "SEL27OFONT", 0xFFDDDDDD, UILabel.Align_Centered, (1.5, 1.5));
        bindLabel.pin(UIPin.Pin_Left, offset: 15);
        bindLabel.pin(UIPin.Pin_Right, offset: -15);
        bindLabel.pin(UIPin.Pin_VCenter, value: 1.0, offset: 15);
        bindLabel.multiline = false;
        centerView.add(bindLabel);

        let noteString = UIHelper.FilterKeybinds( StringTable.Localize(withGamepad ? "$ESC_PROMPT_GAMEPAD" : "$ESC_PROMPT") );
        let subTitle2 = new("UILabel").init((0,0), (70, 15), noteString, "PDA13FONT", 0xFFDDDDDD, UILabel.Align_Centered, (1, 1));
        subTitle2.pin(UIPin.Pin_Left, offset: 15);
        subTitle2.pin(UIPin.Pin_Right, offset: -15);
        subTitle2.pin(UIPin.Pin_Bottom, offset: -10);
        subTitle2.multiline = false;
        subTitle2.setAlpha(0.85);
        centerView.add(subTitle2);

        dimStart = getRenderTime();
	}


	override bool TranslateKeyboardEvents() { return false; }

	private void SetMenuMessage(int which) {
		let parent = OptionMenu(mParentMenu);
		if (parent != null) {
			let it = parent.GetItem('Controlmessage');
			if (it != null) {
				it.SetValue(0, which);
			}
		}
	}
    

	override bool OnInputEvent(InputEvent ev) {
		// This menu checks raw keys, not GUI keys because it needs the raw codes for binding.
		if (ev.type == InputEvent.Type_KeyDown) {
			mOwner.SendKey(ev.KeyScan);
			menuactive = Menu.On;
			SetMenuMessage(0);
            //Close();
            mSourceView.returnFromKeybind();
			mParentMenu.MenuEvent((ev.KeyScan == InputEvent.KEY_ESCAPE) ? Menu.MKEY_Abort : Menu.MKEY_Input, 0);

            if(ev.KeyScan != InputEvent.KEY_ESCAPE && ev.KeyScan != InputEvent.Key_Pad_Start) {
                bindLabel.setText(KeyBindings.NameKeys(ev.KeyScan, 0));
                timeout = 10;
                dimStart = getRenderTime();
            } else {
                Close();
            }

			return true;
		}
		return false;
	}


    override void Ticker() {
        Super.Ticker();

        if(timeout > 0) {
            timeout--;

            if(timeout == 0) {
                timeout = -1;
                Close();
            }
        }

        if(ticks == 1) {
            let anim = centerView.animateFrame(
                0.1,
                fromSize: (lastScreenSize.x + 30, 80),
                toSize: (lastScreenSize.x + 30, 250),
                fromAlpha: 0.0,
                toAlpha: 1,
                layoutSubviewsEveryFrame: true,
                ease: Ease_Out
            );

            anim.layoutEveryFrame = true;
        }
    }


	override void Drawer() {
		mParentMenu.Drawer();

        Screen.ClearClipRect();
        
        double time = getRenderTime();
        double dim = timeout == 0 ? MIN((time - dimStart) / 0.12, 1.0) * 0.7  : MAX((dimStart - time) / 0.12, 0.0) * 0.7;
        Screen.dim(0xFF020202, 0.55, 0, 0, lastScreenSize.x, lastScreenSize.y);
        
        //Screen.dim(0xFF020202, 0.55, 0, 0, lastScreenSize.x, lastScreenSize.y);
        
        Super.Drawer();
	}
}