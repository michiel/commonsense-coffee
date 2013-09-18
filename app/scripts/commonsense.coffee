#
# async implementation of SenseOS API
# depends on,
#
# - md5
# - jquery
#

class SenseApi

  constructor: (args={})->
    for arg in args
      @[arg] = args[arg]

    $.ajaxSetup
      global      : true
      type        : "POST"
      dataType    : 'json'
      contentType : "application/json; charset=UTF-8"

  #
  # Public variables
  #

  serverType : 'live'
  serverUrl  : 'https://api.sense-os.nl'
  sessionId  : null
  verbose    : true

  #
  # Private variables
  #

  # These servers all set '*' CORS access headers

  senseServers =
    live : 'https://api,sense-os.nl'
    dev  : 'http://api.dev.sense-os.nl'
    rc   : 'http://api.rc.dev.sense-os.nl'

  #
  # JS/API functions
  #

  getSessionId: (cb, err)->
    @sense_api(params, (ret)->
      cb(ret)
    )

  authenticateSessionId: (username, password)->
    hash = CryptoJS.MD5(password).toString()
    params =
      username : username,
      password : hash

    @sense_api 'POST', '/login.json', params,
      ((res)=>
        @log "login ok : id #{res.session_id}"
        @sessionId = res.session_id
      ),
      (()=>
        @log "login not ok"
      )

  @logoutSessionId: ()->
    @sense_api "POST", '/@logout.json', {},
      (()=> @log "logout ok"),
      (()=> @log "logout not ok")

  get: (type, id, succ, err)->
    @sense_api("GET", "/#{type}s/#{id}.json", {}, succ, err)

  getAll: (type, succ, err)->
    @sense_api("GET", "/#{type}s.json", {}, succ, err)

  sense_api : (method, url, data, succ, err)->
    $.ajax
      type       : method
      url        : "#{@serverUrl}#{url}"
      data       : JSON.stringify(data)
      success    : succ
      error      : err
      beforeSend : (req)->
        req.setRequestHeader("X-SESSION_ID", @sessionId) if @sessionId != ''

  log : (msg)=>
    console.log(msg) if @verbose


window.SenseApi = SenseApi


