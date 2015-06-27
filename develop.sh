#!/bin/bash

jade --pretty .
sass --update .
coffee --compile .

python -m http.server 8080
