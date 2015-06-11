class XmlMapper
  attr_accessor :file_name,
  :val1,
  :val2,
  :val3,
  :val4,
  :val5,
  :val6,
  :val7,
  :val8,
  :val9,
  :val10,
  :val11,
  :val12,
  :val13,
  :val14,
  :val15,
  :val16,
  :val17,
  :val18,
  :val19,
  :val20,
  :val21,
  :val22,
  :val23,
  :val24,
  :val25,
  :val26,
  :val27,
  :val28,
  :val29,
  :val30,
  :val31,
  :val32,
  :val33,
  :val34,
  :val35,
  :val36,
  :val37,
  :val38,
  :val39,
  :val40,
  :val41,
  :val42,
  :val43,
  :val44,
  :val45,
  :val46,
  :val47,
  :val48,
  :val49,
  :val50

  def do_parse_auth
    path = File.join(Rails.root, 'app', 'resources', self.file_name + '.xml')

    f = File.open(path)

    document = Nokogiri::XML(f)

    f.close

    document.xpath('//Property').each do |n|
      n.attributes['value'].value = get_val(n.attributes['value'].value[3..(n.attributes['value'].value.index('=@@') - 1)])
    end

    return document
  end

  def do_parse
    path = File.join(Rails.root, 'app', 'resources', self.file_name + '.xml')

    f = File.open(path)

    document = Nokogiri::XML(f)

    f.close

    # Replace all ocurrencies of starting string @@= with values from the class
    document.xpath('.//*').children.each do |n|
      if (n.class == Nokogiri::XML::Text or n.class == Nokogiri::XML::CDATA) and n.text != '' and n.text.strip.include?('@@=')
        _content = get_val(n.content[3..(n.content.index('=@@') - 1)])

        if _content.blank?
          n.remove
        else
          n.content = _content
        end
      end
    end

    # Find all elements that should repeat
    do_parse_repeat(document)

    return document.to_xml
  end

  # I am not responsible of this code.They made me write it, against my will.
  def do_parse_repeat(document, repeat = 0)
    unless document.xpath('.//*[@repeat]').size == 0 then
      counter = 0

      document.xpath('.//*').children.each do |n|
        if n.key?("repeat")
          from_repeat = n.parent.key?("repeat")

          if !from_repeat
            if(repeat == 0)
              _content = get_val(/\=(val[0-9]*)\=/.match(n.attributes['repeat'].value)[1])
            else
              _content = get_val(/\=(val[0-9]*)\=/.match(n.attributes['legacy_parent'].value)[1])
            end

            if _content.blank?
              n.remove
            else
              klazz = XmlMapperDtl.new

              if(repeat == 0)
                klazz.do_parse(n, _content)
              else
                klazz.do_parse(n, _content[counter][:"#{/\=(val[0-9]*)\=/.match(n.attributes['repeat'].value)[1]}"])
              end
            end
          end

          counter = counter + 1
        end
      end

      do_parse_repeat(document, repeat  + 1)
    end
  end

  def get_val(k)
    case k
    when 'val1' then self.val1
    when 'val2' then self.val2
    when 'val3' then self.val3
    when 'val4' then self.val4
    when 'val5' then self.val5
    when 'val6' then self.val6
    when 'val7' then self.val7
    when 'val8' then self.val8
    when 'val9' then self.val9
    when 'val10' then self.val10
    when 'val11' then self.val11
    when 'val12' then self.val12
    when 'val13' then self.val13
    when 'val14' then self.val14
    when 'val15' then self.val15
    when 'val16' then self.val16
    when 'val17' then self.val17
    when 'val18' then self.val18
    when 'val19' then self.val19
    when 'val20' then self.val20
    when 'val21' then self.val21
    when 'val22' then self.val22
    when 'val23' then self.val23
    when 'val24' then self.val24
    when 'val25' then self.val25
    when 'val26' then self.val26
    when 'val27' then self.val27
    when 'val28' then self.val28
    when 'val29' then self.val29
    when 'val30' then self.val30
    when 'val31' then self.val31
    when 'val32' then self.val32
    when 'val33' then self.val33
    when 'val34' then self.val34
    when 'val35' then self.val35
    when 'val36' then self.val36
    when 'val37' then self.val37
    when 'val38' then self.val38
    when 'val39' then self.val39
    when 'val40' then self.val40
    when 'val41' then self.val41
    when 'val42' then self.val42
    when 'val43' then self.val43
    when 'val44' then self.val44
    when 'val45' then self.val45
    when 'val46' then self.val46
    when 'val47' then self.val47
    when 'val48' then self.val48
    when 'val49' then self.val49
    when 'val50' then self.val50
    else raise 'Unknown expected value'
    end
  end
end
