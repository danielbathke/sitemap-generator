#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

die() {
    echo "${red}[ERROR]${reset} $1" > /dev/stderr
    exit 1
}

log() {
    $VERBOSE && echo "${green}[INFO]${reset} $1"
}

show_help() {
    echo "Usage: $0 [OPTIONS] url"
    echo ""
    echo "Options:"
    echo " -o,  --output     Define output filename. Default: sitemap.xml"
    echo " -f,  --frequency  Define URLs frequency. Default: weekly"
    echo "                   See: http://www.sitemaps.org/protocol.html#changefreqdef"
    echo " -h,  --help       See this help"
    exit 0
}

URL=
OUTPUT="sitemap.xml"
FREQUENCY="weekly"
DATE=`date +%Y-%m-%d`
VERBOSE=true
WGET=$(which wget)
SORT=$(which sort)
SED=$(which sed)
AWK=$(which awk)
CAT=$(which cat)
TR=$(which tr)
WC=$(which wc)
RM=$(which rm)

while true; do
    case "$1" in
        -v | --verbose ) VERBOSE=true; shift ;;
        -u | --url ) URL="$2"; shift 2 ;;
        -o | --output ) OUTPUT="$2"; shift 2 ;;
        -f | --frequency ) FREQUENCY="$2"; shift 2 ;;
        -h | --help ) show_help; shift 1;;
        * ) URL="$1"; break ;;
    esac
done

if [ -z "$URL" ]; then
    die "Usage: $0 [OPTIONS] url. Try $0 --help for more informations."
fi

TMP_TXT_FILE=/tmp/sitemap-generator.txt
SED_LOG_FILE=/tmp/sitemap-generator.sedlog.txt

log "URL: $URL"
log "Output: $OUTPUT"
log "Frequency: $FREQUENCY"
log "Priority: Dynamic"
echo ""

log "Crawling $URL => $TMP_TXT_FILE ..."
$WGET --spider --recursive -e robots=off --output-file=$TMP_TXT_FILE --no-verbose --reject=.jpg,.jpeg,.css,.js,.ico,.png $URL

echo ""
log "Cleaning urls ..."
# This sanitizes the &. Undoing that for now
#sed -n "s@.\+ URL:\([^ ]\+\) .\+@\1@p" $TMP_TXT_FILE | sed "s@&@\&amp;@" > $SED_LOG_FILE
# Pull URLs from wget's output
$SED -n "s@.\+ URL:\([^ ]\+\) .\+@\1@p" $TMP_TXT_FILE > $SED_LOG_FILE

log "Sorting and removing any duplicates ..."
$SORT -u -o $SED_LOG_FILE $SED_LOG_FILE

log "Generating $OUTPUT ..."
# Header from www.xml-sitemaps.com
echo '<?xml version="1.0" encoding="UTF-8"?>' > $OUTPUT
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"' >> $OUTPUT
echo '      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' >> $OUTPUT
echo '      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9' >> $OUTPUT
echo '            http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">' >> $OUTPUT

# Loop over lines in the sed log file for parsing - https://unix.stackexchange.com/a/7012/67790
IFS=$'\r\n'     # make newlines the only separator
set -f          # disable globbing
for i in $($CAT < "$SED_LOG_FILE"); do
    BASENAME=$(echo "$i" | $AWK -F[/:] '{print $4}')
    #DIR=$(echo "$i" | sed -r 's|.*/([^/]+)/?$|\1|') # This returns the last part of the URL only (typically the page), and not the category + page. 
    #PATH_COUNT=$(echo "$i" | tr '/' ' ' | wc -w) # This counts everything. http is 1, basename is 2, first path is 3, page is 4, etc. Priority isn't accurate if URL  is in a subfolder to begin with
    PATH_COUNT=$(echo "$i" | $SED "s#${URL}*##" | $TR '/' ' ' | $WC -w) # This removes the input URL, then counts the number of folders in the path. 
    
    # Add a priority element. Basename URL and immediate first level pages are priority 1. Further down the path line get priority 0.8
    # http://www.sitemaps.org/protocol.html#prioritydef
    if [[ ( $PATH_COUNT = 0 ) || ( $PATH_COUNT = 1 ) ]]; then
        PRIORITY=1.0
    else
        PRIORITY=0.8
    fi
    
$CAT >>$OUTPUT <<EOL
    <url>
        <loc>$i</loc>
        <lastmod>$DATE</lastmod>
        <priority>$PRIORITY</priority>
        <changefreq>$FREQUENCY</changefreq>
    <url>
EOL
done

echo '</urlset>' >> $OUTPUT

log "Cleaning temp files ..."
$RM -f $TMP_TXT_FILE  $SED_LOG_FILE

log "Cleaning wget's temp folder ..."
$RM -rf $BASENAME

echo ""
log "Done => $OUTPUT"
echo ""
