class PDATab : UIButton {
    TooltipView tooltip;
    bool isImplemented;
    String notImplementedText;
    
    PDATab init(Vector2 pos, Vector2 size, string text, Font fnt,
                    UIButtonState normal,
                    UIButtonState hover = null,
                    UIButtonState pressed = null,
                    UIButtonState disabled = null,
                    UIButtonState selected = null,
                    UIButtonState selectedHover = null,
                    UIButtonState selectedPressed = null,
                    Alignment textAlign = Align_Centered) {

    
        Super.init(pos, size, text, fnt, normal, hover, pressed, disabled, selected, selectedHover, selectedPressed, textAlign);

        notImplementedText = "Not Yet Implemented";

        return self;
    }


    override void onMouseEnter(Vector2 screenPos) {
        Super.onMouseEnter(screenPos);

        if(disabled && !isImplemented) {
            let mainView = getMenu().mainView;
            if(!tooltip) tooltip = new("TooltipView").init((30,30), (225, 50), notImplementedText, "SEL16FONT", textAlign: UIView.Align_TopLeft);
            tooltip.multiline = false;
            tooltip.frame.pos = mainView.screenToRel(screenPos) + (30,30);
            mainview.add(tooltip);
        }
    }

    override void onMouseExit(Vector2 screenPos, UIView newView) {
        if(tooltip) { 
            tooltip.removeFromSuperview(); 
        }

        Super.onMouseExit(screenPos, newView);
    }

    override bool raycastTest(Vector2 screenPos) {
        return UIView.raycastTest(screenPos);
	}
}