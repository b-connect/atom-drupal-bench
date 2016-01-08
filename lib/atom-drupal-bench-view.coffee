{$, View} = require 'space-pen'
fs = require 'fs'
utils = require './utils'
drush = require './drush'
DrupalService = require './drupal-service'

module.exports =
class AtomDrupalBenchView extends View
  projectPath: null

  @content: ->
    @div class: 'atom-drupal-bench-detail-wrapper', =>
      @h1 class: 'header', 'Drupal Bench'
      @div id: 'atom-drupal-bench-id'
      @div class: 'btn-group', =>
        @button {class: 'btn icon green icon-triangle-right start-all', id: 'atom-drupal-bench-start-all'},'Start all'
        @button {class: 'btn icon red icon icon-primitive-square stop-all', id: 'atom-drupal-bench-stop-all'}, 'Stop all'
      @div id: 'atom-drupal-bench-list', =>
        @div class: 'panel-group'


  constructor:(@projectPath) ->
    console.log 'Construct', @projectPath
    super

  attached: ->
    @list =
      $(@element.querySelector("div[id='atom-drupal-bench-list'] > div"))

  initialize:(projectPath) ->
    console.log 'New View', projectPath
    @projectPath = projectPath

  getPath: ->
    @projectPath

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  setItems:(selector) ->

  showInformations:(entry) ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
