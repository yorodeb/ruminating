#include <stdio.h>

int main() {
    int numberOfProcess = 0;
    printf("Number Of Process? ");
    scanf("%d", &numberOfProcess);

    int arrivalTime[numberOfProcess];
    int burstTime[numberOfProcess];

    for(int i = 0; i < numberOfProcess; i++) {
        printf("ArrivalTime P%d? ", i + 1);
        scanf("%d", &arrivalTime[i]);
    }

    for(int i = 0; i < numberOfProcess; i++) {
        printf("BurstTime? P%d ", i + 1);
        scanf("%d", &burstTime[i]);
    }

    int completionTime[numberOfProcess];
    int turnAroundTime[numberOfProcess];
    int waitingTime[numberOfProcess];

    for(int i = 0; i < numberOfProcess; i++) {
        if(i == 0) {
            if(arrivalTime[i] > 0)
                completionTime[i] = arrivalTime[i] + burstTime[i];
            else
                completionTime[i] = burstTime[i];
        }

        else {
            int startTime;

            if(completionTime[i-1] > arrivalTime[i])
                startTime = completionTime[i-1];
            else
                startTime = arrivalTime[i];

            completionTime[i] = startTime + burstTime[i];
        }
    }

    for(int i = 0; i < numberOfProcess; i++) {
        turnAroundTime[i] = completionTime[i] - arrivalTime[i];
        waitingTime[i] = turnAroundTime[i] - burstTime[i];
		}

		printf("\nAt\tBt\tCt\tTaT\tWt\n");
		for(int i = 0; i < numberOfProcess; i++) {
			printf("%d\t%d\t%d\t%d\t%d\n", arrivalTime[i], burstTime[i], completionTime[i], turnAroundTime[i], waitingTime[i]);
		}

		return 0;
}
