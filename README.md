The Dude Bot
=========

This is a set of Ruby bindings for the chat service Zulip and a sample bot built with those bindings. When The Dude hears his name, he jumps into the conversation. I built this to practice writing bindings and working with JSON.

![ScreenShot](/dude.png)

##How to use it

Download dude_bot.rb. Get an API key and bot email address from Zulip, register your bot in a stream, and run ```ruby dude_bot.rb``` from the command line. Then sit back and enjoy.

To customize your bot, simply change the regex your bot is watching for and overwrite the #get_quotes method to supply a different set of responses. Use your bot for good, not for assholery.

##To do

1. The Dude Bot likes non-sequiturs and is not very convincingly human.  It would be fun to make his responses more dependent on various features of his interlocutors' messages.
2. I used Net::HTTP because it's part of Ruby's standard library but would like to try out Faraday and HTTParty.

##License

WTFPB
