class Origin::YieldsmanagerController < ApplicationController
  def index
    render layout: "yieldmanager"
  end

  def show

  end

  def standardyields
    respond_to do |format|
      format.html { render :layout => 'yieldmanager' }
      format.datatable { render :json => YieldStandardYieldsDatatable.new(view_context) }
    end    
  end

  def standarYieldnew

    @elements = []
    respond_to do |format|
      format.html { render :layout => 'yieldmanager' }
    end    
  end

  def load_elements

    @elements = YlLineClassYields
    .select("T1.*")
    .joins("INNER JOIN [COFFEE_ORIGIN].[yield].[YL_YieldElements] AS T1 ON T1.YE_Id = [COFFEE_ORIGIN].[yield].[Yl_LineClassYields].LC_YE_id")
    .where("[COFFEE_ORIGIN].[yield].[Yl_LineClassYields].LC_PhysicalState = ?",params[:physicalState])
    .where("[COFFEE_ORIGIN].[yield].[Yl_LineClassYields].LC_GroupNum = ?",params[:group])
    .where("[COFFEE_ORIGIN].[yield].[Yl_LineClassYields].LC_Status = ?",1)
    .where("T1.YE_Status = ?",1)
    .order("T1.YE_Id")

    render :json => { :success => true, :response => @elements }

  end

  def cancel_standardyield
    idyield = params[:id]

    begin
      standard = YlStandardYields
      .where("SY_id = ?", idyield)

      #update status in table
      grupObj.update_all "SY_Status = 0, SY_ModificationBy = '"+session[:username][0].to_s+"'" 
      #grupObj.YG_ModificationDt = DateTime.now

      render :json => { :success => true, :id => idyield }
    rescue Exception => e
      render :json => { :success => false, :message => 'Opps!!' + e.message }
    end

    
    
  end

  def get_standard_yields
  	@standarsYields = RefProfitUnit
      .includes(:yl_physicalState)
      .where
  end

  def upload_yields
    spreadsheet = open_spreadsheet(params[:btn_import_tag])

    @rows = []

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[['type', 'value1', 'value2', 'value3', 'value4', 'value5', 'value6', 'value7', 'value8', 'tag_qty', 'exchange_code'], spreadsheet.row(i)].transpose]

      @rows.push(row)
    end

    respond_to do |format|
      format.json { render :json => @rows }
    end
  end

  def open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def groups
  	# @groups = YlYieldGroups
  	# .includes(:physicalState)
  	# .includes(:calcType)

    respond_to do |format|
      format.html { render :layout => 'yieldmanager' }
      format.datatable { render :json => YieldGroupsDatatable.new(view_context) }
    end
  end

  # ============================================================================
  # Edit Group
  # params:
  #   :id => Group Number
  # return: HTML
  # ============================================================================
  def editGroup

    @group = YlYieldGroups
      .where("yg_id = ?", params[:id])
      .first


    #Render with yield Layout
    respond_to do |format|
      format.html { render :layout => 'yieldmanager' }
    end
  end

  def groupsnew
    respond_to do |format|
      format.html { render :layout => 'yieldmanager' }
    end
  end

  def groupcreate

    description = params[:description]
    gold = params[:gold]
    sum = params[:sum]
    physicalState = params[:physicalState]
    hasParen = params[:hasParen]
    parent = params[:parent]
    calcType = params[:calcType]

    #Set Object
    object = YlYieldGroups.new(
          :YG_Description => description,
          :YG_Gold => ((gold=="true")? 1 : 0 ) ,
          :YG_Sum => ((sum=="true")? 1 : 0 ) ,
          :YG_ParentGroup => ((hasParen=="true")? parent : nil ) ,
          :YG_CalcType => calcType ,
          :YG_PhysicalState => physicalState ,
          :YG_ModificationDt => DateTime.now ,
          :YG_ModificationBy => session[:username][0].to_s ,
          :YG_CreationDt => DateTime.now ,
          :YG_CreationBy => session[:username][0].to_s ,
          :YG_Status => 1
        )
    begin
      object.save
    rescue Exception => e
      render :json => { :success => false, :message => 'Error saving group.' + e.message  }
    end

    puts '------------------------------'
    puts object
    render :json => { :success => true }
    

  end

  def edit_group_by_id
    idGroup  = params[:idGroup]
    description = params[:description]
    gold = params[:gold]
    sum = params[:sum]
    physicalState = params[:physicalState]
    hasParen = params[:hasParen]
    parent = params[:parent]
    calcType = params[:calcType]

    #Set Object
    begin
      grupObj = YlYieldGroups
      .find_by(yg_id: idGroup)

      grupObj.update(YG_Description: description)
      grupObj.update(YG_Gold: ((gold=="true")? 1 : 0 ))
      grupObj.update(YG_Sum: ((sum=="true")? 1 : 0 ))
      grupObj.update(YG_ParentGroup: ((hasParen=="true")? parent : nil ))
      grupObj.update(YG_CalcType: calcType)
      grupObj.update(YG_PhysicalState: physicalState)
      grupObj.update(YG_ModificationDt: DateTime.now)
      grupObj.update(YG_ModificationBy: session[:username][0].to_s)

      render :json => { :success => true, :id => idGroup }
    rescue Exception => e
      render :json => { :success => false, :message => 'Opps!!' + e.message }
    end
  end

  def upload_groups
    spreadsheet = open_spreadsheet(params[:btn_upload_groups])

    @rows = []

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[['code', 'description', 'gold', 'sum', 'parentGroup', 'calcType', 'physicalState'], spreadsheet.row(i)].transpose]

      error = ""

      begin
        
        # #Validate Row
        # if i.code == nil
        #   error += "Column Code must be numeric and cannot be empty;"
        # if i.description == nil
        #   error += "Column Description cannot be empty;"
        # if i.gold == nil
        #   error += "Column GreenBean cannot be empty;"
        # if i.sum == nil
        #   error += "Column Sum cannot be empty;"
        # if !i.parentGroup.is_a?(Numeric) and i.parentGroup == nil
        #   error += "Column ParentGroup must be numeric;"

        # if i.physicalState == nil
        #   error += "Column PhysicalState cannot be empty;"

        # if error.empty? == false
        #   raise error

        # #Validate


      rescue 
        #Keep File with Exceptions

      end

    end

    respond_to do |format|
      format.json { render :json => @rows }
    end

  end

  def cancel_group
    idGroup = params[:id]

    puts '---------------------------------'
    puts idGroup

    begin
      grupObj = YlYieldGroups
      .where("yg_id = ?", idGroup)

      #update status in table
      grupObj.update_all "YG_Status = 0, YG_ModificationBy = '"+session[:username][0].to_s+"'" 
      #grupObj.YG_ModificationDt = DateTime.now

      render :json => { :success => true, :id => idGroup }
    rescue Exception => e
      render :json => { :success => false, :message => 'Opps!!' + e.message }
    end

    
    
  end


  def elements
    respond_to do |format|
      format.html { render :layout => 'yieldmanager' }
      format.datatable { render :json => YieldElementsDatatable.new(view_context) }
    end
  end

  def elementsnew
    #Render with yield Layout
    respond_to do |format|
      format.html { render :layout => 'yieldmanager' }
    end
  end

  def elementcreate
    type = params[:type]
    value = params[:value]
    group = params[:group]

    #Set Object
    object = YlYieldElements.new(
          :YE_IdElementType => type,
          :YE_Element => value,
          :YE_IdYieldGroup => group,
          :YE_ModificationDt => DateTime.now ,
          :YE_ModificationBy => session[:username][0].to_s ,
          :YE_CreationDt => DateTime.now ,
          :YE_CreationBy => session[:username][0].to_s ,
          :YE_Status => 1
        )
    begin
      object.save
    rescue Exception => e
      render :json => { :success => false, :message => 'Error saving group.' + e.message  }
    end
    render :json => { :success => true }
  end

  # def groupsDataSource
  # 	respond_to do |format|
  #     format.html
  #     format.datatable { render :json => YieldGroupsDatatable.new(view_context) }
  #   end
  # end

  #####################################################
  #LINE CLASS

  def lineclass
    respond_to do |format|
      format.html { render :layout => 'yieldmanager' }
      format.datatable { render :json => YieldLineGroupDatatable.new(view_context) }
    end
  end

  def editLineClass
    @lineclass = YlLineClassYields
      .includes(:physicalState)
      .includes(:group)
      .includes(:element)
      .where("lc_id = ? ",params[:id])
      .where("lc_status = ?", 1)
      .order("lc_id")
      .first

    puts '--------------------------------------------'
    puts @lineclass.to_json

    respond_to do |format|
      format.html { render :layout => 'yieldmanager' }
    end

  end

  def cancel_lineclass
    idLineClass = params[:id]

 
    begin
      obj = YlLineClassYields
      .where("lc_id = ?", idLineClass)

      #update status in table
      obj.update_all "LC_Status = 0, LC_ModificationBy = '"+session[:username][0].to_s+"'" 
      #grupObj.YG_ModificationDt = DateTime.now

      render :json => { :success => true, :id => idLineClass }
    rescue Exception => e
      render :json => { :success => false, :message => 'Opps!!' + e.message }
    end
  end

 

  def lineclassnew
    respond_to do |format|
      format.html { render :layout => 'yieldmanager' }
    end
  end

  def new_lineclass
    physicalState = params[:physicalState]
    groupNum = params[:groupNum]
    element = params[:element]
    forpay = params[:forpay]

    #Set Object
    object = YlLineClassYields.new(
          :LC_PhysicalState => physicalState,
          :LC_GroupNum => groupNum,
          :LC_YE_id => element,
          :LC_UseForPay => forpay ,
          :LC_ModificationDt => DateTime.now ,
          :LC_ModificationBy => session[:username][0].to_s ,
          :LC_CreationDt => DateTime.now ,
          :LC_CreationBy => session[:username][0].to_s ,
          :LC_Status => 1
        )
    begin
      object.save
    rescue Exception => e
      render :json => { :success => false, :message => 'Error saving group.' + e.message  }
    end
    render :json => { :success => true }
  end

  def edit_lineclass_by_id
    idLineClass  = params[:idLineClass]
    physicalState = params[:physicalState]
    groupNum = params[:groupNum]
    element = params[:element]
    forpay = params[:forpay]


    #Set Object
    begin
      obj = YlLineClassYields
      .where("lc_id = ? ",idLineClass)
      .order("lc_id")
      .first

      obj.update(LC_PhysicalState: physicalState)
      obj.update(LC_GroupNum: groupNum)
      obj.update(LC_YE_id: element)
      obj.update(LC_UseForPay: ((forpay=="true")? 1 : 0 ))
      obj.update(LC_ModificationDt: DateTime.now)
      obj.update(LC_ModificationBy: session[:username][0].to_s)

      render :json => { :success => true, :id => idLineClass }
    rescue Exception => e
      render :json => { :success => false, :message => 'Opps!!' + e.message }
    end
  end


  ########################################################################################################################


  #Purchasing Yields
  def purchasingyields

    @screnningTest = YlRefScreeningTests
    .where("sc_status = ?", 1)

    @defects = YlRefDefects
    .where("df_status = ?", 1)

    @yieldTest = YlRefYieldTests
    .where("yt_testgroup = ?", 1)
    .where("yt_status = ?", 1)

    render layout: "yieldmanager"
  end

  def getTrade
    trade = params[:trade]

    begin
      term = TrdTerm
      .where("trade_num = ?", trade)

      render :json => { :success => true, :obj => term }
    rescue Exception => e
      render :json => { :success => false, :message => 'Opps!!' + e.message }
    end
  end

end
