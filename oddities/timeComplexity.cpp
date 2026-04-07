#include <iostream>
#include <vector>
#include <chrono>

void insertionSort(std::vector<int> &array);
void bubbleSort(std::vector<int> &array);
void selectionSort(std::vector<int> &array);

int main(void){
	int SIZE;
	std::cout << "Size Of Array: "; std::cin >> SIZE;

	int valueOfElement = SIZE - 1;
	std::vector<int> unsortedArray(SIZE);
	for(int i = 0; i < SIZE; i++) {
		unsortedArray[i] = valueOfElement--;
	}

	std::vector<int> trialOne = unsortedArray;
	std::vector<int> trialTwo = unsortedArray;
	std::vector<int> trialThree = unsortedArray;

	auto insertStart = std::chrono::high_resolution_clock::now();
	insertionSort(trialOne);
	auto insertEnd = std::chrono::high_resolution_clock::now();

	auto insertDuration = std::chrono::duration_cast<std::chrono::microseconds>(insertEnd - insertStart);
	long long insertInMS = insertDuration.count();

	auto bubbleStart = std::chrono::high_resolution_clock::now();
	bubbleSort(trialTwo);
	auto bubbleEnd = std::chrono::high_resolution_clock::now();

	auto bubbleDuration = std::chrono::duration_cast<std::chrono::microseconds>(bubbleEnd - bubbleStart);
	long long bubbleInMS = bubbleDuration.count();

	auto selectStart = std::chrono::high_resolution_clock::now();
	selectionSort(trialThree);
	auto selectEnd = std::chrono::high_resolution_clock::now();
	
	auto selectDuration = std::chrono::duration_cast<std::chrono::microseconds>(selectEnd - selectStart);
	long long selectInMS = selectDuration.count();

	std::cout << "\nInsertion Sort - Worst Case:\nTime: " << insertInMS << " MicroSeconds." << std::endl;
	std::cout << "\nBubble Sort - Worst Case:\nTime: " << bubbleInMS << " MicroSeconds." << std::endl;
	std::cout << "\nSelection Sort - Worst Case:\nTime: " << selectInMS << " MicroSeconds." << std::endl;
}

void insertionSort(std::vector<int> &array) {
	for(int i = 1; i < array.size(); i++) {
		int pivot = array[i];
		int j = i - 1;
		while(j >= 0 && array[j] > pivot) {
			array[j+1] = array[j];
			j--;
		}
		array[j+1] = pivot;
	}
}

void bubbleSort(std::vector<int> &array) {
	for(int i = 0; i < array.size() - 1; i++) {
		for(int j = 0; j < array.size() - 1 - i; j++) {
			if(array[j] > array[j+1])
				std::swap(array[j], array[j+1]);
		}
	}
}

void selectionSort(std::vector<int> &array) {
	for(int i = 0; i < array.size(); i++) {
		int minIdx = i;
		for(int j = i + 1; j < array.size(); j++) {
			if(array[j] < array[minIdx])
				minIdx = j;
		}
		std::swap(array[i], array[minIdx]);
	}
}
