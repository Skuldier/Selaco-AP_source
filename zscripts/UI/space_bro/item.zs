class SpaceBroScores : Inventory {
    int scores[8];
    string names[8];

    void setDefaults() {
        scores[0] = 86081;
        names[0] = "TYCHUS";

        scores[1] = 86040;
        names[1] = "DAWN! ";

        scores[2] = 66198;
        names[2] = "TYCHUS";

        scores[3] = 58003;
        names[3] = "NICOLE";

        scores[4] = 46542;
        names[4] = "TYCHUS";

        scores[5] = 35012;
        names[5] = "SVEN  ";

        scores[6] = 10114;
        names[6] = "NED   ";

        scores[7] = 5694;
        names[7] = "J3RRY ";
    }

    clearscope int isHighScore(int score) {
        for(int x = 0; x < scores.size(); x++) {
            if(score > scores[x]) return x;
        }

        return -1;
    }

    int logHighScore(int score) {
        let pos = isHighScore(score);
        if(pos < 0) { return -1; }

        // Shuffle scores down
        for(int x = scores.size() - 1; x > pos; x--) {
            scores[x] = scores[x - 1];
            names[x] = names[x - 1];
        }

        // Log this score
        scores[pos] = score;
        names[pos] = "DAWN  ";    // Dawn is always the player

        return pos;
    }

    override void BeginPlay() {
        Super.BeginPlay();

        setDefaults();
    }

    static SpaceBroScores FindOrCreate(int player = -1) {
        if(player < 0) player = consolePlayer;
        let scores = SpaceBroScores(players[player].mo.FindInventory("SpaceBroScores"));

        if(!scores) {
            players[player].mo.GiveInventory("SpaceBroScores", 1);
            scores = SpaceBroScores(players[player].mo.FindInventory("SpaceBroScores"));
        }

        return scores;
    }

    clearscope static SpaceBroScores Find(int player = -1) {
        if(player < 0) player = consolePlayer;
        return SpaceBroScores(players[player].mo.FindInventory("SpaceBroScores"));
    }
}