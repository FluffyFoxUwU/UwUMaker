# Recipes for each subdir

# Got from command line
SUBDIR 					:= $(SUBDIR)

ABSOLUTE_SUBDIR	:= $(abspath $(PROJECT_DIR)/$(SUBDIR))
BUILD_SUBDIR 		:= $(abspath $(OBJS_DIR)/$(SUBDIR))

include $(ABSOLUTE_SUBDIR)/Makefile
include makefiles/langs.mak

BUILD_DIR_OBJS		:= $(UwUMaker-dirs-y:%=$(BUILD_SUBDIR)/%/built_in.a)
BUILD_NO_DIR_OBJS := $(LANG_C_OBJS) 
BUILD_OBJECTS 		:= $(BUILD_DIR_OBJS) $(BUILD_NO_DIR_OBJS) 

# Recurse to dirs unconditionally
.PHONY: $(BUILD_DIR_OBJS)
$(BUILD_DIR_OBJS):
	$Q$(MKDIR) $(@:/built_in.a=)
	$Q$(MAKE) -f makefiles/subdir.mak SUBDIR=$(SUBDIR)/$(@:$(BUILD_SUBDIR)/%/built_in.a=%) $(abspath $@)

# Group objects into one UwU
$(BUILD_SUBDIR)/built_in.a: $(BUILD_OBJECTS)
	@$(PRINT_STATUS) AR "Archiving '$(@:$(OBJS_DIR)/%=%)'"
	$Q$(AR) qcs --thin $@ $(BUILD_OBJECTS)

# Link into an executable
$(BUILD_SUBDIR)/Executable: $(BUILD_SUBDIR)/built_in.a
	@$(PRINT_STATUS) LD "Linking '$(@:$(OBJS_DIR)/%=%)'"
	$Q$(CC) $(BUILD_SUBDIR)/built_in.a $(UwUmaker-linker-flags) -o $@

.PHONY: cmd_clean
cmd_clean:
	@$(PRINT_STATUS) CLEAN "Cleaning '$(BUILD_SUBDIR:$(OBJS_DIR)/%=%)'"
	$Q$(RM) $(BUILD_NO_DIR_OBJS) $(BUILD_SUBDIR)/Executable $(BUILD_SUBDIR)/built_in.a
	@# Recurse to each dirs unconditionally
	@$(foreach child,$(UwUMaker-dirs-y), $(MAKE) -f makefiles/subdir.mak SUBDIR=$(SUBDIR)/$(child) cmd_clean && ) true

.PHONY: cmd_all
ifeq ($(ABSOLUTE_SUBDIR),$(PROJECT_DIR))
cmd_all: $(BUILD_SUBDIR)/Executable
else
cmd_all: $(BUILD_SUBDIR)/built_in.a
endif





