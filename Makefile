build: src/**/*
	forge build
	yarn generate-typechain

test: test/**/* src/**/*
	forge test -v

clean:
	rm -rf cache