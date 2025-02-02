# frozen_string_literal: true

class CalendarsController < ApplicationController
  load_and_authorize_resource

  # GET /calendars/1
  def show
    @academic_year = academic_year
    @current_events = list_current_events(@academic_year)
    if @calendar.schools.count == 1
      @school = @calendar.schools.first
    end
  end

  def destroy
    if @calendar.school? || @calendar.national?
      redirect_to admin_calendars_path, notice: 'Cannot delete national or school calendars' if @calendar.school?
    end
    if @calendar.regional? && @calendar.calendars.count > 0
      redirect_to admin_calendars_path, notice: 'Cannot delete regional calendar with children'
    else
      @calendar.destroy
      redirect_to admin_calendars_path, notice: 'Calendar was successfully deleted.'
    end
  end

  def resync
    @resync_service = CalendarResyncService.new(@calendar, 1.week.ago)
    @resync_service.resync
  end

  private

  def academic_year
    academic_year_ids = @calendar.calendar_events.pluck(:academic_year_id).uniq.sort_by(&:to_i).reject(&:nil?)
    AcademicYear.find(academic_year_ids).select(&:current?).first
  end

  def list_current_events(academic_year)
    return [] unless academic_year
    next_academic_year = academic_year.next_year
    academic_year_filter = next_academic_year.present? ? [academic_year, next_academic_year] : academic_year
    @calendar.calendar_events.where(academic_year: academic_year_filter).order(:start_date)
  end
end
