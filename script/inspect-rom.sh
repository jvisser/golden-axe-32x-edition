#!/bin/bash

# Better to use https://ide.kaitai.io/devel/ if possible...
docker run -v "$(pwd)/..:/share" -it kaitai/ksv ./rom/rom.bin ./doc/struct/rom.ksy