import * as _ from "underscore"
# import "jquery-ui/autocomplete"

import {TextInput, TextInputView} from "models/widgets/text_input"
import * as p from "core/properties"

export class AutocompleteInputView extends TextInputView

  render: () ->
    super()
    $input = @$el.find("input")
    this_wrap = @
    $input.autocomplete({source: @model.completions
                         minLength: @model.min_chars
                         autoFocus: @model.auto_first
                         # FIXME: callbacks not firing??
                         change: (event, ui) ->
                             console.log("jquery-change callback", event, ui)
                             this_wrap.change_input()
                         select: (event, ui) ->
                             console.log("jquery-select callback", event, ui)
                             this_wrap.change_input()
                        })
    # TODO: add css?
    $input.autocomplete("widget").addClass("bk-ui-autocomplete")

    # Listen for autocompletion selection and emit on_change callback
    # FIXME: callbacks not firing??
    $input.on("autocompletechange", (event, ui) ->
        console.log("Selected", ui)
        this_wrap.change_input()
        )
    return @

export class AutocompleteInput extends TextInput
  type: "AutocompleteInput"
  default_view: AutocompleteInputView

  @define {
    completions: [ p.Array, [] ]
    min_chars: [ p.Number, 2 ]
    auto_first: [ p.Bool, false ]
  }
