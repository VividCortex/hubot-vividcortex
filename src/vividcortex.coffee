# Description:
#   Renders VividCortex profiler as images
#
# Configuration:
#   HUBOT_VC_ENVIRONMENT # This is the environment ID, you'll see it in the VividCortex app URL too
#   HUBOT_VC_TOKEN # This is the same token used to install VividCortex
#
# Commands:
#   hubot <vividcortex|vc> <count> minute|hour|day|month
#   hubot <vividcortex|vc> 30 minutes
#   hubot <vividcortex|vc> 12 hours
#   hubot <vividcortex|vc> 2 days
#
# Author:
#   cesarvarela

# VividCortex api URL

api = "https://app.vividcortex.com/api/v2"
host = ""  # specify a host e.g. id=99 to restrict to a single host

# Config
ENVIRONMENT = process.env.HUBOT_VC_ENVIRONMENT
TOKEN = process.env.HUBOT_VC_TOKEN

module.exports = (robot) ->


  environmentIsOk = (msg) ->

    unless ENVIRONMENT?
      msg.send "Missing HUBOT_VC_ENVIRONMENT in environment: please set and try again"
      return false

    unless TOKEN?
      msg.send "Missing HUBOT_VC_TOKEN in environment: please set and try again"
      return false

    return true # thanks coffeescript, but I like my returns


  # Generates the url to be loaded before generating the screenshot,

  getURL = (count, unit) ->

    base = api + "/share/capture?selector=" + encodeURIComponent('[vc-shareable="profiler-table"]') + "&url="
    url_arg = "/#{ENVIRONMENT}/profiler?rank=queries&by=time&orderBy=-time"
    url_arg = url_arg + "&hosts=#{host}&limit=10&filterBy=&filterByTagName=&filterByTagValue=&scaleCpuMode=false"
    url_arg = url_arg + "&compare=false&cols=rank&cols=time&cols=throughput&cols=latency&cols=queryNotifications"
    url_arg = url_arg + "&cols=userCpu&cols=systemCpu&cols=residentMemory&cols=virtualMemory&cols=bytesRead"
    url_arg = url_arg + "&cols=bytesWritten&cols=fileHandlers&cols=syscallsWrite&cols=syscallsRead&cols=count"
    url_arg = url_arg + "&cols=dataSize&cols=indexSize&cols=totalSize&cols=dataFree&cols=rowCount&cols=socketState"
    url_arg = url_arg + "&cols=socketPort&cols=mplQueryCount&cols=mplQueryLocks&cols=pgLocksWaitTime&cols=pgLocksCount"

    from = 0
    from = switch unit
      when "minutes", "minute" then 60
      when "hours", "hour" then 3600
      when "days", "day" then 3600 * 24
      when "months", "month" then 3600 * 24 * 30
      else from = 3600

    range =  "&from=" + (-from * count) + "&until=0&difference=3600"
    url = base + encodeURIComponent(url_arg + range)

    return url


  # Respond callback

  robot.respond /(vividcortex|vc) (.+)/i, (msg) ->

    unless environmentIsOk msg
      return

    commandArray = msg.match[2].replace(/^\s+|\s+$/g, "").split(/\s+/)

    if commandArray[1]
      # if 2 words after vividcortex|vc
      if commandArray[0].match /^\d+$/ # check if user specified a number
        count = parseInt commandArray[0]
        unit = commandArray[1]
      else
        count = 1
        unit = commandArray[1]
    else
      count = 1
      unit = "hour"

    api_url = getURL(count, unit)
    robot.http(api_url)
    .header('Accept', 'application/json')
    .header('Authorization', "Bearer #{TOKEN}")
    .get() (err, res, body) ->
      try
        data = JSON.parse(body)
      catch e
        msg.send "Invalid api-share response: #{api_url} #{body}"

      if data and 'url' of data
        msg.send "Top queries by total time on mysql-navisite-2 over last #{count} #{unit}"
        msg.send data.url
