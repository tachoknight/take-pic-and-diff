# take-pic-and-diff
Bash script that takes a picture (in this case, the raspistill program as it's meant to run on a Raspberry Pi), and uses ImageMagick's compare program to determine if a newly taken picture warrants processing.

Couple of notes:

1. It was written for a specific purpose on a Raspberry Pi, but should be generic enough that you can use it on some other platform

2. On a raspi b+ it takes almost a minute to run, so depending on the hardware you're using, plan your cron job accordingly. :)
