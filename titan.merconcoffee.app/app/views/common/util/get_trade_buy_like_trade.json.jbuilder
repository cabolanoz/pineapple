json.array! @trades do |trade|
  trade_dtl = trade.trade_dtl
  strategy = trade.strategy
  counterpart = trade.counterpart
  obligation_hdr = trade.obligation_hdr

  json.merge! trade.attributes
  json.trade_dtl trade_dtl
  json.strategy strategy
  json.counterpart counterpart
  json.obligation_hdr obligation_hdr
end
