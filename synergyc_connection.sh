#!/bin/bash

ssh -f -L 3333:localhost:24800 $1 -N
synergyc localhost:3333
