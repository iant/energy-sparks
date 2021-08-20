module Schools
  class SchoolTargetsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :school_target, via: :school

    include SchoolAggregation
    include SchoolProgress
    include ActivityTypeFilterable

    before_action :check_aggregated_school_in_cache, only: :show
    before_action :calculate_current_progress, only: :show

    def index
      if @school.has_current_target?
        redirect_to school_school_target_path(@school, @school.current_target)
      else
        redirect_to new_school_school_target_path(@school)
      end
    end

    def show
      setup_activity_suggestions
    end

    #create first or new target if current has expired
    def new
      if @school.has_current_target?
        redirect_to school_school_target_path(@school, @school.current_target)
      elsif @school.has_target?
        @previous_school_target = @school.most_recent_target
        @school_target = Targets::SchoolTargetService.new(@school).build_target
        render :new
      else
        @school_target = Targets::SchoolTargetService.new(@school).build_target
        render :first
      end
    end

    def create
      if @school_target.save
        redirect_to school_school_target_path(@school, @school_target), notice: 'Target successfully created'
      elsif @school.has_target?
        render :new
      else
        render :first
      end
    end

    def edit
    end

    def update
      if @school_target.update(school_target_params)
        redirect_to school_school_target_path(@school, @school_target), notice: 'Target successfully updated'
      else
        render :edit
      end
    end

    private

    def school_target_params
      params.require(:school_target).permit(:electricity, :gas, :storage_heaters, :start_date, :target_date, :school_id)
    end

    def setup_activity_suggestions
      @activities_count = @school.activities.count
      suggester = NextActivitySuggesterWithFilter.new(@school, activity_type_filter)
      @activities_from_programmes = suggester.suggest_from_programmes.limit(4)
      @activities_from_alerts = suggester.suggest_from_find_out_mores.sample(1)
    end
  end
end
