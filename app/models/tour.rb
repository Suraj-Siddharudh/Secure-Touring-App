class Tour < ApplicationRecord
	belongs_to :user, optional: true 
	before_create :set_available_seats
	
	has_many :bookings
	has_many :bookmark
	mount_uploader :image, ImageUploader
	serialize :image, JSON
	validate :image_size_validation
	

	validates_presence_of :Name, :pickup, :status, :countries, :states, :Description
	validates_numericality_of :total_seats, greater_than: 0, less_than_or_equal_to: 100, presence: true #avail_seats
	validates_numericality_of  :Price, greater_than: 0, less_than_or_equal_to: 300000
	validates_length_of :Description, maximum: 200
	validates :start_date, presence: true
	validates :end_date, presence: true
	validates :booking_deadline, presence: true
	# validate :valid_start_date?
	validate :valid_end_date?
	validate :valid_booking_deadline?

	# def valid_start_date?
	# 	errors.add(:start_date, "must be a Date") unless start_date.instance_of? Date
	# 	errors.add(:end_date, "must be a Date") unless end_date.instance_of? Date
	# 	errors.add(:booking_deadline, "must be a Date") unless booking_deadline.instance_of? Date
	# end

  def valid_end_date?
	  errors.add(:start_date, "must be before end_date") unless start_date < end_date
	end

	def valid_booking_deadline?
		if status.eql? "Active"
			errors.add(:booking_deadline, "must be between today and Start Date") unless booking_deadline > Date.today
			errors.add(:booking_deadline, "must be between today and Start Date") unless booking_deadline < start_date
		end
	end

# Image validation in image_uloader.rb
	def image_size_validation
		errors[:image] << "should be less than 5MB" if image.size > 5.megabytes
	end

	private

	def set_available_seats
	  self.avail_seats = self.total_seats
	end
end
