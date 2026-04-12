# frozen_string_literal: true

# spec/lib/commands/restore_db_spec.rb
require 'rails_helper'
require 'commands/restore_db'

RSpec.describe RestoreDb do
  let(:target) { 'primary' }
  let(:mock_options) { { 'target' => target, 'latest_backup' => false } }
  let(:instance) { described_class.new([], mock_options, {}) }

  before do
    allow(instance).to receive(:say_info)
    allow(instance).to receive(:say_warning)
    allow(instance).to receive(:say_highlight)
    allow(instance).to receive(:run)
    allow(instance).to receive(:verbose?).and_return(false)
    allow(instance).to receive(:pretend?).and_return(false)
    allow(instance).to receive(:prompt_for_data_source_file).and_return('1')
    allow(instance).to receive(:downloads_path).and_return('/tmp/downloads')
    allow(instance).to receive(:backup_path).and_return('/tmp/backups')
    
    allow(Rails.application).to receive(:config_for).with(:database).and_return({
      primary: {
        username: 'user', port: 5432, host: 'localhost', password: '', database: "sails_#{Rails.env}"
      }
    }.with_indifferent_access)
  end

  describe '#check_for_available_backups' do
    it 'lists available backups' do
      expect(instance).to receive(:list_available_backups)
      instance.check_for_available_backups
    end
  end

  describe '#select_backup_file_from_prioritized_list' do
    it 'selects a backup file' do
      expect(instance).to receive(:selected_data_source_file).and_return('primary_20240601.dump')
      instance.select_backup_file_from_prioritized_list
      expect(instance.data_source_file).to eq('primary_20240601.dump')
    end
  end

  describe '#copy_backup_file_to_mounted_volume' do
    it 'copies the backup file' do
      instance.instance_variable_set(:@data_source_file, 'primary_20240601.dump')
      expect(FileUtils).to receive(:cp)
      instance.copy_backup_file_to_mounted_volume
      expect(instance.restore_file).to eq('primary_restore.dump')
    end
  end

  describe '#restore_database_from_backup' do
    it 'runs pg_restore command' do
      instance.instance_variable_set(:@restore_file, 'primary_restore.dump')
      expect(instance).to receive(:run).with(
        'pg_restore', '--jobs', '8', '--clean',
        "--username='user'", "--host='localhost'", "--port='5432'", "--dbname='sails_#{Rails.env}'",
        '--no-password',
        '/tmp/downloads/primary_restore.dump'
      )
      instance.restore_database_from_backup
    end
  end

  describe '#restore_database' do
    it 'returns correct db name for primary' do
      expect(instance.send(:restore_database)).to eq("sails_#{Rails.env}")
    end

    context 'with crm target' do
      let(:target) { 'crm' }
      it 'returns correct db name for crm' do
        expect(instance.send(:restore_database)).to eq("twenty_crm_#{Rails.env}")
      end
    end
  end

  describe '#prioritized_recent_backup_files', :time_sensitive do
    subject(:result) { instance.send(:prioritized_recent_backup_files) }

    let(:now) { Time.zone.local(2025, 1, 3, 4, 1, 0) }
    let(:target) { 'crm' }
    let(:format) { '%Y%m%d.%H%M%S%z' }
    let(:mock_backup_files) do
      # Fixed times relative to 'now'
      [
        "crm_(20250103.035600-0500).dump",
        "crm_(20250103.035100-0500).dump",
        "crm_(20250103.034600-0500).dump",
        "crm_(20250103.034100-0500).dump",
        "crm_(20250103.033600-0500).dump"
      ].shuffle
    end
    let(:expected_result) do
      %w[
        crm_(20250103.035600-0500).dump
        crm_(20250103.035100-0500).dump
        crm_(20250103.034600-0500).dump
      ]
    end

    before do
      allow(instance).to receive(:available_backup_files) { mock_backup_files }
    end

    around do |example|
      travel_to(now) { example.run }
    end

    it 'returns prioritized list of backup files' do
      is_expected.to eq(expected_result)
    end
  end
end
