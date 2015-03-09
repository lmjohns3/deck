#!/bin/bash

HIGHLIGHTCDN="http://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.3"
FONTS="Source+Sans+Pro:400,700,400italic,700italic|Source+Code+Pro:400,700|Source+Serif+Pro:400,700|PT+Sans:400,700,400italic,700italic|PT+Mono|PT+Serif:400,700,400italic,700italic|Inconsolata:400,700|Merriweather:400,400italic,700,700italic|Merriweather+Sans:400,400italic,700,700italic"

usage() {
    cat <<_EOF
setup.sh [-dfm] [-l "A B ..."] [-t STYLE]

Command-line arguments:
  -b              install mathbox.js
  -d              install deck.js
  -f              install PT, Source, Merriweather, and Inconsolata fonts
  -l "A B ..."    install nonstandard highlight.js languages A, B, ...
  -m              install mathjax
  -t THEME        install highlight.js with a particular theme, e.g. github

See https://highlightjs.org/static/test.html for available highlight.js themes.

Example invocation to get going from scratch:

  ./setup.sh -bdfm -t github

_EOF
    exit 1
}

install=""
while getopts ":bdfl:mt:" opt
do case $opt in
   b)
       install="$install mathbox "
       ;;
   d)
       install="$install deck "
       ;;
   f)
       install="$install fonts "
       ;;
   l)
       install="$install hljslangs=${OPTARG}= "
       ;;
   m)
       install="$install mathjax "
       ;;
   t)
       install="$install hljs=$OPTARG "
       ;;
   *)
       usage
       ;;
esac
done

shift $((OPTIND-1))

if [[ -z "$install" || -n "$1" ]]
then usage
fi

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
if [[ "$install" = *" fonts "* ]]
then
    echo "Installing fonts ..."
    mkdir -p fonts
    curl -sSL "http://fonts.googleapis.com/css?family=$FONTS" > fonts/_fonts.css
    grep src fonts/_fonts.css | \
        sed 's|^  src\: local(.*), local(.\(.*\).), url(\(.*\)) format.*|echo "- \1"; curl -sSL "\2" > fonts/\1.ttf|' | \
        sed 's|^  src\: local(.\(.*\).), url(\(.*\)) format.*|echo "- \1"; curl -sSL "\2" > fonts/\1.ttf|' | bash
    cat fonts/_fonts.css >> fonts/fonts.css
    rm -f fonts/_fonts.css
fi

# MATHJAX
if [[ "$install" = *" mathjax "* ]]
then
    echo "Downloading MathJax ..."
    curl -sSL "https://github.com/mathjax/MathJax/archive/v2.4-latest.zip" > MathJax.zip
    echo "Unpacking MathJax ..."
    unzip MathJax.zip >/dev/null 2>&1
    mv MathJax-2.4-latest mathjax
fi

# MATHBOX.JS
if [[ "$install" = *" mathbox "* ]]
then
    echo "Downloading MathBox.js ..."
    curl -sSL "https://github.com/unconed/MathBox.js/archive/master.zip" > MathBox.zip
    echo "Unpacking MathBox ..."
    unzip MathBox.zip >/dev/null 2>&1
    mv MathBox.js-master mathbox.js
fi

# DECK.JS
if [[ "$install" = *" deck "* ]]
then
    echo "Installing deck.js ..."
    curl -sSL "https://github.com/imakewebthings/deck.js/archive/latest.zip" > deck.zip
    unzip deck.zip >/dev/null 2>&1
    rm -fr deck
    mv deck.js-latest deck.js
fi

# HIGHLIGHT.JS
if [[ "$install" = *" hljs"* ]]
then
    theme=$(echo "$install" | sed 's|.* hljs=\([^ ]*\) .*|\1|')
    echo "Installing highlight.js ($theme) ..."
    mkdir -p highlight.js
    curl -sSL "${HIGHLIGHTCDN}/highlight.min.js" > highlight.js/highlight.min.js
    curl -sSL "${HIGHLIGHTCDN}/styles/$theme.min.css" > highlight.js/$theme.min.css
    echo "You may need to add to your SCSS: @import 'highlight.js/$theme.min.css'"
fi
if [[ "$install" = *" hljslangs"* ]]
then
    for lang in $(echo "$install" | sed "s|.* hljslangs=\([^=]*\)= .*|\1|")
    do
        echo "- adding $lang"
        echo "You may need to add to your Jade: script(src='highlight.js/$lang.min.js')"
        curl -sSL "${HIGHLIGHTCDN}/languages/$lang.min.js" > highlight.js/$lang.min.js
    done
fi
