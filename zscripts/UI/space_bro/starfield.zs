// A container for drawing a single layer of the star field
class SpacebroStars {
    double moveScale;
    UITexture tex;
    Color col;
    
    Shape2D shape;

    SpacebroStars init(double moveScale, string image) {
        self.moveScale = moveScale;
        tex = UITexture.Get(image);
        col = 0xFFFFFFFF;

        return self;
    }

    void draw(double tm, Vector2 camPos = (0,0), double scale = 1.0) {
        if(!shape) {
            shape = new("Shape2D");
        }

        shape.clear();
        int vc;
        Vector2 move = (camPos * moveScale);
        Vector2 containerSize = (Screen.GetWidth(), Screen.GetHeight());
        Vector2 size = (containerSize.x / tex.size.x, containerSize.y / tex.size.y);

        move.x /= tex.size.x * scale;
        move.y /= tex.size.y * scale;

        Shape2DHelper.AddQuad(shape, (0,0), containerSize, (move * scale), size / scale, vc);

        Screen.DrawShape(tex.texID,
            true, shape,
            DTA_Alpha, 1.0,
            DTA_Color, col
            //DTA_Filtering, true
        );
    }
}