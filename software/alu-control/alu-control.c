#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <signal.h>
#include <stdbool.h>

#include <hps_0_arm_a9_0.h>

#define OPERAND_A_OFFSET 0x00
#define OPERAND_B_OFFSET 0x01
#define RESULT_LOW_OFFSET 0x02
#define RESULT_HIGH_OFFSET 0x03
#define OPCODE_OFFSET 0x04
#define STATUS_OFFSET 0x05

#define ADD 0x01
#define SUB 0x02
#define MUL 0x03
#define INCA 0x04
#define MOVA 0x05
#define SWAP 0x06
#define TWOS_COMP_ADD 0x07

static volatile bool interrupted = false;

typedef struct
{
	uint32_t *opA;
	uint32_t *opB;
	uint32_t *result_low;
	uint32_t *result_high;
	uint32_t *opcode;
	uint32_t *status;
} ALU;

int alu_check(ALU alu)
{
	if ( (&alu.opA) == NULL || (&alu.opB) == NULL || (&alu.result_low) == NULL ||
	    (&alu.result_high) == NULL || (&alu.opcode) == NULL || (&alu.status) == NULL)
	{
		fprintf(stderr,"ALU struct : NULL member\n");
		return 0;
	}
	return 1;
}


void interrupt_handler(int sig)
{
	printf("Received interrupt signal. Shutting down...\n");
	interrupted = true;
}

int alu_operate(uint32_t op, uint32_t A, uint32_t B, ALU alu)
{
	uint64_t result = 0;
	if (!alu_check(alu)) {
		fprintf(stderr,"Failed Check\n");
		return 0;
	}

	*alu.opA = A;
	*alu.opB = B;

	switch (op)
	{
		case ADD :
			*alu.opcode = ADD;
			break;
		case SUB :
			*alu.opcode = SUB;
			break;
		case MUL :
			*alu.opcode = MUL;
			break;
		case INCA :
			*alu.opcode = INCA;
			break;
		case MOVA :
			*alu.opcode = MOVA;
			break;
		case SWAP :
			*alu.opcode = SWAP;
			break;
		default :
			fprintf(stderr, "Invalid Opcode Arg\n");

	}

	result = (uint64_t) ( ((*alu.result_high) << 32) | *alu.result_low);
	
	return result;
}

ALU alu_init(void)
{
	int err = 0;
	uint32_t *qsys_mmr_base = NULL;
	int devmem_fd = -1;

	ALU alu;
	uint32_t *opA = NULL;
	uint32_t *opB = NULL;
	uint32_t *result_low = NULL;
	uint32_t *result_high = NULL;
	uint32_t *opcode = NULL;
	uint32_t *status = NULL;
		
	devmem_fd = open("/dev/mem", O_RDWR | O_SYNC);

	if (devmem_fd < 0) {
		err = errno;
		fprintf(stderr,"ERROR %d: couldn't open /dev/mem\n", err);
		exit(EXIT_FAILURE);
	}

	qsys_mmr_base = (uint32_t *) mmap(NULL,
			QSYS_MMR_0_SPAN, PROT_READ | PROT_WRITE, MAP_SHARED,
			devmem_fd, QSYS_MMR_0_BASE);

	if (qsys_mmr_base == MAP_FAILED) {
		err = errno;
		fprintf(stderr,"ERROR %d: mmap() failed\n", err);
		close(devmem_fd);
		exit(EXIT_FAILURE);
	}

	opA = qsys_mmr_base + OPERAND_A_OFFSET;
	opB = qsys_mmr_base + OPERAND_B_OFFSET;
	result_low = qsys_mmr_base + RESULT_LOW_OFFSET;
	result_high = qsys_mmr_base + RESULT_HIGH_OFFSET;
	opcode = qsys_mmr_base + OPCODE_OFFSET;
	status = qsys_mmr_base + STATUS_OFFSET;

	alu.opA = opA;
	alu.opB = opB;
	alu.result_low = result_low;
	alu.result_high = result_high;
	alu.opcode = opcode;
	alu.status = status;

	return alu;
}

void alu_print_registers(ALU alu)
{
	printf("*****************************************\n");
	printf("register addresses\n");
	printf("*****************************************\n");
	printf("operandA address:    0x%p\n", alu.opA);
	printf("operandB address:    0x%p\n", alu.opB);
	printf("result_low address:  0x%p\n", alu.result_low);
	printf("result_high address: 0x%p\n", alu.result_high);
	printf("opcode address:      0x%p\n", alu.opcode);
	printf("status address:      0x%p\n", alu.status);
	printf("*****************************************\n");
	printf("register values \n");
	printf("*****************************************\n");
	printf("operandA:    0x%08x\n", *alu.opA);
	printf("operandB:    0x%08x\n", *alu.opB);
	printf("result_low:  0x%08x\n", *alu.result_low);
	printf("result_high: 0x%08x\n", *alu.result_high);
	printf("opcode:      0x%08x\n", *alu.opcode);
	printf("status:      0x%08x\n", *alu.status);
	printf("*****************************************\n");
}


int main()
{
	ALU alu;
	uint32_t A, B;
	int result;

	alu = alu_init();

	alu_print_registers(alu);

	A = 100, B = 100;
	result = alu_operate(ADD, A, B, alu);
	printf("%d + %d = %d\n", A, B, result);

	A = 100, B = -100;
	result = alu_operate(ADD, A, B, alu);
	printf("%d + %d = %d\n", A, B, result);

	A = 0x7FFFFFFF, B = 1;
	result = alu_operate(ADD, A, B, alu);
	printf("%d + %d = %d\n", A, B, result);

	printf("\n");

	/*
	 * SUBTRACT
	 */

	A = 1000, B = 1000;
	result = alu_operate(SUB, A, B, alu);
	printf("%d - %d = %d\n", A, B, result);

	A = 1000, B = 5000;
	result = alu_operate(SUB, A, B, alu);
	printf("%d - %d = %d\n", A, B, result);

	A = 0x80000000, B = 1;
	result = alu_operate(SUB, A, B, alu);
	printf("%d - %d = %d\n", A, B, result);

	/*
	 * MULTIPLY
	 */
	printf("\n");

	A = 7000, B = 500;
	result = alu_operate(MUL, A, B, alu);
	printf("%d * %d = %d\n", A, B, result);

	A = 7000, B = -500;
	result = alu_operate(MUL, A, B, alu);
	printf("%d * %d = %d\n", A, B, result);

	A = 7000, B = 0;
	result = alu_operate(MUL, A, B, alu);
	printf("%d * %d = %d\n", A, B, result);


	/*
	 * INCA
	 */
	printf("\n");

	A = 10;
	result = alu_operate(INCA, A, B, alu);
	printf("%d +1 = %d\n", A, result);

	A = -1;
	result = alu_operate(INCA, A, B, alu);
	printf("%d +1 = %d\n", A,result);

	A = -2;
	result = alu_operate(INCA, A, B, alu);
	printf("%d +1 = %d\n", A,result);

	/*
	 * MOVA
	 */
	printf("\n");

	A = 5;
	result = alu_operate(MOVA, A, B, alu);
	printf("A=%d  R=%d\n", A, result);

	A = 0;
	result = alu_operate(MOVA, A, B, alu);
	printf("A=%d  R=%d\n", A,result);

	A = -5;
	result = alu_operate(MOVA, A, B, alu);
	printf("A=%d  R=%d\n", A,result);

	/*
	 * SWAP
	 */
	printf("\n");

	A = -1, B=0;
	result = alu_operate(SWAP, A, B, alu);
	printf("A and B was : %d and %d\n", A, B);
	printf("A and B now : %d and %d\n", *alu.opA, *alu.opB);

	return 0;
}
