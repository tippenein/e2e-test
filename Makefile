all: build run

build:
	docker build -t clarinet-devnet .

run:
	docker run --network host -v /var/run/docker.sock:/var/run/docker.sock clarinet-devnet
