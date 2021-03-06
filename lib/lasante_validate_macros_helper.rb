module LasanteValidateMacrosHelper

  # validateArray : Contains an array of validates_* methods in the model
  def text_field_with_validation(object, method)
    validateArray = find_required_validation(object, method)
    javascriptTxt = getJavascriptTxt( validateArray, object, method)
    if validateArray.size > 0
      text_field( object , method ) + javascriptTxt
    else
      text_field( object , method )
    end
  end

  def find_required_validation(object, method)
    dir = FileUtils.pwd + "/app/models"
    file = FileUtils.pwd + "/app/Models/#{object}.rb"
    validateArray = []
    if File.exists?(file) && File.directory?(dir)
      # look up for validates methods in the model
      f = File.new(file)
      text = f.read
      if text.scan(/validates_presence_of\s+:#{method}/).size != 0
        if text.scan(/#\s*validates_presence_of\s+:#{method}/).size == 0
          validateArray << "validates_presence_of"
        end
      end
      validate_length_in = text.scan(/validates_length_of\s+:#{method}\s*,\s*:in\s*=>\s*\d+..\d+/).to_s
      if validate_length_in.size != 0
        if text.scan(/#\s*validates_length_of\s+:#{method}\s+:in/).size == 0
          match = validate_length_in.match(/(\d+)..(\d+)/)
          validateArray << "validates_length_of:#{match[1]}:#{match[2]}"
        end
      end
      return validateArray
    else
      # empty hash is returned because file not found
      return []
    end
  end

  def getJavascriptTxt( validateArray, object, method )
    script = ''
    if validateArray.length > 0
      script = "<script type='text/javascript'> var validatorObj = new LiveValidation('#{object}_#{method}', {validMessage: '', wait: 505, onlyOnBlur: true });"
      validateArray.each { |val|
        if val =~ /validates_presence_of/i
          script = script + "validatorObj.add( Validate.Presence, { failureMessage: 'Cette boite ne doit pas etre vide.'} );"
        end
        if val =~ /validates_length_of/i
          splitVal = val.split(':')
          min = splitVal[1];
          max = splitVal[2];
          script = script + "validatorObj.add( Validate.Length, { minimum: #{min}, maximum: #{max} } );"
        end
      }
      script = script + "</script>"
    end
    return script
  end
end

