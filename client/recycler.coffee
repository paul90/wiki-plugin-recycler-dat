###
 Federated Wiki : Recycler Plugin
 Licensed under the MIT license.
###

_ = require 'lodash'

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
  recycledPages = []
  wiki.recycler.get 'system/slugs.json', (error, data) ->
    if error
      $item.append """
        <p style="background-color:#eee;padding:15px;">
          Unable to fetch contents of recycler
        </p>
      """
    else if data.length is 0
      $item.append """
        <p style="background-color:#eee;padding:15px;">
          The recycler is empty
        </p>
      """
    else
      $item.append( ul = $('<ul>') )
      for i in [0...data.length]
        slug = data[i].slug
        if data[i].title?
          title = data[i].title
        else
          title = data[i].slug
        ul.append listItemHtml(slug, title)
      if data.length > 0
        $item.append """
          <ul><button class="empty">Empty Recyler</button></ul>
        """



bind = ($item, item) ->
  $item.on 'click', '.delete', ->
    slug = '/recycler/' + $(this).siblings('a.internal').data('pageName') + '.json'
    console.log 'slug: ', slug
    myInit = {
      method: 'DELETE'
      cache: 'no-cache'
      mode: 'same-origin'
      credentials: 'include'
    }
    fetch slug, myInit
    .then (response) ->
      if response.ok
        emit( $item.empty(), item)

  $item.on 'click', '.empty', ->
    recycleElements = $(this).closest('div', 'recycler').find('a.internal')
    for recycleElement in recycleElements
      slug = '/recycler/' + $(recycleElement).data('pageName') + '.json'
      console.log 'slug: ', slug
      myInit = {
        method: 'DELETE'
        cache: 'no-cache'
        mode: 'same-origin'
        credentials: 'include'
      }
      fetch slug, myInit
      .then (response) ->
        if response.ok
          emit( $item.empty(), item)




window.plugins.recycler = {emit, bind} if window?
module.exports = {escape} if module?
