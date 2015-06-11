module ApplicationHelper

  attr_accessor :username,
    :password,
    :machine

  def self.authenticate
    # Build XmlMapper entity
    klazz = XmlMapper.new
    klazz.file_name = 'authenticate'
    klazz.val1 = Rails.application.secrets[:cxl_user_name]
    klazz.val2 = Rails.application.secrets[:cxl_password]
    klazz.val3 = 'cbolanos'

    # Parse XML with corresponding values
    xml_to_send = klazz.do_parse_auth

    # Build SOAP helper with proper service, method and XML
    ss = SoapSender.new
    ss.service = APP_SERVICE['auth']['service_name']
    ss.method = APP_SERVICE['auth']['method_name']
    ss.xml_resource = xml_to_send

    # Send SOAP request to server
    xml_from_response = ss.do_request

    # Build XML decode helper
    decode = XmlDecode.new
    decode.method = APP_SERVICE['auth']['r_method_name']

    # Decode authentication response
    xml_decode = decode.do_decode(xml_from_response[:soap_response])

    return decode.is_valid_auth(xml_decode)
  end

  def authenticate
    return ApplicationHelper.authenticate
  end

end
