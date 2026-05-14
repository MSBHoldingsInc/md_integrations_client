module MdIntegrations
  class Client
    attr_reader :configuration, :connection

    def initialize(client_id:, client_secret:, environment: :sandbox, base_url: nil, logger: nil, timeout: 30, open_timeout: 10)
      @configuration = Configuration.new(
        client_id:     client_id,
        client_secret: client_secret,
        environment:   environment,
        base_url:      base_url,
        logger:        logger,
        timeout:       timeout,
        open_timeout:  open_timeout
      )
      @token_manager = Auth::TokenManager.new(@configuration)
      @connection    = Connection.new(@configuration, @token_manager)
    end

    # === Core integration resources ===
    def patients;           @patients           ||= Resources::Patients.new(connection);          end
    def cases;              @cases              ||= Resources::Cases.new(connection);             end
    def offerings;          @offerings          ||= Resources::Offerings.new(connection);         end
    def orders;             @orders             ||= Resources::Orders.new(connection);            end
    def messages;           @messages           ||= Resources::Messages.new(connection);          end
    def files;              @files              ||= Resources::Files.new(connection);             end

    # === Reference / catalog ===
    def diseases;           @diseases           ||= Resources::Diseases.new(connection);          end
    def pharmacies;         @pharmacies         ||= Resources::Pharmacies.new(connection);        end
    def dispense_units;     @dispense_units     ||= Resources::DispenseUnits.new(connection);     end
    def questionnaires;     @questionnaires     ||= Resources::Questionnaires.new(connection);    end
    def specialties;        @specialties        ||= Resources::Specialties.new(connection);       end
    def metadata;           @metadata           ||= Resources::Metadata.new(connection);          end

    # === People ===
    def clinicians;             @clinicians             ||= Resources::Clinicians.new(connection);             end
    def support_staffs;         @support_staffs         ||= Resources::SupportStaffs.new(connection);          end
    def internal_support_staffs; @internal_support_staffs ||= Resources::InternalSupportStaffs.new(connection); end
    def medical_assistants;     @medical_assistants     ||= Resources::MedicalAssistants.new(connection);      end
    def partner;                @partner                ||= Resources::Partner.new(connection);                end

    # === Other ===
    def vouchers;           @vouchers           ||= Resources::Vouchers.new(connection);          end
    def subscriptions;      @subscriptions      ||= Resources::Subscriptions.new(connection);     end
    def tags;               @tags               ||= Resources::Tags.new(connection);              end
    def notifications;      @notifications      ||= Resources::Notifications.new(connection);     end
  end
end
