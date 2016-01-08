require "rails_helper"

RSpec.describe UsersController, type: :controller do

  describe "#index" do
    before do
      @all_users = User.all
      get :index
    end

    it "should assign @users" do
      expect(assigns(:users)).to eq(@all_users)
    end

    it "should render the :index view" do
      expect(response).to render_template(:index)
    end
  end

  describe "#new" do
    context "not logged in" do
      before do
        get :new
      end

      it "should assign @user" do
        expect(assigns(:user)).to be_instance_of(User)
      end

      it "should render the :new view" do
        expect(response).to render_template(:new)
      end
    end

    context "logged in" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id

        get :new
      end

      it "should redirect to 'user_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(user_path(@current_user))
      end
    end
  end

  describe "#create" do
    context "success" do
      before do
        @users_count = User.count
        post :create, user: { email: FFaker::Internet.email, password: FFaker::Lorem.words(5).join }
      end

      it "should add new user to the database" do
        expect(User.count).to eq(@users_count + 1)
      end

      it "should redirect_to 'user_path'" do
        expect(response.status).to be(302)
        expect(response.location).to match(/\/users\/\d+/)
      end
    end

    context "failed validations" do
      before do
        # create blank user (fails validations)
        post :create, user: { email: nil, password: nil}
      end

      it "should display an error message" do
        expect(flash[:error]).to be_present
      end

      it "should redirect to 'signup_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(signup_path)
      end
    end

    context "logged in" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id

        post :create, user: { email: FFaker::Internet.email, password: FFaker::Lorem.words(5).join }
      end

      it "should redirect to 'user_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(user_path(@current_user))
      end
    end
  end

  describe "#show" do
    before do
      # create and log in current_user
      @current_user = FactoryGirl.create(:user)
      session[:user_id] = @current_user.id
      
      get :show, id: @current_user.id
    end

    it "should assign @user" do
      expect(assigns(:user)).to eq(@current_user)
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

        get :edit, id: @current_user.id
      end

      it "should assign @user" do
        expect(assigns(:user)).to eq(@current_user)
      end

      it "should render the :edit view" do
        expect(response).to render_template(:edit)
      end
    end

    context "not logged in" do
      before do
        # create user, don't log them in
        user = FactoryGirl.create(:user)
        
        get :edit, id: user.id
      end

      it "should redirect to 'login_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(login_path)
      end
    end

    context "trying to edit another user" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id
        
        another_user = FactoryGirl.create(:user)
        get :edit, id: another_user.id
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
      end

      context "success" do
        before do
          @new_email = FFaker::Internet.email
          put :update, id: @current_user.id, user: { email: @new_email }
          
          # reload @current_user to get changes from :update
          @current_user.reload
        end

        it "should update current_user in the database" do
          expect(@current_user.email).to eq(@new_email)
        end

        it "should redirect_to 'user_path'" do
          expect(response.status).to be(302)
          expect(response).to redirect_to(user_path(@current_user))
        end
      end

      context "failed validations" do
        before do
          # update with blank user params (fails validations)
          put :update, id: @current_user.id, user: { email: nil }
        end

        it "should display an error message" do
          expect(flash[:error]).to be_present
        end

        it "should redirect_to 'edit_user_path'" do
          expect(response).to redirect_to(edit_user_path(@current_user))
        end
      end
    end

    context "not logged in" do
      before do
        # create user, don't log them in
        user = FactoryGirl.create(:user)
        
        new_email = FFaker::Internet.email
        put :update, id: user.id, user: { email: new_email }
      end

      it "should redirect to 'login_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(login_path)
      end
    end

    context "trying to update another user" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id
        
        another_user = FactoryGirl.create(:user)
        new_email = FFaker::Internet.email
        put :update, id: another_user.id, user: { email: new_email }
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
        current_user = FactoryGirl.create(:user)
        session[:user_id] = current_user.id
        
        @users_count = User.count
        delete :destroy, id: current_user.id
      end

      it "should remove current_user from the database" do
        expect(User.count).to eq(@users_count - 1)
      end

      it "should redirect_to 'root_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(root_path)
      end
    end

    context "not logged in" do
      before do
        # create user, don't log them in
        user = FactoryGirl.create(:user)
        
        delete :destroy, id: user.id
      end

      it "should redirect to 'login_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(login_path)
      end
    end

    context "trying to destroy another user" do
      before do
        # create and log in current_user
        @current_user = FactoryGirl.create(:user)
        session[:user_id] = @current_user.id
        
        another_user = FactoryGirl.create(:user)
        delete :destroy, id: another_user.id
      end

      it "should redirect_to 'user_path'" do
        expect(response.status).to be(302)
        expect(response).to redirect_to(user_path(@current_user))
      end
    end
  end

end