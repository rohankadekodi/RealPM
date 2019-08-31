#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <asm/unistd.h>
#include <errno.h>
#include <inttypes.h>
#include <sched.h>
#include <assert.h>
#include <time.h>
#include <math.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/prctl.h>
#include <sys/wait.h>
#include <unistd.h>

#define FSIZE (5ULL*1024*1024*1024)
#define BLKSIZE size_of_block
#define MBSIZE (1024*1024)
#define KBSIZE (1024)
#define GBSIZE (1024*1024*1024)
#define CLSIZE 64
#define HUGEPAGESIZE (2*1024*1024)
#define PAGESIZE (4096)
#define FILENAME "/mnt/pmem_emul/writerand.txt"
#define MMAP_SIZE (16*1024*1024)

char *addr;
struct timeval start,end;
unsigned long long size_of_block;
char append_buf[HUGEPAGESIZE];

#define CLFLUSH_SIZE 64

void setup_arguments(char *argv[], unsigned long long *data_to_append, unsigned long long *granularity_of_read, unsigned long long *granularity_of_append, int *num_ops) {

	int granularity;
	unsigned long value;
	char value_str[10];
	int i;

	if(argv[1][strlen(argv[1])-1] == 'K')
		*data_to_append = KBSIZE;
	else if(argv[1][strlen(argv[1])-1] == 'M')
		*data_to_append = MBSIZE;
	else if(argv[1][strlen(argv[1])-1] == 'G')
		*data_to_append = GBSIZE;

	strcpy(value_str, argv[1]);
	value_str[strlen(argv[1])-1] = '\0';

	value = atoi(value_str);
	*data_to_append = *data_to_append * value;

	value_str[0] = '\0';

	if(argv[2][strlen(argv[2])-1] == 'K')
		*granularity_of_read = KBSIZE;
	else if(argv[2][strlen(argv[2])-1] == 'M')
		*granularity_of_read = MBSIZE;
	else if(argv[2][strlen(argv[2])-1] == 'G')
		*granularity_of_read = GBSIZE;

	strcpy(value_str, argv[2]);
	value_str[strlen(argv[2])-1] = '\0';

	value = atoi(value_str);
	*granularity_of_read = *granularity_of_read * value;

	value_str[0] = '\0';

	if(argv[3][strlen(argv[3])-1] == 'K')
		*granularity_of_append = KBSIZE;
	else if(argv[3][strlen(argv[3])-1] == 'M')
		*granularity_of_append = MBSIZE;
	else if(argv[3][strlen(argv[3])-1] == 'G')
		*granularity_of_append = GBSIZE;

	strcpy(value_str, argv[3]);
	value_str[strlen(argv[3])-1] = '\0';

	value = atoi(value_str);
	*granularity_of_append = *granularity_of_append * value;

	value_str[0] = '\0';

	strcpy(value_str, argv[4]);
	value = atoi(value_str);
	*num_ops = (int) value;
}

void setup_append_buffer() {

	int i = 0;

	for (i = 0; i < HUGEPAGESIZE; i++)
		append_buf[i] = 'R';
}

int create_file() {

	int fd = -1;

	if ((fd = open(FILENAME, O_RDWR | O_CREAT, 0666)) == -1) {
		printf("%s: file not created. err = %s\n", __func__, strerror(errno));
		exit(-1);
	}

	return fd;
}

int open_file() {

	int fd = -1;

	if ((fd = open(FILENAME, O_RDWR)) == -1) {
		printf("%s: file not opened. err = %s\n", __func__, strerror(errno));
		exit(-1);
	}

	return fd;
}

void fsync_file(int fd) {

	if (fsync(fd) != 0) {
		printf("%s: fsync failed! Err = %s\n", __func__, strerror(errno));
		exit(-1);
	}
}


void append_to_file(int fd, unsigned long long data, unsigned long long granularity_of_append) {

	int size_of_buf = granularity_of_append;
	char buf[size_of_buf];
	unsigned long long extent_number = 0, num_ops = 0, i = 0, offset = 0;

	num_ops = data / granularity_of_append;

	for (i = 0; i < num_ops; i++) {

		if (pwrite64(fd, buf, size_of_buf, offset) != size_of_buf) {
			printf("%s: write failed! %s \n", __func__, strerror(errno));
			exit(-1);
		}

		fsync_file(fd);

		offset += size_of_buf;
	}
}

void read_whole_file(int fd, unsigned long long granularity_of_read) {

	int size_of_buf = granularity_of_read;
	char buf[size_of_buf];
	int read_return_val = 0;
	unsigned long long offset = 0;

	do {

		if ((read_return_val = pread64(fd, buf, size_of_buf, offset)) == -1) {
			if (errno != EINVAL) {
				printf("%s: read failed! Err = %s\n", __func__, strerror(errno));			
				exit(-1);
			}
		}

		offset += MMAP_SIZE;

	} while (read_return_val == MBSIZE);
}

void close_file(int fd) {

	close(fd);
}

void unlink_file() {

	if (unlink(FILENAME) != 0) {
		printf("%s: unlink failed! Err = %s\n", __func__, strerror(errno));
		exit(-1);
	}
}

void perform_experiment(unsigned long long data_to_append, unsigned long long granularity_of_read, unsigned long long granularity_of_append, int num_ops) {

	double time_taken = 0.0;
	int fd = -1;
	int i = 0;

	printf("%s: data_to_append = %llu, granularity_of_read = %llu, granularity_of_append = %llu, num_ops = %d\n", __func__, data_to_append, granularity_of_read, granularity_of_append, num_ops);
	fflush(NULL);

	srand(5);

	gettimeofday(&start, NULL);	
	
	for (i = 0 ; i < num_ops ; i++) {

		fd = create_file();
		append_to_file(fd, data_to_append, granularity_of_append);
		//fsync_file(fd);
		close_file(fd);
		fd = open_file();
		read_whole_file(fd, granularity_of_read);
		close_file(fd);
		fd = open_file();
		close_file(fd);
		unlink_file();
	}

	gettimeofday(&end, NULL);	
	time_taken =(end.tv_sec-start.tv_sec)*1000000 + (end.tv_usec-start.tv_usec); 
	printf("%s: time for experiment = %f\n", __func__, time_taken); 
}

int main(int argc, char *argv[])
{
	unsigned long long data_to_append = 0, granularity_of_append = 0, granularity_of_read = 0;
	int num_ops = 0;

	if(argc != 5) {
		printf("Usage: ./a.out <data_to_append> <granularity_of_read> <granularity_of_append> <num_ops>\n");
		exit(-1);
	}

	setup_arguments(argv, &data_to_append, &granularity_of_read, &granularity_of_append, &num_ops);

	printf("################ STARTING HERE ##################\n");
	//creating new file and allocating it in the beginning


	void setup_append_buffer();

//-------------------------------------------------------------------------------------

	printf("################ STARTING MAIN WORKLOAD ##################\n");

	perform_experiment(data_to_append, granularity_of_read, granularity_of_append, num_ops);

//-------------------------------------------------------------------------------------

	return 0;
}
