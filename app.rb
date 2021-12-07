require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/count.rb'

domains = ["app.2g0.xyz","app.2g0.work","app.2g0.info",
    "app.gotoour.site","app.go2link.xyz","app.move2.link",
    "app.2g0.online","app.skip2.xyz","app.skip2.cloud",
    "app.リンクタンシュク.jp","app.ultra-go.info","app.theultrago.xyz"]
    
bads = ["mkr","mrked","dlr","data"]

get '/' do
    @domains = domains
    erb :index
end


post '/mkr' do
    if(domains.include?(params[:selectdomain]) and params[:arg].strip != "" and params[:target].strip != "" and params[:pw].strip != "" and !bads.include?(params[:arg].strip) )
        link = Link.find_by(text: params[:arg],domain: params[:selectdomain])
        if( link == nil )
            if(params[:selectdomain].strip == "app.リンクタンシュク.jp")
                Link.create(text: params[:arg],domain: "app.xn--pckax5a0p0a7dc.jp",password: params[:pw],target: params[:target])
                redirect "/mrked?domain=app.xn--pckax5a0p0a7dc.jp&arg=" + params[:arg] + "&pw=" + params[:pw]
            else
                Link.create(text: params[:arg],domain: params[:selectdomain],password: params[:pw],target: params[:target])
            end
            redirect "/mrked?domain=" + params[:selectdomain] + "&arg=" + params[:arg] + "&pw=" + params[:pw]
        else
            "Already Exited! <a href='/'>Home</a>"
        end
    end
    "Failed to create short url! <a href='/'>Home</a>"
end


get '/mrked' do
    domain = params[:domain]
    arg = params[:arg]
    pw = params[:pw]
    link = Link.find_by(text: arg,domain: domain)
    if( link != nil && link.password == pw)
        if(domain.strip == "app.xn--pckax5a0p0a7dc.jp")
            domain = "app.リンクタンシュク.jp"
        end
        "Original: " + link.target + "<br>Short: http://" + domain + "/" + arg + "<br>Delete it? (click to delete!) -> <a href='/dlr?domain=" + domain + "&arg=" + arg + "&pw=" + pw + "'>DELETE_CONFIRM</a>"
    end
end


get '/dlr' do
    domain = params[:domain]
    arg = params[:arg]
    pw = params[:pw]
    if(domain.strip == "app.xn--pckax5a0p0a7dc.jp")
        domain = "jp.リンクタンシュク.jp"
    end
    link = Link.find_by(text: arg,domain: domain,password: pw)
    if( link != nil )
        link.destroy()
        "Deleted! <a href='/'>Home</a>"
    end
end

get '/data' do
    a = ""
    am = 0
    domains.each do |domain|
        if(domain.strip == "app.リンクタンシュク.jp")
            domain = "app.xn--pckax5a0p0a7dc.jp"
        end
        perDomain = Link.where(domain: domain)
        a = a + "<br>" + domain.to_s + " : " + perDomain.count.to_s
        am = am + perDomain.count
    end
    am = Link.count - am
    a + "<br>Deleted: " + am.to_s + "<br><a href='http://app.ultra-go.info'>Home</a>"
end

get '/:any' do
    domain = request.host
    link = Link.find_by(domain: domain,text: params[:any])
    if( link != nil ) 
        redirect link.target
    else
        redirect "http://app.ultra-go.info/"
    end
end