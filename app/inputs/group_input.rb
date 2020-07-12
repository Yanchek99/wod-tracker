# custom component requires input group wrapper
class GroupInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    @builder.text_field(attribute_name, merged_input_options)
  end

  def prepend(_wrapper_options)
    span_tag = tag.span options[:prepend], class: 'input-group-text'
    template.tag.div span_tag, class: 'input-group-prepend'
  end

  def append(_wrapper_options)
    span_tag = tag.span options[:append], class: 'input-group-text'
    template.tag.div span_tag, class: 'input-group-append'
  end
end
