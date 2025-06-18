class PDAStatWindow : UIView {
    UILabel titleLabel, subTitleLabel;
    UIView contentView;

    PDAStatWindow init(Vector2 pos, Vector2 size, string title, string subText = "") {
        Super.init(pos, size);

        let bg = new("UIImage").init((0,0), size, "", NineSlice.Create("PDASTATB", (55, 62), (66, 69)));
        bg.pinToParent();
        add(bg);

        titleLabel = new("UILabel").init((62, 13 - 4), (100, 20), title, "SEL16FONT");
        titleLabel.multiline = false;
        titleLabel.pin(UIPin.Pin_Left, offset: 62);
        titleLabel.pin(UIPin.Pin_Right, offset: - 7);
        add(titleLabel);

        subTitleLabel = new("UILabel").init((62, 35 - 4), (100, 20), subText, "SEL14FONT", 0xFF8E99B7);
        subTitleLabel.multiline = false;
        subTitleLabel.pin(UIPin.Pin_Left, offset: 62);
        subTitleLabel.pin(UIPin.Pin_Right, offset: - 7);
        add(subTitleLabel);

        contentView = new("UIView").init((0,0), (1, 1));
        contentView.pinToParent(2,60,2,2);
        add(contentView);

        return self;
    }
}