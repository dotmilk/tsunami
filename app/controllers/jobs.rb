Tsunami::App.controllers :jobs do
  
  get :index do
    @jobs = Job.all(:order => 'created_at desc')
    @accounts = Twitkey.all(:order => 'created_at desc')
    @payloads = Storm.all(:order => 'created_at desc')
    render 'jobs/index'
  end

  get :index, :with => :id do
    begin
      Process.kill(:KILL,params[:id].to_i)
    rescue

    end
    Job.where(:pid => params[:id].to_i).destroy_all
    redirect url(:jobs, :index)
  end

  post :index do
    if params[:accounts]
      params[:accounts].each do |acc|
        job = Job.new
        #puts acc
        payload = Storm.find(params["payload"])
        tweets = payload.tweets
        account = Twitkey.where(:name => acc).first
        job.account_name = account[:name]
        job.storm_name = payload[:name]
        #puts "here"
        #p account
        #puts "here"

        beam = Lazer.new(account,tweets)
        #beam.chargin_mah_lazer
        job.pid = fork { beam.chargin_mah_lazer }
        Process.detach(job.pid)
        job.save
      end
    end
    @jobs = Job.all(:order => 'created_at desc')
    @accounts = Twitkey.all(:order => 'created_at desc')
    @payloads = Storm.all(:order => 'created_at desc')
    render 'jobs/index'
  end

end
