#include <bits/stdc++.h>

std::string encryption(std::string prgIn, int key);
std::string decryption(std::string prgIn, int key);

int main() {
    std::string prgIn; int key = 0;
		std::cout << "String: "; std::getline(std::cin, prgIn);
		std::cout << "Key: "; std::cin >> key;
    
    std::cout << "Encrypted: " << encryption(prgIn, key) << std::endl;
    std::cout << "Decrypted: " << decryption(encryption(prgIn, key), key) << std::endl;

		return 0;
}

std::string encryption(std::string prgIn, int key) {
    std::string prgOut;
    
    for(size_t i = 0; i < prgIn.size(); i++) {
        prgIn[i] = std::toupper(prgIn[i]);
    }

    for(size_t i = 0; i < prgIn.size(); i++) {
        int idxOfChar = prgIn[i] - 'A';
        int shifted = (idxOfChar + key) % 26;
        char encrypted = shifted + 'A';
        prgOut.push_back(encrypted);
    }
    
    return prgOut;
}

std::string decryption(std::string prgIn, int key) {
		std::string prgOut;

    for(size_t i = 0; i < prgIn.size(); i++) {
        prgIn[i] = std::toupper(prgIn[i]);
    }
    
    for(size_t i = 0; i < prgIn.size(); i++) {
        int idxOfChar = prgIn[i] - 'A';
        int shifted = (idxOfChar - key + 26) % 26;
        char encrypted = shifted + 'A';
        prgOut.push_back(encrypted);
    }
    
    return prgOut;
}
