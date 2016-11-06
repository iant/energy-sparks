require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe ActivityTypesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # ActivityType. As you add validations to ActivityType, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { name: 'test name', description: 'test description', active: true }
  }

  let(:invalid_attributes) {
    { name: nil }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ActivityTypesController. Be sure to keep this updated too.
  let(:valid_session) { {} }
  context "As an admin user" do
    before(:each) do
      sign_in_user(:admin)
    end
    describe "GET #index" do
      it "assigns all activity_types as @activity_types" do
        activity_type = ActivityType.create! valid_attributes
        get :index, params: {}
        expect(assigns(:activity_types)).to eq([activity_type])
      end
    end

    describe "GET #show" do
      it "assigns the requested activity_type as @activity_type" do
        activity_type = ActivityType.create! valid_attributes
        get :show, params: {id: activity_type.to_param}
        expect(assigns(:activity_type)).to eq(activity_type)
      end
    end

    describe "GET #new" do
      it "assigns a new activity_type as @activity_type" do
        get :new, params: {}
        expect(assigns(:activity_type)).to be_a_new(ActivityType)
      end
    end

    describe "GET #edit" do
      it "assigns the requested activity_type as @activity_type" do
        activity_type = ActivityType.create! valid_attributes
        get :edit, params: {id: activity_type.to_param}
        expect(assigns(:activity_type)).to eq(activity_type)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new ActivityType" do
          expect {
            post :create, params: {activity_type: valid_attributes}
          }.to change(ActivityType, :count).by(1)
        end

        it "assigns a newly created activity_type as @activity_type" do
          post :create, params: {activity_type: valid_attributes}
          expect(assigns(:activity_type)).to be_a(ActivityType)
          expect(assigns(:activity_type)).to be_persisted
        end

        it "redirects to the created activity_type" do
          post :create, params: {activity_type: valid_attributes}
          expect(response).to redirect_to(ActivityType.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved activity_type as @activity_type" do
          post :create, params: {activity_type: invalid_attributes}
          expect(assigns(:activity_type)).to be_a_new(ActivityType)
        end

        it "re-renders the 'new' template" do
          post :create, params: {activity_type: invalid_attributes}
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) {
          { name: 'new name', description: 'new description', active: false}
        }

        it "updates the requested activity_type" do
          activity_type = ActivityType.create! valid_attributes
          put :update, params: {id: activity_type.to_param, activity_type: new_attributes}
          activity_type.reload
          expect(activity_type.name).to eq new_attributes[:name]
          expect(activity_type.description).to eq new_attributes[:description]
          expect(activity_type.active).to eq new_attributes[:active]
        end

        it "assigns the requested activity_type as @activity_type" do
          activity_type = ActivityType.create! valid_attributes
          put :update, params: {id: activity_type.to_param, activity_type: valid_attributes}
          expect(assigns(:activity_type)).to eq(activity_type)
        end

        it "redirects to the activity_type" do
          activity_type = ActivityType.create! valid_attributes
          put :update, params: {id: activity_type.to_param, activity_type: valid_attributes}
          expect(response).to redirect_to(activity_type)
        end
      end

      context "with invalid params" do
        it "assigns the activity_type as @activity_type" do
          activity_type = ActivityType.create! valid_attributes
          put :update, params: {id: activity_type.to_param, activity_type: invalid_attributes}
          expect(assigns(:activity_type)).to eq(activity_type)
        end

        it "re-renders the 'edit' template" do
          activity_type = ActivityType.create! valid_attributes
          put :update, params: {id: activity_type.to_param, activity_type: invalid_attributes}
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      it "does NOT destroy the requested activity_type" do
        activity_type = ActivityType.create! valid_attributes
        expect {
          delete :destroy, params: {id: activity_type.to_param}
        }.to change(ActivityType, :count).by(0)
      end

      it "redirects to the activity_types list" do
        activity_type = ActivityType.create! valid_attributes
        delete :destroy, params: {id: activity_type.to_param}
        expect(response).to redirect_to(activity_types_url)
      end
    end
  end
end
