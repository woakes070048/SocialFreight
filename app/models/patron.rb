class Patron < ActiveRecord::Base

  #STATUS_NAMES = [:active, :inactive, :cancelled, :potential]
  #STATUSES = STATUS_NAMES.each_with_index.each_with_object({}) {|(name, code), all| all[name] = code }
  
  extend FriendlyId
  friendly_id :title, use: :slugged
  serialize  :operations
 
  mount_uploader :logo, LogoUploader

  has_many :counters
  accepts_nested_attributes_for :counters, :allow_destroy => true
  
  has_many :branches
  accepts_nested_attributes_for :branches, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true
  
  has_many :users
  accepts_nested_attributes_for :users, :reject_if => lambda { |a| a[:email].blank? }, :allow_destroy => true  
  
  #has_many :people
  #has_many :companies
  has_many :positions
  has_many :loadings
  #has_many :activities
  #has_many :journals, as: :journaled, dependent: :destroy
  #has_many :documents
  #has_many :costs
  #has_many :invoitems
  #has_many :payoffs
  #has_and_belongs_to_many :operations
  
  attr_accessible :name, :website, :tel, :fax, :postcode, :district, :address, :city_id, :country_id, :status, :saler_id, 
                  :email, :operations, :contact_name, :contact_surname, :time_zone, :language, :logo, :remove_logo,
                  :vehicle_owner, :depot_owner, :patron_type, :iata_code, :fmc_code, :locale, :mail_encoding, 
                  :counters_attributes, :users_attributes, :branches_attributes

  def self.current_id=(id)
    Thread.current[:patron_id] = id
  end

  def self.current_id
    Thread.current[:patron_id]
  end

  before_create :set_initials
  after_create  :create_head_office, :create_patron_user, :create_company #, :create_admin_user

  validates_presence_of :name#, :message => I18n.t('patrons.errors.title.cant_be_blank')
  validates_presence_of :email#, :message => I18n.t('patrons.errors.title.cant_be_blank')
  validates_presence_of :contact_name#, :message => I18n.t('patrons.errors.title.cant_be_blank')
  validates_presence_of :contact_surname#, :message => I18n.t('patrons.errors.title.cant_be_blank')
  validates_presence_of :tel#,   :message => I18n.t('patrons.errors.title.cant_be_blank')
  validates_presence_of :country_id
  validates_uniqueness_of :email, :case_sensitive => false

  validates_length_of   :title, maximum: 255#, :message => I18n.t('tasks.errors.name.too_long')
  validates_length_of   :tel, maximum: 20#, :message => I18n.t('tasks.errors.name.too_long')

  def self.generate_counter(ctype, operation, direction)
    patron = Patron.find(Patron.current_id)
    counter = patron.counters.find_or_initialize_by_operation_and_counter_type(operation, ctype)
    counter.increment(:count, 1)
    counter.save!
    return counter.get_reference
  end

  def set_activity(target, action, creator_id=nil, action_text, user_name)
    creator_id ||= target.user_id
    #return log_later(target, action, creator_id) if self.is_importing
    Activity.log(self, target, action, creator_id, action_text, user_name, self.token)
  end

  #def self.journal_record(patron_id, user, branch, team, journal_model, unit, amount)
  #  patron = Patron.find(Patron.current_id)
  #  Journal.log(patron, journal_model, patron.id, patron.token, unit, amount)

  #  Journal.log(user, journal_model, patron.id, patron.token, unit, amount) if user
  #  Journal.log(branch, journal_model, patron.id, patron.token, unit, amount) if branch
  #  Journal.log(team, journal_model, patron.id, patron.token, unit, amount) if team

  #end

  class << self
    def statuses()
      statuses = {
        'A' => 'Active',
        'C' => 'Closed',
        'I' => 'Cancelled'
      }
    end

    def employee_ranks()
      employee_ranks = {
        '0..3'   => '0-3Employees',
        '4..12'  => '4-12Employees',
        '13..60' => '13-60Employees',
        '61..99' => '61-99Employees',
        '100..+' => '100+Employees'
      }
    end

  end

  private
  def set_initials
    self.title = self.name
    self.token = SecureRandom.urlsafe_base64[0,40]
  end

  private
  def create_head_office
    Patron.current_id = self.id
    branch = self.branches.new
    branch.name = "Head Office"
    branch.tel = self.tel
    branch.fax = self.fax
    branch.country_id = self.country_id
    branch.patron_id = self.id
    branch.save!
  end

  #def create_admin_user
  #  branch = Branch.where(patron_id: self.id).first
  #  user = self.users.new
  #  user.name = "SocialFreight"
  #  user.surname = "Admin"
  #  user.email = "faruk@socialfreight.com"
  #  user.language = self.language
  #  user.locale   = self.locale
  #  user.mail_encoding = self.mail_encoding
  #  user.time_zone = self.time_zone
  #  user.branch_id  = branch.id
  #  user.password = SecureRandom.urlsafe_base64[0,10]
  #  user.password_confirmation = user.password
  #  user.save!
  #  user.add_role :super
  #end

  def create_patron_user
    branch = Branch.where(patron_id: self.id).first
    user = self.users.new
    user.name = self.contact_name
    user.surname = self.contact_surname
    user.email = self.email
    user.language = self.language
    user.locale   = self.locale
    user.mail_encoding = self.mail_encoding
    user.time_zone = self.time_zone
    user.branch_id  = branch.id
    user.password = SecureRandom.urlsafe_base64[0,10]
    user.password_confirmation = user.password
    user.save!
    user.add_role :admin
  end

  def create_company
    #counter = Counter.new
    #counter.counter_type = "Company"
    #counter.count = 1
    #counter.patron_id = self.id
    #counter.save!
    branch = Branch.where(patron_id: self.id).first
    user   = User.where(patron_id: self.id).last
    company = Company.new
    company.name = self.name
    company.tel = self.tel
    company.fax = self.fax
    company.country_id = self.country_id
    company.patron_id = self.id
    company.branch_id  = branch.id
    company.user_id = user.id
    #company.company_no = 1
    company.save!
  end

  #def create_counters
  #end

end
