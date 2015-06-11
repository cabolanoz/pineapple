class XmlDecode
  attr_accessor :method

  def do_decode(xml)
    # Concatenate method name and the static word response for the hash
    f_method = self.method.downcase + '_response'

    return Nokogiri.XML(xml.to_hash[:"#{f_method}"][:return])
  end

  def get_tag_content(xml, tag)
    tag_content = xml.xpath("//#{tag}").first

    if tag_content != nil
      return tag_content.content
    else
      return nil
    end
  end

  def is_valid_auth(xml)
    response = Hash.new

    element = xml.xpath('//MessageResponse').first

    status = element.attributes['status'].value

    if status == 'SUCCESS'
      response['success'] = true
      response['session'] = element.attributes['sessionid'].value
    else
      response['success'] = false
      response['session'] = ''
    end

    return response
  end

end
