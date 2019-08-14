
all: test ## By default, just test everything

help: ## Show this help: a short list of most usefull make targets, with their descriptions.
	@grep -P '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

clean: ## remove build artefacts
	rm -rf *_test .*.c
 

test: test_simple test_extended ## Run all module tests

test_simple: ## Run only basic module tests
	@v vini_test.v

test_extended: ## Run extended (slower) module tests
	@v vini_extended_test.v
