module ScooterRentalError
    class ScooterRentalError < StandardError; end
    class SRBackupError < ScooterRentalError; end
    class SRRecordNotFound < ScooterRentalError; end
    class SRRestoreError < ScooterRentalError; end
    class SRValidationError < ScooterRentalError; end
    class SRStorageError < ScooterRentalError; end
    class SRStorageSwitchError < SRStorageError; end
end 
