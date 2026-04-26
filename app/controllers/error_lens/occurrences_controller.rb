module ErrorLens
  class OccurrencesController < ApplicationController
    def show
      @group      = ErrorLens::ErrorGroup.find(params[:error_id])
      @occurrence = @group.occurrences.find(params[:id])

      @newer = @group.occurrences
                     .where("occurred_at > ?", @occurrence.occurred_at)
                     .order(occurred_at: :asc)
                     .first

      @older = @group.occurrences
                     .where("occurred_at < ?", @occurrence.occurred_at)
                     .order(occurred_at: :desc)
                     .first
    end
  end
end
