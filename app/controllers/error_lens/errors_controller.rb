module ErrorLens
  class ErrorsController < ApplicationController
    GROUPS_PER_PAGE      = 25
    OCCURRENCES_PER_PAGE = 10

    def index
      @groups = ErrorLens::ErrorGroup.recent

      @groups = @groups.filter_by(params[:q])         if params[:q].present?
      @groups = @groups.by_env(params[:environment]) if params[:environment].present?
      @groups = params[:resolved] == "true" ? @groups.resolved : @groups.unresolved

      @total       = @groups.count
      @page        = [params[:page].to_i, 1].max
      @total_pages = (@total / GROUPS_PER_PAGE.to_f).ceil
      @groups      = @groups.limit(GROUPS_PER_PAGE).offset((@page - 1) * GROUPS_PER_PAGE)
    end

    def show
      @group       = ErrorLens::ErrorGroup.find(params[:id])
      @total       = @group.occurrences.count
      @page        = [params[:page].to_i, 1].max
      @total_pages = (@total / OCCURRENCES_PER_PAGE.to_f).ceil
      @occurrences = @group.occurrences
                           .recent
                           .limit(OCCURRENCES_PER_PAGE)
                           .offset((@page - 1) * OCCURRENCES_PER_PAGE)
    end

    def resolve
      @group = ErrorLens::ErrorGroup.find(params[:id])
      @group.resolve!
      redirect_to errors_path, notice: "Error marked as resolved."
    end

    def unresolve
      @group = ErrorLens::ErrorGroup.find(params[:id])
      @group.unresolve!
      redirect_to error_path(@group), notice: "Error reopened."
    end

    def destroy
      @group = ErrorLens::ErrorGroup.find(params[:id])
      @group.destroy!
      redirect_to errors_path, notice: "Error deleted."
    end
  end
end
