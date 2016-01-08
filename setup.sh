#!/bin/bash

HIGHLIGHTCDN="http://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.3"
FONTS="Source+Sans+Pro:400,700,400italic,700italic|Source+Code+Pro:400,700|Source+Serif+Pro:400,700|PT+Sans:400,700,400italic,700italic|PT+Mono|PT+Serif:400,700,400italic,700italic|Inconsolata:400,700|Merriweather:400,400italic,700,700italic|Merriweather+Sans:400,400italic,700,700italic"

usage() {
    cat <<_EOF
setup.sh [-dfm] [-l "A B ..."] [-t STYLE]

Command-line arguments:
  -b              install mathbox
  -d              install deck.js
  -e              install executables (sass, jade, coffee)
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
   e)
       install="$install execs "
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

if [[ "$install" = *" execs "* ]]
then
    if [[ -z "$(which jade)" ]]
    then
        echo "Installing jade (npm package) ..."
        npm install -g jade
    else
        echo "Found $(which jade)!"
    fi
    if [[ -z "$(which coffee)" ]]
    then
        echo "Installing coffee (npm package) ..."
        npm install -g coffee-script
    else
        echo "Found $(which coffee)!"
    fi
    if [[ -z "$(which sass)" ]]
    then
        echo "Installing sass (ruby gem) ..."
        gem install sass
    else
        echo "Found $(which sass)!"
    fi
fi

mkdir -p local

# FONTS
if [[ "$install" = *" fonts "* ]]
then
    echo "Installing fonts ..."
    mkdir -p local/fonts
    curl -sSL "http://fonts.googleapis.com/css?family=$FONTS" > local/fonts/fonts.css
    grep src local/fonts/fonts.css | \
        sed 's|^  src\: local(.*), local(.\(.*\).), url(\(.*\)) format.*|echo "- \1"; curl -sSL "\2" > local/fonts/\1.ttf|' | \
        sed 's|^  src\: local(.\(.*\).), url(\(.*\)) format.*|echo "- \1"; curl -sSL "\2" > local/fonts/\1.ttf|' | bash
fi

# MATHJAX
if [[ "$install" = *" mathjax "* ]]
then
    (
        cd local
        echo "Downloading MathJax ..."
        curl -sSL "https://github.com/mathjax/MathJax/archive/v2.4-latest.zip" > mathjax.zip
        echo "Unpacking MathJax ..."
        unzip mathjax.zip >/dev/null 2>&1
        mv MathJax-2.4-latest mathjax
    )
fi

# MATHBOX.JS
if [[ "$install" = *" mathbox "* ]]
then
    (
        cd local
        echo "Downloading MathBox ..."
        curl -sSL "http://acko.net/files/mathbox2/mathbox-0.0.2.zip" > mathbox.zip
        echo "Unpacking MathBox ..."
        unzip mathbox.zip >/dev/null 2>&1
    )
fi

# DECK.JS
if [[ "$install" = *" deck "* ]]
then
    (
        cd local
        echo "Installing deck.js ..."
        curl -sSL "https://github.com/imakewebthings/deck.js/archive/latest.zip" > deck.zip
        unzip deck.zip >/dev/null 2>&1
        mv deck.js-latest deck.js
    )
fi

# HIGHLIGHT.JS
if [[ "$install" = *" hljs"* ]]
then
    (
        cd local
        theme=$(echo "$install" | sed 's|.* hljs=\([^ ]*\) .*|\1|')
        echo "Installing highlight.js ($theme) ..."
        mkdir -p highlight.js
        curl -sSL "${HIGHLIGHTCDN}/highlight.min.js" > highlight.js/highlight.min.js
        curl -sSL "${HIGHLIGHTCDN}/styles/$theme.min.css" > highlight.js/$theme.min.css
        echo "You may need to add to your SCSS: @import 'highlight.js/$theme.min.css'"
    )
fi
if [[ "$install" = *" hljslangs"* ]]
then
    (
        cd local
        for lang in $(echo "$install" | sed "s|.* hljslangs=\([^=]*\)= .*|\1|")
        do
            echo "- adding $lang"
            echo "You may need to add to your Jade: script(src='highlight.js/$lang.min.js')"
            curl -sSL "${HIGHLIGHTCDN}/languages/$lang.min.js" > highlight.js/$lang.min.js
        done
    )
fi
