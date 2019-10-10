# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Parsers::Security::Sast do
  describe '#parse!' do
    subject(:parser) { described_class.new }

    let(:commit_sha) { Digest::SHA1.hexdigest(SecureRandom.uuid) }

    context "when parsing valid reports" do
      where(report_format: %i(sast sast_deprecated))

      with_them do
        let(:report) { Gitlab::Ci::Reports::Security::Report.new(artifact.file_type, commit_sha) }
        let(:artifact) { create(:ee_ci_job_artifact, report_format) }

        before do
          artifact.each_blob do |blob|
            parser.parse!(blob, report)
          end
        end

        it "parses all identifiers and occurrences" do
          expect(report.occurrences.length).to eq(33)
          expect(report.identifiers.length).to eq(17)
          expect(report.scanners.length).to eq(3)
        end

        it 'generates expected location' do
          location = report.occurrences.first.location

          expect(location).to be_a(::Gitlab::Ci::Reports::Security::Locations::Sast)
          expect(location).to have_attributes(
            file_path: 'python/hardcoded/hardcoded-tmp.py',
            start_line: 1,
            end_line: 1,
            class_name: nil,
            method_name: nil
          )
        end

        it "generates expected metadata_version" do
          expect(report.occurrences.first.metadata_version).to eq('1.2')
        end
      end
    end

    context "when parsing an empty report" do
      let(:report) { Gitlab::Ci::Reports::Security::Report.new('sast', commit_sha) }
      let(:blob) { JSON.generate({}) }

      it { expect(parser.parse!(blob, report)).to be_empty }
    end
  end
end
