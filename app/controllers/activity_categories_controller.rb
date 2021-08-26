class ActivityCategoriesController < ApplicationController
  load_and_authorize_resource

  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @activity_categories = @activity_categories.featured.by_name
    @activity_categories = @activity_categories.select { |activity_category| activity_category.activity_types.count > 4 }
  end
end
