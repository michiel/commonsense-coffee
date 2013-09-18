doStuff =(username, password)->
  api = new SenseApi
  api.authenticateSessionId username, password,
    ->
      logme "AUTH OK, fetching sensors ..."
      api.getAll 'sensor', (res)->
        logme "Received #{res.sensors.length} sensors, fetching individually by ID ..."
        for sensor in res.sensors
          api.get 'sensor', sensor.id, (sensor)->
            logme "Sensor #{sensor.sensor.id} is called #{sensor.sensor.name}"
    ->
      logme "AUTH FAILED, aborting  ..."

$ ->
  $("#submit").click (e)->
    logme "Doing stuff ..."
    doStuff(
      $("input[name=username]")[0].value,
      $("input[name=password]")[0].value
    )

window.logme = (msg)->
  $("#log").append(
    $("<li>").text(msg)
  )
