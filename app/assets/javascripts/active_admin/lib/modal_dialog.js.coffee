ActiveAdmin.modal_dialog = (message, inputs, callback)->
  if typeof(inputs) == "string"
    selected_ids = $(".collection_selection:checked").map ->
      return $(this).val()
    .get()
    params = {'ids': selected_ids, 'partial_name': $.parseJSON(inputs)}
    url = window.location.href + "/batch_action_form_view?" + $.param(params)
    response = $.get(url)
    response.done (data) ->
      partial = $('<div class="batch_action_partial_container">'+data+'</div>')
      partial.find('input[type="submit"]').remove()
      html = """<form id="dialog_confirm" title="#{message}">"""
      html += partial.html()
      html += "</form>"
      ActiveAdmin.start_dialog(html, callback)
    response.fail (data) ->
      alert(data.statusText)
  else
    html = """<form id="dialog_confirm" title="#{message}"><ul>"""
    for name, type of inputs
      if /^(datepicker|checkbox|text)$/.test type
        wrapper = 'input'
      else if type is 'textarea'
        wrapper = 'textarea'
      else if $.isArray type
        [wrapper, elem, opts, type] = ['select', 'option', type, '']
      else
        throw new Error "Unsupported input type: {#{name}: #{type}}"

      klass = if type is 'datepicker' then type else ''
      html += """<li>
        <label>#{name.charAt(0).toUpperCase() + name.slice(1)}</label>
        <#{wrapper} name="#{name}" class="#{klass}" type="#{type}">""" +
          (if opts then (
            for v in opts
              $elem = $("<#{elem}/>")
              if $.isArray v
                $elem.text(v[0]).val(v[1])
              else
                $elem.text(v)
              $elem.wrap('<div>').parent().html()
          ).join '' else '') +
        "</#{wrapper}>" +
      "</li>"
      [wrapper, elem, opts, type, klass] = [] # unset any temporary variables

    html += "</ul></form>"
    ActiveAdmin.start_dialog(html, callback)

ActiveAdmin.start_dialog = (html, callback) ->
  form = $(html).appendTo('body')
  $('body').trigger 'modal_dialog:before_open', [form]

  form.dialog
    modal: true
    open: (event, ui) ->
      $('body').trigger 'modal_dialog:after_open', [form]
    dialogClass: 'active_admin_dialog'
    buttons:
      OK: ->
        callback $(@).serializeObject()
        $(@).dialog('close')
      Cancel: ->
        $(@).dialog('close').remove()