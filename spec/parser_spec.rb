require 'rspec'
require_relative '../jcrvalidator'
require 'pp'

describe 'parser' do

  it 'should parse an ip4 value defintion' do
    tree = JCRValidator.parse( 'trule : ip4' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:value_rule][:ip4]).to eq("ip4")
    tree = JCRValidator.parse( 'trule :ip4' )
    expect(tree[:rules][:value_rule][:ip4]).to eq("ip4")
    tree = JCRValidator.parse( 'trule : ip4 ' )
    expect(tree[:rules][:value_rule][:ip4]).to eq("ip4")
  end

  it 'should parse an ip6 value defintion' do
    tree = JCRValidator.parse( 'trule : ip6' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:value_rule][:ip6]).to eq("ip6")
    tree = JCRValidator.parse( 'trule :ip6' )
    expect(tree[:rules][:value_rule][:ip6]).to eq("ip6")
    tree = JCRValidator.parse( 'trule : ip6 ' )
    expect(tree[:rules][:value_rule][:ip6]).to eq("ip6")
  end

  it 'should parse a string without a regex' do
    tree = JCRValidator.parse( 'trule : string' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:value_rule][:string]).to eq("string")
  end

  it 'should parse a string with a regex' do
    tree = JCRValidator.parse( 'trule : string /a.regex.goes.here.*/' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:value_rule][:string]).to eq("string")
    expect(tree[:rules][:value_rule][:regex]).to eq("a.regex.goes.here.*")
    tree = JCRValidator.parse( 'trule : string /a.regex\\.goes.here.*/' )
    expect(tree[:rules][:value_rule][:regex]).to eq("a.regex\\.goes.here.*")
  end

  it 'should parse a uri without a uri template' do
    tree = JCRValidator.parse( 'trule : uri' )
    expect(tree[:rules][:value_rule][:uri]).to eq("uri")
  end

  it 'should parse a uri with a uri template' do
    tree = JCRValidator.parse( 'trule : uri http://example.com/{path}' )
    expect(tree[:rules][:value_rule][:uri]).to eq("uri")
    expect(tree[:rules][:value_rule][:uri_template]).to eq("http://example.com/{path}")
  end

  it 'should parse a integer value without a range' do
    tree = JCRValidator.parse( 'trule : integer' )
    expect(tree[:rules][:value_rule][:integer_v]).to eq("integer")
  end

  it 'should parse a integer value with a full range' do
    tree = JCRValidator.parse( 'trule : integer 0..100' )
    expect(tree[:rules][:value_rule][:integer_v]).to eq("integer")
    expect(tree[:rules][:value_rule][:min]).to eq("0")
    expect(tree[:rules][:value_rule][:max]).to eq("100")
  end

  it 'should parse a integer value with a min range' do
    tree = JCRValidator.parse( 'trule : integer 0..' )
    expect(tree[:rules][:value_rule][:integer_v]).to eq("integer")
    expect(tree[:rules][:value_rule][:min]).to eq("0")
  end

  it 'should parse a integer value with a max range' do
    tree = JCRValidator.parse( 'trule : integer ..100' )
    expect(tree[:rules][:value_rule][:integer_v]).to eq("integer")
    expect(tree[:rules][:value_rule][:max]).to eq("100")
  end

  it 'should parse a float value with a full range' do
    tree = JCRValidator.parse( 'trule : float 0.0..100.0' )
    expect(tree[:rules][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:value_rule][:min]).to eq("0.0")
    expect(tree[:rules][:value_rule][:max]).to eq("100.0")
  end

  it 'should parse a float value with a min range' do
    tree = JCRValidator.parse( 'trule : float 0.3939..' )
    expect(tree[:rules][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:value_rule][:min]).to eq("0.3939")
  end

  it 'should parse a float value with a max range' do
    tree = JCRValidator.parse( 'trule : float ..100.003' )
    expect(tree[:rules][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:value_rule][:max]).to eq("100.003")
  end

  it 'should parse an enumeration' do
    tree = JCRValidator.parse( 'trule : < 1.0 2 true "yes" "Y" >' )
    expect(tree[:rules][:value_rule][:enumeration][0][:float]).to eq("1.0")
    expect(tree[:rules][:value_rule][:enumeration][1][:integer]).to eq("2")
    expect(tree[:rules][:value_rule][:enumeration][2][:boolean]).to eq("true")
    expect(tree[:rules][:value_rule][:enumeration][3][:q_string]).to eq("yes")
    expect(tree[:rules][:value_rule][:enumeration][4][:q_string]).to eq("Y")
    tree = JCRValidator.parse( 'trule : < "no" false 1.0 2 true "yes" "Y" >' )
    expect(tree[:rules][:value_rule][:enumeration][0][:q_string]).to eq("no")
    expect(tree[:rules][:value_rule][:enumeration][1][:boolean]).to eq("false")
    expect(tree[:rules][:value_rule][:enumeration][2][:float]).to eq("1.0")
    expect(tree[:rules][:value_rule][:enumeration][3][:integer]).to eq("2")
    expect(tree[:rules][:value_rule][:enumeration][4][:boolean]).to eq("true")
    expect(tree[:rules][:value_rule][:enumeration][5][:q_string]).to eq("yes")
    expect(tree[:rules][:value_rule][:enumeration][6][:q_string]).to eq("Y")
    tree = JCRValidator.parse( 'trule : < null "no" false 1.0 2 true "yes" "Y" >' )
    expect(tree[:rules][:value_rule][:enumeration][0][:null]).to eq("null")
    expect(tree[:rules][:value_rule][:enumeration][1][:q_string]).to eq("no")
    expect(tree[:rules][:value_rule][:enumeration][2][:boolean]).to eq("false")
    expect(tree[:rules][:value_rule][:enumeration][3][:float]).to eq("1.0")
    expect(tree[:rules][:value_rule][:enumeration][4][:integer]).to eq("2")
    expect(tree[:rules][:value_rule][:enumeration][5][:boolean]).to eq("true")
    expect(tree[:rules][:value_rule][:enumeration][6][:q_string]).to eq("yes")
    expect(tree[:rules][:value_rule][:enumeration][7][:q_string]).to eq("Y")
  end

  it 'should parse a float value with a max range' do
    tree = JCRValidator.parse( 'trule VALUE float ..100.003' )
    expect(tree[:rules][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:value_rule][:max]).to eq("100.003")
  end

  it 'should parse a member rule with float value with a max range' do
    tree = JCRValidator.parse( 'trule "thing" VALUE float ..100.003' )
    expect(tree[:rules][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[:rules][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:member_rule][:value_rule][:max]).to eq("100.003")
    tree = JCRValidator.parse( 'trule MEMBER "thing" VALUE float ..100.003' )
    expect(tree[:rules][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[:rules][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:member_rule][:value_rule][:max]).to eq("100.003")
    tree = JCRValidator.parse( 'trule "thing" : float ..100.003' )
    expect(tree[:rules][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[:rules][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:member_rule][:value_rule][:max]).to eq("100.003")
  end

  it 'should parse a member rule with a rule name' do
    tree = JCRValidator.parse( 'trule "thing" my_value_rule' )
    expect(tree[:rules][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[:rules][:member_rule][:target_rule_name][:rule_name]).to eq("my_value_rule")
  end

  it 'should parse an object rule with rule names' do
    tree = JCRValidator.parse( 'trule { my_rule1, my_rule2 }' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[:rules][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with names' do
    tree = JCRValidator.parse( 'trule { "thing" my_value_rule, my_rule2 }' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[:rules][:object_rule][0][:member_rule][:target_rule_name][:rule_name]).to eq("my_value_rule")
    expect(tree[:rules][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    tree = JCRValidator.parse( 'trule { MEMBER "thing" my_value_rule, my_rule2 }' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[:rules][:object_rule][0][:member_rule][:target_rule_name][:rule_name]).to eq("my_value_rule")
    expect(tree[:rules][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with value rule' do
    tree = JCRValidator.parse( 'trule { "thing" : float ..100.003, my_rule2 }' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[:rules][:object_rule][0][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:object_rule][0][:member_rule][:value_rule][:max]).to eq("100.003")
    expect(tree[:rules][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    tree = JCRValidator.parse( 'trule { MEMBER "thing" : float ..100.003, my_rule2 }' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[:rules][:object_rule][0][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:object_rule][0][:member_rule][:value_rule][:max]).to eq("100.003")
    expect(tree[:rules][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with value rule spelled out' do
    tree = JCRValidator.parse( 'trule OBJECT MEMBER "thing" : float ..100.003, my_rule2 END_OBJECT' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[:rules][:object_rule][0][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:object_rule][0][:member_rule][:value_rule][:max]).to eq("100.003")
    expect(tree[:rules][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    tree = JCRValidator.parse( 'trule OBJECT MEMBER "thing" : float ..100.003 AND my_rule2 END_OBJECT' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[:rules][:object_rule][0][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:object_rule][0][:member_rule][:value_rule][:max]).to eq("100.003")
    expect(tree[:rules][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with rule names with optionality' do
    tree = JCRValidator.parse( 'trule { my_rule1, ? my_rule2 }' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[:rules][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[:rules][:object_rule][1][:member_optional]).to eq("?")
    tree = JCRValidator.parse( 'trule { ?my_rule1, ? my_rule2 }' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[:rules][:object_rule][0][:member_optional]).to eq("?")
    expect(tree[:rules][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[:rules][:object_rule][1][:member_optional]).to eq("?")
  end

  it 'should parse an object rule with embeded member rules with value rule with optionality' do
    tree = JCRValidator.parse( 'trule { ? "thing" : float ..100.003, my_rule2 }' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[:rules][:object_rule][0][:member_optional]).to eq("?")
    expect(tree[:rules][:object_rule][0][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:object_rule][0][:member_rule][:value_rule][:max]).to eq("100.003")
    expect(tree[:rules][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    tree = JCRValidator.parse( 'trule { ? MEMBER "thing" : float ..100.003, my_rule2 }' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[:rules][:object_rule][0][:member_optional]).to eq("?")
    expect(tree[:rules][:object_rule][0][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[:rules][:object_rule][0][:member_rule][:value_rule][:max]).to eq("100.003")
    expect(tree[:rules][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with rule names' do
    tree = JCRValidator.parse( 'trule [ my_rule1, my_rule2 ]' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[:rules][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    tree = JCRValidator.parse( 'trule ARRAY my_rule1 AND my_rule2 END_ARRAY' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[:rules][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with rule names and repitition' do
    tree = JCRValidator.parse( 'trule [ 1*2 my_rule1, 1* my_rule2, *3 my_rule3 ]' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[:rules][:array_rule][0][:repetition_min]).to eq("1")
    expect(tree[:rules][:array_rule][0][:repetition_max]).to eq("2")
    expect(tree[:rules][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[:rules][:array_rule][1][:repetition_min]).to eq("1")
    expect(tree[:rules][:array_rule][1][:repetition_max]).to eq("")
    expect(tree[:rules][:array_rule][2][:target_rule_name][:rule_name]).to eq("my_rule3")
    expect(tree[:rules][:array_rule][2][:repetition_min]).to eq("")
    expect(tree[:rules][:array_rule][2][:repetition_max]).to eq("3")
  end

  it 'should parse an array rule with an object rule' do
    tree = JCRValidator.parse( 'trule [ my_rule1, { my_rule2 } ]' )
    expect(tree[:rules][:rule_name]).to eq("trule")
    expect(tree[:rules][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[:rules][:array_rule][1][:object_rule][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule [ : integer , { my_rule2 } ]' )
  end

  it 'should parse an array rule with a rulename and an array rule' do
    tree = JCRValidator.parse( 'trule [ my_rule1 , [ my_rule2 ] ]' )
  end

  it 'should parse an array rule with a rulename and an array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule [ my_rule1 , [ : integer, { my_rule2 } ] ]' )
  end
end