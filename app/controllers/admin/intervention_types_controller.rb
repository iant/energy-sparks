module Admin
  class InterventionTypesController < AdminController
    load_and_authorize_resource

    def index
      @intervention_types = @intervention_types.includes(:intervention_type_group).order("intervention_types.title", :title)
    end

    def show
      #      @recorded = Intervention.where(activity_type: @activity_type).count
      #      @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
    end

    def new
      add_intervention_type_suggestions
    end

    def edit
      number_of_suggestions_so_far = @intervention_type.intervention_type_suggestions.count
      if number_of_suggestions_so_far > 8
        @intervention_type.intervention_type_suggestions.build
      else
        # Top up to 8
        add_intervention_type_suggestions(number_of_suggestions_so_far)
      end
    end

    def create
      if @intervention_type.save
        redirect_to admin_intervention_types_path, notice: 'Intervention type was successfully created.'
      else
        add_intervention_type_suggestions
        render :new
      end
    end

    def update
      if @intervention_type.update(intervention_type_params)
        redirect_to admin_intervention_types_path, notice: 'Intervention type was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      # Intervention types should be marked inactive rather than deleted
      # this method does NOT delete the Intervention type
      redirect_to admin_intervention_types_path, notice: 'Intervention type not deleted, please mark as inactive'
    end

  private

    def add_intervention_type_suggestions(number_of_suggestions_so_far = 0)
      (0..(7 - number_of_suggestions_so_far)).each { @intervention_type.intervention_type_suggestions.build }
    end

    def intervention_type_params
      params.require(:intervention_type).permit(:title,
          :summary,
          :description,
          :download_links,
          :image,
          :active,
          :intervention_type_group_id,
          :points,
          :other,
          intervention_type_suggestions_attributes: suggestions_params
      )
    end

    def suggestions_params
      [:id, :suggested_type_id, :_destroy]
    end
  end
end
