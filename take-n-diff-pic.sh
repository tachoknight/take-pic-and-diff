#!/bin/bash

#
# tl;dr: Take a pic, compare to previous pic, and if there's enough difference,
# do something with the new pic, which also becomes the previous pic
#
# This script is used to take pictures for a timelapse movie of the
# build-out of the new space at Pumping Station: One (http://pumpingstationone.org).
# This script is scheduled via cron to run every two minutes (on a Raspi 2
# this script takes almost 50 seconds to run, so two minutes gives it a minute
# to rest and not consume 100% of the CPU all the time).
#
# The script was written to run on a raspberry pi with the camera module.
# It also assumes ImageMagick is installed (that's what does the image
# comparison). The PS:1 version uses Amazon's S3 SDK to upload the 'new'
# image to a bucket, but you can just as easily do something else with the
# image, just copying to a different directory or whatever.
#

# The directory the script and images live. This is to keep cron happy
SAVEDIR=/home/pi/camera/test
# The filename format we'll use for the images
filename=ns-$(date -u +"%d%m%Y_%H%M-%S").jpg

echo Taking pic...
# Replace the line below with whatever program you want to use to take a picture
raspistill -o $SAVEDIR/$filename

echo Beginning test...
# This line uses ImageMagick's 'compare' program to get a diff of the
# previous picture (prev_pic.jpg) and the new picture we just took
# (see http://www.imagemagick.org/script/command-line-options.php#metric)
# Because the output of compare is to stderr we have to pipe it to stdout to
# capture it in a variable
diffamount=$((`compare -metric ncc $SAVEDIR/prev_pic.jpg $SAVEDIR/$filename null:`) 2>&1)

# Depending on what kind of change you can expect you may want to adjust this
# value
threshold=0.85

echo Difference is $diffamount and threshold is $threshold

# Bash doesn't deal with floats, so we send it to the command line
# calculator bc which will send back a 0 or 1
if (( $(bc <<< "$diffamount < $threshold") ))
then
    echo There was enough change

    #
    # TODO: Do something with the image, like copy it somewhere else
    # for further processing, add to a database or whatever. Note that
    # you don't want to do a 'mv' or remove the image as part of whatever
    # you're doing, because we need it to become the previous image
    # for future comparisons
    #
    # cp $SAVEDIR/$filename /somewhere-else

    # The new image will become the previous image that we compare the
    # *next* image to, next time this script is run
    rm $SAVEDIR/prev_pic.jpg
    mv $SAVEDIR/$filename $SAVEDIR/prev_pic.jpg
else
    # There wasn't enough change between the previous image and the
    # current one. The reason why the new image doesn't become the
    # previous one in this block is because I wanted to see keep track
    # of the date/time combo of when something interesting happened, so
    # the end result is a series of images with the actual date/times that
    # a change was detected.
    echo Not enough change
fi

echo Removing $filename
# Regardless of whether there was sufficient change, we want to clean up
# 'cause the raspi doesn't have an awful lot of free disk space where this
# directory lives
rm $SAVEDIR/$filename

echo Done
