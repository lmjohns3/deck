#!/bin/bash

fonts="Source+Sans+Pro:400,700,400italic,700italic|Source+Code+Pro:400,700|Source+Serif+Pro:400,700,400italic,700italic"

while getopts ":f:" opt
do case $opt in
   f)
       fonts="PT+Sans:400,700,400italic,700italic|PT+Mono:400,700|PT+Serif:400,700,400italic,700italic"
       ;;
esac
done

if [[ -z "$(which jade)" ]]
then
    echo 'Installing jade (npm package) ...'
    npm install -g jade
else
    echo "Found $(which jade)!"
fi

if [[ -z "$(which sass)" ]]
then
    echo 'Installing sass (ruby gem) ...'
    gem install sass
else
    echo "Found $(which sass)!"
fi

echo 'Installing fonts ...'
mkdir -p fonts
curl "http://fonts.googleapis.com/css?family=$fonts" | \
  sed "s|local('|local('fonts/|g" > fonts/fonts.css
grep src fonts/fonts.css | \
  sed 's|^  src\: local(.*), local(.\(.*\).), url(\(.*\)) format.*|curl "\2" > \1.ttf|' | \
  sed 's|^  src\: local(.\(.*\).), url(\(.*\)) format.*|curl "\2" > \1.ttf|' | \
  /bin/bash

if [[ ! -f MathJax.zip ]]
then
    echo 'Downloading MathJax ...'
    curl -L 'https://github.com/mathjax/MathJax/archive/v2.4-latest.zip' > MathJax.zip
else
    echo 'MathJax already downloaded!'
fi

if [[ ! -f mathjax ]]
then
    echo 'Unpacking MathJax ...'
    unzip MathJax.zip
    mv MathJax-2.4-latest mathjax
else
    echo 'MathJax already unpacked!'
fi

echo 'Installing deck.js ...'
curl -L 'https://github.com/imakewebthings/deck.js/archive/latest.zip' > deck.zip
unzip deck.zip
mv deck.js-latest deck
