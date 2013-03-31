class UsersController < ApplicationController
  before_action :verify_signed_in, only: [:edit, :update, :index, :destroy] #specify action to be run before "edit" and "update" methods
  before_action :verify_correct_user, only: [:edit, :update] 
  before_action :verify_admin, only: :destroy
  before_action :verify_non_user, only: [:new, :create]

  def index
    @users = User.paginate(page: params[:page], per_page: 10)
  end

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(user_params)
		if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
			redirect_to @user
		else
			render 'new'
		end
  end

  def edit
    # @user instantiated in :verify_correct_user
  end

  def update
    # @user instantiated in :verify_correct_user
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.admin?
      flash[:error] = "error"
      redirect_to root_path
    else
      @user.destroy
      flash[:success] = "User destroyed."
      redirect_to users_path
    end
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "User not found"
      redirect_to root_path
  end

  private
  	def user_params
  		params.require(:user).permit(:name,:email,:password,:password_confirmation)
  	end

    def verify_correct_user
      @user = User.find(params[:id])
      if !current_user?( @user )
        redirect_to root_path
      end
    end

    def verify_admin
      if !current_user.admin?
        flash[:error] = "You do not have access to this command."
        redirect_to root_path
      end
    end

    def verify_non_user
      redirect_to user_path(current_user) unless current_user.nil?
    end
end
