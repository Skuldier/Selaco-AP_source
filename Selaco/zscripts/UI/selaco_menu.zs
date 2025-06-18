mixin class GamepadInput {
    Vector2 getGamepadRawLook() {
        Vector2 con;

        for(int x = 0; x < JoystickConfig.NumJoysticks(); x++) {
            let joy = JoystickConfig.GetJoystick(x);
            
            for(int y = 0; y < joy.GetNumAxes(); y++) {
                if(joy.GetAxisMap(y) == JoystickConfig.JOYAXIS_Pitch) {
                    con.y += joy.GetRawAxis(y);
                } else if(joy.GetAxisMap(y) == JoystickConfig.JOYAXIS_Yaw) {
                    con.x += joy.GetRawAxis(y);
                }
            }
        }

        con.x = clamp(con.x, -1.0, 1.0);
        con.y = clamp(con.y, -1.0, 1.0);
        return con;
    }

    Vector2 getGamepadRawMove() {
        Vector2 con;

        for(int x = 0; x < JoystickConfig.NumJoysticks(); x++) {
            let joy = JoystickConfig.GetJoystick(x);
            
            for(int y = 0; y < joy.GetNumAxes(); y++) {
                if(joy.GetAxisMap(y) == JoystickConfig.JOYAXIS_Forward) {
                    con.y += joy.GetRawAxis(y);
                } else if(joy.GetAxisMap(y) == JoystickConfig.JOYAXIS_Side) {
                    con.x += joy.GetRawAxis(y);
                }
            }
        }

        con.x = clamp(con.x, -1.0, 1.0);
        con.y = clamp(con.y, -1.0, 1.0);
        return con;
    }
}


// Defines the functions to add rumble to standard navigation events
mixin class SelacoFeedbackMenu {
    InputHandler mInputHandler;

    InputHandler getInputHandler() {
        if(!mInputHandler) {
            mInputHandler = InputHandler.Instance();
        }

        return mInputHandler;
    }

    void addUIFeedback(Array<float> pulses) {
        let ih = getInputHandler();

        if(ih) {
            ih.AddUIFeedback(pulses);
        }
    }
}

class SelacoGamepadMenu : UIMenu {
    mixin SelacoFeedbackMenu;
    mixin UIInputHandlerAccess;
    mixin GamepadInput;
    
    override void onFirstTick() {
        super.onFirstTick();
        
        // Only hide the mouse by default if this menu was opened directly from gameplay
        if(!mParentMenu) {
            if(isUsingGamepad()) {
                hideCursor();
            } else {
                showCursor(true);
            }
        }

        if(automapactive) {
            Screen.CloseAutomap();
        }
    }

    override void didNavigate(bool withController) {
		if(withController) {
            InputHandler ih = getInputHandler();

            if(ih) {
                ih.AddUIFeedback(ih.navFeedback);
            }
        }
	}

	override void didActivate(UIControl control, bool withController) {
		if(withController) {
            InputHandler ih = getInputHandler();

            if(ih) {
                ih.AddUIFeedback(ih.buttonFeedback);
            }
        }
	}

    override void didReverse(bool withController) {
		if(withController) {
            InputHandler ih = getInputHandler();

            if(ih) {
                ih.AddUIFeedback(ih.reverseButtonFeedback);
            }
        }
	}
}


// Simple wrapper to handle a few menu actions for in-game menus
// For instance all in game menus should close if the player dies
class SelacoGamepadMenuInGame : SelacoGamepadMenu {
    override void ticker() {
        Super.ticker();

        if(!players[consolePlayer].mo || players[consolePlayer].mo.health <= 0) {
            closeOnDeath();
        }
    }

    virtual void closeOnDeath() {
        Close();
    }
}