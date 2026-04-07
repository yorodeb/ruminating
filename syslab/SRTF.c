#include <stdio.h>

int main() {
    int n;

    printf("Number Of Process? ");
    scanf("%d", &n);

    int at[n], bt[n], rt[n], ct[n], tat[n], wt[n];

    for(int i = 0; i < n; i++) {
        printf("Arrival Time P%d? ", i+1);
        scanf("%d", &at[i]);
    }

    for(int i = 0; i < n; i++) {
        printf("Burst Time P%d? ", i+1);
        scanf("%d", &bt[i]);
        rt[i] = bt[i];
    }

    int currentTime = 0, completed = 0;

    while(completed < n) {
        int minIndex = -1;
        int minRT = 9999;

        for(int i = 0; i < n; i++) {
            if(at[i] <= currentTime && rt[i] > 0) {
                if(rt[i] < minRT) {
                    minRT = rt[i];
                    minIndex = i;
                }
            }
        }

        if(minIndex == -1) {
            currentTime++;
            continue;
        }

        rt[minIndex]--;
        currentTime++;

        if(rt[minIndex] == 0) {
            ct[minIndex] = currentTime;
            completed++;
        }
    }

    for(int i = 0; i < n; i++) {
        tat[i] = ct[i] - at[i];
        wt[i] = tat[i] - bt[i];
    }

    printf("\nProcess\tAT\tBT\tCT\tTAT\tWT\n");
    for(int i = 0; i < n; i++) {
        printf("P%d\t%d\t%d\t%d\t%d\t%d\n", 
               i+1, at[i], bt[i], ct[i], tat[i], wt[i]);
    }

    return 0;
}
