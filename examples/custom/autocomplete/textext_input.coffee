# import * as _ from "underscore"
# Cannot import jquery here, otherwise it overwrites (?) the
# globally loaded jquery object with function plugins
# import * as $ from "jquery"

import {InputWidget, InputWidgetView} from "models/widgets/input_widget"
import template from "./tag_input_template"
import * as p from "core/properties"

export class TextExtInputView extends InputWidgetView
  tagName: "div"
  className: "bk-widget-form-group"
  template: template
  # events:
  #   "change input": "change_input"

  initialize: (options) ->
    super(options)
    @render()
    @listenTo(@model, 'change', @render)

  render: () ->
    super()
    @$el.html(@template(@model.attributes))
    # TODO: using below hack to use globally loaded jquery, which has
    # the function plugin extensions, instead of saved @$el object
    $input = $(@$el.find("input"))
    completions = @model.completions
    # TODO: allow different completion names and labels?
    # http://textextjs.com/manual/examples/tags-with-custom-labels.html
    # TODO: allow custom rendering
    # http://textextjs.com/manual/examples/autocomplete-with-custom-render.html
    values = @model.value
    this_wrap = @
    if $input.textext?
      # TODO: implement contains instead of match from start:
      # https://github.com/alexgorbatchev/jquery-textext/issues/168
      # http://stackoverflow.com/questions/29688035/jquery-textext-set-autocomplete-suggestions-to-filter-based-on-contains-rather
      $input.textext({
        # TODO: is using tags plugin too complicated?
        # For one, need to retrieve value correctly:
        # http://stackoverflow.com/questions/34007494/get-textext-tags-in-javascript
        plugins: 'arrow tags autocomplete'
        tags: {
         items: values
        }
      }).bind('getSuggestions',
        (e, data) ->
          $(this).trigger(
            'setSuggestions',
            result: $(e.target).textext()[0].itemManager().filter(
              completions, (if data then data.query else '') || ''
            )
         )
      ).bind('tagChange',
        (e, context) ->
          console.log('tag_changed', context, e)
          this_wrap.change_tags()
      )
    # http://stackoverflow.com/questions/18952703/remove-tag-event-in-tag-jquery
    # TODO: tagChange: https://github.com/alexgorbatchev/jquery-textext/pull/26
    # TODO: use bind
    # # TODO: add css?
    # $input.autocomplete("widget").addClass("bk-ui-autocomplete")
    return @

  change_tags: () ->
    # TODO: check if callback is triggered
    $input = $(@$el.find("input.bk-widget-form-input"))
    if $input.textext?
      values = $input.textext()[0].tags()._formData;
      console.log("widget/textext_input: values #{values}", values)
      @model.value = values  # (val["name"] for val in values)

export class TextExtInput extends InputWidget
  type: "TextExtInput"
  default_view: TextExtInputView

  @define {
    value: [ p.Array, [] ]
    placeholder: [ p.String, "" ]
    completions: [ p.Array, [] ]
    min_chars: [ p.Number, 2 ]
    auto_first: [ p.Bool, false ]
  }
