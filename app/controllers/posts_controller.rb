class PostsController < ApplicationController
  before_filter :set_post, except: [:index, :new, :create]
  before_filter :authorize, except: [:index, :show]

  def index
    @posts = Post.all
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      flash[:notice] = "Successfully created post."
      redirect_to post_path(@post)
    else
      flash[:error] = @post.errors.full_messages.join(", ")
      redirect_to new_post_path
    end
  end

  def show
  end

  def share
    if request.post?
      sms_body = "I think you would love this amazing blog post! Check it out here: #{request.protocol}#{request.host}#{post_path(@post)}."
      phone_numbers = share_params[:numbers].split(",")

      sms_service = SmsService.new
      sms_service.send_messages(phone_numbers, sms_body)

      if sms_service.success_numbers.any?
        flash[:notice] = "Text #{'message'.pluralize(sms_service.success_numbers.count)} sent to #{sms_service.success_numbers.join(", ")}."
      end
      if sms_service.error_numbers.any?
        flash[:error] = "Text #{'message'.pluralize(sms_service.error_numbers.count)} could not send to #{sms_service.error_numbers.join(", ")}."
      end

      redirect_to post_path(@post)
    end
  end

  def edit
    # don't let current_user see another user's post edit view
    unless current_user == @post.user
      redirect_to user_path(current_user)
    end
  end

  def update
    # only let current_user update their own posts
    if current_user == @post.user
      if @post.update_attributes(post_params)
        flash[:notice] = "Successfully updated post."
        redirect_to post_path(@post)
      else
        flash[:error] = @post.errors.full_messages.join(", ")
        redirect_to edit_post_path(@post)
      end
    else
      redirect_to user_path(current_user)
    end
  end

  def destroy
    # only let current_user delete their own posts
    if current_user == @post.user
      @post.destroy
      flash[:notice] = "Successfully deleted post."
    end
    redirect_to user_path(current_user)
  end

  private

    def post_params
      params.require(:post).permit(:title, :content)
    end

    def set_post
      post_id = params[:id]
      @post = Post.find_by_id(post_id)
    end

    def share_params
      params.require(:share).permit(:numbers)
    end

end