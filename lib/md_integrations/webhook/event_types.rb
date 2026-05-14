module MdIntegrations
  module Webhook
    module EventTypes
      # Case status transitions
      CASE_CREATED    = 'case_created'.freeze
      CASE_ASSIGNED   = 'case_assigned'.freeze
      CASE_WAITING    = 'case_waiting'.freeze
      CASE_APPROVED   = 'case_approved'.freeze
      CASE_PROCESSING = 'case_processing'.freeze
      CASE_COMPLETED  = 'case_completed'.freeze
      CASE_CANCELLED  = 'case_cancelled'.freeze
      CASE_SUPPORT    = 'case_support'.freeze

      # Offerings
      OFFERING_SUBMITTED = 'offering_submitted'.freeze

      # Orders
      ORDER_STATUS_CHANGED          = 'order_status_changed'.freeze
      ORDER_TRACKING_NUMBER_CHANGED = 'order_tracking_number_changed'.freeze

      # Patients
      PATIENT_CREATED  = 'patient_created'.freeze
      PATIENT_MODIFIED = 'patient_modified'.freeze
      PATIENT_DELETED  = 'patient_deleted'.freeze

      # Messages
      MESSAGE_CREATED = 'message_created'.freeze

      # Workflows
      INTRO_VIDEO_REQUESTED = 'intro_video_requested'.freeze

      ALL = [
        CASE_CREATED, CASE_ASSIGNED, CASE_WAITING, CASE_APPROVED,
        CASE_PROCESSING, CASE_COMPLETED, CASE_CANCELLED, CASE_SUPPORT,
        OFFERING_SUBMITTED,
        ORDER_STATUS_CHANGED, ORDER_TRACKING_NUMBER_CHANGED,
        PATIENT_CREATED, PATIENT_MODIFIED, PATIENT_DELETED,
        MESSAGE_CREATED,
        INTRO_VIDEO_REQUESTED
      ].freeze
    end
  end
end
