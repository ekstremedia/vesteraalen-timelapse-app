This will be a android and iphone app for the cameras section of my website http://ekstremedia.no

The website is at /www/nesthus_2026/ 

This app will be a free "latest images and timelapse" app. 

I want it simple, with the same kind of dark and light theme as on my website, and norwegian bokmål, nynorsk and english like my huske app (/www/huske-docker/huske-mobile ) 

The app will be made with flutter. 

Set everything up for me and make the following pages:

First page will list the images. 

Make the API's in my website app if needed: /www/nesthus_2026/ - this is the website active on production right now.

So first page will just list the last images, displaying the current image, with names and last updated date. 

Click on image will go to its camera page, with embedded youtube of latest timelapse, displaying daytime, evenening and keogram images for that day, if they exist. Also add a datepicker so we can go back in time, and a NOW button to instantly go to todays date. Note that todays date will show current image but yesterdays timelapse, since todays timelapse will never be ready. 

When displaying current images, we need to poll from website, from cached apis so we dont stress server.

Make sure app is visually pleasing and support all kinds of sizes responsively, small mobiles, larger mobiles, tablets.  It needs to work on both android and apple.

Make it so that when i push to main, ci should build both for android and apple, and let them have the same auto increased build number. See how we did it in /www/huske-docker/huske-mobile 

I want everything documented in both a CLAUDE.md and a daily logs like we did in /www/huske-docker/logs 

I also want flutter tests for all componentes. Write domain driven, test driven, commented, clean code.


