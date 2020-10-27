Sitemap Generator
=================

This is a fork of https://github.com/danielbathke/sitemap-generator. The purpose of this fork is to provide some dynamic control over the priority. The input URL and first level pages are priority 1. The rest of the sitemap will get priority 0.8. As a result, option `-p` has been removed. 

Setting the priority like this [lets the search engines know which pages you deem most important for the crawlers](https://www.sitemaps.org/protocol.html#prioritydef). Typically first level pages and categories are most important.

## Installation

1. Download the `sitemap-generator.sh` to your system
2. Run `chmod +x sitemap-generator.sh`
3. Run `./sitemap-generator.sh -o /path/to/where/you/want/sitemap.xml http://your-website-url/`

### Crontab

To run on an automated schedule use crontab. Here's the entry I use which updates sitemap.xml every day at midnight. 

1. Run `crontab -e` to edit your crontab
2. To run the script every week, [Sunday at midnight](https://crontab.guru/every-week), at the bottom add `0 0 * * 0 /path/to/sitemap-generator.sh -o /path/to/where/you/want/sitemap.xml http://your-website-url/ >/dev/null 2>&1` - if you need to run this as sudo, [you may need to put this into root's crontab](https://askubuntu.com/a/173930/802852)
3. Save and exit crontab

---

**Usage:** sitemap-generator.sh [OPTIONS] url

**Options:**
-    -o,  --output     Define output filename. Default: sitemap.xml
-    -f,  --frequency  Define URLs frequency. Default: weekly - See: http://www.sitemaps.org/protocol.html#changefreqdef
-    -h,  --help       See this help
