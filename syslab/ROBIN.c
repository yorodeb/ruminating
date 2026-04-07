#include <stdio.h>

int main() {
    int n, tq;

    printf("Number of Processes? ");
    scanf("%d", &n);

    int at[n], bt[n], rem_bt[n], ct[n], tat[n], wt[n];

    for(int i = 0; i < n; i++) {
        printf("Arrival Time P%d? ", i+1);
        scanf("%d", &at[i]);
    }

    for(int i = 0; i < n; i++) {
        printf("Burst Time P%d? ", i+1);
        scanf("%d", &bt[i]);
        rem_bt[i] = bt[i];
    }

    printf("Enter Time Quantum: ");
    scanf("%d", &tq);

    int currentTime = 0, completed = 0;

    while(completed < n) {
        int done = 1;

        for(int i = 0; i < n; i++) {
            if(rem_bt[i] > 0 && at[i] <= currentTime) {
                done = 0;

                if(rem_bt[i] > tq) {
                    currentTime += tq;
                    rem_bt[i] -= tq;
                } else {
                    currentTime += rem_bt[i];
                    ct[i] = currentTime;
                    rem_bt[i] = 0;
                    completed++;
                }
            }
        }

        if(done) {
            currentTime++;
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
