deck.js-presentation
====================

This repository is a template for using deck.js for nice presentations. It
includes the following features:

- Use [jade](http://jade-lang.com) to generate HTML
- Use [sass](http://sass-lang.com) to generate CSS
- Include math easily with [MathJax](http://mathjax.org)
- Show beautiful source code with [highlight.js](http://highlightjs.org)
- Typeset everything using [awesome fonts](http://google.com/fonts)

Everything required to show your slides is installed locally using the
`setup.sh` script, so you will not need internet access during your presentation
(unless you include things in your slides that require it, e.g. YouTube videos).

Installation
------------

Just download/unzip or clone this repository, run the included `setup.sh` script
to install everything, then run `develop.sh`.

    git clone https://github.com/lmjohns3/deck.js-presentation slides
    cd slides
    ./setup.sh -d -m -f source -t github
    ./develop.sh

You can then edit your slides and view them in your browser locally. When you're
done editing and ready to present, you copy the entire folder onto a USB drive
or the like.

The `setup.sh` script can install individual components as needed. Run
`setup.sh` for some command-line help. You might need to edit the `setup.sh`
script (or just install things yourself) if what you're trying to do is beyond
its current scope.

Requirements
------------

The `setup.sh` script installs everything you need locally, inside the current
directory. To use the script and all of the features that it relies on, you'll
need the following on your system:

- [ruby](http://rubygems.org) - required to use sass
- [npm](http://npmjs.org) - required to use jade
- [curl](http://curl.haxx.se) - used to download fonts, MathJax and deck.js

Note that none of these tools are needed when you have finished creating your
slides -- they are just used when in "development mode."

If you're running on a Mac or Linux box, most of these tools are probably
already installed. If not, it's pretty straightforward to install them using
existing package managers.
