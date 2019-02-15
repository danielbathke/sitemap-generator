sitemap-generator
=================

This is a fork of https://github.com/danielbathke/sitemap-generator. The purpose of this fork is to provide some dynamic control over the priority. The input URL and first level pages are priority 1. The rest of the sitemap will get priority 0.8. 

As a result, option `-p` has been removed. 

**Usage:** sitemap-generator.sh [OPTIONS] url

**Options:**
-    -o,  --output     Define output filename. Default: sitemap.xml
-    -f,  --frequency  Define URLs frequency. Default: monthly - See: http://www.sitemaps.org/protocol.html#changefreqdef
-    -h,  --help       See this help
