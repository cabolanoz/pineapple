require 'test_helper'

class Traffic::TransfermanagerControllerTest < ActionController::TestCase

  test "Children tag should be repeat it properly" do
        params = {"equipment_num"=>"2838", "cargo_num"=>"4050", "strategy_num"=>"3071", "qty_to_alloc"=>"100", "draw_num"=>"54939", "draw_qty"=>"-100.0", "draw_dt"=>"20150505", "build"=>{"0"=>{"build_num"=>"54859", "build_qty"=>"96", "build_dt"=>"20150429", "tag"=>{"0"=>{"build_draw_num"=>"54859", "tag_type_cd"=>"Chop Data", "ref_bd_tag_num"=>"122683", "bd_tag_num"=>"122685", "tag_value1"=>"tag2", "tag_value2"=>"tag2", "tag_value3"=>"tag2", "tag_value4"=>"tag2", "tag_value7"=>"", "tag_value8"=>"", "tag_alloc_qty"=>"0", "qty_to_alloc"=>"90", "tag_qty"=>"90", "tag_qty_uom_cd"=>"46kbg", "tag_source_ind"=>"0", "chop_id"=>"143540-1-34853"}, "1"=>{"build_draw_num"=>"54859", "tag_type_cd"=>"Chop Data", "ref_bd_tag_num"=>"122683", "bd_tag_num"=>"122688", "tag_value1"=>"tag2", "tag_value2"=>"tag2", "tag_value3"=>"tag2", "tag_value4"=>"tag2", "tag_value7"=>"", "tag_value8"=>"", "tag_alloc_qty"=>"0.00", "qty_to_alloc"=>"6", "tag_qty"=>"6", "tag_qty_uom_cd"=>"46kbg", "tag_source_ind"=>"0", "chop_id"=>"143540-1-34853"}}}, "1"=>{"build_num"=>"54929", "build_qty"=>"4", "build_dt"=>"20150505", "tag"=>{"0"=>{"build_draw_num"=>"54929", "tag_type_cd"=>"Chop Data", "ref_bd_tag_num"=>"null", "bd_tag_num"=>"122826", "tag_value1"=>"N", "tag_value2"=>"A", "tag_value3"=>"D", "tag_value4"=>"A", "tag_value7"=>"N", "tag_value8"=>"D", "tag_alloc_qty"=>"0.00", "qty_to_alloc"=>"1", "tag_qty"=>"1", "tag_qty_uom_cd"=>"46kbg", "tag_source_ind"=>"0", "chop_id"=>"143461-1-34891"}, "1"=>{"build_draw_num"=>"54929", "tag_type_cd"=>"Chop Data", "ref_bd_tag_num"=>"null", "bd_tag_num"=>"122828", "tag_value1"=>"N", "tag_value2"=>"A", "tag_value3"=>"D", "tag_value4"=>"A", "tag_value7"=>"N", "tag_value8"=>"D", "tag_alloc_qty"=>"0.00", "qty_to_alloc"=>"3", "tag_qty"=>"3", "tag_qty_uom_cd"=>"46kbg", "tag_source_ind"=>"0", "chop_id"=>"143461-1-34891"}}}}}

        puts Rails.env
        post :put_build_draw_match, params.to_json
        assert_response :success

  end

end
