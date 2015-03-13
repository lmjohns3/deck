#!/bin/bash

jade --pretty .
sass --update .
coffee -c .

python -m http.server 8080
