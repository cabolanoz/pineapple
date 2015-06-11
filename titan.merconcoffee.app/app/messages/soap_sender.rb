class SoapSender
  attr_accessor :service,
    :method,
    :session,
    :xml_resource,
    :sender

  def do_request
    v_endpoint = Rails.application.secrets[:cxl_endpoint]

    if !self.session.blank?
      v_endpoint = Rails.application.secrets[:cxl_endpoint] + self.session
    end

    soap_client = Savon.client(
      :convert_request_keys_to => :none,
      :endpoint => v_endpoint,
      :env_namespace => :'SOAP-ENV',
      # :log => true,
      # :log_level => :debug,
      :namespace => 'urn:' + self.service,
      :namespaces => {
        'xmlns:xsd' => 'http://www.w3.org/1999/XMLSchema',
        'xmlns:xsi' => 'http://www.w3.org/1999/XMLSchema-instance'
      },
      :namespace_identifier => :ns1,
      # :pretty_print_xml => true,
      :soap_version => 1
    )

    message = self.xml_resource.to_s

    begin
      error_response = nil

      response = soap_client.call(
        :"#{self.method}",
        attributes: {
          'xmlns:ns1' => 'urn:' + self.service,
          'SOAP-ENV:encodingStyle' => 'http://schemas.xmlsoap.org/soap/encoding/'
        },
        message: {
          msgstr: message,
          :attributes! => {
            msgstr: {
              "xsi:type" => "xsd:string"
            }
          }
        }
      )

    rescue Savon::Error => soap_error
      error_response = soap_error.xml

      # Insert new transaction log
      transaction_log = TransactionLog.new do |t|
        t.user_name = self.sender
        t.cxl_user_name = Rails.application.secrets[:cxl_user_name]
        t.description = self.service + "::" + self.method
        t.xml_request = self.xml_resource.to_s
        t.xml_response = error_response
        t.execution_date = DateTime.now
        t.level_response = "ERROR - 400"
      end

      transaction_log.save
    end

    if response.blank?
      return { success: false, soap_response: error_response }
    else
      return { success: true, soap_response: response.body }
    end
  end
end
