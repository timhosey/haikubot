# HaikuBot

## A Note on Syllables
Because of the nature of HaikuBot, it will generate haiku in the 5-7-5 form. However,
this is generally not a requirement as haiku are more meant to convey ideas, emotions,
and not judgments. Unfortunately, it's hard to calibrate an unfeeling bot for emotions.

That said, HaikuBot also doesn't always generate a perfect 5-7-5 but sometimes will
spit out 5-6-5 or, in the event of abbreviations, longer phrases.

Some really great reading is here:
* http://www.graceguts.com/further-reading/forms-in-english-haiku
* http://www.nahaiwrimo.com/home/why-no-5-7-5

## Purpose
This is a Twitter bot written in Ruby intended to fetch tweets, analyze them for 17
syllables, and generate a 5-7-5 haiku (when possible) overlaid onto an image using
ImageMagick and the `mini_magick` gem. It also credits the author.

Built-in are limits for Twitter API. The settings in code (which can be changed) are:
* Checks every 2 minutes for 500 tweets matching specific hashtags
* If a workable haiku is found, it generates the haiku image
* The image will be posted to Twitter, tagging the author
* The image will be posted to a gallery site
* A timer is set for 5 minutes (will be 60 minutes when run in production) before re-run

## On Slurs
The default behavior of this bot uses the `swearjar` gem to scan posts for discriminatory
language/slurs and skips the post if it contains any instances of it. The `swearjar` gem
can be used for a variety of things, like insults, profanity, and more. This isn't fool-proof,
however, and the bot should be monitored for instances that may slip through.

## Todo
Here's a rough to-do list of things I'd like to add:
* Post finalized haiku image to Twitter
* Post finalized haiku image to a site
* Tag original author in Tweet