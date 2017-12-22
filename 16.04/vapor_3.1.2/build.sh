#!/bin/bash

mkdir src/usr/local/bin/

cd build

swift build -c release

cp .build/release/Executable ../src/usr/local/bin/vapor
