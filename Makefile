build: src/**/*
	forge build
	yarn generate-typechain

test: test/**/* src/**/*
	forge test -vvvv

clean:
	rm -rf cache