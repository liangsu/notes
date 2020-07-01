#include <stdio.h>
#include <pthread.h>


void* new_thread(){
	
	while(1){
		printf("i am new thread \n");
		sleep(1);
	}
	
}

int main(){
	
	
	pthread_t pid;
	
	pthread_create(&pid, NULL, new_thread, NULL);
	
	while(1){
		printf("i am main thread \n");
		sleep(1);
	}
	
	return 0;
}