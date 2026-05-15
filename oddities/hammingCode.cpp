#include <iostream>
#include <cmath>
using namespace std;

// Function to calculate redundant bits
int calculateRedundantBits(int m) {
    int r = 0;
    while (pow(2, r) < (m + r + 1)) {
        r++;
    }

    return r;
}

// Function to generate Hamming Code
void generateHammingCode(int data[], int m) {
    int r = calculateRedundantBits(m);
    int totalBits = m + r;

    int hamming[50];
    // Fill data and parity positions
    int j = 0;
    for (int i = 1; i <= totalBits; i++) {

        // Power of 2 positions are parity bits
        if ((i & (i - 1)) == 0) {
            hamming[i] = 0;
        } else {
            hamming[i] = data[j++];
        }
    }

    // Calculate parity bits
    for (int i = 0; i < r; i++) {

        int parityPos = pow(2, i);
        int parity = 0;

        for (int j = 1; j <= totalBits; j++) {
            if (j & parityPos) {
                parity ^= hamming[j];
            }
        }

        hamming[parityPos] = parity;
    }

    cout << "\nGenerated Hamming Code: ";
    for (int i = totalBits; i >= 1; i--) {
        cout << hamming[i];
    }

    cout << endl;

    // Simulate received code
    int received[50];

    cout << "\nReceived Code\n";

    for (int i = totalBits; i >= 1; i--) {
        cin >> received[i];
    }

    // Error detection
    int errorPos = 0;

    for (int i = 0; i < r; i++) {

        int parityPos = pow(2, i);
        int parity = 0;

        for (int j = 1; j <= totalBits; j++) {
            if (j & parityPos) {
                parity ^= received[j];
            }
        }

        if (parity != 0) {
            errorPos += parityPos;
        }
    }

    if (errorPos == 0) {
        cout << "\nNo error detected.\n";
    } else {
        cout << "\nError detected at position: "
             << errorPos << endl;

        // Correct the bit
        received[errorPos] ^= 1;

        cout << "Corrected code: ";

        for (int i = totalBits; i >= 1; i--) {
            cout << received[i];
        }

        cout << endl;
    }
}

int main() {

    int prgIn;
    cout << "Enter number of data bits: ";
    cin >> prgIn;

    int data[20];
    cout << "Enter data bits one by one:\n";

    // Input from MSB to LSB
    for (int i = prgIn - 1; i >= 0; i--) {
        cin >> data[i];
    }

    generateHammingCode(data, prgIn);
    return 0;
}
