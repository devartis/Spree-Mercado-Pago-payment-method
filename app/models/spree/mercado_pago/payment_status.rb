class Spree::MercadoPago::PaymentStatus
  def self.pending?(status)
    status == 'pending' or status == 'in_process' or status == 'in_mediation'
  end

  def self.failed?(status)
    status == 'rejected' or status == 'cancelled'
  end

  def self.approved?(status)
    status == 'approved'
  end
end