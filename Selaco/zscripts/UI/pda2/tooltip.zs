class TooltipView : UILabel {
    Vector2 offset;

    TooltipView init(Vector2 pos, Vector2 size, string text, Font fnt, int textColor = 0xFFFFFFFF, Alignment textAlign = Align_TopLeft, Vector2 fontScale = (1,1)) {
        Super.init(pos, size, text, fnt, textColor, textAlign, fontScale);

        offset = pos;

        return self;
    }

    override bool event(ViewEvent ev) {
        if(ev.type == UIEvent.Type_MouseMove) {
            let mpos = (ev.MouseX, ev.MouseY);
            self.frame.pos = parent.screenToRel(mpos) + offset;
        }

        return Super.event(ev); 
    }
}