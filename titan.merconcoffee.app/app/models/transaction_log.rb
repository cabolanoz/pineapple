class TransactionLog < McgensConnection

  self.table_name = "titan.Transaction_Log"
  self.primary_key = "transaction_id"

end
