#!/bin/bash
ls -1 pkg/*.cpio.zst | sed s/^.*\\/\// | sed -e 's/\.cpio.zst$//' > list.txt

