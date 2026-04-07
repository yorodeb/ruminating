#include <bits/stdc++.h>

void printing(int numberOftime);
int multiply(int x, int y);
int sumOfN(int N);

int main() {
    std::cout << "Starting..\n";
    //printingFunction!
    printing(2);
    
    //summitionOfN-Natural Number
    int summition = sumOfN(4);
    std::cout << "Sum Of N-Natural Number: " << summition << std::endl;
    
    //productOfMultiplication
    int product = multiply(2,5);
    std::cout << "Product: " << product << std::endl;
    std::cout << "The-End!\n";
}

void printing(int numberOftime){
    if(numberOftime <= 0){
        return;
    }
    
    std::cout << numberOftime << " :: Erratic!\n";
    printing(numberOftime - 1);
    std::cout << numberOftime << " :: Eccentric!\n";
}

int sumOfN(int N){
    if(N <= 0){
        return 0;
    }
    
    return N + sumOfN(N - 1);
}

int multiply(int a, int b){
    if(b <= 0){
        return 0;
    }
    
    return a + multiply(a, b - 1);
}
