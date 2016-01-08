require "rails_helper"

RSpec.describe PostsController, type: :controller do

  describe "#index" do
    before do
      @all_posts = Post.all
      get :index
    end

    it "should assign @posts" do
      expect(assigns(:posts)).to eq(@all_posts)
    end

    it "should render the :index view" do
      expect(response).to render_template(:index)
    end
  end

  describe "#new" do
    context "logged in" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id

        get :new
      end

      it "should assign @post" do
        expect(assigns(:post)).to be_instance_of(Post)
      end

      it "should render the :new view" do
        expect(response).to render_template(:new)
      end
    end

    context "not logged in" do
      before do
        get :new
      end

      it "should redirect to 'login_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "#create" do
    context "logged in" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id
      end

      context "success" do
        before do
          @posts_count = @current_user.posts.count
          post :create, post: { title: FFaker::Lorem.words(5).join(" "), content: FFaker::Lorem.paragraph }
        end

        it "should add new post to current_user" do
          expect(@current_user.posts.count).to eq(@posts_count + 1)
        end

        it "should redirect_to 'post_path'" do
          expect(response.status).to be(302)
          expect(response.location).to match(/\/posts\/\d+/)
        end
      end

      context "failed validations" do
        before do
          # create blank post (fails validations)
          post :create, post: { title: nil, content: nil}
        end

        it "should display an error message" do
          expect(flash[:error]).to be_present
        end

        it "should redirect to 'new_post_path'" do
          expect(response.status).to be(302)
          expect(response).to redirect_to(new_post_path)
        end
      end
    end

    context "not logged in" do
      before do
        post :create, post: { title: FFaker::Lorem.words(5).join(" "), content: FFaker::Lorem.paragraph }
      end

      it "should redirect to 'login_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "#show" do
    before do
      @post = FactoryGirl.create(:post)
      get :show, id: @post.id
    end

    it "should assign @post" do
      expect(assigns(:post)).to eq(@post)
    end

    it "should render the :show view" do
      expect(response).to render_template(:show)
    end
  end

  describe "#edit" do
    context "logged in" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id

        @post = FactoryGirl.create(:post)
        @current_user.posts << @post
        get :edit, id: @post.id
      end

      it "should assign @post" do
        expect(assigns(:post)).to eq(@post)
      end

      it "should render the :edit view" do
        expect(response).to render_template(:edit)
      end
    end

    context "not logged in" do
      before do
        post = FactoryGirl.create(:post)
        get :edit, id: post.id
      end

      it "should redirect to 'login_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(login_path)
      end
    end

    context "trying to edit another user's post" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id
        
        another_user = FactoryGirl.create(:user)
        post = FactoryGirl.create(:post)
        another_user.posts << post
        get :edit, id: post.id
      end

      it "should redirect_to 'user_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(user_path(@current_user))
      end
    end
  end

  describe "#update" do
    context "logged in" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id

        @post = FactoryGirl.create(:post)
        @current_user.posts << @post
      end

      context "success" do
        before do
          @new_title = FFaker::Lorem.words(5).join(" ")
          @new_content = FFaker::Lorem.paragraph
          put :update, id: @post.id, post: { title: @new_title, content: @new_content }
          
          # reload @post to get changes from :update
          @post.reload
        end

        it "should update post in the database" do
          expect(@post.title).to eq(@new_title)
          expect(@post.content).to eq(@new_content)
        end

        it "should redirect_to 'post_path'" do
          expect(response.status).to be(302)
          expect(response).to redirect_to(post_path(@post))
        end
      end

      context "failed validations" do
        before do
          # update with blank post params (fails validations)
          put :update, id: @post.id, post: { title: nil, content: nil }
        end

        it "should display an error message" do
          expect(flash[:error]).to be_present
        end

        it "should redirect_to 'edit_post_path'" do
          expect(response).to redirect_to(edit_post_path(@post))
        end
      end
    end

    context "not logged in" do
      before do
        # create user, don't log them in
        user = FactoryGirl.create(:user)

        post = FactoryGirl.create(:post)
        user.posts << post
        
        new_title = FFaker::Lorem.words(5).join(" ")
        new_content = FFaker::Lorem.paragraph
        put :update, id: post.id, post: { title: new_title, content: new_content }
      end

      it "should redirect to 'login_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(login_path)
      end
    end

    context "trying to update another user's post" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id
        
        another_user = FactoryGirl.create(:user)
        post = FactoryGirl.create(:post)
        another_user.posts << post

        new_title = FFaker::Lorem.words(5).join(" ")
        new_content = FFaker::Lorem.paragraph
        put :update, id: post.id, post: { title: new_title, content: new_content }
      end

      it "should redirect_to 'user_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(user_path(@current_user))
      end
    end
  end

  describe "#destroy" do
    context "logged in" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id

        post = FactoryGirl.create(:post)
        @current_user.posts << post
        
        @posts_count = @current_user.posts.count
        delete :destroy, id: post.id
      end

      it "should remove current_user's post from the database" do
        expect(@current_user.posts.count).to eq(@posts_count - 1)
      end

      it "should redirect_to 'user_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(user_path(@current_user))
      end
    end

    context "not logged in" do
      before do
        # create user, don't log them in
        user = FactoryGirl.create(:user)

        post = FactoryGirl.create(:post)
        user.posts << post
        delete :destroy, id: post.id
      end

      it "should redirect to 'login_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(login_path)
      end
    end

    context "trying to destroy another user's post" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id

        another_user = FactoryGirl.create(:user)
        post = FactoryGirl.create(:post)
        another_user.posts << post

        delete :destroy, id: post.id
      end

      it "should redirect_to 'user_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(user_path(@current_user))
      end
    end
  end
end