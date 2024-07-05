#!/bin/bash

rm -rf gnuplot-6.0.1.tar.gz
wget https://sourceforge.net/projects/gnuplot/files/gnuplot/6.0.1/gnuplot-6.0.1.tar.gz
tar xzf gnuplot-6.0.1.tar.gz
cd gnuplot-6.0.1
./configure
make
sudo make install