drush = require 'drush-node'
dir = false


class BenchProjectUtils
  dir : null
  constructor: (dir) ->
    @dir = dir

module.init = (dir) ->
