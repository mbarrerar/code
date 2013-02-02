FailedMigrationError = Class.new(SystemExit)

if Rails.env.production? || Rails.env.quality_assurance?
  migrations = Rails.root.join('db','migrate')
  if migrations.directory?
    ActiveRecord::Migrator.migrate(migrations)
  else
    raise FailedMigrationError
  end
end