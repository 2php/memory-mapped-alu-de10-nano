EXEC=alu-control
SRCS=alu-control.c
OBJS=$(SRCS:.c=.o)

INCLUDE_DIRS=include
INC_PARAMS=$(foreach d, $(INCLUDE_DIRS), -I$d)

ARMBUILDDIR=build/arm
ARMEXECDIR=.

CFLAGS=-static -g -Wall -std=gnu99 -O0 $(INC_PARAMS)
LDFLAGS=-g -Wall

CC=gcc

.PHONY: arm
arm: armdirs $(ARMEXECDIR)/$(EXEC)

$(ARMEXECDIR)/$(EXEC): $(ARMBUILDDIR)/$(OBJS)
	$(CC) $(LDFLAGS) $^ -o $@

$(ARMBUILDDIR)/$(OBJS): $(SRCS)
	@echo "----------------------------------"
	@echo "building for arm..."
	@echo "----------------------------------"
	$(CC) $(CFLAGS) -c $^ -o $@

.PHONY: armdirs
armdirs: $(ARMBUILDDIR) $(ARMEXECDIR)

$(ARMBUILDDIR):
	@echo "----------------------------------"
	@echo "creating arm directories..."
	@echo "----------------------------------"
	mkdir -p $@

$(ARMEXECDIR):
	mkdir -p $@

.PHONY: clean
clean:
	@echo "----------------------------------"
	@echo "removing build files..."
	@echo "----------------------------------"
	rm -rf $(BUILDDIR)
	@echo "----------------------------------"
	@echo "removing executable files..."
	@echo "----------------------------------"
	rm -rf $(ARMEXECDIR)/$(EXEC) $(EXEC)
