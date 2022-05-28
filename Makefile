OUTPUT=bin/tcp_estats

.PHONY: build
build: $(OUTPUT)

.PHONY: sum
sum: go.sum

.PHONY: fmt
fmt: *.go cmd/tcp_estats/*.go probe/*.c probe/*.h
	go fmt cmd/tcp_estats/*.go
	clang-format -i --style=Google probe/*.c
	clang-format -i --style=Google probe/*.h

# TODO: probe tests?
.PHONY: test
test: cmd/tcp_estats/*.go 
	go test cmd/tcp_estats/*.go

.PHONY: clean
clean:
	-@rm $(OUTPUT)
	-@rm cmd/tcp_estats/tcp_estats_bpfe*.go
	-@rm cmd/tcp_estats/tcp_estats_bpfe*.o

.PHONY: run
run: build test
	sudo ./$(OUTPUT)

$(OUTPUT): cmd/tcp_estats/tcp_estats_bpfel.go cmd/tcp_estats/tcp_estats_bpfeb.go cmd/tcp_estats/*.go 
	CGO_ENABLED=1 go build -o $@ ./cmd/tcp_estats

cmd/tcp_estats/tcp_estats_bpfe%.go: probe/*.c probe/*.h
	go generate cmd/tcp_estats/main.go

cmd/tcp_estats/*_string.go: cmd/tcp_estats/tcp_estats.go
	go generate cmd/tcp_estats/tcp_estats.go

go.sum:
	go mod download github.com/cilium/ebpf
	go get github.com/ciliun/ebpf/cmd/bpf2go
