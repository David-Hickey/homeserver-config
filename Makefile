# Allow optional dependencies
.SECONDEXPANSION:

# Auto-detect all stack directories that contain a docker-compose.yml
STACK_DIR := stacks
STACKS := $(patsubst $(STACK_DIR)/%/docker-compose.yml,%,$(wildcard $(STACK_DIR)/*/docker-compose.yml))

# Default target
all: $(STACKS)

# Pattern rule: each stack depends on its env files and compose file
# Output is a generated .env file per stack
$(STACKS): %: $(STACK_DIR)/%/.env

# Build .env file by merging public and private envs (if they exist)
$(STACK_DIR)/%/.env: $$($(STACK_DIR)/%/public.env) $$(wildcard $(STACK_DIR)/%/private.env)
	@echo "Merging env files for $*..."
	@echo "# Generated environment file for $*" > $@  # clear old .env
	@if [ -f $(STACK_DIR)/$*/public.env ]; then cat $(STACK_DIR)/$*/public.env >> $@; fi
	@if [ -f $(STACK_DIR)/$*/private.env ]; then cat $(STACK_DIR)/$*/private.env >> $@; fi

# Cleanup
clean:
	@echo "Cleaning generated .env files..."
	@for s in $(STACKS); do rm -f $(STACK_DIR)/$$s/.env; done

.PHONY: all clean $(STACKS)
