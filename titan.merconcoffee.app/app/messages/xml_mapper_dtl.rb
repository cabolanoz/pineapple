class XmlMapperDtl
  def do_parse(node, value)
    if value != nil and value.size > 0
      value.reverse.each do |v|
        # Magic. Do not touch.
        new_node = node.clone
        new_node.remove_attribute("repeat")
        new_node.remove_attribute("legacy_parent")

        new_node.children.each do |n|
          if n.key?("repeat")
            n['legacy_parent'] =  node.attributes["repeat"]
          else
            if (n.class == Nokogiri::XML::Text or n.class == Nokogiri::XML::Element) and n.text != '' and n.text.strip.include?('@=@=')
              _content = get_val(n.content[4..(n.content.index('=@=@') - 1)], v)

              if _content.blank?
                n.remove
              else
                n.content = _content
              end
            end
          end

          node.add_next_sibling(new_node)
        end
      end
    end

    node.remove
  end

  def get_val(k, v)
    case k
    when 'val1' then v[:val1]
    when 'val2' then v[:val2]
    when 'val3' then v[:val3]
    when 'val4' then v[:val4]
    when 'val5' then v[:val5]
    when 'val6' then v[:val6]
    when 'val7' then v[:val7]
    when 'val8' then v[:val8]
    when 'val9' then v[:val9]
    when 'val10' then v[:val10]
    when 'val11' then v[:val11]
    when 'val12' then v[:val12]
    when 'val13' then v[:val13]
    when 'val14' then v[:val14]
    when 'val15' then v[:val15]
    when 'val16' then v[:val16]
    when 'val17' then v[:val17]
    when 'val18' then v[:val18]
    when 'val19' then v[:val19]
    when 'val20' then v[:val20]
    when 'val21' then v[:val21]
    when 'val22' then v[:val22]
    when 'val23' then v[:val23]
    when 'val24' then v[:val24]
    when 'val25' then v[:val25]
    when 'val26' then v[:val26]
    when 'val27' then v[:val27]
    when 'val28' then v[:val28]
    when 'val29' then v[:val29]
    when 'val30' then v[:val30]
    when 'val31' then v[:val31]
    when 'val32' then v[:val32]
    when 'val33' then v[:val33]
    when 'val34' then v[:val34]
    when 'val35' then v[:val35]
    when 'val36' then v[:val36]
    when 'val37' then v[:val37]
    when 'val38' then v[:val38]
    when 'val39' then v[:val39]
    when 'val40' then v[:val40]
    when 'val41' then v[:val41]
    when 'val42' then v[:val42]
    when 'val43' then v[:val43]
    when 'val44' then v[:val44]
    when 'val45' then v[:val45]
    when 'val46' then v[:val46]
    when 'val47' then v[:val47]
    when 'val48' then v[:val48]
    when 'val49' then v[:val49]
    when 'val50' then v[:val50]
    else raise 'Unknown expected value'
    end
  end
end
