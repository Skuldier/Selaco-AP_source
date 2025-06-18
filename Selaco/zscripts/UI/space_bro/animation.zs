class Bronimation {
    int frameTime;
    Array<UITexture> frames;

    Bronimation init(int ft = 2) {
        frameTime = ft;
        return self;
    }

    void addFrame(String img) {
        frames.push(UITexture.Get(img));
    }

    UITexture getFrame(int ticks, bool loop = true) {
        double ftm = double(ticks) / double(frames.size() * frameTime);

        if(loop) {
            ftm = UIMath.Loopd(ftm, 0.0, 1.0);
        } else {
            ftm = CLAMP(ftm, 0.0, 1.0);
        }

        return frames[ round( ftm * (frames.size() - 1)) ];
    }
}