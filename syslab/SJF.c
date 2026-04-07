#include <stdio.h>

int main() {
    int n;

    printf("Number Of Process? ");
    scanf("%d", &n);

    int at[n], bt[n], ct[n], tat[n], wt[n];
    int completed[n];

    for(int i = 0; i < n; i++) {
        completed[i] = 0;
    }

    for(int i = 0; i < n; i++) {
        printf("Arrival Time P%d? ", i+1);
        scanf("%d", &at[i]);
    }

    for(int i = 0; i < n; i++) {
        printf("Burst Time P%d? ", i+1);
        scanf("%d", &bt[i]);
    }

    int currentTime = 0, completedCount = 0;

    while(completedCount < n) {
        int minIndex = -1;
        int minBT = 9999;

        for(int i = 0; i < n; i++) {
            if(at[i] <= currentTime && completed[i] == 0) {
                if(bt[i] < minBT) {
                    minBT = bt[i];
                    minIndex = i;
                }
            }
        }

        if(minIndex == -1) {
            currentTime++;
        } else {
            currentTime += bt[minIndex];
            ct[minIndex] = currentTime;
            completed[minIndex] = 1;
            completedCount++;
        }
    }

    for(int i = 0; i < n; i++) {
        tat[i] = ct[i] - at[i];
        wt[i] = tat[i] - bt[i];
    }

    printf("\nProcess\tAT\tBT\tCT\tTAT\tWT\n");
    for(int i = 0; i < n; i++) {
        printf("P%d\t%d\t%d\t%d\t%d\t%d\n", i+1, at[i], bt[i], ct[i], tat[i], wt[i]);
    }

    return 0;
}
