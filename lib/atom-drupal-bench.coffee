{requirePackages}     = require 'atom-utils'
{CompositeDisposable} = require 'atom'
AtomDrupalBenchView = require './atom-drupal-bench-view'
DrupalService = require './drupal-service'
HashMap = require 'hashmap'
Storage = require './storage'

AtomDrupalBench =
  views: new HashMap()
  subscriptions: null
  service: null
  panel: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add(
      atom.commands.add('atom-workspace',
                        'atom-drupal-bench:toggle': => @toggle())
    )

    atom.packages.activatePackage('tree-view').then (treeViewPkg) =>
      @treeView = treeViewPkg.mainModule.createView()
      @treeView.drupalBenchOriginalClickHandler = @treeView.entryClicked

      if atom.project.getDirectories().length > 0
        @performIndex()

      atom.project.onDidChangePaths (projectPaths) =>
        if projectPaths.length > 0
          @performIndex()

      atom.workspace.observeTextEditors (editor) =>
        editor.onDidSave (event) =>
          isContainedInProject = false

          for projectDirectory in atom.project.getDirectories()
            if event.path.indexOf(projectDirectory.path) != -1
              isContainedInProject = true
              break

          if isContainedInProject
            @performIndex(event.path)

  performIndex:(path) ->
    DrupalService.index()

  log:(e) ->
    console.log e

  deactivate: ->
    @subscriptions.dispose()
    @view.destroy()

  serialize: ->
    AtomDrupalBenchState: @view.serialize()

  activateAndFocus: ->
    @view.activate()
    @view.focus()

  toggle: ->
    paths = atom.project.getDirectories()
    _this = @

    paths.forEach((p)->
      if _this.views.has(p.path)
        view = _this.views.get(p.path)
        if view.active
          view.deactivate()
        else
          view.activate()
      else
        console.log p.path
        DrupalService.getDataStore(p.path,(ds)->
          storage = new Storage(DrupalService,ds)
          view = new AtomDrupalBenchView(storage)
          @panel =  atom.workspace.addRightPanel(
            item: view.getElement(),
            visible: true
          )
          _this.views.set(p.path,view)
        )

    )

module.exports =  AtomDrupalBench
