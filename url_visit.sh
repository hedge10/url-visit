#!/usr/bin/env sh
#
# The MIT License (MIT)
#
# Copyright (c) 2024 hedge10
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
usage() {
    echo 'Usage: url_visit.sh DOMAIN...

The sitemap is expected to be called 'sitemap.xml'. We look for http://mydomain.com/sitemap.xml.
Without an argument, it cannot run, obviously ;-)

Information:
  -h    Prints this help and exits.
'
}

# Name of downloaded sitemap for temporary processing.
# This file deleted after the warmup.
SITEMAP="tmp_sitemap.xml"

# User agent string to be used when crawling the site.
USER_AGENT="Cache Warmer"

download_sitemap() {
    _domain="$1"

    if curl --fail --silent --output "$SITEMAP" "${_domain}/sitemap.xml"; then
      echo "Sitemap downloaded successfully"
    else
      echo "Sitemap download failed"
      exit 1
    fi
}

warmup() {
    _domain="$1"

    grep -E -o "${_domain}[^<]+" "$SITEMAP" | while read -r line; do
        curl -A "$USER_AGENT" -s -L "$line" > /dev/null 2>&1
        echo "$line"
    done
}

main() {
    if [ "$#" -ne 1 ] || [ "$1" == "-h" ]; then
      usage
      exit 1
    fi

    download_sitemap "$1"
    warmup "$1"

    rm -f "$SITEMAP"
}

main "$@"
