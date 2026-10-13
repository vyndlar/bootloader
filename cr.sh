#!/bin/sh

make clean && make boot && qemu-system-x86_64 -drive format=raw,file=boot.flp -d int,cpu_reset -D q.log
