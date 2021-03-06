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
    user = User.find_by(:username => params[:username])
    if !!user
      redirect "/usererror"
    end

    if params[:username].size > 0
      user = User.new(:username => params[:username], :password => params[:password])
        if user.save
          redirect "/login"
        else
          redirect "/failure"
        end
    else
      redirect "/failure"
    end
  end

  get '/account' do
    if logged_in?
      user = User.find(session[:user_id])
      session[:username] = user.username
      session[:balance] = user.balance
      erb :account
    else
      redirect "/"
    end
  end

  get "/deposit" do
    if logged_in?
      erb :deposit
    else
      redirect '/'
    end
  end

  post '/deposit' do
    if logged_in?
      user = User.find(session[:user_id])
      user.balance = user.balance + params[:deposit].to_f
      user.save
      user = User.find(session[:user_id])
      session[:balance] = user.balance
      erb :account
    else
      redirect "/"
    end
  end

  get "/withdrawal" do
    if logged_in?
      erb :withdrawal
    else
      redirect '/'
    end
  end

  post '/withdrawal' do
    if logged_in?
      user = User.find(session[:user_id])
      if user.balance >= params[:withdrawal].to_f
        user.balance = user.balance - params[:withdrawal].to_f
        user.save
        user = User.find(session[:user_id])
        session[:balance] = user.balance
        erb :account
      else
        redirect "/account"
      end
    else
      redirect "/"
    end
  end

  get "/login" do
    erb :login
  end

  post "/login" do
    user = User.find_by(:username => params[:username])
    if user && user.authenticate(params[:password])
       session[:user_id] = user.id
       redirect "/account"
    else
       redirect "/failure"
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/usererror" do
    erb :usererror
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

end
