#!/bin/bash

jade --pretty --watch *.jade &
jade_pid=$!

sass --watch *.sass

kill $jade_pid
