#!/bin/bash

highlightcdn="http://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.3"
highlightstyle="github"  # "tomorrow-night-bright"
highlightlangs=""
fonts="Source+Sans+Pro:400,700,400italic,700italic|Source+Code+Pro:400,700|Source+Serif+Pro:400,700,400italic,700italic"

usage() {
    cat <<_EOF
setup.sh [-f] [-l "A B ..."] [-s STYLE]

Command-line arguments:
  -f            install PT instead of Source font family
  -l "A B ..."  install highlight.js languages A, B, ...
  -s STYLE      install the given highlight.js style,
                defaults to ${highlightstyle}

See https://highlightjs.org/static/test.html for available highlight.js styles.

_EOF
    exit 1
}

while getopts ":fl:s:" opt
do case $opt in
   f)
       fonts="PT+Sans:400,700,400italic,700italic|PT+Mono:400,700|PT+Serif:400,700,400italic,700italic"
       ;;
   l)
       highlightlangs=$OPTARG
       ;;
   s)
       highlightstyle=$OPTARG
       ;;
   *)
       usage
       ;;
esac
done

shift $((OPTIND-1))

if [[ -z "$(which jade)" ]]
then
    echo "Installing jade (npm package) ..."
    npm install -g jade
else
    echo "Found $(which jade)!"
fi

if [[ -z "$(which sass)" ]]
then
    echo "Installing sass (ruby gem) ..."
    gem install sass
else
    echo "Found $(which sass)!"
fi

# FONTS
echo "Installing fonts ..."
mkdir -p fonts
curl -sSL "http://fonts.googleapis.com/css?family=$fonts" | \
  sed "s|local('|local('fonts/|g" > fonts/fonts.css
grep src fonts/fonts.css | \
  sed 's|^  src\: local(.*), local(.\(.*\).), url(\(.*\)) format.*|echo "- \1"; curl -sSL "\2" > \1.ttf|' | \
  sed 's|^  src\: local(.\(.*\).), url(\(.*\)) format.*|echo "- \1"; curl -sSL "\2" > \1.ttf|' | \
  /bin/bash

# MATHJAX
if [[ ! -f MathJax.zip ]]
then
    echo "Downloading MathJax ..."
    curl -sSL "https://github.com/mathjax/MathJax/archive/v2.4-latest.zip" > MathJax.zip
else
    echo "MathJax already downloaded!"
fi

if [[ ! -d mathjax ]]
then
    echo "Unpacking MathJax ..."
    unzip MathJax.zip >/dev/null 2>&1
    mv MathJax-2.4-latest mathjax
else
    echo "MathJax already unpacked!"
fi

# DECK.JS
echo "Installing deck.js ..."
curl -sSL "https://github.com/imakewebthings/deck.js/archive/latest.zip" > deck.zip
unzip deck.zip >/dev/null 2>&1
rm -fr deck
mv deck.js-latest deck

# HIGHLIGHT.JS
echo "Installing highlight.js ..."
mkdir -p highlight
curl -sSL "${highlightcdn}/highlight.min.js" > highlight/highlight.min.js

echo "- installing $highlightstyle theme"
echo "@import 'highlight/${highlightstyle}.min.css'" >> theme.sass
curl -sSL "${highlightcdn}/styles/${highlightstyle}.min.css" > highlight/${highlightstyle}.min.css

for l in $highlightlangs
do
    echo "- adding $l"
    echo "script(src='highlight/$l.min.js')" >> slides.jade
    curl -sSL "${highlightcdn}/languages/$l.min.js" > highlight/$l.min.js
done
