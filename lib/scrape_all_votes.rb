require_relative 'voted'
require_relative 'get_mps'
require 'json'
require 'date'

class GetAllVotes
   def initialize
     @all_file = get_all_file()
     $all_mp =  GetMp.new
   end
   def get_all_file
     hash = []
     uri = "https://ckan.dubno-adm.rv.ua/api/3/action/package_show?id=rezul-tati-rolosuvannya-u-2019-rotsi"
     json = open(uri).read
     hash_json = JSON.parse(json)
     hash_json["result"]["resources"].each do |r|

         hash << { path: r["url"], last_modified: r["last_modified"]}
     end
     return hash
   end
  def get_all_votes
    @all_file.each do |f|
      update = UpdatePar.first(url: f[:path], last_modified: f[:last_modified])
      if update.nil?
        read_file(f[:path] )
        UpdatePar.create!(url: f[:path], last_modified: f[:last_modified])
      end
    end
  end
  def read_file(file)
     i = 1
    json = open(file).read
     # p file
    my_hash = JSON.parse(json)
    my_hash["PD"].each do |v|
      v["GLList"].each do |vote|
        # p vote
        # p vote["GLTime"]
        date_caden = Date.strptime(vote["GLTime"].strip,'%d.%m.%Y')
               date_vote = DateTime.strptime(vote["GLTime"].strip, '%d.%m.%Y %H:%M:%S')
        name = vote["GLText"]
        rada_id = 10
        if vote["RESULT"] ==  " РІШЕННЯ ПРИЙНЯТО "
          option = "Прийнято"
        else
          option= "Не прийнято"
        end

        event = VoteEvent.first(name: name, date_vote: date_vote, number: i, date_caden: date_caden, rada_id: rada_id, option: option)

        if event.nil?
              events = VoteEvent.new(name: name, date_vote: date_vote, number: i, date_caden: date_caden, rada_id: rada_id, option: option)
              events.date_created = Date.today
              events.save
        else
              events = event
              events.votes.destroy!
        end
        i = i + 1
        # p file
        vote["DPList"].each do |dep_vote|
          vote = events.votes.new
          vote.voter_id = $all_mp.serch_mp(dep_vote["DPName"])
          vote.result =  short_voted_result(dep_vote["DPGolos"])
          vote.save
        end
      end
    end



  end
  def short_voted_result(result)
    hash = {
        "НЕ ГОЛОСУВАВ":  "not_voted",
        ВІДСУТНІЙ: "absent",
        ВІДСУТНЯ: "absent",
        ПРОТИ:  "against",
        ЗА: "aye",
        УТРИМАВСЯ: "abstain",
        УТРИМАЛАСЬ: "abstain"
    }
    hash[:"#{result.upcase}"]
  end
end
