require 'rubygems'
require 'mechanize'
require 'hpricot'

class Modul
  attr_reader :modulNr
  attr_reader :modulText
  attr_reader :semester
  attr_reader :date
  attr_reader :grade
  attr_reader :passed
  #was first note but this was a bit confusing in this context
  attr_reader :memo
  attr_reader :try
  attr_accessor :cp
  
  def initialize(modulNr,modulText,semester,date,grade,passed,memo,try)
    @modulNr = modulNr.innerText.strip.to_i
    @modulText = modulText.innerText.strip
    @semester = semester.innerText.strip
    @date = date.innerText.strip
    @grade = grade.innerText.strip.gsub(",",".").to_f
    @passed = !passed.innerText.strip.include?("nicht")
    @memo = memo.innerText.strip
    @try = try.innerText.strip.to_i
    @cp = 0.0
    # if isMainModul and @modulNr > 1000 then
    #       @cp = fetchCP(curriculum)
    #     else
    #       @cp = 0.0
    #     end
  end
  
  def isMainModul
    return @modulNr % 10 == 0
  end
  

  
end

class QisScraper
  attr_reader :user
  attr_reader :pass
  attr_reader :sessionId
  attr_reader :agent
  attr_reader :baseUrl
  
  def initialize(user, pass,sessionId = nil)
    @user = user
    @pass = pass
    @sessionId = sessionId
    @agent = WWW::Mechanize.new
    @baseUrl = 'https://qis1.rz.fh-wiesbaden.de/qisserver/servlet/de.his.servlet.RequestDispatcherServlet?'
    login
  end
  
  def login
    puts "Logging in..."
    post = {
      'asdf' => @user,
      'fdsa' => @pass,
      'submit' => 'Anmelden'
    }
  
    loginPage = @agent.post(@baseUrl + 'state=user&type=1',post)
    
    if loginPage.links.select{|l| l.text.strip.eql?("Abmelden")}.empty?
      raise "Login failed"
    end
    puts "Succesfully logged in"
    
    #extract session id 
    # split link and extract part value for asi
    @sessionId = loginPage.links.select{|l| l.text.strip.eql?("Allgemeine Verwaltung")}.first.href.split('=').last
    puts "SessionID is: " + @sessionId
  end
  
  
  #Fetches all Modules (passed or not)
  #Returns a Hashmap with modulename a s key and Module as value
  def fetchModules
    puts "Fetching Modules"
    #direct url to gradeTable
    url = @baseUrl + 'state=htmlbesch&moduleParameter=Student&menuid=notenspiegel&breadcrumb=notenspiegel&breadCrumbSource=menu&asi='
   # pp @sessionId
    gradePage = @agent.get(url + @sessionId)

    #fetch curriculum for creditpoints
    #curriculum = agent.get('http://web-1k.rz.fh-wiesbaden.de/bachelorcurriculum.cfm?fb=22&sprachid=1&sid=103&poid=93&detail=ja').body

    doc =  Hpricot(gradePage.body)
    table = doc.at("//table[2]")
    rows = (table/"tr")
    
    modules = []
    
    (1...rows.length).to_a.each do |i|
      size = (rows[i]/"td").size
      cells = (rows[i]/"td")
      
      #TODO insert debug/log code
      mod = Modul.new(cells[0],cells[1],cells[2],cells[3],cells[4],cells[5],cells[6],cells[7])
      modules.push mod
    end  
    puts "Fetched " + modules.length.to_s + " modules"
    return modules
  end
  
  def fetchOpenExams
    raise "Not implemented yet"
    url ='state=posinfo&moduleParameter=Student&menuid=infoexams&breadcrumb=infoexams&breadCrumbSource=menu&asi='
  end
end
