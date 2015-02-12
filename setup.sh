#!/bin/bash

HIGHLIGHTCDN="http://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.3"
SOURCEFONTS="Source+Sans+Pro:600,900,600italic,900italic|Source+Code+Pro:500,900|Source+Serif+Pro:400,600,700"
PTFONTS="PT+Sans:400,700,400italic,700italic|PT+Mono|PT+Serif:400,700,400italic,700italic"

usage() {
    cat <<_EOF
setup.sh [-dfm] [-l "A B ..."] [-t STYLE]

Command-line arguments:
  -d              install deck.js
  -f {pt,source}  install PT or Source fonts
  -l "A B ..."    install nonstandard highlight.js languages A, B, ...
  -m              install mathjax
  -t THEME        install highlight.js with a particular theme, e.g. github

See https://highlightjs.org/static/test.html for available highlight.js themes.

Example invocation to get going from scratch:

  ./setup.sh -d -m -f source -t github

_EOF
    exit 1
}

install=""
while getopts ":df:l:mt:" opt
do case $opt in
   d)
       install="$install deck "
       ;;
   f)
       install="$install fonts=$OPTARG "
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
if [[ "$install" = *" fonts="* ]]
then
    echo "Installing fonts ..."
    [[ "$install" = *"fonts=pt"* ]] && fn=$PTFONTS || fn=$SOURCEFONTS
    mkdir -p fonts
    curl -sSL "http://fonts.googleapis.com/css?family=$fn" > _fonts.css
    grep src _fonts.css | \
        sed 's|^  src\: local(.*), local(.\(.*\).), url(\(.*\)) format.*|echo "- \1"; curl -sSL "\2" > fonts/\1.ttf|' | \
        sed 's|^  src\: local(.\(.*\).), url(\(.*\)) format.*|echo "- \1"; curl -sSL "\2" > fonts/\1.ttf|' | bash
    cat _fonts.css | \
        sed 's|^  src\: local(.*), local(.\(.*\).), .*|  src: url(\1.ttf) format('truetype');|' | \
        sed 's|^  src\: local(.\(.*\).), url.*|  src: url(\1.ttf) format('truetype');|' >> fonts/fonts.css
    rm _fonts.css
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

# DECK.JS
if [[ "$install" = *" deck "* ]]
then
    echo "Installing deck.js ..."
    curl -sSL "https://github.com/imakewebthings/deck.js/archive/latest.zip" > deck.zip
    unzip deck.zip >/dev/null 2>&1
    rm -fr deck
    mv deck.js-latest deck
fi

# HIGHLIGHT.JS
if [[ "$install" = *" hljs"* ]]
then
    theme=$(echo "$install" | sed 's|.* hljs=\([^ ]*\) .*|\1|')
    echo "Installing highlight.js ($theme) ..."
    mkdir -p highlight
    curl -sSL "${HIGHLIGHTCDN}/highlight.min.js" > highlight/highlight.min.js
    curl -sSL "${HIGHLIGHTCDN}/styles/$theme.min.css" > highlight/$theme.min.css
    echo "You may need to add to your SCSS: @import 'highlight/$theme.min.css'"
fi
if [[ "$install" = *" hljslangs"* ]]
then
    for lang in $(echo "$install" | sed "s|.* hljslangs=\([^=]*\)= .*|\1|")
    do
        echo "- adding $lang"
        echo "You may need to add to your Jade: script(src='highlight/$lang.min.js')"
        curl -sSL "${HIGHLIGHTCDN}/languages/$lang.min.js" > highlight/$lang.min.js
    done
fi
