class MercadoPago::MoneyRequestStatus
  def self.pending?(status)
    status == 'pending'
  end

  def self.failed?(status)
    %w(rejected cancelled).include? status
  end

  def self.accepted?(status)
    status == 'accepted'
  end
end