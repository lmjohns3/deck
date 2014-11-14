#!/bin/bash

set -x

if [[ -z "$(which jade)" ]]
then npm install -g jade
fi

if [[ -z "$(which sass)" ]]
then gem install sass
fi

#fonts="PT+Sans:400,700,400italic,700italic|PT+Mono:400,700|PT+Serif:400,700,400italic,700italic"
fonts="Source+Sans+Pro:400,700,400italic,700italic|Source+Code+Pro:400,700|Source+Serif+Pro:400,700,400italic,700italic"

mkdir -p fonts
curl "http://fonts.googleapis.com/css?family=$fonts" | \
  sed "s|local('|local('fonts/|g" > fonts/fonts.css
grep src fonts/fonts.css | \
  sed 's|^  src\: local(.*), local(.\(.*\).), url(\(.*\)) format.*|curl "\2" > \1.ttf|' | \
  sed 's|^  src\: local(.\(.*\).), url(\(.*\)) format.*|curl "\2" > \1.ttf|' | \
  /bin/bash

if [[ ! -f MathJax.zip ]]
then curl 'https://github.com/mathjax/MathJax/archive/v2.4-latest.zip' > MathJax.zip
fi

if [[ ! -f mathjax ]]
then
    unzip MathJax.zip
    mv MathJax-2.4-latest mathjax
fi

curl -L 'https://github.com/imakewebthings/deck.js/archive/latest.zip' > deck.zip
unzip deck.zip
mv deck.js-latest deck
