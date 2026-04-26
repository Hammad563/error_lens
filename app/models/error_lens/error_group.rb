module ErrorLens
  class ErrorGroup < ActiveRecord::Base
    self.table_name = "error_lens_groups"

    has_many :occurrences,
             class_name:  "ErrorLens::ErrorOccurrence",
             foreign_key: :error_group_id,
             dependent:   :destroy

    scope :unresolved, -> { where(resolved_at: nil) }
    scope :resolved,   -> { where.not(resolved_at: nil) }
    scope :recent,     -> { order(last_seen_at: :desc) }
    scope :by_env,     ->(env) { where(environment: env) if env.present? }
    scope :filter_by,  ->(q) { where("error_class ILIKE ? OR message ILIKE ?", "%#{q}%", "%#{q}%") if q.present? }

    def resolved?
      resolved_at.present?
    end

    def resolve!
      update!(resolved_at: Time.current)
    end

    def unresolve!
      update!(resolved_at: nil)
    end

    def formatted_location
      return nil unless location.present?
      location.sub("#{Rails.root}/", "").split(":in").first
    end
  end
end
