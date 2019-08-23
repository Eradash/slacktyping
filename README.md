# SlackTyping

A very good program that makes it so it says i'm typing when anyone else is typing

https://twitter.com/leinweber/status/989267343002951680

## Installation

Generate a [legacy token](https://api.slack.com/custom-integrations/legacy-tokens) for the workspaces you want to integrate with.

Create a Heroku account, and create a project, linking the project with your github project

In the settings of your Heroku project, create a **Config Vars** with the following value:

`SLACK_API_TOKENS` -- `<token1> <token2> <...>`

_Notice the space between tokens, enter the tokens without the `<` and `>`_

Manualy deploy your project on Heroku the first time, and you can setup the automatic deploy if you want ;)

## Running locally

- clone the project
- run `bundle install`.
- Set your token variables: `export SLACK_API_TOKENS="<token1> <token2> <...>"`
- Run the command `ruby typing.rb`
- Enjoy!
