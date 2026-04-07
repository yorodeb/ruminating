#include <iostream>
#include <vector>
#include <random>
#include <algorithm>
#include <chrono>

int binarySearch(std::vector<int> &array, int target);

int main(void) {
	const int sizeOfArray = 100000;
	std::vector<int> unsortedArray(sizeOfArray);

	for(int i = 0; i < sizeOfArray; i++) {
		unsortedArray[i] = i + 1;
	}
	
	std::random_device RD;
	std::mt19937 randomEngine(RD());
	std::shuffle(unsortedArray.begin(), unsortedArray.end(), randomEngine);

	auto startTime = std::chrono::high_resolution_clock::now();
	binarySearch(unsortedArray, 7193);
	auto endTime = std::chrono::high_resolution_clock::now();

	auto timeTaken = std::chrono::duration_cast<std::chrono::nanoseconds> (endTime - startTime);
	long long timeInNanoSec = timeTaken.count();

	std::cout << "Binary Search w/ Randomly Generated Unsorted Array:\nTime: " << timeInNanoSec << " NanoSeconds." << std::endl;
}

int binarySearch(std::vector<int> &array, int target) {
	int leftBit = 0; int rightBit = array.size() - 1;
	while(leftBit <= rightBit) {
		int midBit = leftBit + (rightBit - leftBit) / 2;

		if(target == array[midBit]) {
			return midBit;
		} else if(target < array[midBit]) {
			rightBit = midBit - 1;
		} else {
			leftBit = midBit + 1;
		}
	}

	return -1;
}
