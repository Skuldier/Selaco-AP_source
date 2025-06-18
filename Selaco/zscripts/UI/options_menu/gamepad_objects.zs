class OptionMenuSliderGamepadSensitivity : OptionMenuItemTooltipSlider
{
	JoystickConfig mJoy;
	
	OptionMenuSliderGamepadSensitivity Init(String label, String tooltip, String defImage, double min, double max, double step, int showval, JoystickConfig joy)
	{
		Super.Init(label, tooltip, defImage, "", min, max, step, showval);
		mJoy = joy;
		return self;
	}

	override double GetSliderValue()
	{
		return mJoy.GetSensitivity();
	}

	override void SetSliderValue(double val)
	{
		mJoy.SetSensitivity(val);
	}
}


class OptionMenuSliderGamepadScale : OptionMenuItemTooltipSlider {
	int mAxis;
	int mNeg;
	JoystickConfig mJoy;
		
	OptionMenuSliderGamepadScale Init(String label, String tooltip, String defImage, int axis, double min, double max, double step, int showval, JoystickConfig joy)
	{
		Super.Init(label, tooltip, defImage, "", min, max, step, showval);
		mAxis = axis;
		mNeg = 1;
		mJoy = joy;
		return self;
	}

	override double GetSliderValue()
	{
		double d = mJoy.GetAxisScale(mAxis);
		mNeg = d < 0? -1:1;
		return d;
	}

	override void SetSliderValue(double val)
	{
		mJoy.SetAxisScale(mAxis, val * mNeg);
	}
}


class OptionMenuSliderGamepadDeadZone : OptionMenuItemTooltipSlider {
	int mAxis;
	int mNeg;
	JoystickConfig mJoy;

	OptionMenuSliderGamepadDeadZone Init(String label, String tooltip, String defImage, int axis, double min, double max, double step, int showval, JoystickConfig joy)
	{
		Super.Init(label, tooltip, defImage, "", min, max, step, showval);
		mAxis = axis;
		mNeg = 1;
		mJoy = joy;
		return self;
	}

	override double GetSliderValue()
	{
		double d = mJoy.GetAxisDeadZone(mAxis);
		mNeg = d < 0? -1:1;
		return d;
	}

	override void SetSliderValue(double val)
	{
		mJoy.SetAxisDeadZone(mAxis, val * mNeg);
	}
}


class OptionMenuSliderGamepadAcceleration : OptionMenuItemTooltipSlider {
	int mAxis;
	JoystickConfig mJoy;

	OptionMenuSliderGamepadAcceleration Init(String label, String tooltip, String defImage, int axis, double min, double max, double step, int showval, JoystickConfig joy)
	{
		Super.Init(label, tooltip, defImage, "", min, max, step, showval);
		mAxis = axis;
		mJoy = joy;
		return self;
	}

	override double GetSliderValue()
	{
		return mJoy.GetAxisAcceleration(mAxis);
	}

	override void SetSliderValue(double val)
	{
		mJoy.SetAxisAcceleration(mAxis, val);
	}
}


class OptionMenuItemGamepadInverter : OptionMenuItemTooltipOption {
	int mAxis;
	JoystickConfig mJoy;
	
	OptionMenuItemGamepadInverter Init(String label, String tooltip, String defImage, int axis, int center, JoystickConfig joy)
	{
		Super.Init(label, tooltip, defImage, "none", "YesNo", "none", center: center);
		mAxis = axis;
		mJoy = joy;
		return self;
	}

	override int GetSelection()
	{
		float f = mJoy.GetAxisScale(mAxis);
		return f > 0? 0:1;
	}

	override void SetSelection(int Selection)
	{
		let f = abs(mJoy.GetAxisScale(mAxis));
		if (Selection) f*=-1;
		mJoy.SetAxisScale(mAxis, f);
	}
}


class OptionMenuGamepadResetDefaults : OptionMenuItemTooltipCommand {
	int mAxis;
	JoystickConfig mJoy;
	
	OptionMenuGamepadResetDefaults Init(String label, String tooltip, String defImage, JoystickConfig joy) {
		Super.Init(label, tooltip, defImage, "none", "resetdefaults");
		mJoy = joy;
		return self;
	}

	override bool Activate() {
		mJoy.RestoreDefaults();

		return true;
	}
}


class OptionMenuItemGamepadMap : OptionMenuItemTooltipOption
{
	int mAxis;
	JoystickConfig mJoy;
	
	OptionMenuItemGamepadMap Init(String label, String tooltip, String defImage, int axis, Name values, int center, JoystickConfig joy)
	{
		Super.Init(label, tooltip, defImage, 'none', values, "none", null, center);
		mAxis = axis;
		mJoy = joy;
		return self;
	}

	override int GetSelection()
	{
		double f = mJoy.GetAxisMap(mAxis);
		let opt = OptionValues.GetCount(mValues);
		if (opt > 0)
		{
			// Map from joystick axis to menu selection.
			for(int i = 0; i < opt; i++)
			{
				if (f ~== OptionValues.GetValue(mValues, i))
				{
					return i;
				}
			}
		}
		return -1;
	}

	override void SetSelection(int selection)
	{
		let opt = OptionValues.GetCount(mValues);
		// Map from menu selection to joystick axis.
		if (opt == 0 || selection >= opt)
		{
			selection = JoystickConfig.JOYAXIS_None;
		}
		else
		{
			selection = int(OptionValues.GetValue(mValues, selection));
		}
		mJoy.SetAxisMap(mAxis, selection);
	}
}