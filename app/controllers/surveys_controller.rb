# -*- encoding : utf-8 -*-
class SurveysController < ApplicationController

  def index
  end

  def new
    render :layout=>false
  end


  def create
    answer = MSurveyAnswer.new(params[:answer])
    answer.save!
    redirect_to edit_survey_path(answer)
  end

  def show
  end

  def edit
    @answer = MSurveyAnswer.find(params[:id])
    render :layout=>false
  end

  def update
    @answer = MSurveyAnswer.find(params[:id])
    @answer.update_attributes(params[:answer])
    redirect_to edit_survey_path(@answer)
  end

end
