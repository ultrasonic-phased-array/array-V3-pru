#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <prussdrv.h>
#include <pruss_intc_mapping.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include "pru.h"
#include "util.h"
#include <unistd.h>
#include <inttypes.h>
#include <sys/mman.h>

#define PRU1_NUM 	1
#define PRU1_FILE_NAME "pru1.bin"

#define PRU0_NUM 	0
#define PRU0_FILE_NAME "pru0.bin"

#define MEMSIZE			30*32

void initialize_pru();
void start_pru();
void uninitialize_pru();
void signal_handler(int sig);
static unsigned int proc_read(const char * const fname);

typedef struct
{
	// in the DDR shared with the PRU
	uintptr_t pixels_dma;

	// write 1 to start, 0xFF to abort. will be cleared when started
	volatile unsigned command;

	// will have a non-zero response written when done
	volatile unsigned response;

	volatile unsigned phasecounter;
} __attribute__((__packed__)) pru_command_t;

pru_command_t * pru0_command;
pru_t * pru;

static unsigned int proc_read(const char * const fname) {
	FILE * const f = fopen(fname, "r");
	if (!f)
		die("%s: Unable to open: %s", fname, strerror(errno));
	unsigned int x;
	fscanf(f, "%x", &x);
	fclose(f);
	return x;
}

void initialize_pru(){
	prussdrv_init ();

	/* Open PRU Interrupt */
	if (prussdrv_open(PRU_EVTOUT_0) != 0)
	{
		printf("prussdrv_open open failed\n");
		return(-1);
	}

	if (prussdrv_open(PRU_EVTOUT_1) != 0)
	{
		printf("prussdrv_open open failed\n");
		return(-1);
	}


  /* Initialize struct with INTC interrupt map (see PRU ref. guide, Fig. 97) */
  tpruss_intc_initdata pru_intc_data = PRUSS_INTC_INITDATA;

  /* Initialize INTC */
  if (prussdrv_pruintc_init(&pru_intc_data) != 0) {
    return(-1);
    fprintf(stderr, "An error occurred while initializing INTC.");
  }

	/* Initialize pointer to PRU data memory */
	const unsigned short pru_num = 0;

	void * pru_data_mem;
	prussdrv_map_prumem(
		PRUSS0_PRU0_DATARAM,
		&pru_data_mem
	);

	const int mem_fd = open("/dev/mem", O_RDWR);
	if (mem_fd < 0)
		die("Failed to open /dev/mem: %s\n", strerror(errno));

	const uintptr_t ddr_addr = proc_read("/sys/class/uio/uio0/maps/map1/addr");
	const uintptr_t ddr_size = proc_read("/sys/class/uio/uio0/maps/map1/size");

	const uintptr_t ddr_offset = ddr_addr;
	const size_t ddr_filelen = ddr_size;

	/* map the memory */
	uint8_t * const ddr_mem = mmap(
		0,
		ddr_filelen,
		PROT_WRITE | PROT_READ,
		MAP_SHARED,
		mem_fd,
		ddr_offset
	);
	if (ddr_mem == MAP_FAILED)
		die("Failed to mmap offset @ %zu bytes: %s\n",
			ddr_offset,
			ddr_filelen,
			strerror(errno)
		);

	close(mem_fd);

	pru = calloc(1, sizeof(*pru));
	if (!pru)
		die("calloc failed: %s", strerror(errno));

	*pru = (pru_t) {
		.pru_num	= pru_num,
		.data_ram	= pru_data_mem,
		.data_ram_size	= 8192,
		.ddr_addr	= ddr_addr,
		.ddr		= (void*)(ddr_mem),
		.ddr_size	= ddr_size,
	};

	fprintf(stderr,
		"%s: PRU %d: data %p @ %zu bytes, DMA %p /  @ %zu bytes\n",
		__func__,
		pru_num,
		pru->data_ram,
		pru->data_ram_size,
		pru->ddr,
		pru->ddr_addr,
		pru->ddr_size
	);

	pru0_command = calloc(1, sizeof(*pru0_command));
	pru0_command = pru->data_ram;

	pru0_command->command = 0x00;

	printf("Otters are ready!\n");
	fflush(stdout);

}

void start_pru(){
	prussdrv_exec_program (PRU0_NUM, PRU0_FILE_NAME);
	//pruDataMem_int[0] = 1;
	prussdrv_exec_program (PRU1_NUM, PRU1_FILE_NAME);
}

void uninitialize_pru(){
	/* Wait until PRU0 has finished execution */
	printf("INFO: Waiting for HALT command.\r\n");
  prussdrv_pru_wait_event (PRU_EVTOUT_0);

	//prussdrv_pru_clear_event (PRU0_ARM_INTERRUPT);
	//prussdrv_pru_clear_event (PRU1_ARM_INTERRUPT);

	prussdrv_pru_disable (PRU0_NUM);
	prussdrv_pru_disable (PRU1_NUM);
	prussdrv_exit ();

}
int main (int argc, char ** argv)
{
	/* PRU code only works if executed as root */
	if (getuid() != 0) {
			fprintf(stderr, "This program needs to run as root.\n");
			exit(EXIT_FAILURE);
	}

	initialize_pru();
	start_pru();

	uint8_t * const out = pru->ddr;

	for(int timeslots = 0; timeslots < MEMSIZE / 32; timeslots++) {
		for(int channels = 0; channels < 32; channels++) {
			out[channels + 32 * timeslots] = 0xFF * (timeslots < 15);
		}
	}
	printf("Starting phased array. Press ctrl+c to abort...\n");
	sleep(2);

	pru0_command->command = 0x01;

	while (pru0_command->response != 0x01) {} // wait for PRU0 ready

	pru0_command->phasecounter = 0;
	while(1) {
		printf("Periods: %d\r", pru0_command->phasecounter);
		fflush(stdout);
		usleep(100000);
	}

	pru0_command->command = 0xFF; // tell PRU0 to exit
	while (pru0_command->response != 0xFF) {} // wait for PRU0 exit

	printf("Otter: %d\n", pru0_command->response);

	uninitialize_pru();
	return(0);
}
