// An extremely dirty and possibly unstable hashtable for simple int keys and values
// Use at your own risk
class IntTable {
    Array<uint> keys;
    Array<uint> values;
    int size;
    int capacity;
    double load_factor;

    const key2gen = uint((int.max - 1) / 2);

    static const int primeTbl[] = {
        11,
        19,
        37,
        73,
        109,
        163,
        251,
        367,
        557,
        823,
        1237,
        1861,
        2777,
        4177,
        6247,
        9371,
        14057,
        21089,
        31627,
        47431,
        71143,
        106721,
        160073,
        240101,
        360163,
        540217,
        810343,
        1215497,
        1823231,
        2734867,
        4102283,
        6153409,
        9230113,
        13845163
    };

    static bool TestPrime (int x) {
        if ((x & 1) != 0) {
            int top = int(Sqrt (x));
            
            for (int n = 3; n < top; n += 2) {
                if ((x % n) == 0)
                    return false;
            }
            return true;
        }
        // There is only one even prime - 2.
        return (x == 2);
    }
    
    static int CalcPrime (int x) {
        for (int i = (x & (~1))-1; i < int.max; i += 2) {
            if (TestPrime (i)) return i;
        }
        return x;
    }

    static int ToPrime (int x) {
        for (int i = 0; i < IntTable.primeTbl.size(); i++) {
            if (x <= IntTable.primeTbl [i])
                return IntTable.primeTbl [i];
        }
        return CalcPrime (x);
    }
    

    IntTable init(int initial_capacity = 8, double initial_load_factor = 0.75) {
        capacity = ToPrime(initial_capacity * 2);
        load_factor = initial_load_factor;
        keys.resize(capacity);
        values.resize(capacity);
        size = 0;

        return self;
    }

    void put(uint key, uint value) {
        if (size >= capacity * load_factor) {
            resize();
        }
        int index = hash(key);
        int step = hash2(key);
        int fart = 0;
        while (keys[index] != 0) {
            if (keys[index] == key) {
                values[index] = value;
                return;
            }
            fart++;
            
            int oldIndex = index;
            index = (index + step) % capacity;
            if(index == oldIndex) index = (index + 1) % capacity;   // Protect against math
        }
        //if(fart > 50) Console.Printf("\c[YELLOW]Warning: Put took %d iterations.\nSet %d to %d", fart, key, value);
        keys[index] = key;
        values[index] = value;
        size++;
    }

    uint, bool get(uint key) {
        int index = find(key);
        if (index == -1) {
            return 0, false;
        }
        return values[index], true;
    }

    void remove(uint key) {
        int index = find(key);
        if (index != -1) {
            keys[index] = 0;
            values[index] = 0;
            size--;
        }
    }

    bool contains(uint key) {
        return find(key) != -1;
    }

    private int hash(uint key) {
        return key % capacity;
    }

    private int hash2(uint key) {
        return 1 + (key % key2gen);
    }

    private int find(uint key) {
        int index = hash(key);
        int step = hash2(key);
        int fart = 0;
        while (keys[index] != key) {
            if (keys[index] == 0) {
                return -1;
            }
            fart++;
            int oldIndex = index;
            index = (index + step) % capacity;

            if(index == oldIndex) index = (index + 1) % capacity;   // Protect against math
            if(fart > 200) {                                        // Protect against my idiocy
                Console.Printf("\c[RED]INTTABLE Find took %d iterations to find key: %d (Hash: %d  - Step: %d - Capacity: %d) and never found anything. Something is wrong.\nDump:", fart, key, index, step, capacity);
                for(int x = 0; x < keys.size(); x++) {
                    if(keys[x] != 0) Console.Printf("\tK: %d\t\tValue: %d", keys[x], values[x]);
                }
                ThrowAbortException("INTTABLE issue. Please check!");
                return -1;
            } 
        }
        if(fart > 5) Console.Printf("\c[YELLOW]Find took %d iterations", fart);
        return index;
    }

    private void resize() {
        
        int new_capacity = ToPrime(capacity * 2);
        Array<uint> new_keys;
        new_keys.resize(new_capacity);
        Array<uint> new_values;
        new_values.resize(new_capacity);

        for (int i = 0; i < capacity; i++) {
            if (keys[i] != 0) {
                int index = hash(keys[i]);
                int step = hash2(keys[i]);
                while (new_keys[index] != 0) {
                    index = (index + step) % new_capacity;
                }
                new_keys[index] = keys[i];
                new_values[index] = values[i];
            }
        }
        keys.move(new_keys);
        values.move(new_values);
        capacity = new_capacity;
    }
}