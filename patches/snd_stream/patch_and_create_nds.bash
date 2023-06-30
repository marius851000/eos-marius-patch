cd rom
#armips ../new_snd_stream_official_v2_looppoint_fix_eu.asm
cd ..
ndstool -c testsndstream_patched.nds -9 rom/arm9.bin -7 rom/arm7.bin -y9 rom/y9.bin -y7 rom/y7.bin -d rom/data -y rom/overlay -t rom/banner.bin -h ~/tmp/testsndstreamus.nds -r9 0x2000000 -e9 0x2000800 -r7 0x2380000 -e7 0x2380000
