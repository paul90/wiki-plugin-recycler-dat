###
 Federated Wiki : Recycler Plugin
 Licensed under the MIT license.
###

queue = require 'async/queue'


escape = (line) ->
  line
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

listItemHtml = (slug, title) ->
  """
    <li>
      <a class="internal" href="#" title="recycler" data-page-name="#{slug}" data-site="recycler">
        #{escape title}
      </a>
      <button class="delete">✕</button>
    </li>
  """

emit = ($item, item) ->


  extractPageInfo = (page) ->
    rawPageData = await wiki.archive.readFile("/recycler/" + page.name)
    pageJSON = JSON.parse(rawPageData)
    return
      slug: page.name.split('.')[0]
      title: pageJSON.title

  try
    pages = await wiki.archive.readdir('/recycler', {includeStats: true})
  catch error
    console.log "recycler emit", error
    $item.append """
      <p style="background-color:#eee;padding:15px;">
        Unable to fetch contents of recycler
      </p>
    """
    return

  pages = pages.filter (page) -> page.stat.isFile() and page.name.endsWith('.json')

  pages = pages.map (page) ->
    pageEntry = await extractPageInfo(page)
    .then (pageEntry) ->
      return pageEntry

  Promise.all(pages)
  .then (pages) ->
    if pages.length is 0
      $item.append """
        <p style="background-color:#eee;padding:15px;">
          The recycler is empty
        </p>
      """
    else
      $item.append( ul = $('<ul>') )
      for i in [0...pages.length]
        slug = pages[i].slug
        if pages[i].title?
          title = pages[i].title
        else
          title = pages[i].slug
        ul.append listItemHtml(slug, title)
      if pages.length > 0
        $item.append """
          <ul><button class="empty">Empty Recycler</button></ul>
        """



bind = ($item, item) ->
  q = queue( (task, cb) ->
    await wiki.archive.unlink(task.slug)
    .then () ->
      recyclerList = $(task.item).parent().parent()
      $(task.item).parent().remove()

      if $(recyclerList).children().length is 0
        # no pages left in recycler so show message for empty recycler
        $item.empty()
        $item.append """
          <p style="background-color:#eee;padding:15px;">
            The recycler is empty
          </p>
        """
        cb()
    .catch (error) ->
      console.log "recycler error: ", error
      cb()
  , 2) # just 2 processes working on the queue

  $item.on 'click', '.delete', ->
    slug = '/recycler/' + $(this).siblings('a.internal').data('pageName') + '.json'
    q.push {slug: slug
    item: this}, (err) ->
      if err
        console.log "recycler error: ", err

  $item.on 'click', '.empty', ->
    recycleElements = $(this).parent().parent().children().first()
    $(recycleElements).children().each( () ->
      slug = '/recycler/' + $(this).children('a.internal').data('pageName') + '.json'
      delButton = $(this).children('delete')
      q.push {slug: slug
      item: delButton}, (err) ->
        if err
          console.log 'recycler error: ', err
    )





window.plugins.recycler = {emit, bind} if window?
module.exports = {escape} if module?
