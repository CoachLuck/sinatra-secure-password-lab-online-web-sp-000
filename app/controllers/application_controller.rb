require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    #your code here
    user = User.new(username: params[:username], password: params[:password])

    if user.save
      redirect '/login'
    else
      redirect '/failure'
    end
  end

  get '/account' do
    @user = current_user
    puts "ACcount Balance: #{@user.balance}"
    if @user.balance == nil
      @user.update(balance: 0)
    end

    erb :account
  end


  get "/login" do
    erb :login
  end

  post "/login" do
    ##your code here
    user = User.find_by(username: params[:username])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect '/account'
    else
      redirect '/failure'
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

  post "/account/deposit" do
    deposit = params[:deposit].to_i
    @user = current_user
    @user.balance ||= 0.0
    new_bal = @user.balance

    if deposit > 0
      puts "ADDING"
      new_bal += deposit
      puts "#{new_bal}"
    end

    @user.update(balance: new_bal)
    puts "New Balance: #{@user.balance}"
    redirect '/account'
  end

  post "/account/withdraw" do
    withdraw = params[:withdraw].to_i
    @user = current_user
    @user.balance ||= 0.0
    new_bal = @user.balance

    if withdraw > 0
      if new_bal - withdraw < 0
        new_bal -= withdraw
      else
        redirect '/failure'
      end
    end

    @user.balance = new_bal
    @user.save
    redirect '/account'
  end

end
