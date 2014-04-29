require 'date'

module JqueryDatepicker
  module FormHelper
    # Mehtod that generates datepicker input field inside a form
    def datepicker(object_name, method, options = {}, timepicker = false)
      options[:timepicker] = timepicker
      input_tag = JqueryDatepicker::InstanceTag.new(object_name, method, self, options)
      input_tag.render
    end
  end

end

module JqueryDatepicker::FormBuilder
  def datepicker(method, options = {})
    @template.datepicker(@object_name, method, objectify_options(options))
  end

  def datetime_picker(method, options = {})
    @template.datepicker(@object_name, method, objectify_options(options), true)
  end
end

class JqueryDatepicker::InstanceTag < ActionView::Helpers::Tags::TextField
  include ActionView::Helpers::JavaScriptHelper

  FORMAT_REPLACEMENTES = { "yy" => "%Y", "mm" => "%m", "dd" => "%d", "d" => "%-d", "m" => "%-m", "y" => "%y", "M" => "%b" }

  # Extending ActionView::Helpers::InstanceTag module to make Rails build the name and id
  # Just returns the options before generate the HTML in order to use the same id and name (see to_input_field_tag mehtod)

  def initialize(object_name, method_name, template_object, options = {})
    @method = options.delete(:timepicker) ? 'datetimepicker' : 'datepicker'
    @javascript_options, @tag_options = split_options(options)
    @tag_options[:value] = format_date(@tag_options[:value], String.new(@javascript_options[:dateFormat])) if @tag_options[:value] && !@tag_options[:value].empty? && @javascript_options.has_key?(:dateFormat)

    super(object_name, method_name, template_object, @tag_options)
  end

  def field_type
    'text'
  end

  def get_name_and_id(options = {})
    add_default_name_and_id(options)
    options
  end

  def available_datepicker_options
    [:disabled, :altField, :altFormat, :appendText, :autoSize, :buttonImage, :buttonImageOnly, :buttonText, :calculateWeek, :changeMonth, :changeYear, :closeText, :constrainInput, :currentText, :dateFormat, :dayNames, :dayNamesMin, :dayNamesShort, :defaultDate, :duration, :firstDay, :gotoCurrent, :hideIfNoPrevNext, :isRTL, :maxDate, :minDate, :monthNames, :monthNamesShort, :navigationAsDateFormat, :nextText, :numberOfMonths, :prevText, :selectOtherMonths, :shortYearCutoff, :showAnim, :showButtonPanel, :showCurrentAtPos, :showMonthAfterYear, :showOn, :showOptions, :showOtherMonths, :showWeek, :stepMonths, :timepicker, :weekHeader, :yearRange, :yearSuffix]
  end

  def split_options(options)
    tf_options = options.slice!(*available_datepicker_options)
    return options, tf_options
  end

  def format_date(tb_formatted, format)
    new_format = translate_format(format)
    Date.parse(tb_formatted).strftime(new_format)
  end

  # Method that translates the datepicker date formats, defined in (http://docs.jquery.com/UI/Datepicker/formatDate)
  # to the ruby standard format (http://www.ruby-doc.org/core-1.9.3/Time.html#method-i-strftime).
  # This gem is not going to support all the options, just the most used.

  def translate_format(format)
    format.gsub!(/#{FORMAT_REPLACEMENTES.keys.join('|')}/) { |match| FORMAT_REPLACEMENTES[match] }
  end

  def render
    super + javascript_tag("jQuery(document).ready(function(){jQuery('##{get_name_and_id(@tag_options.stringify_keys)['id']}').#{@method}(#{@javascript_options.to_json})});")
  end
end