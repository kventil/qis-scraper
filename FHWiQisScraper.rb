require 'rubygems'
require 'mechanize'
require 'hpricot'
require  "QisScraper.rb"

class FHWiQisScraper < QisScraper
  attr_reader :curriculum_body
  attr_reader :modules
  def initialize(name,password)
    super(name,password)
    @curriculum_body = agent.get('http://web-1k.rz.fh-wiesbaden.de/bachelorcurriculum.cfm?fb=22&sprachid=1&sid=103&poid=93&detail=ja').body
    @modules = fetchModules
    fetchCreditPoints
  end
  
  def getAverageGrade
    puts "Calculating average grade"
    allCp = 0;
    gradeCp = 0.0;
    modules.each{
      |modul|
      allCp = allCp + modul.cp
      gradeCp = gradeCp + modul.grade * modul.cp
    }
    return gradeCp/allCp
  end
  
  private
  def fetchCreditPoints
    puts "Fetching Creditpoints"
    modules.each{
      |modul|
      fetchCPforModul(modul)
    }
  end
  
  def fetchCPforModul(modul)
    # >1000 because of the mysterios modules without any sense
    if modul.isMainModul and modul.modulNr > 1000 then
    doc = Hpricot(@curriculum_body)
    table = doc.at("//table[1]")
    rows = (table/"tr")
    selRow = rows.select{|row| row.innerText.include?(modul.modulNr.to_s)}
    cells = (selRow[0]/"td")
    modul.cp =  cells[3].innerText.strip.to_f
    else
    modul.cp = 0.0
    end
  end
end


