class TrdHeader < CiclonProConnection

  self.table_name = "TRD_HEADER"
  self.primary_key = "trade_num"

  belongs_to :trade_dtl, :class_name => 'TrdDetail', :foreign_key => 'trade_num'
  belongs_to :trade_trm, :class_name => 'TrdTerm', :foreign_key => 'trade_num'
  belongs_to :internal_company, :class_name => 'RefCompany', :foreign_key => 'internal_company_num'
  belongs_to :trader, :class_name => 'RefPerson', :foreign_key => 'trader_person_num'
  belongs_to :strategy, :class_name => 'OrgStrategy', :foreign_key => 'strategy_num'
  belongs_to :counterpart, :class_name => 'RefCompany', :foreign_key => 'counterpart_company_num'
  has_many :obligation_hdr, :class_name => 'OpsObligationHdr', :foreign_key => 'trade_num'
  
end
