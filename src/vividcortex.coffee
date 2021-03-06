# Description:
#   Renders VividCortex components as images
#
# Configuration:
#   HUBOT_VC_ORGANIZATION # This is the organization nickname, you'll see it in the VividCortex app URL
#   HUBOT_VC_ENVIRONMENT # This is the environment ID, you'll see it in the VividCortex app URL too
#   HUBOT_VC_TOKEN # This is the same token used to install VividCortex
#
# Commands:
#   hubot <vividcortex|vc> <top-queries|query-compare|top-processes> last <count> <seconds|minutes|hours|days|month> - Generate a capture of the specified component
#   hubot <vividcortex|vc> <top-queries|query-compare|top-processes> last minute|hour|month
#   hubot <vividcortex|vc> query-compare last N seconds
#   hubot <vividcortex|vc> top-processes last 10 minutes
#   hubot <vividcortex|vc> top-queries last 20 days
#   hubot <vividcortex|vc> share top-queries last 3 months
#
# Notes:
#   - Does not support graphs at the moment
#   - The second parameter only accepts "last" as a option, the plan is making it support multiple values like timestamps.
#
# Author:
#   cesarvarela

# VividCortex api URL

api = "https://app.vividcortex.com/api/v2"

# Config

ORGANIZATION = process.env.HUBOT_VC_ORGANIZATION
ENVIRONMENT = process.env.HUBOT_VC_ENVIRONMENT
TOKEN = process.env.HUBOT_VC_TOKEN

module.exports = (robot) ->


  environmentIsOk = (msg) ->

    unless ORGANIZATION?
      msg.send "Missing HUBOT_VC_ORGANIZATION in environment: please set and try again"
      return false

    unless ENVIRONMENT?
      msg.send "Missing HUBOT_VC_ENVIRONMENT in environment: please set and try again"
      return false

    unless TOKEN?
      msg.send "Missing HUBOT_VC_TOKEN in environment: please set and try again"
      return false

    return true # thanks coffeescript, but I like my returns

  urls =

  # Customizing this URLS allow us to add/remove columns, filters, sort by, etc.

    "top-queries"   : "/top-queries?limit=5&hosts="
    "query-compare" : "/query-compare?limit=5&hosts="
    "top-processes" : "/top-processes?limit=5&hosts="


  # Generates the url to be loaded before generating the screenshot,
  # the <since> parameter is going to be used in the future

  getURL = (component, since, count, unit) ->

    base = "/#{ORGANIZATION}/#{ENVIRONMENT}"
    from = 0
    till = 0

    from = switch unit
      when "seconds", "second" then 1
      when "minutes", "minute" then 60
      when "hours", "hour" then 3600
      when "days", "day" then 3600 * 24
      when "months", "month" then 3600 * 24 * 30
      else from = 3600

    range =  "&from=" + (-from * count) + "&until=" + till
    url = base + urls[component] + range

    return url


  # Creates the api-share request

  loadShare = (config, msg) ->

    msg.send "Capturing #{config.component}, say cheese..."

    robot.http("#{api}/share/capture?selector=" + encodeURIComponent(config.selector) + "&url=" + encodeURIComponent(config.url))
    .header('Accept', 'application/json')
    .header('Authorization', "Bearer #{TOKEN}")
    .get() (err, res, body) ->
      try
        data = JSON.parse(body)
      catch e
        msg.send "Invalid api-share response: #{body}"

      if data and 'url' of data
        msg.send data.url


  # Respond callback

  robot.respond /(vividcortex|vc) (.+)/i, (msg) ->

    unless environmentIsOk msg
      return

    commandArray = msg.match[2].replace(/^\s+|\s+$/g, "").split(/\s+/)

    component = commandArray[0]
    since = commandArray[1]

    if commandArray[2]
      if commandArray[2].match /^\d+$/ # check if user specified a number
        count = parseInt commandArray[2]
        unit = commandArray[3]
      else
        count = 1
        unit = commandArray[2]
    else
      count = 1
      unit = "hour"

    if component of urls
      config =
        component: component
        selector: "[vc-shareable=\"#{component}\"]"
        url: getURL(component, since, count, unit, msg)

      loadShare(config, msg)
    else
      msg.send "Component #{component} not defined."