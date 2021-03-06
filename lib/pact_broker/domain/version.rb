require 'pact_broker/db'
require 'pact_broker/domain/order_versions'
require 'pact_broker/repositories/helpers'

module PactBroker
  module Domain
    class Version < Sequel::Model
      set_primary_key :id
      one_to_many :pact_publications, order: :revision_number, class: "PactBroker::Pacts::PactPublication", key: :consumer_version_id
      associate(:many_to_one, :pacticipant, :class => "PactBroker::Domain::Pacticipant", :key => :pacticipant_id, :primary_key => :id)
      one_to_many :tags, :reciprocal => :version, order: :created_at

      dataset_module do
        include PactBroker::Repositories::Helpers

        def delete
          PactBroker::Domain::Tag.where(version: self).delete
          super
        end
      end

      def after_create
        OrderVersions.(self)
      end

      def before_destroy
        PactBroker::Domain::Tag.where(version: self).destroy
        super
      end

      def to_s
        "Version: number=#{number}, pacticipant=#{pacticipant_id}"
      end

      def version_and_updated_date
        "Version #{number} - #{updated_at.to_time.localtime.strftime("%d/%m/%Y")}"
      end

      # What about provider??? This makes no sense
      def latest_pact_publication
        pact_publications.last
      end
    end

    Version.plugin :timestamps, :update_on_create=>true
  end
end

# Table: versions
# Columns:
#  id             | integer                     | PRIMARY KEY DEFAULT nextval('versions_id_seq'::regclass)
#  number         | text                        |
#  repository_ref | text                        |
#  pacticipant_id | integer                     | NOT NULL
#  order          | integer                     |
#  created_at     | timestamp without time zone | NOT NULL
#  updated_at     | timestamp without time zone | NOT NULL
# Indexes:
#  versions_pkey                        | PRIMARY KEY btree (id)
#  uq_ver_ppt_ord                       | UNIQUE btree (pacticipant_id, "order")
#  versions_pacticipant_id_number_index | UNIQUE btree (pacticipant_id, number)
#  ndx_ver_num                          | btree (number)
#  ndx_ver_ord                          | btree ("order")
# Foreign key constraints:
#  versions_pacticipant_id_fkey | (pacticipant_id) REFERENCES pacticipants(id)
# Referenced By:
#  tags                                                         | tags_version_id_fkey                                            | (version_id) REFERENCES versions(id)
#  pact_publications                                            | pact_publications_consumer_version_id_fkey                      | (consumer_version_id) REFERENCES versions(id)
#  verifications                                                | fk_verifications_versions                                       | (provider_version_id) REFERENCES versions(id)
#  latest_pact_publication_ids_for_consumer_versions            | latest_pact_publication_ids_for_consum_consumer_version_id_fkey | (consumer_version_id) REFERENCES versions(id) ON DELETE CASCADE
#  latest_verification_id_for_pact_version_and_provider_version | latest_v_id_for_pv_and_pv_provider_version_id_fk                | (provider_version_id) REFERENCES versions(id) ON DELETE CASCADE
