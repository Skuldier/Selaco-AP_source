struct SFX {
    Sound id;
    
    uint startTic;

    // Get the amount of time this sound has been playing
    float PlayTime(uint curTic) {
        return float(curTic - startTic) / float(Object.TICRATE);
    }

    bool IsFinished(uint curTic) {
        return PlayTime(curTic) >= Object.S_GetLength(id);
    }

    bool IsValid() {
        return id != 0;
    }
}

class SoundUtil {
    static void PlaySoundFX(Actor a, out SFX s, uint curTic, Sound snd, int channel = 0, int flags = 0, float volume = 1.0, float pitch = 1.0) {
        s.id = snd;
        s.startTic = curTic;

        a.S_StartSound(snd, channel, flags, volume);
    }

    static void APlaySoundFX(Actor a, out SFX s, uint curTic, Sound snd, int channel = 0, int flags = 0, float volume = 1.0, float pitch = 1.0) {
        s.id = snd;
        s.startTic = curTic;

        a.A_StartSound(snd, channel, flags, volume);
    }

    static void PlaySound(int curTic, Sound snd, int channel = 0, int flags = 0, float volume = 1.0) {
        S_StartSound(snd, channel, flags, volume);
    }
}