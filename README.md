#About

The Slack Weather Bot is a Slack Bot that communicates the weather for a given day.

The bot responds to three core commands
-weather now
-weather tomorrow
-whenever report `number of days`

'weather now' will give the weather for new york if no other flags are provided 
'weather now' will give the weather for chicago, los angeles, and a random location on earth if appended with "chicago", "los angeles", and "random" respectively

'weather tomorrow' works exactly like 'weather now' but with the weather for tomorrow

'whenever report' gives the weather report for up to 90 days in the future or past. 
e.g 'whenever report 20' or 'whenever report -20'

The bot will also report if the temperature today is 20 degrees different from the weather tomorrow

#Install

clone this repository, get an API key for the darksy weather API and your slack bot
create a .env file and load your keys into there
