# import * as _ from "underscore"
# Cannot import jquery here, otherwise it overwrites (?) the
# globally loaded jquery object with function plugins
# import * as $ from "jquery"

import {InputWidget, InputWidgetView} from "models/widgets/input_widget"
import template from "./tag_input_template"
import * as p from "core/properties"

export class TokenInputView extends InputWidgetView
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
    $input = $(@$el.find("input.bk-widget-form-input"))
    if $input.tokenInput?
      completions = ({"name": val} for val in @model.completions)
      values = ({"name": val} for val in @model.value)
      this_wrap = @  # bind to closure?
      $input.tokenInput(completions, {
          prePopulate: values
          # TODO: ability to have different completion labels and values?
          propertyToSearch: "name"
          theme: "facebook"
          minChars: @model.min_chars
          onAdd:
            (item) -> this_wrap.change_tags()
          onDelete:
            (item) -> this_wrap.change_tags()
          # TODO
          resultsLimit: @model.max_items
          })
      # TODO: note that this is not currently defined in bokeh-css
      # $input.autocomplete("widget").addClass("bk-ui-autocomplete")
      # TODO: This should be moved to a css file ideally, so that these
      # properties can be overwritten by other css files. Is it possible
      # to use bk-widget-form-input styling directly?
      # TODO: anything to do about the width?
      @$el.find("ul.token-input-list-facebook").css({
            border: "1px solid #ccc"
            "border-radius": "4px"
            # TODO: use @model.height?
            "min-height": "31px"
           })
    return @

  change_tags: () ->
    # TODO: check if callback is triggered
    $input = $(@$el.find("input.bk-widget-form-input"))
    if $input.tokenInput?
      values = $input.tokenInput("get")
      console.log("widget/token_input: values #{values}", values)
      @model.value = (val["name"] for val in values)

export class TokenInput extends InputWidget
  type: "TokenInput"
  default_view: TokenInputView

  @define {
    value: [ p.Array, [] ]
    placeholder: [ p.String, "" ]
    completions: [ p.Array, [] ]
    min_chars: [ p.Number, 2 ]
    max_items: [ p.Number, 10 ]
    auto_first: [ p.Bool, false ]
  }
