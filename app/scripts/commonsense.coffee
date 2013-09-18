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

  authenticateSessionId: (username, password, succ, err)->
    hash = CryptoJS.MD5(password).toString()
    params =
      username : username,
      password : hash

    @sense_api 'POST', '/login.json', params,
      ((res)=>
        @log "login ok : id #{res.session_id}"
        @sessionId = res.session_id
        succ(res) if succ
      ),
      ((res)=>
        @log "login not ok"
        err(res) if err
      )

  logoutSessionId: (succ, err)->
    @sense_api "POST", '/@logout.json', {},
      ((res)=>
        @log "logout ok"
        @sessionId = null
        succ(res) if succ
      ),
      ((res)=>
        @log "logout not ok"
        err(res) if err
      )

  get: (type, id, succ, err)->
    @sense_api("GET", "/#{type}s/#{id}.json", {}, succ, err)

  getAll: (type, succ, err)->
    @sense_api("GET", "/#{type}s.json", {}, succ, err)

  sense_api : (method, url, data={}, succ=(->), err=(->))->

    if !@sessionId and url != '/login.json'
      throw new Error "No valid session! Login first or wait for login to complete!"

    $.ajax
      type       : method
      url        : "#{@serverUrl}#{url}"
      data       : JSON.stringify(data)
      success    : succ
      error      : err
      beforeSend : (req)=>
        req.setRequestHeader("X-SESSION_ID", @sessionId) if @sessionId != ''

  log : (msg)=>
    console.log(msg) if @verbose


window.SenseApi = SenseApi


