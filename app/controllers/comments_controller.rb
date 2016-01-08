class CommentsController < ApplicationController
  before_filter :set_post
  before_filter :set_comment, except: [:new, :create]
  before_filter :authorize

  def new
    @comment = Comment.new
  end

  def create
    @comment = current_user.comments.new(comment_params)
    @post.comments << @comment
    if @comment.save
      flash[:notice] = "Successfully added comment."
      redirect_to post_path(@post)
    else
      flash[:error] = @comment.errors.full_messages.join(", ")
      redirect_to new_post_comment(@post)
    end
  end

  def edit
    # don't let current_user see another user's comment edit view
    unless current_user == @comment.user
      redirect_to user_path(current_user)
    end
  end

  def update
    # only let current_user update their own comments
    if current_user == @comment.user
      if @comment.update_attributes(comment_params)
        flash[:notice] = "Successfully updated comment."
        redirect_to post_path(@post)
      else
        flash[:error] = @comment.errors.full_messages.join(", ")
        redirect_to edit_post_comment_path(@post, @comment)
      end
    else
      redirect_to user_path(current_user)
    end
  end

  def destroy
    # only let current_user delete their own comments
    if current_user == @comment.user
      @comment.destroy
      flash[:notice] = "Successfully deleted comment."
      redirect_to post_path(@post)
    else
      redirect_to user_path(current_user)
    end
  end

  private

    def comment_params
      params.require(:comment).permit(:content)
    end

    def set_post
      post_id = params[:post_id]
      @post = Post.find_by_id(post_id)
    end

    def set_comment
      comment_id = params[:id]
      @comment = Comment.find_by_id(comment_id)
    end

end