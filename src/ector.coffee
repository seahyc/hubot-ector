# Description:
#   Make hubot learn and reply, when no other script is triggered.
#
# Dependencies:
#   "ector": "^0.1.6"
#
# Configuration:
#   None
#
# Commands:
#   sentence not triggering any other command - Makes hubot reply (see "shut up" and "speak").
#   hubot shut up - Make hubot quiet.
#   hubot speak - Make hubot speak again.
#
# Notes:
#   None
#
# Author:
#   parmentf

util = require 'util'
Ector = require 'ector'
FileConceptNetwork =  require('file-concept-network').FileConceptNetwork

dirname = __dirname.split('/')
inde = dirname.indexOf 'node_modules'
file_backup = dirname.slice(0,inde).join('/')+'/scripts/cn.json'
console.log file_backup
ector = new Ector()
ector.injectConceptNetwork FileConceptNetwork
ector.cn.load file_backup, (err) ->
  if err
    console.error 'Error while loading cn.json\n%s', err
previousResponseNodes = null
quiet = false
speakReplies = 
  [ 'Thanks.', 'OK', 'As you will.', 'Glad to be here again :)', ':)', 'Thank you.']

module.exports = (robot) ->

  ector.setName robot.name

  robot.respond /shut up/i, (msg) ->
    quiet = true

  robot.respond /speak/i, (msg) ->
    quiet = false
    msg.reply msg.random speakReplies

  robot.respond /save yourself/i, (msg) ->
    ector.cn.save file_backup, (err) ->
      if err
        msg.reply "An error occurred while saving cn.json:", err
      else
        msg.reply "Thanks, My mind is safe now!"

  robot.catchAll (msg) ->
    text = msg.message.text.replace robot.name+' ', ''
    ector.setUser msg.message.user.name
    ector.addEntry text
    ector.linkNodesToLastSentence previousResponseNodes
    if not quiet and msg.message.room not in ['general'] and (msg.message.text.indexOf(robot.name) > -1)
      response = ector.generateResponse()
      previousResponseNodes = response.nodes
      msg.send response.sentence
