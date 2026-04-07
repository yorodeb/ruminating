#include <iostream>

class Node{
	public:
		int data;
		Node *next;

		Node(int data){
			this->data = data;
			next = nullptr;
		}
};

int main(void){
	int prgIn;
	Node *head = nullptr; Node *tail = nullptr;
	do{
		std::cout << "1 :: Countinue..\n2 ::Exit!\n"; std::cin >> prgIn;
		if(prgIn == 2){
			std::cout << "EXITING..!\nCreated Linked List: ";
			while(head != nullptr){
				std::cout << head->data << " -> ";
				head = head->next;
			}
			std::cout << std::endl;
			break;
		}
		int prgData;
		std::cout << "Value For Node: "; std::cin >> prgData;

		Node *nextNode = new Node(prgData);
		if(head == nullptr){
			head = nextNode;
			tail = nextNode;
		}
		else{
			tail->next = nextNode;
			tail = nextNode;
		}

	} while(prgIn == 1);

	return (0);
}
