# 📖 Data Structures & Algorithms  
## ✍️ By Dr. Aman Gupta  

---

## 📌 Table of Contents
- [Rudiments](#rudiments)
- [Inception](#inception)
- [Arrays](#arrays)
- [Matrix](#matrix)
- [Searching](#searching)
- [Sorting](#sorting)

---

# 🧩 Rudiments  
📅 August 28, 2025  

---

### 🔹 Armstrong Number
```c
int isArmstrong(int n) {
    int original = n;
    int sum = 0;

    while (n > 0) {
        int digit = n % 10;
        sum += digit * digit * digit;
        n /= 10;
    }

    return (sum == original);
}
```

---

### 🔹 Count Digits
```c
int numberOfDigit(int n) {
    if (n == 0) return 1;

    int count = 0;
    while (n > 0) {
        count++;
        n /= 10;
    }
    return count;
}
```

---

### 🔹 Reverse Digits
```c
int reverseDigit(int n) {
    int reversed = 0;

    while (n > 0) {
        int digit = n % 10;
        reversed = reversed * 10 + digit;
        n /= 10;
    }

    return reversed;
}
```

---

### 🔹 Sum of Digits
```c
int sumOfDigits(int n) {
    int sum = 0;

    while (n > 0) {
        sum += n % 10;
        n /= 10;
    }

    return sum;
}
```

---

### 🔹 Prime Check
```c
int primeChecker(int n) {
    if (n <= 1) return 0;

    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) return 0;
    }

    return 1;
}
```

---

### 🔹 Factorial
```c
int factorial(int n) {
    if (n < 0) return -1;

    int result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }

    return result;
}
```

---

# 🚀 Inception  
📅 September 1, 2025  

---

### 🔹 Sum of AP
```c
int sumOfAP(int n, int a, int d) {
    int sum = 0;

    for (int i = 0; i < n; i++) {
        sum += a + i * d;
    }

    return sum;
}
```

---

### 🔹 Triangular Number (nth term)
```c
int nthTerm(int n) {
    return n * (n + 1) / 2;
}
```

---

### 🔹 Binomial Coefficient
```c
int nCr(int n, int r) {
    if (r < 0 || r > n) return 0;

    long long nf = factorial(n);
    long long rf = factorial(r);
    long long nrf = factorial(n - r);

    return nf / (rf * nrf);
}
```

---

### 🔹 LCM
```c
int findLCM(int a, int b) {
    int max = (a > b) ? a : b;

    while (1) {
        if (max % a == 0 && max % b == 0)
            return max;
        max++;
    }
}
```

---

### 🔹 GCD (Euclidean)
```c
int findHCF(int a, int b) {
    while (b != 0) {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}
```

---

### 🔹 Count Divisors divisible by 3
```c
int countDivisors(int n) {
    int count = 0;

    for (int i = 1; i <= n; i++) {
        if (n % i == 0 && i % 3 == 0) {
            count++;
        }
    }

    return count;
}
```

---

### 🔹 FizzBuzz
```c
void fizzBuzz(int n) {
    for (int i = 1; i <= n; i++) {
        if (i % 15 == 0)
            printf("FizzBuzz\n");
        else if (i % 3 == 0)
            printf("Fizz\n");
        else if (i % 5 == 0)
            printf("Buzz\n");
        else
            printf("%d\n", i);
    }
}
```

---

### 🔹 Sum of First N Numbers
```c
int sumOfNumbers(int n) {
    int sum = 0;

    for (int i = 1; i <= n; i++) {
        sum += i;
    }

    return sum;
}
```

---

# 📦 Arrays  
📅 September 14, 2025  

---

### 🔹 Largest Element
```c
int largest(int arr[], int n) {
    int max = arr[0];

    for (int i = 1; i < n; i++) {
        if (arr[i] > max)
            max = arr[i];
    }

    return max;
}
```

---

### 🔹 Linear Search
```c
int search(int arr[], int n, int x) {
    for (int i = 0; i < n; i++) {
        if (arr[i] == x)
            return i;
    }
    return -1;
}
```

---

### 🔹 Array Sum (C++)
```cpp
int arraySum(vector<int>& arr) {
    int sum = 0;

    for (int x : arr) {
        sum += x;
    }

    return sum;
}
```

---

### 🔹 Count Primes in Array
```cpp
int isPrime(int n) {
    if (n <= 1) return 0;
    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) return 0;
    }
    return 1;
}

int countingPrime(vector<int>& arr) {
    int count = 0;

    for (int x : arr) {
        if (isPrime(x))
            count++;
    }

    return count;
}
```

---

### 🔹 Palindrome Array
```cpp
bool isPerfect(vector<int>& arr) {
    int l = 0, r = arr.size() - 1;

    while (l < r) {
        if (arr[l] != arr[r])
            return false;
        l++; r--;
    }

    return true;
}
```

---

### 🔹 Reverse Array
```cpp
void reverseArray(vector<int>& arr) {
    int l = 0, r = arr.size() - 1;

    while (l < r) {
        swap(arr[l], arr[r]);
        l++; r--;
    }
}
```

---

### 🔹 Missing Number
```cpp
int missingNum(vector<int>& arr) {
    int n = arr.size() + 1;
    int expected = n * (n + 1) / 2;

    int sum = 0;
    for (int x : arr) sum += x;

    return expected - sum;
}
```

---

# 🧮 Matrix  
📅 September 21, 2025  

---

### 🔹 Matrix Sum
```cpp
int sumOfMatrix(int N, int M, vector<vector<int>>& grid) {
    int sum = 0;

    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            sum += grid[i][j];
        }
    }

    return sum;
}
```

---

### 🔹 Transpose
```cpp
vector<vector<int>> transpose(vector<vector<int>>& mat) {
    int n = mat.size();

    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            swap(mat[i][j], mat[j][i]);
        }
    }

    return mat;
}
```

---

### 🔹 Diagonal Sum
```cpp
int diagonalSum(vector<vector<int>>& matrix) {
    int sum = 0;
    int n = matrix.size();

    for (int i = 0; i < n; i++) {
        sum += matrix[i][i];
        if (i != n - i - 1)
            sum += matrix[i][n - i - 1];
    }

    return sum;
}
```

---

# 🔍 Searching  
📅 September 15, 2025  

---

### 🔹 Binary Search
```cpp
int search(vector<int>& nums, int target) {
    int l = 0, r = nums.size() - 1;

    while (l <= r) {
        int mid = l + (r - l) / 2;

        if (nums[mid] == target)
            return mid;
        else if (target < nums[mid])
            r = mid - 1;
        else
            l = mid + 1;
    }

    return -1;
}
```

---

# 🔃 Sorting
📅 September 25, 2025  

---

### 🔹 Bubble Sort
```cpp
void bubbleSort(vector<int>& arr) {
    int n = arr.size();

    for (int i = 0; i < n - 1; i++) {
        for (int j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                swap(arr[j], arr[j + 1]);
            }
        }
    }
}
```

---

### 🔹 Selection Sort
```cpp
void selectionSort(vector<int>& arr) {
    int n = arr.size();

    for (int i = 0; i < n; i++) {
        int minIdx = i;

        for (int j = i + 1; j < n; j++) {
            if (arr[j] < arr[minIdx])
                minIdx = j;
        }

        swap(arr[i], arr[minIdx]);
    }
}
```

---

### 🔹 Insertion Sort
```cpp
void insertionSort(vector<int>& arr) {
    for (int i = 1; i < arr.size(); i++) {
        int key = arr[i];
        int j = i - 1;

        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j--;
        }

        arr[j + 1] = key;
    }
}
```
---
