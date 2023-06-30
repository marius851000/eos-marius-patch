mkdir -p rom
ndstool -x ~/tmp/testsndstreamus.nds -9 rom/arm9.bin -7 rom/arm7.bin -y9 rom/y9.bin -y7 rom/y7.bin -d rom/data -y rom/overlay -t rom/banner.bin -h rom/header.bin
