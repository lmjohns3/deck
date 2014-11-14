#!/bin/bash

jade --pretty --watch $1.jade &
jade_pid=$!

sass --watch $1.sass

kill $jade_pid
