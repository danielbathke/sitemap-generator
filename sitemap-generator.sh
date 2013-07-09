#/bin/bash

DATE=`date +%Y-%m-%d`

wget --spider --recursive --output-file=sitemap.txt --no-verbose --reject=.jpg,.jpeg,.css,.js,.ico $1

sed -n "s@.\+ URL:\([^ ]\+\) .\+@\1@p" sitemap.txt | sed "s@&@\&amp;@" > sedlog.txt

echo '<?xml version="1.0" encoding="UTF-8"?>' > sitemap.xml
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> sitemap.xml

awk '{print "<url><loc>"$0"</loc><lastmod>'$DATE'</lastmod><changefreq>monthly</changefreq><priority>0.8</priority></url>"}' sedlog.txt >> sitemap.xml

echo '</urlset>' >> sitemap.xml

