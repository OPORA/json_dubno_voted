require 'open-uri'
require 'json'
class GetMp
  def initialize
    @data_hash = JSON.load(open('http://dubnomp.oporaua.org/'))
  end
  def serch_mp(full_name)
    # p full_name
    if full_name =="Іванова Марія Петрівна"
      return 35
    elsif  full_name == "Момотюк Юрій Володимирович"
      return 36
    elsif  full_name == "Опалак Вадим Олександрович"
      return  37
    elsif  full_name == "Тимрук Віктор Станіславович"
      return  38
    else
      name =full_name.gsub(/'/,'’')
      data = @data_hash.find {|k| k["full_name"] == name  }
      return data["deputy_id"]
    end
  end
end
