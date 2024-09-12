BASE_IMAGE_TAG = latest
BUILD_IMAGE_TAG = v2

all:
	go build -ldflags='-s -w' -buildvcs=false -o adapter

STAGE_DIR = stage

tls_cert:
	wget https://github.com/neuvector/manifests/raw/a7a69b63b7d27f880fbc3b7f0c58049f3928ab59/build/share/etc/neuvector/certs/ssl-cert.key -O ssl-cert.key
	wget https://github.com/neuvector/manifests/raw/a7a69b63b7d27f880fbc3b7f0c58049f3928ab59/build/share/etc/neuvector/certs/ssl-cert.pem -O ssl-cert.pem

copy_adpt: tls_cert
	mkdir -p ${STAGE_DIR}/usr/local/bin/
	mkdir -p ${STAGE_DIR}/etc/neuvector/certs
	#
	cp registry-adapter/adapter ${STAGE_DIR}/usr/local/bin/
	cp ssl-cert.key ${STAGE_DIR}/etc/neuvector/certs
	cp ssl-cert.pem ${STAGE_DIR}/etc/neuvector/certs

stage_init:
	rm -rf ${STAGE_DIR}; mkdir -p ${STAGE_DIR}

stage_adpt: stage_init copy_adpt

adapter_image: stage_adpt
	docker pull neuvector/adapter_base:${BASE_IMAGE_TAG}
	docker build --build-arg NV_TAG=$(NV_TAG) --build-arg BASE_IMAGE_TAG=${BASE_IMAGE_TAG} -t neuvector/registry-adapter -f registry-adapter/build/Dockerfile .

binary:
	@echo "Making $@ ..."
	@docker pull neuvector/build_fleet:${BUILD_IMAGE_TAG}
	@docker run --rm -ia STDOUT --name build --net=none -v $(CURDIR):/go/src/github.com/neuvector/registry-adapter -w /go/src/github.com/neuvector/registry-adapter --entrypoint ./make_bin.sh neuvector/build_fleet:${BUILD_IMAGE_TAG}
