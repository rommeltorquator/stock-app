class HomeController < ApplicationController
  def index
    @hope = 'Hope is the anchor of the soul'
    @brokers = Broker.all
    @buyers = Buyer.all
    @pending_approval = User.where(approved: false)
    @transactions = PurchaseTransaction.all
    @new_user = User.new
  end

  def portfolio; end

  def transaction
    @transactions = if current_buyer
                      current_buyer.purchase_transactions
                    elsif current_broker
                      PurchaseTransaction.where(broker_id: current_broker.id)
                    elsif current_admin
                      PurchaseTransaction.all
                    end
  end

  def show_user
    @user = User.find(params[:id])
  end

  def approve
    @broker = User.find(params[:broker])
    if @broker
      @broker.update(approved: true)
      UserMailer.with(email: @broker.email).admin_approved_email.deliver_now
      @broker.save
      redirect_to root_path, notice: 'Broker approved'
    else
      redirect_to root_path, notice: 'Broker not approved'
    end
  end

  def create_user
    @user = User.new(email: params[:user][:email], first_name: params[:user][:first_name], last_name: params[:user][:last_name], type: params[:user][:type], password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])

    if @user.save
      redirect_to transaction_home_index_path, alert: 'new user created!'
    else
      redirect_to root_path, alert: "not saved errors? #{@user.errors.any?}"
    end
  end

  def update_buyer
    if params[:broker]
      @user = User.find(params[:broker][:id])
      @user.update(email: params[:broker][:email], first_name: params[:broker][:first_name], last_name: params[:broker][:last_name])

      redirect_to root_path, notice: 'updated na po sya'
    elsif params[:buyer]
      @user = User.find(params[:buyer][:id])
      @user.update(email: params[:buyer][:email], first_name: params[:buyer][:first_name], last_name: params[:buyer][:last_name])

      redirect_to root_path, notice: 'updated na po sya'
    end
  end
end
