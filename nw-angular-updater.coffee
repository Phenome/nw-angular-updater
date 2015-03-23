GUI = require 'nw.gui'
fs = require 'fs'
http = require 'http'
path = require 'path'
child_process = require 'child_process'

class UpdateService
  __DIR = path.dirname process.execPath
  constructor: (@q, @http, {@infoUrl,@downloadUrl,@filename,@currentVersion}, @auto=true) ->
    if not @infoUrl or not @downloadUrl or not @filename or not @currentVersion
      throw new Error 'Not Configured'
    if @auto
      @checkAndUpdate() 
    else
      @check
  check: ->
    deferred = @q.defer()
    @updateRequired = false
    @checking = true
    @http.get @infoUrl
    .success (data) =>
      @checking = false
      @updateRequired = data.version > @currentVersion
      deferred.resolve @updateRequired
    deferred.promise
  download: ->
    deferred = @q.defer()
    @downloading = true
    file = fs.createWriteStream path.join __DIR, "#{@filename}.download"
    http.get @downloadUrl, (response) =>
      response.pipe file
      response.on 'end', =>
        @downloading = false
        @restartRequired = true
        deferred.resolve true
    .on 'error', (err) ->
      @downloading = false
      @restartRequired = false
      deferred.reject err
    deferred.promise
  unlink: ->
    deferred = @q.defer()
    fs.unlink path.join(__DIR, @filename), (err) ->
      if err
        deferred.reject err
      else
        deferred.resolve true
    deferred.promise
  rename: ->
    deferred = @q.defer()
    fs.rename (path.join __DIR, "#{@filename}.download"), (path.join __DIR, @filename), (err) ->
      if err
        deferred.reject err
      else
        deferred.resolve true
    deferred.promise
  checkAndUpdate: ->
    @check()
    .then =>
      return @q.reject() if not @updateRequired
    .then =>
      @download()
    .then =>
      @unlink()
    .then =>
      @rename()
    .catch (err) =>
      console.log 'error', err
      @checking = @downloading = @restartRequired = false
  restart: ->
    child = child_process.spawn process.execPath, [], detached: true
    #Don't wait for it
    child.unref();
    #Quit current
    GUI.window.hide(); # hide window to prevent black display
    GUI.app.quit();  # quit node-webkit app

class UpdateServiceProvider
  setInfoUrl: (@infoUrl) -> @
  setDownloadUrl: (@downloadUrl) -> @
  setFilename: (@filename) -> @
  setCurrentVersion: (@currentVersion) -> @
  setAuto: (@auto) -> @
  $get: ['$q', '$http', (q, http) ->
    new UpdateService q, http, {@infoUrl,@downloadUrl,@filename,@currentVersion}, @auto
  ]

angular.module 'nwUpdater', []
.provider 'nwUpdate', UpdateServiceProvider