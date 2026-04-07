#include <iostream>

std::string encryption(std::string _prgIn, int _key);
std::string decryption(std::string _prgIn, int _key);

int main() {
	std::string _prgIn; int _key;
	std::cout << "String: "; std::getline(std::cin, _prgIn);
	std::cout << "Key: "; std::cin >> _key;

	std::cout << "Encrypted: " << encryption(_prgIn, _key) << std::endl;
	std::cout << "Decrypted: " << decryption(encryption(_prgIn, _key), _key) << std::endl;
	return 0;
}

std::string encryption(std::string _prgIn, int _key) {
	std::string _prgOut;

	for(size_t i = 0; i < _prgIn.size(); ++i) {
		_prgIn[i] = std::toupper(_prgIn[i]);
	}

	for(size_t i = 0; i < _prgIn.size(); ++i) {
		int _idxOfChar = _prgIn[i] - 'A';
		int _ciphered = _idxOfChar ^ _key;
		char _encrypted = _ciphered + 'A';
		_prgOut.push_back(_encrypted);
	}

	return _prgOut;
}

std::string decryption(std::string _prgIn, int _key) {
	std::string _prgOut;

	for(size_t i = 0; i < _prgIn.size(); ++i) {
		_prgIn[i] = std::toupper(_prgIn[i]);
	}

	for(size_t i = 0; i < _prgIn.size(); ++i) {
		int _idxOfChar = _prgIn[i] - 'A';
		int _deciphered = _idxOfChar ^ _key;
		char _decrypted = _deciphered + 'A';
		_prgOut.push_back(_decrypted);
	}

	return _prgOut;
}
