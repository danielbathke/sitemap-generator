#/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

die() {
    echo "${red}[ERROR]${reset} $1" > /dev/stderr
    exit 1
}

log() {
    $VERBOSE && echo "${green}[INFO]${reset} $1" > /dev/stdout
}

URL=
OUTPUT="sitemap.xml"
FREQUENCY="monthly"
PRIORITY=0.8
DATE=`date +%Y-%m-%d`
VERBOSE=false

while true; do
    case "$1" in
        -v | --verbose ) VERBOSE=true; shift ;;
        -u | --url ) URL="$2"; shift 2 ;;
        -o | --output ) OUTPUT="$2"; shift 2 ;;
        -f | --frequency ) FREQUENCY="$2"; shift 2 ;;
        -p | --priority ) PRIORITY="$2"; shift 2 ;;
        * ) URL="$1"; break ;;
    esac
done

if [ -z "$URL" ]; then
    die "Usage: $0 [OPTIONS] url"
fi

TMP_TXT_FILE=$OUTPUT.txt
SED_LOG_FILE=$OUTPUT.sedlog.txt

log "URL: $URL"
log "Output: $OUTPUT"
log "Frequency: $FREQUENCY"
log "Priority: $PRIORITY"
echo ""

log "Crawling $URL => $TMP_TXT_FILE ..."
wget --spider --recursive --output-file=$TMP_TXT_FILE --no-verbose --reject=.jpg,.jpeg,.css,.js,.ico,.png $URL

log "Cleaning urls ..."
sed -n "s@.\+ URL:\([^ ]\+\) .\+@\1@p" $TMP_TXT_FILE | sed "s@&@\&amp;@" > $SED_LOG_FILE

log "Generating $OUTPUT ..."
echo '<?xml version="1.0" encoding="UTF-8"?>' > $OUTPUT
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> $OUTPUT

log "Generating XML metadata in $OUTPUT ..."
awk '{print "\t<url><loc>"$0"</loc><lastmod>'$DATE'</lastmod><changefreq>monthly</changefreq><priority>0.8</priority></url>"}' $SED_LOG_FILE >> $OUTPUT

echo '</urlset>' >> $OUTPUT

log "Cleaning temp files ..."
rm -f $TMP_TXT_FILE  $SED_LOG_FILE

echo ""
log "Done => $OUTPUT"
echo ""
